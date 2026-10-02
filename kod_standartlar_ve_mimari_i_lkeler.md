# 📐 Yazılım Mimarisi, Kod Standartları ve Kalite İlkeleri

Bu doküman; "Aşkın Uçan Rotası" projesinin sürdürülebilir, modüler, test edilebilir ve yüksek performanslı kalmasını sağlamak amacıyla uyulması gereken **SOLID prensiplerini**, **kod paket/dosya boyutu kısıtlamalarını** ve **anti-spagetti kurallarını** tanımlar.

---

## 📏 1. Dosya Boyutu ve Kapsam Kuralı (500 Satır Limiti)

Proje genelinde okunabilirliği korumak ve "God Object" (her işi tek başına yapan devasa sınıflar) oluşumunu engellemek için aşağıdaki kurallar zorunludur:

* **Maksimum 500 Satır Sınırı:** Hiçbir kaynak kod dosyası (`.dart`, `.ts`, `.js`, `.kt`, `.swift` vb.) **500 satırı geçemez**.
* **Erken Uyarı (Refactor Eşiği):** Bir dosya 350-400 satır aralığına ulaştığında alarm verilmeli, bölünme planı yapılmalı; 500 satıra ulaştığında derhal alt bileşenlere (sub-components, helper, controller, service) parçalanmalıdır.
* **UI ve Mantık İzolasyonu:** Tek bir dosyada hem UI hiyerarşisi hem veri çekme hem de mini-game oyun mantığı kesinlikle bir arada bulunamaz.

---

## 🏛️ 2. SOLID Prensiplerine Uyum

Tüm sistem bileşenleri, veri akışları ve mini-game modülleri SOLID prensiplerine uygun inşa edilir:

### S — Single Responsibility Principle (Tek Sorumluluk Prensibi)
* Her sınıf, servis veya modül yalnızca tek bir sorumluluğa sahip olmalıdır.
* **Kural:** Bir mini-game sınıfı aynı anda hem skoru yönetip hem ses efekti çalıp hem de Canvas çizimi yapamaz.
  * Çizim işlemleri: `GameRenderer`
  * Skor/Tur yönetimi: `MiniGameScoreManager`
  * Ses tetikleyicileri: `AudioEffectService`

### O — Open/Closed Principle (Açık/Kapalı Prensibi)
* Sınıflar genişletilmeye (extension) açık, ancak kaynak kod değişikliğine (modification) kapalı olmalıdır.
* **Kural:** Yeni bir ada veya mini-game eklendiğinde rota ve navigasyon sistemi baştan yazılmamalıdır. Ortak bir `MiniGameContract` / `MiniGameBase` arayüzü implement edilerek yeni oyun sisteme dinamik olarak enjekte edilebilmelidir.

### L — Liskov Substitution Principle (Liskov Yerine Geçme Prensibi)
* Alt sınıflar, türedikleri üst sınıfın veya arayüzün tüm sözleşmelerini bozmadan yerine geçebilmelidir.
* **Kural:** `MiniGameBase` sınıfından türeyen `AirHockeyController` ve `MemoryMatchController`, aynı yaşam döngüsü metodlarını (`initialize()`, `onUpdate(dt)`, `onRender()`, `dispose()`) beklenen yan etkisiz biçimde sunmalıdır.

### I — Interface Segregation Principle (Arayüz Ayrımı Prensibi)
* İstemciler (sınıflar), kullanmadıkları metodları içeren şişkin arayüzleri uygulamaya zorlanmamalıdır.
* **Kural:** Yalnızca dokunma girdisi alan bir mini-game'e jiroskop veya fizik çarpışma arayüzü zorunlu kılınamaz. Arayüzler atomik olmalıdır:
  * `ITouchInputHandler`
  * `IPhysicsBody`
  * `ITickable`

### D — Dependency Inversion Principle (Bağımlılıkların Tersi Çevrilmesi)
* Üst seviye modüller alt seviye modüllere doğrudan sıkı sıkıya bağlı olmamalıdır; her iki taraf da soyutlamalara (abstract class / interface) dayanmalıdır.
* **Kural:** Seyir/Trivia yöneticisi doğrudan yerel SQLite ya da spesifik bir API paketine bağlanmaz; `IQuestionRepository` arayüzü üzerinden veri talep eder.

---

## 🍝 3. Spagetti Kodu Önleme ve Mimari Disiplin

Spagetti kod; kontrolsüz bağımlılıklar, iç içe geçmiş mantıklar ve kontrolsüz global durumlar nedeniyle projenin genişletilemez hale gelmesidir. Bunu önlemek için uygulanacak kurallar:

### 1. Durum Yönetimi (State Separation)
* UI bileşenleri yalnızca bir "gözlemci"dir (Observer). Ekranda hiçbir iş mantığı, matematiksel çarpışma hesabı veya doğrudan veri mutasyonu yürütülmez.
* Model (Veri) ➔ Controller/Bloc/ViewModel (Mantık) ➔ View (Salt Görsel Sunum) akışı katı bir şekilde korunur.

### 2. Global Değişken ve "God Object" Yasağı
* Proje genelinde dağınık, kontrolsüz global değişkenler tanımlanamaz.
* Tüm servis ve bağımlılıklar **Dependency Injection (DI)** ya da merkezi **Service Locator** desenleri aracılığıyla sağlanır.

### 3. Katı Modüler Klasör Hiyerarşisi
Her mini-game tamamen kendi izole klasöründe yaşar ve dışarıya yalnızca kendi ana giriş noktasını açar:

```text
lib/
├── core/                   # Tüm projenin paylaştığı ortak yapılar
│   ├── network/            # HTTP / WebSocket istemcileri
│   ├── contracts/          # SOLID arayüzleri (IMiniGame, IRepository)
│   ├── math/               # Vektör hesapları, çarpışma algoritmaları
│   └── theme/              # Renk, tipografi ve ortak stiller
├── features/
│   ├── sailing_trivia/     # Seyir evresi ve soru-cevap modülü
│   │   ├── controllers/
│   │   ├── models/
│   │   └── views/
│   └── minigames/          # Mini-game modülleri (tamamen izole)
│       ├── game_01_top_atma/
│       │   ├── controllers/
│       │   ├── logic/      # 500 satırı aşmayacak bölünmüş kurallar
│       │   └── views/
│       └── game_10_lav_tirmanis/
│           ├── controllers/
│           ├── physics/    # İp ve sıçrama fiziği motoru
│           └── views/
```

### 4. Game Loop Performans Disiplini
* `onUpdate(double dt)` gibi her karede (saniyede 60-120 kez) çalışan fonksiyonların içinde:
  * Kesinlikle yeni nesne oluşturulamaz (`new Vector2()`, yeni liste tanımlama vb.).
  * Bellek tahsisi yasaktır; tüm değişkenler önceden havuzlanır (**Object Pooling**).
  * Ağır I/O, veritabanı okuması veya JSON parse işlemi çalıştırılamaz.

### 5. Temiz İsimlendirme ve Kendini Açıklayan Kod
* Tek harfli veya belirsiz değişken isimleri (`a`, `temp`, `flag2`, `doWork()`) kabul edilmez.
* Kod kendini açıklayacak netlikte olmalıdır: `isBallCollidingWithWall`, `calculateTensionForce()`, `remainingRoundTimeSeconds`.