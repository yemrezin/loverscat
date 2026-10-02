# ⚡ Oyun Motorsuz Mobil Geliştirme: Mimari ve FPS Optimizasyon Rehberi

Bu doküman, "Aşkın Uçan Rotası" projesinin harici bir oyun motoru (Unity, Unreal, Godot vb.) kurulmadan saf mobil çatılarıyla (Flutter, React Native, Swift/Kotlin) geliştirilmesi durumunda ortaya çıkacak performans risklerini, FPS darboğazlarını ve teknik çözüm mimarisini açıklar.

---

## 🛑 1. Neden Standart UI İle FPS Düşer? (Darboğaz Analizi)

Mobil uygulamaların standart UI mantığı (Flutter Widget'ları, React Native JSX, Android XML/Compose) statik veya düşük hareketli ekranlar için tasarlanmıştır.

| Problem | Standart UI Davranışı | Sonuç |
| :--- | :--- | :--- |
| **Render Ağacı (Rebuild Loop)** | Her karede nesnelerin koordinatı değiştikçe tüm ağaç baştan hesaplanır. | CPU %100 kullanıma ulaşır, ısınma ve anlık takılma başlar. |
| **Hitbox & Çarpışma** | Çarpışma kontrolleri UI katmanında manuel döngülerle yapılır. | Hızlı hareket eden nesneler (örn: Air Hokey diski) engellerin içinden geçer (tunneling). |
| **Garbage Collection (GC)** | Saniyede 60 kare boyunca yeni state/objeler üretilip çöpe atılır. | Bellek temizleyici devreye girdiğinde yarım saniyelik mikro donmalar (jank) oluşur. |
| **Thread Kilitlenmesi** | UI mantığı ile oyun lojiği aynı iş parçacığında (Main Thread) yarışır. | Dokunmatik gecikmesi (input lag) tavan yapar. |

---

## 🎯 2. Mini-Game Risk & Performans Matrisi

| Mini-Game | Standart UI (Widget/View) | Canvas / Hafif Paket (Flame vb.) | FPS Riski Derecesi |
| :--- | :--- | :--- | :--- |
| **1. Üstten Top Atma** | Sorunsuz çalışır | Pürüzsüz | 🟢 Düşük |
| **2. Okçuluk Düellosu** | Ok yay animasyonu takılabilir | Akıcı | 🟡 Orta |
| **3. Air Hokey** | Disk yüksek hızda kare atlar | 60 FPS sabit kalır | 🔴 Yüksek |
| **4. Bomba Paslamaca** | Sorunsuz çalışır | Pürüzsüz | 🟢 Düşük |
| **5. Hafıza Oyunu** | Sorunsuz çalışır | Pürüzsüz | 🟢 Düşük |
| **6. Labirentte Saklambaç** | Görüş sisi (Fog of War) yavaşlatır | Shader/Masking ile hızlı | 🟡 Orta |
| **7. Ateş ve Su** | Platform zıplamaları sert ve yapay kalır | Fizik optimizasyonuyla akıcı | 🔴 Yüksek |
| **8. Lazer & Ayna** | Açı yansımalarında hafif gecikme | Matematiksel ışın takibi hızlı | 🟡 Orta |
| **9. Raylı Maden Arabası** | Zemin akışı ve engeller arayüzü kilitler | Sprite batching ile 60 FPS | 🔴 Yüksek |
| **10. Lavdan Kaçış (Final)** | İp esnemesi ve lav partikülleri çöker | Verlet Entegrasyonu ile stabil | 🚨 Kritik |

---

## 🛠️ 3. Çözüm Stratejisi: Hibrit Mimari Yaklaşımı

Oyun motoru programı indirmeden akıcı performans almak için en ideal model **Hibrit Mimari**'dir:

```
[ Trivia / Soru-Cevap Ekranı ] ➔ Standart Mobil UI (Hızlı, temiz, kolay formlar)
              │
              ▼
[ Ada Geçişi & Mini-Game ]   ➔ Tek Bir Çizim Yüzeyi (Hardware Accelerated Canvas)
```

### Altın Kurallar (Motorsuz 60 FPS Almak İçin):

1. **Doğrudan GPU Çizimi (Canvas / CustomPainter):**
   * Oyun nesnelerini ayrı component/widget yapmak yerine, tek bir `Canvas` bileşeni üzerinde piksel bazlı çizdirin.
2. **Ekran Yenileme Senkronizasyonu (Ticker / vsync):**
   * Asla `Timer.periodic` veya `setInterval` kullanmayın; doğrudan ekranın donanım tazeleme frekansına bağlanan `Ticker` mekanizmasını kullanın.
3. **Bellek Havuzlama (Object Pooling):**
   * Lav damlaları, oklar veya maden yolu taşları için sürekli yeni nesne üretmeyin. Önceden oluşturulmuş 20 nesneyi ekran dışına çıktıkça başa sarıp tekrar kullanın.
4. **Hafif Kod Kütüphanesi Desteği (Örn: Flutter + Flame):**
   * Ağır bir editör kullanmak istemiyorsanız, saf kod paketi olan **Flame** (Flutter için) veya **Phaser.js** (Web/Capacitor için) kullanarak Canvas yönetimini ve 2D çarpışmaları optimize edilmiş hazır C/C++ motorlarına havale edin.

---

## 📋 Geliştirici Tavsiyesi (Karar Özeti)

* **Trivia ve Menüler:** Kesinlikle standart mobil UI ile yazılmalıdır (Geliştirme süresini %70 kısaltır).
* **Fizik Gerektiren Oyunlar (3, 7, 9, 10):** Standart widget'larla zorlanmamalı; doğrudan `Canvas` çizimi veya hafif kod tabanlı bir 2D oyun kütüphanesi (Flutter kullanılıyorsa `Flame`, React Native kullanılıyorsa `Skia / React Native Game Engine`) tercih edilmelidir.