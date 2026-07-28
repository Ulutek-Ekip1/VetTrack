# VetTrack Frontend (Flutter)

Bu proje VetTrack sisteminin Flutter Web ve Mobil frontend uygulamasıdır.

## 🚀 Proje Yapısı (Clean Architecture)

```
lib/
├── core/                  # Ortak servisler, altyapı, tema, router, hata yönetimi
└── features/              # Özellik bazlı Clean Architecture modülleri
    ├── auth/              # Giriş & Kayıt ve Rol Yönetimi
    ├── pet/               # Hayvan Yönetimi (Sahip Tarafı)
    ├── visit/             # Ziyaret & Hasta Bulma (Web Doktor Paneli)
    ├── treatment/         # Tedavi Girişi & Zaman Çizelgesi
    ├── recommendation/    # Öneri Modülü (Mama, kum, bakım)
    └── notification/      # Anlık Bildirimler (FCM)
```

## 🛠 Kurulum ve Çalıştırma

1. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
2. `.env` dosyasını oluşturun ve gerekli anahtarları doldurun.
3. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```
