/// Specific behavioral animations executed by the Cat Judge.
enum CatReactionType {
  idle,
  angelWings,
  slapPlayer1,
  slapPlayer2,
  doublePawAngry,
}

/// Rich metadata for the Cat Judge's verdict.
class CatReaction {
  final CatReactionType type;
  final String title;
  final String subtitle;
  final bool shakeScreen;
  final bool isDoubleSlap;
  final bool showConfetti;

  const CatReaction({
    required this.type,
    required this.title,
    required this.subtitle,
    this.shakeScreen = false,
    this.isDoubleSlap = false,
    this.showConfetti = false,
  });

  static const CatReaction idle = CatReaction(
    type: CatReactionType.idle,
    title: 'Gözüm Üzerinizde! 🐾',
    subtitle: 'Cevaplarınızı dikkatli verin, pati hazır bekliyor...',
  );

  static const CatReaction bothCorrect = CatReaction(
    type: CatReactionType.angelWings,
    title: 'Miyavv! Melek Misiniz?! 😇✨',
    subtitle: 'İkiniz de birbirinizi mükemmel tanıdınız! Göklere uçuyoruz!',
    showConfetti: true,
  );

  static const CatReaction slapP1 = CatReaction(
    type: CatReactionType.slapPlayer1,
    title: 'Oyuncu 1 Çuvalladı! ÇAAT! 😾💥',
    subtitle: 'Sevgilinin cevabını hiç tahmin edemedin, al sana pati tokatı!',
    shakeScreen: true,
  );

  static const CatReaction slapP2 = CatReaction(
    type: CatReactionType.slapPlayer2,
    title: 'Oyuncu 2 Çuvalladı! ÇAAT! 😾💥',
    subtitle: 'Sevgilinin cevabını bilemedin, kedi affetmez!',
    shakeScreen: true,
  );

  static const CatReaction bothWrong = CatReaction(
    type: CatReactionType.doublePawAngry,
    title: 'İKİNİZ DE BİLEMEDİNİZ! ÇİFT PATİ! 😾💥🐾',
    subtitle: 'Birbirinizi hiç dinlemiyor musunuz siz?! İkinize de tokat!',
    shakeScreen: true,
    isDoubleSlap: true,
  );
}
