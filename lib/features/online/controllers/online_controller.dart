import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:loverscat/features/profile/domain/models/friend_request.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import 'package:loverscat/features/quiz/domain/models/question.dart';
import '../data/online_api_client.dart';
import '../data/online_socket_client.dart';
import '../models/online_state.dart';
import 'online_message_processor.dart';

export '../models/online_state.dart';

class OnlineController extends StateNotifier<OnlineState> {
  static const _profileKey = 'loverscat_user_profile_v2';

  static String get defaultLocalUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return 'http://$host:4000';
      }
    }
    return 'http://127.0.0.1:4000';
  }

  final Ref _ref;
  final OnlineSocketClient _socketClient = OnlineSocketClient();
  Timer? _reconnectTimer;
  Timer? _syncTimer;
  bool _disposed = false;

  OnlineApiClient get _apiClient => OnlineApiClient(state.serverUrl);

  OnlineController(this._ref)
      : super(OnlineState(
          user: UserProfile.defaultProfile(),
          serverUrl: defaultLocalUrl,
          isLoggedIn: false,
        )) {
    _init();
  }

  bool get _isInTest {
    final bindingStr = WidgetsBinding.instance.runtimeType.toString();
    return bindingStr.contains('Test') || bindingStr.contains('Automated');
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProfileStr = prefs.getString(_profileKey);

      if (savedProfileStr != null) {
        final userProfile = UserProfile.fromJson(savedProfileStr);
        state = state.copyWith(user: userProfile, partner: userProfile.partnerProfile, isLoggedIn: true);
        _syncCouplePlayersWithOnlineProfiles();
        if (!_isInTest) {
          connect();
          _startSyncTimer();
        }
      } else {
        state = state.copyWith(isLoggedIn: false);
      }
    } catch (e) {
      debugPrint('[OnlineController] Init error: $e');
    }
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    if (_isInTest || !state.isLoggedIn) return;
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (state.isLoggedIn && !_disposed) fetchRequests();
    });
  }

  void _syncCouplePlayersWithOnlineProfiles() {
    final myAvatar = PetAvatar(type: state.user.petType, name: state.user.username);
    final partnerAvatar = state.partner != null
        ? PetAvatar(type: state.partner!.petType, name: state.partner!.username)
        : const PetAvatar(type: PetType.rabbit, name: 'Bekleniyor...');

    _ref.read(couplePlayersProvider.notifier).setPlayers(
          CouplePlayers(player1: myAvatar, player2: partnerAvatar),
        );
  }

  String get _wsUrl {
    final uri = Uri.parse(state.serverUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final portString = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$portString';
  }

  // --- Authentication ---

  Future<bool> register({
    required String username,
    required String password,
    PetType petType = PetType.cat,
    String petName = 'Mırmır',
  }) async {
    state = state.copyWith(isConnecting: true, clearError: true);
    final result = await _apiClient.register(
      username: username,
      password: password,
      petType: petType,
      petName: petName,
    );

    if (result.success && result.data != null) {
      final profile = result.data!;
      await _saveProfile(profile);
      state = state.copyWith(
        user: profile,
        isLoggedIn: true,
        isConnecting: false,
        statusMessage: 'Kayıt başarılı! Hoş geldin @${profile.username} ✨',
      );
      _syncCouplePlayersWithOnlineProfiles();
      if (!_isInTest) {
        connect();
        _startSyncTimer();
      }
      return true;
    }
    state = state.copyWith(isConnecting: false, lastError: result.error ?? 'Kayıt işlemi başarısız oldu.');
    return false;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isConnecting: true, clearError: true);
    final result = await _apiClient.login(username: username, password: password);

    if (result.success && result.data != null) {
      final profile = result.data!;
      await _saveProfile(profile);
      state = state.copyWith(
        user: profile,
        isLoggedIn: true,
        isConnecting: false,
        statusMessage: 'Giriş başarılı! Hoş geldin @${profile.username} 🐾',
      );
      _syncCouplePlayersWithOnlineProfiles();
      if (!_isInTest) {
        connect();
        _startSyncTimer();
      }
      return true;
    }
    state = state.copyWith(isConnecting: false, lastError: result.error ?? 'Kullanıcı adı veya şifre hatalı.');
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    _syncTimer?.cancel();
    _reconnectTimer?.cancel();
    _socketClient.dispose();

    state = OnlineState(
      user: UserProfile.defaultProfile(),
      serverUrl: defaultLocalUrl,
      isLoggedIn: false,
      isConnected: false,
    );
    _syncCouplePlayersWithOnlineProfiles();
  }

  // --- WebSocket Connection & Realtime Sync ---

  Future<void> connect() async {
    if (_disposed || _isInTest || !state.isLoggedIn) return;
    state = state.copyWith(isConnecting: true, clearError: true);

    await _socketClient.connect(
      wsUrl: _wsUrl,
      onMessage: (msg) {
        state = OnlineMessageProcessor.process(
          raw: msg,
          currentState: state,
          onSaveProfile: _saveProfile,
          onSyncPlayers: _syncCouplePlayersWithOnlineProfiles,
        );
      },
      onConnected: () {
        state = state.copyWith(isConnected: true, isConnecting: false);
        _send('auth', {'username': state.user.username});
      },
      onDisconnected: () {
        state = state.copyWith(isConnected: false, isConnecting: false);
        _scheduleReconnect();
      },
      onError: (err) {
        state = state.copyWith(
          isConnected: false,
          isConnecting: false,
          lastError: 'Sunucu bağlantısı koptu. Yeniden bağlanılıyor...',
        );
        _scheduleReconnect();
      },
    );

    fetchRequests();
  }

  void _scheduleReconnect() {
    if (_disposed || !state.isLoggedIn) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!state.isConnected && state.isLoggedIn) connect();
    });
  }

  void _send(String type, Map<String, dynamic> payload) {
    if (state.isConnected) _socketClient.send(type, payload);
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, profile.toJson());
    } catch (_) {}
  }

  // --- User Profile Actions ---

  Future<void> updateUsername(String newUsername) async {
    final sanitized = newUsername.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    if (sanitized.length < 3) {
      state = state.copyWith(lastError: 'Kullanıcı adı en az 3 karakter olmalıdır.');
      return;
    }
    _send('update_profile', {
      'newUsername': sanitized,
      'petType': state.user.petType.name,
      'petName': state.user.petName,
    });
  }

  Future<void> updatePet(PetType petType, [String? petName]) async {
    _send('update_profile', {
      'petType': petType.name,
      'petName': petName ?? state.user.petName,
    });
  }

  Future<void> updateProfile({
    String? newUsername,
    PetType? petType,
    String? petName,
  }) async {
    final cleanUname = (newUsername != null && newUsername.trim().isNotEmpty)
        ? newUsername.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '')
        : null;

    _send('update_profile', {
      if (cleanUname != null) 'newUsername': cleanUname,
      if (petType != null) 'petType': petType.name,
      if (petName != null) 'petName': petName,
    });
  }

  Future<bool> uploadCustomAvatar(String? base64String) async {
    state = state.copyWith(clearError: true);
    final result = await _apiClient.uploadCustomAvatar(
      username: state.user.username,
      base64String: base64String,
    );

    if (result.success && result.data != null) {
      final updatedUser = result.data!;
      state = state.copyWith(
        user: updatedUser,
        statusMessage: (base64String != null && base64String.isNotEmpty)
            ? 'Profil fotoğrafın güncellendi! 📸'
            : 'Fotoğraf kaldırıldı, karakterine dönüldü! 🐾',
      );
      await _saveProfile(updatedUser);
      _syncCouplePlayersWithOnlineProfiles();
      return true;
    }
    state = state.copyWith(lastError: result.error ?? 'Fotoğraf güncellenemedi.');
    return false;
  }

  Future<bool> removeCustomAvatar() => uploadCustomAvatar(null);

  Future<void> fetchRequests() async {
    if (!state.isLoggedIn || state.user.username.isEmpty) return;
    final requests = await _apiClient.fetchFriendRequests(state.user.username);
    if (requests != null) {
      state = state.copyWith(
        incomingRequests: requests.incoming,
        sentRequests: requests.sent,
      );
    }
  }

  Future<bool> sendFriendRequest(String toUsername) async {
    final clean = toUsername.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
    if (clean.isEmpty) {
      state = state.copyWith(lastError: 'Lütfen geçerli bir kullanıcı adı girin.');
      return false;
    }
    if (clean == state.user.username.toLowerCase()) {
      state = state.copyWith(lastError: 'Kendinize arkadaşlık isteği gönderemezsiniz!');
      return false;
    }

    final result = await _apiClient.sendFriendRequest(
      fromUsername: state.user.username,
      toUsername: clean,
    );

    if (result.success && result.data != null) {
      final req = result.data!;
      final updatedList = List<FriendRequest>.from(state.sentRequests)
        ..removeWhere((r) => r.id == req.id)
        ..insert(0, req);
      state = state.copyWith(
        sentRequests: updatedList,
        statusMessage: '@$clean kullanıcısına arkadaşlık isteği gönderildi! 🚀',
        clearError: true,
      );
      _send('send_friend_request', {'fromUsername': state.user.username, 'toUsername': clean});
      return true;
    }
    _send('send_friend_request', {'fromUsername': state.user.username, 'toUsername': clean});
    state = state.copyWith(statusMessage: '@$clean kullanıcısına istek iletiliyor...');
    return true;
  }

  Future<bool> respondFriendRequest(String requestId, bool accept) async {
    final result = await _apiClient.respondFriendRequest(
      requestId: requestId,
      username: state.user.username,
      accept: accept,
    );

    if (result.success) {
      if (accept && result.data != null) {
        final partner = result.data!;
        final updatedUser = state.user.copyWith(partnerUsername: partner.username);
        final updatedIncoming = List<FriendRequest>.from(state.incomingRequests)
          ..removeWhere((r) => r.id == requestId || r.fromUsername.toLowerCase() == partner.username.toLowerCase());

        state = state.copyWith(
          user: updatedUser,
          partner: partner,
          incomingRequests: updatedIncoming,
          statusMessage: '@${partner.username} ile eşleştiniz! Birlikte oynayın 💕🎉',
        );
        _saveProfile(updatedUser);
        _syncCouplePlayersWithOnlineProfiles();
      } else {
        final updatedIncoming = List<FriendRequest>.from(state.incomingRequests)
          ..removeWhere((r) => r.id == requestId);
        state = state.copyWith(incomingRequests: updatedIncoming, statusMessage: 'İstek reddedildi.');
      }

      _send('respond_friend_request', {
        'requestId': requestId,
        'username': state.user.username,
        'accept': accept,
      });
      return true;
    }
    _send('respond_friend_request', {
      'requestId': requestId,
      'username': state.user.username,
      'accept': accept,
    });
    return true;
  }

  Future<void> unpair() async {
    await _apiClient.unpair(state.user.username);
    _send('unpair_partner', {'username': state.user.username});

    final updatedUser = state.user.copyWith(clearPartner: true);
    state = state.copyWith(
      user: updatedUser,
      clearPartner: true,
      statusMessage: 'Partner bağlantısı sonlandırıldı. 💔',
    );
    _saveProfile(updatedUser);
    _syncCouplePlayersWithOnlineProfiles();
  }

  void sendGameAction(String actionType, Map<String, dynamic> actionData) {
    _send('game_action', {
      'fromUsername': state.user.username,
      'actionType': actionType,
      'actionData': actionData,
    });
  }

  void setReady(bool ready) {
    state = state.copyWith(isSelfReady: ready);
    sendGameAction(ready ? 'player_ready' : 'player_unready', {'ready': ready});
  }

  Future<List<QuizQuestion>> fetchCustomQuestions([String? username]) =>
      _apiClient.fetchCustomQuestions(username ?? state.user.username);

  Future<bool> createCustomQuestion(
    String text,
    List<String> options, {
    QuestionType type = QuestionType.multipleChoice,
  }) async {
    final result = await _apiClient.createCustomQuestion(
      username: state.user.username,
      text: text,
      options: options,
      type: type,
    );
    if (result.success) {
      state = state.copyWith(statusMessage: 'Sorunuz başarıyla eklendi! ✨', clearError: true);
      return true;
    }
    state = state.copyWith(lastError: result.error ?? 'Soru eklenemedi.');
    return false;
  }

  Future<bool> deleteCustomQuestion(String questionId) =>
      _apiClient.deleteCustomQuestion(questionId: questionId, username: state.user.username);

  Future<List<QuizQuestion>> fetchQuizTest([String? username]) =>
      _apiClient.fetchQuizTest(username ?? state.user.username);

  void clearStatus() {
    state = state.copyWith(clearStatus: true, clearError: true);
  }

  @override
  void dispose() {
    _disposed = true;
    _syncTimer?.cancel();
    _reconnectTimer?.cancel();
    _socketClient.dispose();
    super.dispose();
  }
}

final onlineProvider = StateNotifierProvider<OnlineController, OnlineState>((ref) {
  return OnlineController(ref);
});
