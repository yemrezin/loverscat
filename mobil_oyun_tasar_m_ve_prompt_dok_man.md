# 🎮 Proje: Aşkın Uçan Rotası (Co-Op / Çift Oyunu)

Bu doküman, çiftler için geliştirilen soru-cevap ve mini-game odaklı mobil oyunun hikaye, dünya tasarımı, oyun döngüsü ve öğretici (tutorial) kurgusunu içeren temel tasarım ve yapay zeka prompt şablonudur.

---

## 📖 1. Giriş Hikayesi (Sinematik / Panel Akışı)

* **Panel 1: Huzurlu Başlangıç**
  * *Görsel:* Güneşli, tropik bir ada sahili. İki sevgili piknik yaparken kahkahalar atıyor. Küçük çocukları ise elinde rengarenk, devasa bir uçan balon demetiyle neşeyle koşturuyor.
  * *Metin:* *"Sıradan, güneşli bir ada sabahıydı... Ta ki gökyüzü uyanana kadar."*

* **Panel 2: Beklenmedik Fırtına**
  * *Görsel:* Gökyüzü aniden büyülü bir mor/mavi parıltıyla titriyor. Mistik bir ada rüzgarı esip balon demetini sarıyor. Çocuk iplere sıkıca tutunmuş halde rüzgarla birlikte göğe doğru yükseliyor.
  * *Metin:* *"Mistik Uyum Denizi'nin rüzgarları, küçük çocuğu gökyüzüne doğru fırlattı!"*

* **Panel 3: Ufuktaki Hedef**
  * *Görsel:* Kamera gökyüzünden uzaklaşıyor; çocuk balonlarla birlikte ufukta beliren, dumanları tüten son ada olan *Wano Zirvesi*'ne doğru sürükleniyor.
  * *Metin:* *"İzler gökyüzünde, tehlike ise en uçtaki lav püskürten zirvede!"*

* **Panel 4: Yola Çıkış**
  * *Görsel:* İki sevgili sahildeki pedallı küçük tekneye atlıyor, el ele tutuşuyorlar. Kararlı yüz ifadeleri.
  * *Metin:* *"Ne kadar uzak olursa olsun, seni birlikte geri alacağız!"*

---

## 🔄 2. Temel Oyun Döngüsü (Core Game Loop)

```
[Deniz Seyri: Soru-Cevap (Trivia)] ➔ [Rüzgar/Enerji Doldurma] ➔ [Adaya Varış] ➔ [Ada Mini-Game] ➔ [İpucu/İlerleme] ➔ [Bir Sonraki Ada]
```

1. **Deniz Seyri (Trivia / Soru-Cevap):**
   * Adalar arasında yol alırken tekne durur ya da yavaşlar.
   * Yelkenlerin rüzgarla dolması için çiftler soru cevaplar:
     * *Genel Kültür / Refleks Soruları:* Hızlı yanıt veren ek puan alır.
     * *Çift Uyumu Soruları:* İki tarafın da birbiri hakkındaki sorulara aynı yanıtı vermesi gerekir ("Eşinin en sevdiği renk ne?", "İlk nerede tanıştınız?").
2. **Ada Aşaması (Mini-Game):**
   * Her ada çocuğun düşürdüğü bir eşyaya ev sahipliği yapar (şapka, ayakkabı, oyuncak ayı vb.).
   * Ada geçişi için mini-game başarıyla tamamlanmalıdır (bazıları 1v1 tatlı rekabet, bazıları tam co-op iş birliği).

---

## 🏝️ 3. Adalar ve Mini-Game Listesi (10 Ada Konsepti)

| Ada No | Ada Adı (Esinlenme) | Mini-Game | Oynanış Tipi | Açıklama & Kontroller |
| :---: | :--- | :--- | :---: | :--- |
| **1** | **Shells Cove** | Üstten Top Atma | 1v1 (Rekabet) | Sütunlara yukarıdan top bırakma mantığı. İlk 5'liyi oluşturan veya potaya 5 top sokan kazanır. |
| **2** | **Syrup Woods** | Okçuluk Düellosu | 1v1 (Rekabet) | Rüzgar açısını ve mesafesini ayarlayarak hareketli hedefleri vurma mücadelesi. |
| **3** | **Baratie Coast** | Air Hokeyi | 1v1 (Rekabet) | Hızlı refleks testi. Parmakla disk kontrol edilip rakip kaleye gol atılmaya çalışılır (3 veya 5 sayıda biter). |
| **4** | **Arlong Reef** | Bomba Paslamaca (Hot Potato) | Karışık | Geri sayan saatli bomba ekranda belirir. Hızlı dokunuşlarla bomba karşı tarafa paslanır; süresi bitip patlayan kaybeder. |
| **5** | **Drum Peak** | Hafıza Oyunu (Memory Match) | Sıralı / Eşli | Kış temalı kartları sırayla çevirip sembol çiftlerini eşleştirme. |
| **6** | **Alabasta Sands** | Labirentte Saklambaç | 1v1 (Gizlilik) | Sisli çöl labirentinde kısıtlı görüş açısıyla biri saklanır/kaçmaya çalışır, diğeri haritada onu yakalamaya çalışır. |
| **7** | **Skypiea Ruins** | Ateş ve Su (Elemental Run) | Co-Op (İş Birliği) | Biri kırmızı (ateş), diğeri mavi (su) kapılarını ve butonlarını yönetir; birbirlerine yol açarak çıkışa varırlar. |
| **8** | **Water Seven Bay** | Lazer & Ayna Yönlendirme | Co-Op (Bulmaca) | Bir oyuncu lazer açısını sabitler, diğeri hareketli aynaları çevirerek ışığı hedef kristale odaklar. |
| **9** | **Sabaody Grove** | Raylı Maden Arabası | Co-Op (Senkron) | Arkadan gelen bekçi köpeğinden maden arabasıyla kaçış. Oyuncu 1 sağ-sol şerit değiştirir; Oyuncu 2 zıpla-eğil kontrolünü yapar. |
| **10** | **Wano Zirvesi (BÜYÜK FİNAL)** | Lavdan Kaçış (Bread & Fred Tipi) | Sıkı Co-Op | İki karakter birbirine iple bağlıdır. Biri kayaya tutunup diğerini fırlatır; yükselen lavlardan kaçarak zirvedeki balona asılı çocuğa ulaşırlar. |

---

## 🎓 4. Öğretici (Tutorial / Onboarding) Tasarımı

### Adım 1: Soru-Cevap & Yelken Doldurma
* **Görsel:** Tekne denizin ortasında süzülür, rüzgar çubuğu boştur.
* **Mesaj:** *"Uyum Denizi'nde ilerlemek için yelkenlerinizi bilgi ve sevginizle doldurun!"*
* **Aksiyon:** Ekrana deneme amaçlı basit bir soru gelir. Yanıtlandığında yelkenler şişer, tekne hızlanır.

### Adım 2: İlk Ada ve Kontrol Gösterimi
* **Görsel:** Tekne 1. Ada olan Shells Cove kıyısına yanaşır.
* **Mesaj:** *"Her adada çocuğumuzun bir izi var. Engelleri aşmak için hazır olun!"*
* **Animasyon:** Ekranın sağında ve solunda 2 saniyelik parmak hareketi simülasyonu gösterilir (Sütun seç ve top bırak).
* **Aksiyon:** 3-2-1 geri sayımı sonrası ilk kısa maç başlar.

### Adım 3: Büyük Hedef ve Uyum Skoru
* **Görsel:** Ada geçilince harita açılır; rota üzerindeki 10 ada ve en sondaki tüten yanardağ belirir.
* **Mesaj:** *"10 adayı aşın, puanları toplayın ve zirvede çocuğunuza kavuşun!"*
* **UI:** Ekranın üst köşesinde ortak "Uyum Puanı" ve "Tamamlanan Ada Sayacı" yerleşir.

---

## 💡 Yapay Zeka Geliştirici Prompt Şablonu

> *"Aşağıdaki oyun kurgusu için [Unity / Flutter / Godot / React Native] tabanlı bir mobil prototip tasarlıyorum. 10 adadan oluşan bu yolculukta iki kişilik (online veya tek ekranda split-screen) oynanış yapısı bulunuyor. Yukarıda tanımlanan [X]. adadaki mini-game'in temel mekanik kodlarını ve UI bileşenlerini adım adım oluştur."*