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
   cd frontend
   flutter pub get
   ```
2. `.env` dosyasını oluşturun (`.env.example` şablonundan kopyalayabilirsiniz):
   ```bash
   cp .env.example .env
   ```
3. Uygulamayı `.env` yapılandırması ile çalıştırın:
   * **Doğrudan Staging Backend ile Çalıştırma:**
     ```bash
     flutter run --dart-define-from-file=.env
     ```
   * **Web (Chrome) için:**
     ```bash
     flutter run -d chrome --dart-define-from-file=.env --web-port=3000
     ```
   * **Mobil (Android Emülatör) için:**
     ```bash
     flutter run -d emulator-5554 --dart-define-from-file=.env
     ```

> **Not:** `AppConstants.apiBaseUrl` varsayılan olarak canlı Staging Backend'e (`https://vettrack-staging-a0fb.up.railway.app`) ayarlıdır. Lokal backend üzerinde geliştirme yapmak isterseniz `.env` dosyanızda `API_BASE_URL=http://localhost:8080` (veya emülatör için `http://10.0.2.2:8080`) tanımlayabilirsiniz.
