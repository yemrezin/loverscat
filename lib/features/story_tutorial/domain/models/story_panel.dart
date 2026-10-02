/// Model for narrative cinematic panels of "Aşkın Uçan Rotası".
class StoryPanel {
  final int step;
  final String title;
  final String illustrationIcon;
  final String imageAssetPath;
  final String subtitle;
  final String quote;

  const StoryPanel({
    required this.step,
    required this.title,
    required this.illustrationIcon,
    required this.imageAssetPath,
    required this.subtitle,
    required this.quote,
  });

  static const List<StoryPanel> introPanels = [
    StoryPanel(
      step: 1,
      title: 'Huzurlu Ada Sabahı',
      illustrationIcon: '🐻🧺🎈',
      imageAssetPath: 'assets/images/story_bear_family.jpg',
      subtitle: 'Sıradan, güneşli bir ada sabahıydı... Anne ve baba ayı çimenlerde huzurla otururken, küçük kızları ellerinde parlak kırmızı kalp balonuyla neşeyle gülümsüyordu.',
      quote: '"Aşk dolu, sıcacık bir ada sabahı... Ta ki kaderin rüzgarı esene kadar."',
    ),
    StoryPanel(
      step: 2,
      title: 'Mistik Rüzgar & Kırmızı Balon',
      illustrationIcon: '🌪️🎈👧',
      imageAssetPath: 'assets/images/story_bear_floating.jpg',
      subtitle: 'Aniden esen büyülü bir rüzgar, küçük kızın kırmızı kalp balonunu göğe doğru kaldırdı! Kız çocuğu balona sıkıca tutunarak ufuktaki gizemli adalara doğru süzülmeye başladı.',
      quote: '"Anne ve baba ayı endişeyle gökyüzüne baktı; biricik kızları ufukta kayboluyordu!"',
    ),
    StoryPanel(
      step: 3,
      title: 'Büyük Kurtarma Yolculuğu',
      illustrationIcon: '⛵🤝💖',
      imageAssetPath: 'assets/images/story_bear_boat.jpg',
      subtitle: 'Anne ve baba ayı hiç tereddüt etmeden küçük teknelerine atladılar ve el ele tutuştular. 10 adalık tehlikeli denizi aşk sorularıyla aşacak ve kızlarını kurtaracaklar!',
      quote: '"Ne kadar uzak olursa olsun, sevgimizin gücüyle seni kurtaracağız!"',
    ),
  ];
}
