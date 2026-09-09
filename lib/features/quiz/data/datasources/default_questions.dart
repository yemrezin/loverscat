import '../../domain/models/question.dart';

/// Predefined list of at least 10 high-quality, authentic couple questions.
final List<QuizQuestion> defaultQuizQuestions = [
  const QuizQuestion(
    id: 'default_1',
    text: 'Pazar sabahı uyandığında sevgilinin ilk yapmak isteyeceği şey nedir?',
    type: QuestionType.multipleChoice,
    options: [
      'Sıcacık bir kahve yapıp battaniyeye sarılmak ☕',
      'Öğlene kadar yatakta dönüp uyumaya devam etmek 😴',
      'Mükellef bir kahvaltı hazırlamak 🍳',
      'Hemen üstünü giyinip dışarı yürüyüşe çıkmak 👟',
    ],
  ),
  const QuizQuestion(
    id: 'default_2',
    text: 'Sevgilin sinirlendiğinde onu en hızlı ne sakinleştirir?',
    type: QuestionType.multipleChoice,
    options: [
      'Sevdiği tatlıyı/yemeği önüne koymak 🍰',
      'Sessizce sarılıp saçını okşamak 🫂',
      'Biraz kendi haline bırakıp alan tanımak 🧘',
      'Komik kedi videoları açıp güldürmeye çalışmak 🐱',
    ],
  ),
  const QuizQuestion(
    id: 'default_3',
    text: 'Birlikte tatile çıksanız onun hayalindeki tatil hangisi olurdu?',
    type: QuestionType.multipleChoice,
    options: [
      'Deniz kenarında sakin bir butik otel ve gün batımı 🌅',
      'Doğanın içinde ahşap dağ evi ve şömine başı 🪵',
      'Avrupa sokaklarında günde 20.000 adım keşif turu ✈️',
      'Her şey dahil otelde şezlongdan kalkmama keyfi 🍹',
    ],
  ),
  const QuizQuestion(
    id: 'default_4',
    text: 'Akşam birlikte izleyecek bir şey ararken onun ilk tercihi ne olur?',
    type: QuestionType.multipleChoice,
    options: [
      'Sürükleyici bir suç/gizem dizisi 🕵️‍♂️',
      'Romantik komedi veya iç ısıtan film 🍿',
      'Nostaljik Harry Potter veya Yüzüklerin Efendisi maratonu 🧙‍♂️',
      'Gülmekten karnımızı ağrıtacak bir sit-com 📺',
    ],
  ),
  const QuizQuestion(
    id: 'default_5',
    text: 'Issız bir adaya düşsek onun en çok özleyeceği şey ne olurdu?',
    type: QuestionType.multipleChoice,
    options: [
      'Kesintisiz hızlı internet ve telefonu 📱',
      'Sıcak duş ve yumuşacık yatağı 🛏️',
      'Kahve ve tatlı krizleri 🍫',
      'Kendi kendine kaldığı sessiz anlar 🌙',
    ],
  ),
  const QuizQuestion(
    id: 'default_6',
    text: 'Sevgilinin telefonunda en çok vakit geçirdiği uygulama hangisidir?',
    type: QuestionType.multipleChoice,
    options: [
      'Instagram (Reels izleme bağımlılığı) 📸',
      'TikTok veya YouTube shorts 🎥',
      'Twitter (X) veya haber takibi 🐦',
      'WhatsApp ve sohbetler 💬',
    ],
  ),
  const QuizQuestion(
    id: 'default_7',
    text: 'Yemek siparişi verirken asla vazgeçemediği favori mutfak hangisi?',
    type: QuestionType.multipleChoice,
    options: [
      'Bol peynirli çıtır pizza 🍕',
      'Ev yapımı lezzetinde sulu burger 🍔',
      'Sushi ve Asya lezzetleri 🍣',
      'Döner, lahmacun veya kebap 🥙',
    ],
  ),
  const QuizQuestion(
    id: 'default_8',
    text: 'En tahammül edemediği ev işi/küçük aksaklık nedir?',
    type: QuestionType.multipleChoice,
    options: [
      'Bulaşık makinesini boşaltmak 🍽️',
      'Çorapların oraya buraya atılması 🧦',
      'Çöpü kapıya çıkarmak 🗑️',
      'Yatak örtüsünün düzeltilmemesi 🛌',
    ],
  ),
  const QuizQuestion(
    id: 'default_9',
    text: 'Piyangodan büyük ikramiye çıksa ilk alacağı veya yapacağı şey nedir?',
    type: QuestionType.multipleChoice,
    options: [
      'Dünya turu bileti almak 🌍',
      'Kedili, bahçeli müstakil bir ev satın almak 🏡',
      'İşinden istifa edip aylarca dinlenmek 🏖️',
      'Tüm hayalindeki teknolojik aletleri sepete eklemek 💻',
    ],
  ),
  const QuizQuestion(
    id: 'default_10',
    text: 'Bir hayvan olsaydı sence tam olarak hangi hayvana benzerdi?',
    type: QuestionType.multipleChoice,
    options: [
      'Günde 16 saat uyuyan şımarık ev kedisi 🐱',
      'Sürekli ilgi ve sevgi bekleyen heyecanlı golden köpek 🐶',
      'Kendi dünyasında gezen tatlı bir panda 🐼',
      'Geceleri aktif, meraklı bir baykuş 🦉',
    ],
  ),
  const QuizQuestion(
    id: 'default_11',
    text: 'Sevgilinin en sevdiği şarkı türü veya onu mest eden müzik nedir?',
    type: QuestionType.openEnded,
  ),
  const QuizQuestion(
    id: 'default_12',
    text: 'İlişkimizin ilk başladığı günlere dair en unutamadığı anı nedir?',
    type: QuestionType.openEnded,
  ),
];
