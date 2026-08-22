# VetTrack

VetTrack, evcil hayvan sahipleri ile veteriner klinikleri arasındaki takip ve iletişim süreçlerini tek bir platformda birleştiren bir veteriner takip uygulamasıdır. Proje, ULUTEK Yazılım Vadisi Staj Programı kapsamında Ekip 1 tarafından geliştirilmiştir.

## Proje amacı

VetTrack; evcil hayvanların sağlık bilgilerinin, ziyaret ve tedavi geçmişlerinin düzenli biçimde saklanmasını, veteriner hekimlerin klinik süreçleri yönetmesini ve kullanıcıların ihtiyaç duydukları bilgilere kolayca erişmesini amaçlar.

Uygulama, yapay zekâ destekli genel bilgilendirme sunar ancak veteriner hekimin klinik değerlendirmesinin yerine geçmez.

## Platformlar

### Android mobil uygulama

Flutter ile geliştirilen mobil uygulama, ağırlıklı olarak evcil hayvan sahiplerinin kullanımına yöneliktir. Kullanıcılar:

- Profil ve evcil hayvan bilgilerini yönetebilir.
- Hayvan fotoğrafı ekleyebilir.
- Ziyaret, tedavi ve öneri geçmişini görüntüleyebilir.
- Gemini tabanlı yapay zekâ asistanını kullanabilir.
- Bildirimleri ve planlanan tedavileri takip edebilir.

### Web uygulaması

Flutter Web uygulaması, özellikle veteriner hekim ve klinik personeli akışlarını destekler. Kullanıcılar:

- Klinik ve üyelik süreçlerini yönetebilir.
- Hasta ve hayvanları kodla arayabilir.
- Ziyaret başlatıp kapatabilir.
- Tedavi ve veteriner önerileri ekleyebilir.
- Ziyaret geçmişini inceleyebilir.

## Temel modüller

- Kimlik doğrulama ve rol bazlı yetkilendirme
- Klinik ve üyelik yönetimi
- Evcil hayvan ve sahip profili yönetimi
- Ziyaret ve hasta takip süreçleri
- Tedavi, aşı, operasyon ve ilaç kayıtları
- Veteriner önerileri
- Yapay zekâ destekli sohbet asistanı
- Firebase Cloud Messaging bildirimleri
- Fotoğraf ve dosya depolama

## Teknolojiler

### Frontend

- Dart ve Flutter
- Flutter BLoC
- GoRouter
- Dio
- Supabase Flutter
- Firebase Core ve Firebase Messaging
- GetIt
- Google Sign-In
- Flutter Secure Storage
- Image Picker / Image Cropper
- fl_chart

### Backend

- Java 17
- Spring Boot 4.1
- Spring Web MVC
- Spring Data JPA / Hibernate
- Spring Security ve OAuth2 Resource Server
- PostgreSQL ve Supabase
- Flyway
- Google Gemini API
- Firebase Admin SDK
- Redis ve Caffeine
- OpenAPI / Swagger UI
- Sentry

## Proje yapısı

```text
frontend/   Flutter Android ve Web uygulaması
backend/    Spring Boot REST API
docs/       API, mimari ve entegrasyon dokümantasyonu
```

Frontend, özellik bazlı Clean Architecture yaklaşımıyla; backend ise modüler REST API yaklaşımıyla yapılandırılmıştır.

## Dokümantasyon

- [`docs/PROJECT_DOCUMENTATION.md`](docs/PROJECT_DOCUMENTATION.md) — mimari, modüller, güvenlik ve test yaklaşımı
- [`docs/api-contract.md`](docs/api-contract.md) — API endpoint'leri, roller ve hata kodları
- [`docs/openapi.yaml`](docs/openapi.yaml) — OpenAPI tanımı
- [`docs/AI_INTEGRATION_GUIDE.md`](docs/AI_INTEGRATION_GUIDE.md) — Gemini entegrasyonu ve AI güvenliği

## Proje durumu

VetTrack; evcil hayvan sahipleri, veteriner hekimler ve klinik personeli için mobil ve web istemcileri bulunan modüler bir uygulama projesidir.
