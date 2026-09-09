import 'package:flutter_test/flutter_test.dart';
import 'package:loverscat/features/pet/domain/models/pet_avatar.dart';
import 'package:loverscat/features/pet/presentation/controllers/pet_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PetAvatar Model Tests', () {
    test('Default pet avatar is Cat with name Mırmır', () {
      const defaultPet = PetAvatar.defaultPet;
      expect(defaultPet.type, PetType.cat);
      expect(defaultPet.name, 'Mırmır');
    });

    test('All 4 pet types have correct Turkish display names and icons', () {
      expect(PetType.cat.displayName, 'Kedi 🐱');
      expect(PetType.rabbit.displayName, 'Tavşan 🐰');
      expect(PetType.fox.displayName, 'Tilki 🦊');
      expect(PetType.cheese.displayName, 'Peynir 🧀');
    });

    test('PetAvatar serialization to/from JSON map', () {
      const original = PetAvatar(type: PetType.fox, name: 'Kurnaz');
      final map = original.toMap();

      expect(map['type'], 'fox');
      expect(map['name'], 'Kurnaz');

      final reconstructed = PetAvatar.fromMap(map);
      expect(reconstructed.type, PetType.fox);
      expect(reconstructed.name, 'Kurnaz');
    });
  });

  group('PetNotifier State and Storage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Updating pet type and name persists correctly', () async {
      final notifier = PetNotifier();
      expect(notifier.state.type, PetType.cat);

      await notifier.setPet(const PetAvatar(type: PetType.rabbit, name: 'Pamuk'));
      expect(notifier.state.type, PetType.rabbit);
      expect(notifier.state.name, 'Pamuk');

      await notifier.setPet(notifier.state.copyWith(type: PetType.cheese));
      expect(notifier.state.type, PetType.cheese);
      expect(notifier.state.name, 'Pamuk');
    });
  });
}
