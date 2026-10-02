import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/profile/domain/models/friend_request.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import 'package:loverscat/features/quiz/domain/models/question.dart';

/// Result envelope for API requests.
class ApiResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResult.success(this.data)
      : success = true,
        error = null;

  const ApiResult.failure(this.error)
      : success = false,
        data = null;
}

/// HTTP REST client responsible for network communication with the backend server.
class OnlineApiClient {
  final String serverUrl;

  const OnlineApiClient(this.serverUrl);

  /// Registers a new user.
  Future<ApiResult<UserProfile>> register({
    required String username,
    required String password,
    required PetType petType,
    required String petName,
  }) async {
    try {
      final cleanUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
      final uri = Uri.parse('$serverUrl/api/register');
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
        return ApiResult.success(profile);
      } else {
        return ApiResult.failure(data['error'] as String? ?? 'Kayıt işlemi başarısız oldu.');
      }
    } catch (_) {
      return const ApiResult.failure('Sunucuya bağlanılamadı. Lütfen sunucunun açık olduğundan emin olun.');
    }
  }

  /// Logs in an existing user.
  Future<ApiResult<UserProfile>> login({
    required String username,
    required String password,
  }) async {
    try {
      final cleanUsername = username.trim().toLowerCase().replaceFirst(RegExp(r'^@'), '');
      final uri = Uri.parse('$serverUrl/api/login');
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
        return ApiResult.success(profile);
      } else {
        return ApiResult.failure(data['error'] as String? ?? 'Kullanıcı adı veya şifre hatalı.');
      }
    } catch (_) {
      return const ApiResult.failure('Sunucuya bağlanılamadı. Lütfen sunucunun açık olduğundan emin olun.');
    }
  }

  /// Updates or removes user custom photo avatar.
  Future<ApiResult<UserProfile>> uploadCustomAvatar({
    required String username,
    String? base64String,
  }) async {
    try {
      final uri = Uri.parse('$serverUrl/api/user/avatar');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'customAvatarBase64': (base64String != null && base64String.isNotEmpty) ? base64String : null,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final updatedUser = UserProfile.fromMap(data['user'] as Map<String, dynamic>);
        return ApiResult.success(updatedUser);
      } else {
        return ApiResult.failure(data['error'] as String? ?? 'Fotoğraf güncellenemedi.');
      }
    } catch (e) {
      return ApiResult.failure('Fotoğraf yüklenirken hata oluştu: $e');
    }
  }

  /// Fetches incoming and sent friend requests.
  Future<({List<FriendRequest> incoming, List<FriendRequest> sent})?> fetchFriendRequests(String username) async {
    if (username.isEmpty) return null;
    try {
      final uri = Uri.parse('$serverUrl/api/friend-requests/${Uri.encodeComponent(username)}');
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
          return (incoming: incomingList, sent: sentList);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Sends a friend request.
  Future<ApiResult<FriendRequest>> sendFriendRequest({
    required String fromUsername,
    required String toUsername,
  }) async {
    try {
      final uri = Uri.parse('$serverUrl/api/friend-request');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromUsername': fromUsername,
          'toUsername': toUsername,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        final req = FriendRequest.fromMap(data['request'] as Map<String, dynamic>);
        return ApiResult.success(req);
      } else {
        return ApiResult.failure(data['error'] as String? ?? 'İstek gönderilemedi.');
      }
    } catch (e) {
      return ApiResult.failure('Bağlantı hatası: $e');
    }
  }

  /// Responds to a friend request (accept or reject).
  Future<ApiResult<UserProfile?>> respondFriendRequest({
    required String requestId,
    required String username,
    required bool accept,
  }) async {
    try {
      final uri = Uri.parse('$serverUrl/api/friend-request/respond');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': requestId,
          'username': username,
          'accept': accept,
        }),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        if (accept && data['partner'] != null) {
          final partner = UserProfile.fromMap(data['partner'] as Map<String, dynamic>);
          return ApiResult.success(partner);
        }
        return const ApiResult.success(null);
      } else {
        return ApiResult.failure(data['error'] as String? ?? 'Cevap verilemedi.');
      }
    } catch (e) {
      return ApiResult.failure('Bağlantı hatası: $e');
    }
  }

  /// Unpairs the current partner.
  Future<void> unpair(String username) async {
    try {
      final uri = Uri.parse('$serverUrl/api/unpair');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
    } catch (_) {}
  }

  /// Fetches custom questions of a user.
  Future<List<QuizQuestion>> fetchCustomQuestions(String username) async {
    if (username.isEmpty) return [];
    try {
      final uri = Uri.parse('$serverUrl/api/questions/${Uri.encodeComponent(username)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return (data['questions'] as List? ?? [])
              .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Creates a new custom question.
  Future<ApiResult<void>> createCustomQuestion({
    required String username,
    required String text,
    required List<String> options,
    required QuestionType type,
  }) async {
    try {
      final uri = Uri.parse('$serverUrl/api/questions');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'text': text,
          'type': type.name,
          'options': options,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return const ApiResult.success(null);
      } else {
        return ApiResult.failure(data['error'] as String? ?? 'Soru eklenemedi.');
      }
    } catch (_) {
      return const ApiResult.failure('Sunucuya ulaşılamadı.');
    }
  }

  /// Deletes a custom question by ID.
  Future<bool> deleteCustomQuestion({
    required String questionId,
    required String username,
  }) async {
    try {
      final uri = Uri.parse('$serverUrl/api/questions/$questionId?username=${Uri.encodeComponent(username)}');
      final res = await http.delete(uri);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return res.statusCode == 200 && data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Fetches the assembled quiz test for a user.
  Future<List<QuizQuestion>> fetchQuizTest(String username) async {
    if (username.isEmpty) return [];
    try {
      final uri = Uri.parse('$serverUrl/api/quiz-test/${Uri.encodeComponent(username)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return (data['questions'] as List? ?? [])
              .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
