import '../../../core/contracts/mini_game_contract.dart';

/// Registry maintaining all 10 island mini-game definitions and future hooks.
/// Follows Open/Closed Principle (OCP) - new mini-games can be plugged in seamlessly.
class MiniGameRegistry {
  static final Map<int, MiniGameMetadata> _gamesByIsland = {
    1: const MiniGameMetadata(
      id: MiniGameId.shellsCoveBallDrop,
      islandName: 'Shells Cove',
      description: 'Yukarıdan sütunlara renkli topları bırakarak eşleştirin veya potalara 5 top sokun!',
      controlGuide: 'Ekrana dokunarak sütun seçin ve topu serbest bırakın.',
      droppedChildItemName: 'Hasır Bebek Şapkası',
      droppedChildItemIcon: '👒',
      storyClue: 'İlk adada minik hasır şapkasının izi bulundu!',
    ),
    2: const MiniGameMetadata(
      id: MiniGameId.syrupWoodsArchery,
      islandName: 'Syrup Woods',
      description: 'Rüzgar açısını ve yay mesafesini hesaplayarak hareketli hedefleri vurun!',
      controlGuide: 'Yayı geriye doğru çekip rüzgar göstergesine göre nişan alın.',
      droppedChildItemName: 'Ahşap Korsan Dürbünü',
      droppedChildItemIcon: '🔭',
      storyClue: 'Ormanın derinliklerinde oyuncak dürbününü düşürmüş!',
    ),
    3: const MiniGameMetadata(
      id: MiniGameId.baratieAirHockey,
      islandName: 'Baratie Coast',
      description: 'Reflekslerinizi yarıştırın! Diski parmağınızla yönlendirip rakip kaleye gol atın.',
      controlGuide: 'Tokmağı parmağınızla sürükleyerek diske vurun ve kalenizi savunun.',
      droppedChildItemName: 'Minik Aşçı Önlüğü',
      droppedChildItemIcon: '🍳',
      storyClue: 'Yüzen restoranın iskelesinde sevimli aşçı önlüğü asılı kalmış!',
    ),
    4: const MiniGameMetadata(
      id: MiniGameId.arlongHotPotato,
      islandName: 'Arlong Reef',
      description: 'Saatli bomba patlamadan önce hızlı dokunuşlarla karşı tarafa paslayın!',
      controlGuide: 'Bomba ekranınıza geldiğinde gecikmeden butona basıp fırlatın.',
      droppedChildItemName: 'Deniz Kabuğu Bileklik',
      droppedChildItemIcon: '🐚',
      storyClue: 'Mercanların arasında sedefli bileklik ışıldıyor!',
    ),
    5: const MiniGameMetadata(
      id: MiniGameId.drumMemoryMatch,
      islandName: 'Drum Peak',
      description: 'Karlı dağın gizemli kartlarını sırayla çevirip sembol çiftlerini bulun.',
      controlGuide: 'Kartlara dokunarak eşini tahmin edin ve hafızanızı konuşturun.',
      droppedChildItemName: 'Yünlü Kış Eldiveni',
      droppedChildItemIcon: '🧤',
      storyClue: 'Kardelenlerin yanında sıcacık kırmızı eldiveni duruyor!',
    ),
    6: const MiniGameMetadata(
      id: MiniGameId.alabastaHideAndSeek,
      islandName: 'Alabasta Sands',
      description: 'Sisli çöl labirentinde kısıtlı görüşle saklanın veya partnerinizi yakalayın!',
      controlGuide: 'Joystick veya ok tuşlarıyla kum fırtınasının içinden kaçın.',
      droppedChildItemName: 'Sarı Kum Saati Kolye',
      droppedChildItemIcon: '⏳',
      storyClue: 'Vahanın kıyısında zamanın sevgiyi eritemeyeceğinin kanıtı bulundu!',
    ),
    7: const MiniGameMetadata(
      id: MiniGameId.skypieaElementalRun,
      islandName: 'Skypiea Ruins',
      description: 'Ateş ve Su kapılarını birlikte yönetin; birbirinize yol açarak tapınaktan çıkın!',
      controlGuide: 'Oyuncu 1 ateş butonlarını, Oyuncu 2 su kollarını kontrol eder.',
      droppedChildItemName: 'Beyaz Melek Tüyü',
      droppedChildItemIcon: '🪶',
      storyClue: 'Gökyüzü bulutlarından süzülen melek tüyü umudu tazeledi!',
    ),
    8: const MiniGameMetadata(
      id: MiniGameId.waterSevenLaserMirror,
      islandName: 'Water Seven Bay',
      description: 'Bir oyuncu lazeri odaklar, diğeri aynaları çevirerek ışığı kristale ulaştırır.',
      controlGuide: 'Aynaları döndürerek ışık huzmesini hedef kristale kırın.',
      droppedChildItemName: 'Ahşap Oyuncak Yelkenli',
      droppedChildItemIcon: '⛵',
      storyClue: 'Kanal sularında kendi boyadığı minik tekne süzülüyor!',
    ),
    9: const MiniGameMetadata(
      id: MiniGameId.sabaodyMinecart,
      islandName: 'Sabaody Grove',
      description: 'Hızlı maden arabasında Oyuncu 1 sağ-sol yapar, Oyuncu 2 zıpla-eğil ile engelleri aşar!',
      controlGuide: 'Kusursuz senkronizasyon ile maden raylarında hayatta kalın.',
      droppedChildItemName: 'Rengarenk Balon İpi',
      droppedChildItemIcon: '🧵',
      storyClue: 'Uçan balon demetinin ipleri ağaç dallarında görüldü!',
    ),
    10: const MiniGameMetadata(
      id: MiniGameId.wanoLavaEscape,
      islandName: 'Wano Zirvesi',
      description: 'BÜYÜK FİNAL! İki sevgili birbirine bağlı iplerle lavlardan kaçıp çocuğuna kavuşuyor!',
      controlGuide: 'Biri kayaya tutunup diğerini yukarı fırlatır; el ele zirveye tırmanın.',
      droppedChildItemName: 'Küçük Yavrunuz & Balon Demeti!',
      droppedChildItemIcon: '🎈👶🎈',
      storyClue: 'ZİRVEDESİNİZ! Lavlar ve fırtına dindi, küçük yavrunuz kollarınızda!',
    ),
  };

  /// Returns metadata for a given island (1 to 10).
  static MiniGameMetadata getGameForIsland(int islandNumber) {
    return _gamesByIsland[islandNumber] ?? _gamesByIsland[1]!;
  }

  /// Lists all 10 island mini-games.
  static List<MiniGameMetadata> get allGames => _gamesByIsland.values.toList();
}
