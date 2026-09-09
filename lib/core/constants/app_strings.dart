/// Turkish localized strings for "Paws & Us"
class AppStrings {
  AppStrings._();

  // General App Info
  static const String appName = 'Paws & Us';
  static const String appSubtitle = 'Çiftler İçin Kedi Temalı Bilgi Yarışması 🐾';

  // Home Screen
  static const String startGame = 'Oyuna Başla 🎮';
  static const String createCustomQuiz = 'Kendi Sorunu Ekle ✍️';
  static const String howToPlay = 'Nasıl Oynanır? 📖';
  static const String coupleStreak = 'Aşk Serisi (Streak)';
  static const String birdWhispersAvailable = 'Kuş Fısıltısı Jokeri';

  // Rules / Explanation
  static const String rulesTitle = 'Nasıl Oynanır?';
  static const String step1Title = '1. Kendini Anlat';
  static const String step1Desc = 'Her iki taraf da sırayla kendi cevabını seçer ve mühürler. Kimse diğerinin cevabını göremez!';
  static const String step2Title = '2. Zihin Okuma';
  static const String step2Desc = 'Şimdi sevgilinin ne cevap verdiğini tahmin etme zamanı! Her 10 doğru tahminde bir Kuş Fısıltısı jokeri kazanırsınız.';
  static const String step3Title = '3. Kedi Yargısı';
  static const String step3Desc = 'Yargıç Kedi sonuçları açıklar! İkiniz de bildiyseniz uçar, biri bilemediyse pati tokatı atar, ikiniz de bilemediyseniz ekranı sarsarak öfkelenir!';

  // Step 1: Kendini Anlat
  static const String step1Header = '1. Adım: Kendini Anlat 🤫';
  static const String step1Subheader = 'Kendi cevabını belirle ve kimseye göstermeden mühürle!';
  static const String sealButton = 'Cevabımı Mühürle 🐾';
  static const String waitingPartnerToSeal = 'Cevabın kilitlendi! Sıradaki oyuncu bekleniyor...';

  // Step 2: Zihin Okuma
  static const String step2Header = '2. Adım: Zihin Okuma 🔮';
  static const String step2Question = 'Sence o ne cevap verdi?';
  static const String submitGuessButton = 'Tahmini Kilitle 🎯';
  static const String birdHintButton = 'Kuşlar Fısıldasın 🕊️';
  static const String birdHintUsed = 'Kuş Fısıldadı!';
  static const String noBirdHints = 'Henüz Kuş Fısıltın yok! (Her 10 doğru tahminde 1 hak)';

  // Step 3: Kedi Yargısı
  static const String step3Header = '3. Adım: Kedi Yargısı ⚖️';
  static const String nextQuestionButton = 'Sonraki Soru ➡️';
  static const String finishGameButton = 'Oyunu Tamamla 🏆';

  // Cat Reactions
  static const String catReactionBothCorrect = 'Miyavv! Ruh eşi misiniz nesiniz?! 😇';
  static const String catReactionP1Wrong = 'Oyuncu 1 sevgilisini hiç tanımıyor! Çaaat! 😾💥';
  static const String catReactionP2Wrong = 'Oyuncu 2 fena çuvalladı! Al sana pati! 😾💥';
  static const String catReactionBothWrong = 'İkiniz de birbirinizi dinlemiyor musunuz?! ÇİFT PATİ TOKATI! 😾💥🐾';

  // Pass Turn Barrier
  static const String passPhoneTitle = 'Telefonu Sevgiline Ver! 📱';
  static const String passPhoneDesc = 'Gözlerini kapat ve telefonu sıradaki oyuncuya uzat. Kopya çekmek kesinlikle yasaktır!';
  static const String readyButton = 'Hazırım, Ben Aldım! ✨';

  // Quiz Builder
  static const String builderTitle = 'Soru Oluşturucu ✍️';
  static const String questionInputHint = 'Sorunu buraya yaz... (Örn: En sevdiğim tatil aktivitesi nedir?)';
  static const String questionTypeLabel = 'Soru Türü:';
  static const String typeMultipleChoice = 'Çoktan Seçmeli (4 Şık)';
  static const String typeOpenEnded = 'Açık Uçlu (Kısa Metin)';
  static const String optionHint = 'Şık';
  static const String saveQuestionButton = 'Soruyu Kaydet 💾';
  static const String questionSavedSuccess = 'Soru başarıyla kaydedildi! 🐾';
  static const String emptyQuestionError = 'Lütfen bir soru metni girin.';
  static const String emptyOptionsError = 'Lütfen 4 şıkkı da doldurun.';
  static const String customQuestionsTitle = 'Eklenen Özel Sorular';
  static const String noCustomQuestions = 'Henüz özel soru eklenmedi. Hadi bir tane ekle!';
}
