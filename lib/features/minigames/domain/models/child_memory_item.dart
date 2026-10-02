/// Represents one of the 10 nostalgic memory items dropped by the lost child on the 10 islands.
class ChildMemoryItem {
  final int islandNumber;
  final String islandName;
  final String itemName;
  final String itemIcon;
  final String emotionalDescription;
  final String findingStory;
  final bool isRecovered;

  const ChildMemoryItem({
    required this.islandNumber,
    required this.islandName,
    required this.itemName,
    required this.itemIcon,
    required this.emotionalDescription,
    required this.findingStory,
    this.isRecovered = false,
  });

  ChildMemoryItem copyWith({bool? isRecovered}) {
    return ChildMemoryItem(
      islandNumber: islandNumber,
      islandName: islandName,
      itemName: itemName,
      itemIcon: itemIcon,
      emotionalDescription: emotionalDescription,
      findingStory: findingStory,
      isRecovered: isRecovered ?? this.isRecovered,
    );
  }

  static const List<ChildMemoryItem> default10IslandItems = [
    ChildMemoryItem(
      islandNumber: 1,
      islandName: 'Shells Cove',
      itemName: 'Hasır Bebek Şapkası',
      itemIcon: '👒',
      emotionalDescription: 'Güneşten korunması için annesinin sevgiyle ördüğü minik hasır şapka.',
      findingStory: 'Kumsaldaki palmiyenin dalına takılmış, rüzgarla hafifçe sallanıyordu...',
    ),
    ChildMemoryItem(
      islandNumber: 2,
      islandName: 'Syrup Woods',
      itemName: 'Ahşap Korsan Dürbünü',
      itemIcon: '🔭',
      emotionalDescription: 'Babasının tahtadan oyduğu, ufuklara bakıp kahkahalar attığı oyuncak dürbün.',
      findingStory: 'Ormandaki dev meşe ağacının altındaki çimlerin üzerinde parıldıyordu.',
    ),
    ChildMemoryItem(
      islandNumber: 3,
      islandName: 'Baratie Coast',
      itemName: 'Minik Aşçı Önlüğü',
      itemIcon: '🍳',
      emotionalDescription: 'Birlikte kurabiye yaparken üzerine un bulaştırdığı sarı kareli önlük.',
      findingStory: 'Sahildeki ahşap iskelenin ucundaki fenerin demirine asılı kalmış.',
    ),
    ChildMemoryItem(
      islandNumber: 4,
      islandName: 'Arlong Reef',
      itemName: 'Deniz Kabuğu Bileklik',
      itemIcon: '🐚',
      emotionalDescription: 'Kumsalda el ele yürürken topladığınız sedefli taşlardan yaptığı bileklik.',
      findingStory: 'Mercan resifinin hemen kıyısında, dalgaların nazikçe okşadığı kumların içindeydi.',
    ),
    ChildMemoryItem(
      islandNumber: 5,
      islandName: 'Drum Peak',
      itemName: 'Yünlü Kış Eldiveni',
      itemIcon: '🧤',
      emotionalDescription: 'Zirvedeki soğuk rüzgardan ellerini koruyan kırmızı pofuduk eldiven.',
      findingStory: 'Kardelen çiçeklerinin açtığı karlı kayanın üzerinde sıcacık duruyordu.',
    ),
    ChildMemoryItem(
      islandNumber: 6,
      islandName: 'Alabasta Sands',
      itemName: 'Sarı Kum Saati Kolye',
      itemIcon: '⏳',
      emotionalDescription: 'Zamanın ve mesafelerin sevginizi asla tüketemeyeceğinin küçük hatırası.',
      findingStory: 'Çöl vahasındaki serin su kaynağının kıyısında parıldıyordu.',
    ),
    ChildMemoryItem(
      islandNumber: 7,
      islandName: 'Skypiea Ruins',
      itemName: 'Beyaz Melek Tüyü',
      itemIcon: '🪶',
      emotionalDescription: 'Gökyüzü adasının beyaz bulutlarından kopmuş, umut dolu hafif bir tüy.',
      findingStory: 'Antik tapınağın çan kulesinde, rüzgara meydan okurcasına duruyordu.',
    ),
    ChildMemoryItem(
      islandNumber: 8,
      islandName: 'Water Seven Bay',
      itemName: 'Ahşap Oyuncak Yelkenli',
      itemIcon: '⛵',
      emotionalDescription: 'Kendi minik elleriyle boyadığı ve sizinle birlikte yüzdürmeyi hayal ettiği tekne.',
      findingStory: 'Kanal sularında sakince yüzüyor, sanki sizi bekliyordu.',
    ),
    ChildMemoryItem(
      islandNumber: 9,
      islandName: 'Sabaody Grove',
      itemName: 'Rengarenk Balon İpi',
      itemIcon: '🧵',
      emotionalDescription: 'Uçan balon demetinden kopan ipeksi bağ. Hedefe artık çok az kaldı!',
      findingStory: 'Dev mangrov köklerinin arasına dolanmış, yukarıyı işaret ediyordu.',
    ),
    ChildMemoryItem(
      islandNumber: 10,
      islandName: 'Wano Zirvesi',
      itemName: 'Küçük Yavrunuz & Balon Demeti!',
      itemIcon: '🎈👶🎈',
      emotionalDescription: 'BÜYÜK FİNAL! Uçan balonlar ve lavlar arasından kurtarılan biricik evladınız.',
      findingStory: 'Zirvede gözyaşları ve kahkahalar içinde sarıldınız. Aile yeniden bir arada!',
    ),
  ];
}
