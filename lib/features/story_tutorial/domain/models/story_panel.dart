/// Model for narrative cinematic panels of "Aşkın Uçan Rotası".
class StoryPanel {
  final int step;
  final String title;
  final String illustrationIcon;
  final String subtitle;
  final String quote;
  final String backgroundGlowColorHex;

  const StoryPanel({
    required this.step,
    required this.title,
    required this.illustrationIcon,
    required this.subtitle,
    required this.quote,
    this.backgroundGlowColorHex = '0x33FFB703',
  });

  static const List<StoryPanel> introPanels = [
    StoryPanel(
      step: 1,
      title: 'Huzurlu Başlangıç',
      illustrationIcon: '🏝️🧺🎈',
      subtitle: 'Sıradan, güneşli bir ada sabahıydı... İki sevgili piknik yaparken kahkahalar atıyor, küçük çocukları ise elinde devasa bir uçan balon demetiyle neşeyle koşturuyordu.',
      quote: '"Sıradan, güneşli bir ada sabahıydı... Ta ki gökyüzü uyanana kadar."',
    ),
    StoryPanel(
      step: 2,
      title: 'Beklenmedik Fırtına',
      illustrationIcon: '🌪️⚡🎈👶',
      subtitle: 'Gökyüzü aniden büyülü bir mor parıltıyla titredi. Mistik Uyum Denizi\'nin rüzgarları esti ve balon demetine sarıldı. Çocuk iplere sıkıca tutunmuş halde göğe doğru yükseldi!',
      quote: '"Mistik Uyum Denizi\'nin rüzgarları, küçük çocuğu gökyüzüne doğru fırlattı!"',
    ),
    StoryPanel(
      step: 3,
      title: 'Ufuktaki Hedef',
      illustrationIcon: '🌋🗺️🧭',
      subtitle: 'Çocuk balonlarla birlikte ufukta beliren, dumanları tüten son ada olan Wano Zirvesi\'ne doğru sürükleniyor. 10 adalık tehlikeli bir rota önünüzde uzanıyor!',
      quote: '"İzler gökyüzünde, tehlike ise en uçtaki lav püskürten zirvede!"',
    ),
    StoryPanel(
      step: 4,
      title: 'Yola Çıkış',
      illustrationIcon: '⛵🤝💖',
      subtitle: 'İki sevgili sahildeki pedallı küçük tekneye atlıyor, el ele tutuşuyorlar. Uyum sorularıyla yelkenleri şişirip adaları tek tek aşacak ve çocuklarını kurtaracaklar!',
      quote: '"Ne kadar uzak olursa olsun, seni birlikte geri alacağız!"',
    ),
  ];
}
