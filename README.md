# 🐾 Paws & Us - Çiftler İçin Kedi Temalı Bilgi Yarışması

Flutter kullanılarak geliştirilmiş, dikey (portrait) modda çalışan, pastel görsel stile ve 60 FPS akıcı vektörel animasyonlara sahip çift yarışması mobil uygulaması.

---

## 🌸 Özellikler

### 1. 3 Aşamalı Oyun Döngüsü (State Machine)
- **1. Adım ("Kendini Anlat"):** Her iki taraf da sırayla kendi cevabını seçer ve mühürler. Pass-and-play gizlilik perdesi sayesinde telefon el değiştirirken cevaplar asla sızmaz.
- **2. Adım ("Zihin Okuma"):** *"Sence o ne cevap verdi?"* — Partnerler birbirlerinin kilitlediği cevapları tahmin eder.
  - **🕊️ Kuşlar Fısıldasın Jokeri:** Her 10 doğru tahminde +1 joker kazanılır. Minik kuş kulağınıza sevgilinizin mühürlediği cevabı fısıldar!
- **3. Adım ("Kedi Yargısı"):** Yargıç Kedi kararı açıklar:
  - **İkisi de bildiyse:** Kediye melek kanatları çıkar, göklere uçar, altın hale parıldar ve pastel konfetiler patlar! Aşk serisine (streak) +1 eklenir.
  - **Sadece biri bilemediyse:** Kedi bilemeyen oyuncuya dönüp ekrana pati tokatı indirir (`HapticFeedback.heavyImpact()`), ekran sallanır (`ScreenShakeWidget`).
  - **İkisi de bilemediyse:** Kedi kaşlarını çatar, dumanlar tüterek iki patiyle ekrana tokat atar!

### 2. Özel Quiz Oluşturucu (Custom Quiz Builder)
- Kullanıcılar ilişkiye özel sorular ekleyebilir.
- Soru türleri: **Çoktan Seçmeli (4 Şık)** veya **Açık Uçlu (Kısa Metin)**.
- `SharedPreferences` ile JSON formatında yerel depolamada saklanır.
- 12 adet hazır, eğlenceli ve denenmiş çift sorusu ile birlikte gelir.

---

## 🏛️ Mimari & SOLID Prensipleri

- **Single Responsibility Principle (SRP):**
  - UI bileşenleri sadece çizim ve kullanıcı etkileşiminden sorumludur.
  - Kedi tepkileri bağımsız `CatJudgeEngine` sınıfı tarafından hesaplanır.
  - Skor, streak ve joker takibi `QuizGameNotifier` içindedir.
- **Open/Closed & Dependency Inversion (OCP & DIP):**
  - Veri akışı `IQuizRepository` arayüzü ile soyutlanmıştır.
  - Şimdilik `LocalMockQuizRepository` kullanılır. İleride WebSocket veya Firebase eklendiğinde domain veya UI kodunda tek bir satır dahi değiştirilmez.
- **State Management:**
  - `flutter_riverpod` ile reaktif ve context-bağımsız durum yönetimi.
- **Görsel Dil & 60 FPS Animasyonlar:**
  - Harici ağır asset bağımlılıkları olmadan doğrudan Flutter `CustomPainter` ve `AnimationController` ile çizilen vektörel kedi ve kuş grafikleri.
  - Pastel pembe (`#FFD1DC`), lavanta (`#E6E6FA`), adaçayı/nane (`#D8F3DC`), krem zemin (`#FAF0F2`) ve koyu mor/kahve tipografi (`#4A4453`).

---

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         // Pastel renk paleti
│   │   └── app_strings.dart        // Türkçe metinler & kedi replikleri
│   ├── theme/
│   │   └── app_theme.dart          // 20px yuvarlak köşeli yumuşak tema
│   └── utils/
│       └── haptic_utils.dart       // Ağır & hafif haptic bildirimleri
├── features/
│   ├── quiz/
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── question.dart         // QuizQuestion & QuestionType
│   │   │   │   ├── round_answer.dart     // RoundAnswer, PlayerId, GamePhase
│   │   │   │   ├── cat_reaction.dart     // CatReaction & CatReactionType
│   │   │   │   └── game_state.dart       // QuizGameState
│   │   │   └── repositories/
│   │   │       └── i_quiz_repository.dart // IQuizRepository arayüzü
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── default_questions.dart // 12 adet varsayılan soru
│   │   │   └── repositories/
│   │   │       └── mock_quiz_repository.dart // SharedPreferences JSON repo
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── cat_judge_engine.dart  // SRP Kedi Yargıç Motoru
│   │       │   ├── quiz_game_notifier.dart // 3 adımlı durum makinesi
│   │       │   └── quiz_providers.dart    // Riverpod sağlayıcıları
│   │       ├── screens/
│   │       │   ├── home_screen.dart       // Karşılama ve maskot ekranı
│   │       │   ├── quiz_play_screen.dart  // Ana oyun ekranı (3 adım döngüsü)
│   │       │   └── quiz_builder_screen.dart // Özel soru ekleme ekranı
│   │       └── widgets/
│   │           ├── cat_display_widget.dart      // 60 FPS Vektörel Kedi Animasyonu
│   │           ├── screen_shake_widget.dart     // Tokat ekran sarsıntısı
│   │           ├── whispering_bird_button.dart  // Kuş jokeri & ipucu diyaloğu
│   │           ├── answer_input_card.dart       // Şıklar & açık metin girdisi
│   │           ├── confetti_overlay_widget.dart // Konfeti kutlaması
│   │           └── turn_transition_overlay.dart // Pass-and-play gizlilik perdesi
│   └── custom_quiz/
│       └── presentation/
│           └── custom_questions_sheet.dart      // Eklenen soruları yönetme/silme
└── main.dart                                    // Portrait lock & ProviderScope
```

---

## 🚀 Çalıştırma

Gereksinimler: Flutter SDK (>= 3.0.0).

```bash
# Paketleri indir
flutter pub get

# Testleri çalıştır
flutter test

# Uygulamayı başlat (Android / iOS / Web / Desktop)
flutter run
```
