import 'dart:convert';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';

class UserProfile {
  final String username;
  final String displayName;
  final PetType petType;
  final String petName;
  final String? partnerUsername;
  final UserProfile? partnerProfile;
  final bool isOnline;
  final String? customAvatarBase64;

  const UserProfile({
    required this.username,
    required this.displayName,
    required this.petType,
    required this.petName,
    this.partnerUsername,
    this.partnerProfile,
    this.isOnline = true,
    this.customAvatarBase64,
  });

  String get formattedUsername => username.startsWith('@') ? username : '@$username';

  static UserProfile defaultProfile({String? username}) {
    final uname = username ?? 'kullanici_${DateTime.now().millisecondsSinceEpoch % 1000}';
    return UserProfile(
      username: uname.toLowerCase(),
      displayName: uname,
      petType: PetType.cat,
      petName: 'Mırmır',
      partnerUsername: null,
      partnerProfile: null,
      isOnline: true,
      customAvatarBase64: null,
    );
  }

  UserProfile copyWith({
    String? username,
    String? displayName,
    PetType? petType,
    String? petName,
    String? partnerUsername,
    bool clearPartner = false,
    UserProfile? partnerProfile,
    bool? isOnline,
    String? customAvatarBase64,
    bool clearCustomAvatar = false,
  }) {
    return UserProfile(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      petType: petType ?? this.petType,
      petName: petName ?? this.petName,
      partnerUsername: clearPartner ? null : (partnerUsername ?? this.partnerUsername),
      partnerProfile: clearPartner ? null : (partnerProfile ?? this.partnerProfile),
      isOnline: isOnline ?? this.isOnline,
      customAvatarBase64: clearCustomAvatar
          ? null
          : (customAvatarBase64 ?? this.customAvatarBase64),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username.toLowerCase(),
      'displayName': displayName,
      'petType': petType.name,
      'petName': petName,
      'partnerUsername': partnerUsername?.toLowerCase(),
      'partnerProfile': partnerProfile?.toMap(),
      'isOnline': isOnline,
      'customAvatarBase64': customAvatarBase64,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final typeStr = map['petType'] as String?;
    final petType = PetType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PetType.cat,
    );

    final uname = (map['username'] as String? ?? 'oyuncu').toLowerCase();
    return UserProfile(
      username: uname,
      displayName: uname,
      petType: petType,
      petName: map['petName'] as String? ?? 'Mırmır',
      partnerUsername: (map['partnerUsername'] as String?)?.toLowerCase(),
      partnerProfile: map['partnerProfile'] != null
          ? UserProfile.fromMap(map['partnerProfile'] as Map<String, dynamic>)
          : null,
      isOnline: map['isOnline'] as bool? ?? false,
      customAvatarBase64: map['customAvatarBase64'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
