import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';

class FriendRequest {
  final String id;
  final String fromUsername;
  final String toUsername;
  final String fromDisplayName;
  final PetType fromPetType;
  final String fromPetName;
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'rejected'

  const FriendRequest({
    required this.id,
    required this.fromUsername,
    required this.toUsername,
    required this.fromDisplayName,
    required this.fromPetType,
    required this.fromPetName,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUsername': fromUsername,
      'toUsername': toUsername,
      'fromDisplayName': fromDisplayName,
      'fromPetType': fromPetType.name,
      'fromPetName': fromPetName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    final typeStr = map['fromPetType'] as String?;
    final petType = PetType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PetType.cat,
    );

    return FriendRequest(
      id: map['id'] as String? ?? '',
      fromUsername: (map['fromUsername'] as String? ?? '').toLowerCase(),
      toUsername: (map['toUsername'] as String? ?? '').toLowerCase(),
      fromDisplayName: map['fromDisplayName'] as String? ?? (map['fromUsername'] as String? ?? ''),
      fromPetType: petType,
      fromPetName: map['fromPetName'] as String? ?? 'Mırmır',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] as String? ?? 'pending',
    );
  }
}
