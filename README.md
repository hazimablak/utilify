# 🛠️ Utilify - The Ultimate Multipurpose Toolkit

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State_Management-blue?style=for-the-badge)

**Utilify**, günlük dijital ihtiyaçlarınızı tek bir çatı altında toplayan, modüler ve yüksek performanslı bir Flutter uygulamasıdır. İçerisinde Görsel Düzenleme, PDF İşlemleri, Yapay Zeka Destekli Ses/Çeviri Araçları ve Akıllı OCR Tarayıcı barındırır.

## ✨ Öne Çıkan Özellikler (Modüller)

### 🎨 1. Image Lab (Görsel Atölyesi)
- Fotoğraf Sıkıştırma (Pro Kalite)
- Gelişmiş Kırpma ve Düzenleme
- Yapay Zeka Arka Plan Silici
- Akıllı Bulanıklaştırma (Blur)
- Meme Maker ve Fotoğraf Filtreleri

### 📄 2. PDF Studio
- Çoklu Görselden PDF Oluşturma (Sıralama destekli)
- PDF Birleştirme
- PDF Şifreleme / Şifre Çözme
- Belirli Sayfaları Çıkartma

### 🎙️ 3. Voice & Text (Ses ve Çeviri)
- **Lingua Master:** Anında sesli veya yazılı çift yönlü çeviri (Google ML Kit).
- **Text-to-Speech:** Özelleştirilebilir hız ve ton ayarıyla metin seslendirme.
- **Transcribe (Deşifre):** Uzun konuşmaları anında metne dökme.
- **Voice Effects:** Eğlenceli ses filtreleri (Helyum, Robot, Uzaylı vb.).

### 🔍 4. OCR & Scanner (Akıllı Tarayıcı)
- **Text Recognizer:** Fotoğraflardaki metinleri saniyeler içinde kopyalanabilir yazıya çevirme.
- **QR & Barkod:** Tarama ve anında özel QR kod oluşturup galeriye indirme.
- **Business Card Scanner:** Kartvizitlerden Telefon, E-Posta ve Web Sitesi ayıklama (Regex & ML Kit).
- **Çeviri Kamerası:** Yabancı metinleri fotoğraflayıp anında Türkçe'ye çevirme.

---

## 🏗️ Mimari ve Klasör Yapısı (Clean Architecture)
Bu proje, sürdürülebilirliği sağlamak ve kod karmaşasını önlemek adına **Clean Architecture** prensipleriyle `logic` (Provider) ve `screens` (UI) olarak ayrıştırılmış modüler bir yapıya sahiptir.

```text
lib/
 ┣ 📂 features/
 ┃ ┣ 📂 image_lab/      (logic & screens)
 ┃ ┣ 📂 pdf_studio/     (logic & screens)
 ┃ ┣ 📂 voice_text/     (logic & screens)
 ┃ ┗ 📂 ocr_scanner/    (logic & screens)
 ┣ 📂 widgets/          (Ortak bileşenler)
 ┗ 📜 main.dart         (MultiProvider ve Başlangıç)