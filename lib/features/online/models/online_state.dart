import 'package:loverscat/features/profile/domain/models/friend_request.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';

/// State representation for the online connectivity, pairing, and live session.
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
