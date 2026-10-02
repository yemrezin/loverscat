import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:loverscat/features/profile/domain/models/friend_request.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import 'package:loverscat/features/quiz/domain/models/question.dart';

class OnlineState {
  final UserProfile user;
  final UserProfile? partner;
  final bool isLoggedIn;
  final bool isConnected;
  final bool isConnecting;
  final String serverUrl;
  final List<FriendRequest> incomingRequests;
  final List<FriendRequest> sentRequests;
  final String? lastError;
  final String? statusMessage;
  final Map<String, dynamic>? lastGameAction;
  final bool isSelfReady;
  final bool isPartnerReady;

  const OnlineState({
    required this.user,
    this.partner,
    this.isLoggedIn = false,
    this.isConnected = false,
    this.isConnecting = false,
    required this.serverUrl,
    this.incomingRequests = const [],
    this.sentRequests = const [],
    this.lastError,
    this.statusMessage,
    this.lastGameAction,
    this.isSelfReady = false,
    this.isPartnerReady = false,
  });

  bool get isPaired => partner != null && user.partnerUsername != null;

  OnlineState copyWith({
    UserProfile? user,
    UserProfile? partner,
    bool clearPartner = false,
    bool? isLoggedIn,
    bool? isConnected,
    bool? isConnecting,
    String? serverUrl,
    List<FriendRequest>? incomingRequests,
    List<FriendRequest>? sentRequests,
    String? lastError,
    bool clearError = false,
    String? statusMessage,
    bool clearStatus = false,
    Map<String, dynamic>? lastGameAction,
    bool? isSelfReady,
    bool? isPartnerReady,
  }) {
    return OnlineState(
      user: user ?? this.user,
      partner: clearPartner ? null : (partner ?? this.partner),
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      serverUrl: serverUrl ?? this.serverUrl,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      lastError: clearError ? null : (lastError ?? this.lastError),
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      lastGameAction: lastGameAction ?? this.lastGameAction,
      isSelfReady: isSelfReady ?? this.isSelfReady,
      isPartnerReady: isPartnerReady ?? this.isPartnerReady,
    );
  }
}


class OnlineController extends StateNotifier<OnlineState> {
  static const _profileKey = 'loverscat_user_profile_v2';
  static String get defaultLocalUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return 'http://$host:4000';
      }
    }
    return 'http://localhost:4000';
  }

  final Ref _ref;
  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;
  Timer? _reconnectTimer;
  Timer? _syncTimer;
  bool _disposed = false;

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
        state = state.copyWith(
          user: userProfile,
          partner: userProfile.partnerProfile,
          isLoggedIn: true,
        );

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
      if (state.isLoggedIn && !_disposed) {
        fetchRequests();
      }
    });
  }

  void _syncCouplePlayersWithOnlineProfiles() {
    final myAvatar = PetAvatar(type: state.user.petType, name: state.user.username);
    final partnerAvatar = state.partner != null
        ? PetAvatar(type: state.partner!.petType, name: state.partner!.username)
        : const PetAvatar(type: PetType.rabbit, name: 'Bekleniyor...');

    _ref.read(couplePlayersProvider.notifier).setPlayers(
          CouplePlayers(
            player1: myAvatar,
            player2: partnerAvatar,
          ),
        );
  }

  String get _wsUrl {
    final uri = Uri.parse(state.serverUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final portString = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$portString';
  }

  // --- Authentication (SQL Backend) ---

  Future<bool> register({
    required String username,
    required String password,
    PetType petType = PetType.cat,
    String petName = 'Mırmır',
  }) async {
    state = state.copyWith(isConnecting: true, clearError: true);
    try {
      final cleanUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
      final uri = Uri.parse('${state.serverUrl}/api/register');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': cleanUsername,
          'password': password,
          'petType': petType.name,
          'petName': petName,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final profile = UserProfile.fromMap(data['user'] as Map<String, dynamic>);
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
      } else {
        state = state.copyWith(
          isConnecting: false,
          lastError: data['error'] as String? ?? 'Kayıt işlemi başarısız oldu.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        lastError: 'Sunucuya bağlanılamadı. Lütfen sunucunun açık olduğundan emin olun.',
      );
      return false;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isConnecting: true, clearError: true);
    try {
      final cleanUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
      final uri = Uri.parse('${state.serverUrl}/api/login');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': cleanUsername,
          'password': password,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final profile = UserProfile.fromMap(data['user'] as Map<String, dynamic>);
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
      } else {
        state = state.copyWith(
          isConnecting: false,
          lastError: data['error'] as String? ?? 'Kullanıcı adı veya şifre hatalı.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        lastError: 'Sunucuya bağlanılamadı. Lütfen sunucunun açık olduğundan emin olun.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    _syncTimer?.cancel();
    _reconnectTimer?.cancel();
    _channelSub?.cancel();
    _channel?.sink.close();
    _channel = null;

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
    _channelSub?.cancel();
    _channel?.sink.close();

    state = state.copyWith(isConnecting: true, clearError: true);

    try {
      final wsUri = Uri.parse(_wsUrl);
      final channel = WebSocketChannel.connect(wsUri);
      _channel = channel;

      _channelSub = channel.stream.listen(
        (data) {
          _handleMessage(data.toString());
        },
        onDone: () {
          debugPrint('[OnlineController] WebSocket closed.');
          state = state.copyWith(isConnected: false, isConnecting: false);
          _scheduleReconnect();
        },
        onError: (err) {
          debugPrint('[OnlineController] WebSocket error: $err');
          state = state.copyWith(
            isConnected: false,
            isConnecting: false,
            lastError: 'Sunucu bağlantısı koptu. Yeniden bağlanılıyor...',
          );
          _scheduleReconnect();
        },
      );

      // Wait until connection is genuinely ready before sending auth
      try {
        await channel.ready;
        state = state.copyWith(isConnected: true, isConnecting: false);
        _sendAuth();
      } catch (e) {
        debugPrint('[OnlineController] Channel ready error: $e');
        state = state.copyWith(isConnected: false, isConnecting: false);
        _scheduleReconnect();
      }

      // Proactively pull friend requests via REST API
      fetchRequests();
    } catch (e) {
      debugPrint('[OnlineController] Connect exception: $e');
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        lastError: 'Bağlantı hatası: $e',
      );
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || !state.isLoggedIn) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!state.isConnected && state.isLoggedIn) {
        connect();
      }
    });
  }

  void _send(String type, Map<String, dynamic> payload) {
    if (_channel != null && state.isConnected) {
      final msg = jsonEncode({
        'type': type,
        ...payload,
        'payload': payload,
      });
      _channel!.sink.add(msg);
    }
  }

  void _sendAuth() {
    _send('auth', {
      'username': state.user.username,
    });
  }

  void _handleMessage(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final type = map['type'] as String?;
      final payload = map['payload'] as Map<String, dynamic>? ?? map;

      switch (type) {
        case 'auth_success':
        case 'registered': {
          final userMap = payload['user'] as Map<String, dynamic>?;
          final partnerMap = payload['partner'] as Map<String, dynamic>?;
          final incomingList = (payload['incomingRequests'] as List? ?? [])
              .map((e) => FriendRequest.fromMap(e as Map<String, dynamic>))
              .toList();
          final sentList = (payload['sentRequests'] as List? ?? [])
              .map((e) => FriendRequest.fromMap(e as Map<String, dynamic>))
              .toList();

          final updatedUser = userMap != null ? UserProfile.fromMap(userMap) : state.user;
          final updatedPartner = partnerMap != null ? UserProfile.fromMap(partnerMap) : null;

          state = state.copyWith(
            isConnected: true,
            isConnecting: false,
            user: updatedUser,
            partner: updatedPartner,
            incomingRequests: incomingList,
            sentRequests: sentList,
            clearError: true,
          );
          _saveProfile(updatedUser);
          _syncCouplePlayersWithOnlineProfiles();
          break;
        }

        case 'profile_updated': {
          final userMap = payload['user'] as Map<String, dynamic>?;
          if (userMap != null) {
            final updatedUser = UserProfile.fromMap(userMap);
            state = state.copyWith(user: updatedUser, statusMessage: 'Profil başarıyla güncellendi! ✅');
            _saveProfile(updatedUser);
            _syncCouplePlayersWithOnlineProfiles();
          }
          break;
        }

        case 'friend_request_received':
        case 'incoming_friend_request': {
          final reqMap = (payload['request'] as Map<String, dynamic>?) ?? payload;
          final req = FriendRequest.fromMap(reqMap);
          final updatedList = List<FriendRequest>.from(state.incomingRequests)
            ..removeWhere((r) => r.id == req.id)
            ..insert(0, req);
          state = state.copyWith(
            incomingRequests: updatedList,
            statusMessage: '@${req.fromUsername} size arkadaşlık isteği gönderdi! 💌',
          );
          break;
        }

        case 'request_sent':
        case 'friend_request_sent': {
          final reqMap = (payload['request'] as Map<String, dynamic>?) ?? payload;
          final req = FriendRequest.fromMap(reqMap);
          final updatedList = List<FriendRequest>.from(state.sentRequests)
            ..removeWhere((r) => r.id == req.id)
            ..insert(0, req);
          state = state.copyWith(
            sentRequests: updatedList,
            statusMessage: map['message'] as String? ?? '@${req.toUsername} kullanıcısına istek gönderildi! 🚀',
          );
          break;
        }

        case 'pair_success':
        case 'partner_paired': {
          final partnerMap = payload['partner'] as Map<String, dynamic>?;
          if (partnerMap != null) {
            final partner = UserProfile.fromMap(partnerMap);
            final updatedUser = state.user.copyWith(partnerUsername: partner.username);
            final updatedIncoming = List<FriendRequest>.from(state.incomingRequests)
              ..removeWhere((r) => r.fromUsername.toLowerCase() == partner.username.toLowerCase());

            state = state.copyWith(
              user: updatedUser,
              partner: partner,
              incomingRequests: updatedIncoming,
              statusMessage: map['message'] as String? ?? '@${partner.username} ile eşleştiniz! Birlikte oynayın 💕🎉',
            );
            _saveProfile(updatedUser);
            _syncCouplePlayersWithOnlineProfiles();
          }
          break;
        }

        case 'unpair_success':
        case 'partner_unpaired': {
          final updatedUser = state.user.copyWith(clearPartner: true);
          state = state.copyWith(
            user: updatedUser,
            clearPartner: true,
            statusMessage: map['message'] as String? ?? 'Partner bağlantısı sonlandırıldı. 💔',
          );
          _saveProfile(updatedUser);
          _syncCouplePlayersWithOnlineProfiles();
          break;
        }

        case 'partner_updated': {
          final partner = UserProfile.fromMap(payload['partner'] as Map<String, dynamic>? ?? payload);
          state = state.copyWith(partner: partner);
          _syncCouplePlayersWithOnlineProfiles();
          break;
        }

        case 'user_avatar_updated': {
          final userMap = payload['user'] as Map<String, dynamic>?;
          if (userMap != null) {
            final updatedUser = UserProfile.fromMap(userMap);
            state = state.copyWith(
              user: updatedUser,
              statusMessage: 'Profil fotoğrafın güncellendi! 📸',
            );
            _saveProfile(updatedUser);
            _syncCouplePlayersWithOnlineProfiles();
          }
          break;
        }

        case 'partner_avatar_updated': {
          final partnerMap = payload['partner'] as Map<String, dynamic>?;
          if (partnerMap != null) {
            final updatedPartner = UserProfile.fromMap(partnerMap);
            state = state.copyWith(
              partner: updatedPartner,
              statusMessage: '@${updatedPartner.username} profil fotoğrafını güncelledi! 📸',
            );
            _syncCouplePlayersWithOnlineProfiles();
          }
          break;
        }

        case 'partner_status': {
          final isOnline = payload['isOnline'] as bool? ?? false;
          if (state.partner != null) {
            state = state.copyWith(partner: state.partner!.copyWith(isOnline: isOnline));
          }
          break;
        }

        case 'remote_game_action':
        case 'partner_game_action': {
          final actionType = payload['actionType'] as String?;
          final actionData = payload['actionData'] as Map<String, dynamic>? ?? {};

          if (actionType == 'my_ready_status') {
            final isReady = actionData['isReady'] as bool? ?? false;
            state = state.copyWith(isSelfReady: isReady);
          } else if (actionType == 'partner_ready_status') {
            final isReady = actionData['isReady'] as bool? ?? false;
            state = state.copyWith(isPartnerReady: isReady);
          } else if (actionType == 'start_synced_game') {
            state = state.copyWith(
              isSelfReady: false,
              isPartnerReady: false,
              lastGameAction: payload,
            );
          } else {
            state = state.copyWith(lastGameAction: payload);
          }
          break;
        }


        case 'error': {
          final msg = map['message'] as String? ?? 'Bilinmeyen sunucu hatası.';
          state = state.copyWith(lastError: msg);
          break;
        }

        case 'info': {
          final msg = map['message'] as String?;
          if (msg != null) {
            state = state.copyWith(statusMessage: msg);
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('[OnlineController] parse error: $e');
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, profile.toJson());
    } catch (_) {}
  }

  // User Actions
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
    try {
      final uri = Uri.parse('${state.serverUrl}/api/user/avatar');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': state.user.username,
          'customAvatarBase64': (base64String != null && base64String.isNotEmpty) ? base64String : null,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final updatedUser = UserProfile.fromMap(data['user'] as Map<String, dynamic>);
        state = state.copyWith(
          user: updatedUser,
          statusMessage: (base64String != null && base64String.isNotEmpty)
              ? 'Profil fotoğrafın güncellendi! 📸'
              : 'Fotoğraf kaldırıldı, karakterine dönüldü! 🐾',
        );
        await _saveProfile(updatedUser);
        _syncCouplePlayersWithOnlineProfiles();
        return true;
      } else {
        state = state.copyWith(lastError: data['error'] as String? ?? 'Fotoğraf güncellenemedi.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(lastError: 'Fotoğraf yüklenirken hata oluştu: $e');
      return false;
    }
  }

  Future<bool> removeCustomAvatar() async {
    return uploadCustomAvatar(null);
  }

  Future<void> fetchRequests() async {
    if (!state.isLoggedIn || state.user.username.isEmpty) return;
    try {
      final uri = Uri.parse('${state.serverUrl}/api/friend-requests/${Uri.encodeComponent(state.user.username)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final incomingList = (data['incomingRequests'] as List? ?? [])
              .map((e) => FriendRequest.fromMap(e as Map<String, dynamic>))
              .toList();
          final sentList = (data['sentRequests'] as List? ?? [])
              .map((e) => FriendRequest.fromMap(e as Map<String, dynamic>))
              .toList();

          state = state.copyWith(
            incomingRequests: incomingList,
            sentRequests: sentList,
          );
        }
      }
    } catch (_) {}
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

    try {
      final uri = Uri.parse('${state.serverUrl}/api/friend-request');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromUsername': state.user.username,
          'toUsername': clean,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final req = FriendRequest.fromMap(data['request'] as Map<String, dynamic>);
        final updatedList = List<FriendRequest>.from(state.sentRequests)
          ..removeWhere((r) => r.id == req.id)
          ..insert(0, req);
        state = state.copyWith(
          sentRequests: updatedList,
          statusMessage: '@$clean kullanıcısına arkadaşlık isteği gönderildi! 🚀',
          clearError: true,
        );
        // Also send through websocket for instant delivery
        _send('send_friend_request', {
          'fromUsername': state.user.username,
          'toUsername': clean,
        });
        return true;
      } else {
        final errorMsg = data['error'] as String? ?? 'İstek gönderilemedi.';
        state = state.copyWith(lastError: errorMsg);
        return false;
      }
    } catch (e) {
      // Fallback: try websocket
      _send('send_friend_request', {
        'fromUsername': state.user.username,
        'toUsername': clean,
      });
      state = state.copyWith(statusMessage: '@$clean kullanıcısına istek iletiliyor...');
      return true;
    }
  }

  Future<bool> respondFriendRequest(String requestId, bool accept) async {
    try {
      final uri = Uri.parse('${state.serverUrl}/api/friend-request/respond');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'username': state.user.username,
          'accept': accept,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        if (accept && data['partner'] != null) {
          final partner = UserProfile.fromMap(data['partner'] as Map<String, dynamic>);
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
          state = state.copyWith(
            incomingRequests: updatedIncoming,
            statusMessage: 'İstek reddedildi.',
          );
        }

        // Notify WS as well
        _send('respond_friend_request', {
          'requestId': requestId,
          'username': state.user.username,
          'accept': accept,
        });
        return true;
      } else {
        state = state.copyWith(lastError: data['error'] as String? ?? 'Cevap verilemedi.');
        return false;
      }
    } catch (e) {
      _send('respond_friend_request', {
        'requestId': requestId,
        'username': state.user.username,
        'accept': accept,
      });
      return true;
    }
  }

  Future<void> unpair() async {
    try {
      final uri = Uri.parse('${state.serverUrl}/api/unpair');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': state.user.username}),
      );
    } catch (_) {}

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

  Future<List<QuizQuestion>> fetchCustomQuestions([String? username]) async {
    final targetUser = username ?? state.user.username;
    if (targetUser.isEmpty) return [];
    try {
      final uri = Uri.parse('${state.serverUrl}/api/questions/${Uri.encodeComponent(targetUser)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final list = (data['questions'] as List? ?? [])
              .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (_) {}
    return [];
  }

  Future<bool> createCustomQuestion(
    String text,
    List<String> options, {
    QuestionType type = QuestionType.multipleChoice,
  }) async {
    try {
      final uri = Uri.parse('${state.serverUrl}/api/questions');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': state.user.username,
          'text': text,
          'type': type.name,
          'options': options,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        state = state.copyWith(statusMessage: 'Sorunuz başarıyla eklendi! ✨', clearError: true);
        return true;
      } else {
        state = state.copyWith(lastError: data['error'] as String? ?? 'Soru eklenemedi.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(lastError: 'Sunucuya ulaşılamadı.');
      return false;
    }
  }

  Future<bool> deleteCustomQuestion(String questionId) async {
    try {
      final uri = Uri.parse('${state.serverUrl}/api/questions/$questionId?username=${Uri.encodeComponent(state.user.username)}');
      final res = await http.delete(uri);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200 && data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<QuizQuestion>> fetchQuizTest([String? username]) async {
    final targetUser = username ?? state.user.username;
    if (targetUser.isEmpty) return [];
    try {
      final uri = Uri.parse('${state.serverUrl}/api/quiz-test/${Uri.encodeComponent(targetUser)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final list = (data['questions'] as List? ?? [])
              .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (_) {}
    return [];
  }

  void clearStatus() {
    state = state.copyWith(clearStatus: true, clearError: true);
  }


  @override
  void dispose() {
    _disposed = true;
    _syncTimer?.cancel();
    _reconnectTimer?.cancel();
    _channelSub?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

final onlineProvider = StateNotifierProvider<OnlineController, OnlineState>((ref) {
  return OnlineController(ref);
});
