import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/profile/domain/models/user_profile.dart';
import 'package:loverscat/features/profile/domain/models/friend_request.dart';

void main() {
  group('Online Feature Models & Logic Tests', () {
    test('UserProfile JSON serialization and default values', () {
      final profile = UserProfile(
        username: 'deniz_99',
        displayName: 'Deniz',
        petType: PetType.fox,
        petName: 'Ateş',
        partnerUsername: 'baris_42',
      );

      final jsonMap = profile.toMap();
      expect(jsonMap['username'], 'deniz_99');
      expect(jsonMap['displayName'], 'Deniz');
      expect(jsonMap['petType'], 'fox');
      expect(jsonMap['partnerUsername'], 'baris_42');

      final reconstructed = UserProfile.fromMap(jsonMap);
      expect(reconstructed.username, profile.username);
      expect(reconstructed.displayName, profile.username);
      expect(reconstructed.petType, PetType.fox);
      expect(reconstructed.partnerUsername, 'baris_42');
    });

    test('FriendRequest JSON serialization and status checks', () {
      final req = FriendRequest(
        id: 'req_123',
        fromUsername: 'ali',
        fromDisplayName: 'Ali',
        fromPetType: PetType.cheese,
        fromPetName: 'Peynir',
        toUsername: 'ayse',
        status: 'pending',
        createdAt: DateTime(2026, 9, 8, 12, 0),
      );

      final map = req.toMap();
      expect(map['id'], 'req_123');
      expect(map['fromUsername'], 'ali');
      expect(map['fromPetType'], 'cheese');
      expect(map['fromPetName'], 'Peynir');
      expect(map['status'], 'pending');

      final deserialized = FriendRequest.fromMap(map);
      expect(deserialized.id, 'req_123');
      expect(deserialized.fromDisplayName, 'Ali');
      expect(deserialized.fromPetType, PetType.cheese);
      expect(deserialized.fromPetName, 'Peynir');
      expect(deserialized.status, 'pending');
    });

    test('UserProfile copyWith updates partner and username', () {
      final user = UserProfile.defaultProfile(username: 'test_user');
      expect(user.partnerUsername, isNull);

      final updated = user.copyWith(
        username: 'yeni_kullanici',
        displayName: 'Yeni İsim',
        partnerUsername: 'partner_user',
      );

      expect(updated.username, 'yeni_kullanici');
      expect(updated.displayName, 'Yeni İsim');
      expect(updated.partnerUsername, 'partner_user');
    });

    test('UserProfile custom avatar serialization and copyWith', () {
      const sampleBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
      final profile = UserProfile(
        username: 'kedi_sever',
        displayName: 'Kedi Sever',
        petType: PetType.cat,
        petName: 'Mırmır',
        customAvatarBase64: sampleBase64,
      );

      final map = profile.toMap();
      expect(map['customAvatarBase64'], sampleBase64);

      final reconstructed = UserProfile.fromMap(map);
      expect(reconstructed.customAvatarBase64, sampleBase64);

      // Test clearing avatar
      final cleared = reconstructed.copyWith(clearCustomAvatar: true);
      expect(cleared.customAvatarBase64, isNull);

      // Test updating avatar
      final updated = cleared.copyWith(customAvatarBase64: 'another_base64');
      expect(updated.customAvatarBase64, 'another_base64');
    });
  });
}
