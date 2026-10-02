import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:loverscat/features/profile/domain/models/friend_request.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import '../models/online_state.dart';

/// Pure processor for incoming WebSocket messages and state reductions.
class OnlineMessageProcessor {
  const OnlineMessageProcessor._();

  /// Processes raw WebSocket string message and returns updated [OnlineState].
  static OnlineState process({
    required String raw,
    required OnlineState currentState,
    required void Function(UserProfile profile) onSaveProfile,
    required VoidCallback onSyncPlayers,
  }) {
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

          final updatedUser = userMap != null ? UserProfile.fromMap(userMap) : currentState.user;
          final updatedPartner = partnerMap != null ? UserProfile.fromMap(partnerMap) : null;

          final nextState = currentState.copyWith(
            isConnected: true,
            isConnecting: false,
            user: updatedUser,
            partner: updatedPartner,
            incomingRequests: incomingList,
            sentRequests: sentList,
            clearError: true,
          );
          onSaveProfile(updatedUser);
          onSyncPlayers();
          return nextState;
        }

        case 'profile_updated': {
          final userMap = payload['user'] as Map<String, dynamic>?;
          if (userMap != null) {
            final updatedUser = UserProfile.fromMap(userMap);
            final nextState = currentState.copyWith(user: updatedUser, statusMessage: 'Profil başarıyla güncellendi! ✅');
            onSaveProfile(updatedUser);
            onSyncPlayers();
            return nextState;
          }
          return currentState;
        }

        case 'friend_request_received':
        case 'incoming_friend_request': {
          final reqMap = (payload['request'] as Map<String, dynamic>?) ?? payload;
          final req = FriendRequest.fromMap(reqMap);
          final updatedList = List<FriendRequest>.from(currentState.incomingRequests)
            ..removeWhere((r) => r.id == req.id)
            ..insert(0, req);
          return currentState.copyWith(
            incomingRequests: updatedList,
            statusMessage: '@${req.fromUsername} size arkadaşlık isteği gönderdi! 💌',
          );
        }

        case 'request_sent':
        case 'friend_request_sent': {
          final reqMap = (payload['request'] as Map<String, dynamic>?) ?? payload;
          final req = FriendRequest.fromMap(reqMap);
          final updatedList = List<FriendRequest>.from(currentState.sentRequests)
            ..removeWhere((r) => r.id == req.id)
            ..insert(0, req);
          return currentState.copyWith(
            sentRequests: updatedList,
            statusMessage: map['message'] as String? ?? '@${req.toUsername} kullanıcısına istek gönderildi! 🚀',
          );
        }

        case 'pair_success':
        case 'partner_paired': {
          final partnerMap = payload['partner'] as Map<String, dynamic>?;
          if (partnerMap != null) {
            final partner = UserProfile.fromMap(partnerMap);
            final updatedUser = currentState.user.copyWith(partnerUsername: partner.username);
            final updatedIncoming = List<FriendRequest>.from(currentState.incomingRequests)
              ..removeWhere((r) => r.fromUsername.toLowerCase() == partner.username.toLowerCase());

            final nextState = currentState.copyWith(
              user: updatedUser,
              partner: partner,
              incomingRequests: updatedIncoming,
              statusMessage: map['message'] as String? ?? '@${partner.username} ile eşleştiniz! Birlikte oynayın 💕🎉',
            );
            onSaveProfile(updatedUser);
            onSyncPlayers();
            return nextState;
          }
          return currentState;
        }

        case 'unpair_success':
        case 'partner_unpaired': {
          final updatedUser = currentState.user.copyWith(clearPartner: true);
          final nextState = currentState.copyWith(
            user: updatedUser,
            clearPartner: true,
            statusMessage: map['message'] as String? ?? 'Partner bağlantısı sonlandırıldı. 💔',
          );
          onSaveProfile(updatedUser);
          onSyncPlayers();
          return nextState;
        }

        case 'partner_updated': {
          final partner = UserProfile.fromMap(payload['partner'] as Map<String, dynamic>? ?? payload);
          final nextState = currentState.copyWith(partner: partner);
          onSyncPlayers();
          return nextState;
        }

        case 'user_avatar_updated': {
          final userMap = payload['user'] as Map<String, dynamic>?;
          if (userMap != null) {
            final updatedUser = UserProfile.fromMap(userMap);
            final nextState = currentState.copyWith(
              user: updatedUser,
              statusMessage: 'Profil fotoğrafın güncellendi! 📸',
            );
            onSaveProfile(updatedUser);
            onSyncPlayers();
            return nextState;
          }
          return currentState;
        }

        case 'partner_avatar_updated': {
          final partnerMap = payload['partner'] as Map<String, dynamic>?;
          if (partnerMap != null) {
            final updatedPartner = UserProfile.fromMap(partnerMap);
            final nextState = currentState.copyWith(
              partner: updatedPartner,
              statusMessage: '@${updatedPartner.username} profil fotoğrafını güncelledi! 📸',
            );
            onSyncPlayers();
            return nextState;
          }
          return currentState;
        }

        case 'partner_status': {
          final isOnline = payload['isOnline'] as bool? ?? false;
          if (currentState.partner != null) {
            return currentState.copyWith(partner: currentState.partner!.copyWith(isOnline: isOnline));
          }
          return currentState;
        }

        case 'remote_game_action':
        case 'partner_game_action': {
          final actionType = payload['actionType'] as String?;
          final actionData = payload['actionData'] as Map<String, dynamic>? ?? {};

          if (actionType == 'my_ready_status') {
            final isReady = actionData['isReady'] as bool? ?? false;
            return currentState.copyWith(isSelfReady: isReady);
          } else if (actionType == 'partner_ready_status') {
            final isReady = actionData['isReady'] as bool? ?? false;
            return currentState.copyWith(isPartnerReady: isReady);
          } else if (actionType == 'start_synced_game') {
            return currentState.copyWith(
              isSelfReady: false,
              isPartnerReady: false,
              lastGameAction: payload,
            );
          } else {
            return currentState.copyWith(lastGameAction: payload);
          }
        }

        case 'error': {
          final msg = map['message'] as String? ?? 'Bilinmeyen sunucu hatası.';
          return currentState.copyWith(lastError: msg);
        }

        case 'info': {
          final msg = map['message'] as String?;
          if (msg != null) {
            return currentState.copyWith(statusMessage: msg);
          }
          return currentState;
        }
      }
    } catch (e) {
      debugPrint('[OnlineMessageProcessor] parse error: $e');
    }
    return currentState;
  }
}
