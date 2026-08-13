# VetTrack - Kapsamlı Proje Dokümantasyonu ve Mimari Rehberi

Bu doküman, `VetTrack` (Veteriner Takip ve Yapay Zeka Asistanı) sisteminin tüm backend ve frontend mimarisini, veritabanı şemasını, API uç noktalarını, güvenlik mekanizmalarını ve kurulum talimatlarını kapsamaktadır.

---

## 📋 İçindekiler
1. [Sözleşme ve Teknoloji Yığını](#-teknoloji-yığını)
2. [Sistem Mimarisi ve Modüller](#-sistem-mimarisi-ve-modüller)
3. [Yapay Zeka (AI Chatbot) Modülü](#-yapay-zeka-ai-chatbot-modülü)
4. [Veritabanı Şeması ve Flyway Migrasyonları (V1 - V7)](#-veritabanı-şeması-ve-flyway-migrasyonları)
5. [API Uç Noktaları Dokümantasyonu (REST Endpoints)](#-api-uç-noktaları-dokümantasyonu)
6. [Güvenlik, CORS ve Rate Limiting](#-güvenlik-cors-ve-rate-limiting)
7. [Zamanlanmış Görevler ve FCM Push Bildirimleri](#-zamanlanmış-görevler-ve-fcm-push-bildirimleri)
8. [Ortam Değişkenleri (.env) ve Kurulum Rehberi](#-ortam-değişkenleri-ve-kurulum-rehberi)
9. [Test Stratejisi ve Çalıştırma](#-test-stratejisi-ve-çalıştırma)

---

## 🛠️ Teknoloji Yığını

### Backend
- **Dil / Çerçeve**: Java 17, Spring Boot 3.3.x
- **Veritabanı**: PostgreSQL (Supabase tabanlı), H2 (Test ortamı)
- **Veritabanı Geçiş Yönetimi**: Flyway Migration (V1 - V7)
- **Güvenlik & Doğrulama**: Spring Security, OAuth2 Resource Server (JWT), JWKS
- **Yapay Zeka Servisi**: Google Gemini REST API (`gemini-2.5-flash`)
- **Önbellek & Sınırlama**: Caffeine Cache (Rate Limiting)
- **Bildirim Servisi**: Firebase Admin SDK (FCM Push Notifications)

### Frontend
- **Dil / Çerçeve**: Dart, Flutter (Web ve Mobil uyumlu)

---

## 🏛️ Sistem Mimarisi ve Modüller

Proje backend tarafında `com.vettrack.api` kök paketi altında modüler bir mimariye sahiptir:

```
com.vettrack.api
├── ai              # Google Gemini AI Chatbot, Acil Durum Bypass & Bağlam Servisi
├── auth            # JWT Kimlik Doğrulama & Kullanıcı Giriş/Kayıt İşlemleri
├── config          # Security, CORS, RateLimiting, GeminiConfig, Exception Handlers
├── notification    # FCM Push Bildirimleri & Scheduled Treatment Notifier
├── owner           # Pet Sahibi Profil Yönetimi
├── pet             # Evcil Hayvan Kayıt, Güncelleme, Soft-Delete & Fotoğraf Yükleme
├── recommendation  # Veteriner Hekim Bakım & Mama/Egzersiz Tavsiye Servisi
├── storage         # Dosya ve Fotoğraf Depolama Servisi
├── treatment       # Tedavi, Aşı, Operasyon & İlaç Zamanlama Kayıtları
└── visit           # Muayene ve Ziyaret Süreç Yönetimi
```

---

## 🤖 Yapay Zeka (AI Chatbot) Modülü

Yapay zeka asistanı kedinizin/evcil hayvanınızın klinik geçmişini otomatik algılayarak soru-cevap hizmeti sunar.

### Ana Bileşenler:
1. **`EmergencySafetyService`**: 
   - Solunum krizleri, zehirlenme, durmayan kanama ve travma durumlarını **<5 ms** sürede tespit eder.
   - Yapay zeka çağrısını bypass ederek anında acil klinik ve ilk yardım uyarısı döner (`emergency: true`, `ruleVersion: v1.2-emergency`).
   - Prompt Injection ifadelerini (`"önceki talimatları yok say"` vb.) temizler.
2. **`PetContextService`**:
   - Kullanıcının sistemdeki kedisini/pet'ini otomatik bulur.
   - Irk, yaş, cinsiyet ve veritabanındaki son 10 aktif tedavi/aşı kaydını çekerek doğal dil formatında Gemini'ye sistem bağlamı olarak iletir.
3. **`GeminiService`**:
   - `geminiRestClient` üzerinden Google Gemini REST API'ye istek atar.
   - 10s bağlantı ve 30s okuma zaman aşımı (timeout) korumasına sahiptir.
   - Güvenlik ve Prompt Injection spoofing engelleme amacıyla istemciden gelen sohbet geçmişi yok sayılır; model bağlamı yalnızca sunucunun veritabanından güvenli biçimde derlenir.
4. **`AiChatService`**:
   - **Sahiplik & Bütünlük Kontrolü**: `petId` ve `conversationId` parametrelerini doğrulayarak oturum/pet tutarlılığını garanti eder (Yetkisiz erişimde HTTP 403).
   - **Atomik Idempotency & DB Kısıtı**: İstemciden gelen `clientMessageId` yalnızca kullanıcı mesajlarına uygulanır. Veritabanındaki `UNIQUE(owner_id, client_message_id)` çakışmalarında HTTP 500 yerine veritabanı kısıt hatası yakalanıp önbellekteki yanıt döndürülür. İstemci farklı içerikle aynı key kullanırsa HTTP 409 Conflict döner.
   - **Kalıcılık**: Mesajlar `chat_messages` tablosuna saklanır.

---

## 🗄️ Veritabanı Şeması ve Flyway Migrasyonları

- **`V1__init.sql`**: `owners`, `pets`, `visits`, `treatment_entries`, `recommendations`, `device_tokens`, `notifications` tablolarının oluşturulması.
- **`V2__add_soft_delete.sql`**: Pet tablosuna `deleted_at` sütununun eklenmesi.
- **`V3__add_owner_surname_address.sql`**: Kullanıcı soyadı ve adres sütunları.
- **`V4__add_treatment_status_dates.sql`**: Tedavi durumları (`PLANNED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`) ve başlangıç/bitiş tarihleri.
- **`V5__idempotent_schema_fixes.sql`**: Şema iyileştirmeleri.
- **`V7__add_chat_messages_table.sql`**: Yapay zeka sohbet tablosu:
  - Sütunlar: `id`, `conversation_id`, `client_message_id`, `owner_id`, `pet_id`, `role`, `content`, `is_emergency`, `model_name`, `prompt_version`, `created_at`.
  - Atomik Kısıt: `CONSTRAINT uq_owner_client_message UNIQUE (owner_id, client_message_id)`.

---

## 🔌 API Uç Noktaları Dokümantasyonu

Tüm korumalı uç noktalar `Authorization: Bearer <JWT_TOKEN>` başlığı gerektirir.

### 1. Yapay Zeka (AI) API
- **`POST /api/ai/chat`** (veya `/ai/chat`): Yapay Zeka ile sohbet eder.
  - Request: `{ "conversationId": "UUID", "clientMessageId": "String", "petId": "UUID", "message": "String" }`
  - Response: `{ "messageId": "UUID", "conversationId": "UUID", "emergency": false, "reply": "String", "disclaimer": "String", "model": "gemini-2.5-flash", "promptVersion": "v1.2-mvp", "createdAt": "Timestamp" }`
- **`GET /api/ai/chat/history?page=0&limit=50`**: Genel sohbet geçmişini sayfalamalı getirir.
- **`GET /api/ai/chat/history/{petId}?page=0&limit=50`**: Pet bazlı sohbet geçmişini getirir.
- **`DELETE /api/ai/chat/history/conversation/{conversationId}`**: Belirli bir konuşmayı siler (KVKK).
- **`DELETE /api/ai/chat/history`**: Tüm sohbet geçmişini siler (KVKK Unutulma Hakkı).

---

## 🔒 Güvenlik, CORS ve Rate Limiting

- **JWT Doğrulama**: Supabase JWKS vasıtasıyla gelen isteklerin JWT doğrulaması yapılır.
- **Dinamik CORS (`SecurityConfig.java`)**: Flutter Web uygulamasının Chrome üzerinde açtığı herhangi bir porttan (`http://localhost:*`, `http://127.0.0.1:*`) gelen isteklere dinamik CORS izni verilir.
- **Rate Limiter (`RateLimitingFilter.java`)**:
  - Hem `/api/ai/chat` hem de `/ai/chat` uç noktaları için **10 RPM (Dakikada 10 İstek)** sınırı uygulanır.
  - Sınır aşıldığında HTTP 429 Too Many Requests yanıtı ve `Retry-After: 60` başlığı dönülür.

---

## 🚀 Ortam Değişkenleri ve Kurulum Rehberi

### Ortam Değişkenleri Şablonu (`backend/.env.example`)
*NOT: Güvenlik politikaları gereği gerçek API anahtarları veya veritabanı parolaları dokümantasyonlarda ve sürümlenen dosyalarda ASLA saklanmaz.*

```env
# Supabase Database
SUPABASE_DB_URL=jdbc:postgresql://<YOUR_SUPABASE_HOST>:6543/postgres?prepareThreshold=0
SUPABASE_DB_USER=<YOUR_DB_USER>
SUPABASE_DB_PASSWORD=<YOUR_DB_PASSWORD>
SUPABASE_JWKS_URL=https://<YOUR_SUPABASE_PROJECT>.supabase.co/auth/v1/.well-known/jwks.json
SUPABASE_JWT_ISSUER=https://<YOUR_SUPABASE_PROJECT>.supabase.co/auth/v1
SUPABASE_STORAGE_URL=https://<YOUR_SUPABASE_PROJECT>.supabase.co/storage/v1
SUPABASE_SERVICE_KEY=<YOUR_SUPABASE_SERVICE_KEY>
SUPABASE_URL=https://<YOUR_SUPABASE_PROJECT>.supabase.co

# Firebase Credentials
FIREBASE_CREDENTIALS_PATH=./firebase-service-account.json

# Server
PORT=8080

# Gemini AI
GEMINI_API_KEY=<YOUR_GEMINI_API_KEY>
GEMINI_MODEL=gemini-2.5-flash
```

### Projeyi Çalıştırma

#### 1. Backend (Spring Boot)
```powershell
cd C:\Users\yagmu\OneDrive\VetTrack.git\VetTrack\backend
.\run.ps1
```

#### 2. Frontend (Flutter)
```powershell
cd C:\Users\yagmu\OneDrive\VetTrack.git\VetTrack\frontend
flutter pub get
flutter run -d chrome
```

---

## 🧪 Test Stratejisi ve Çalıştırma

```powershell
cd C:\Users\yagmu\OneDrive\VetTrack.git\VetTrack\backend
.\mvnw.cmd test "-Dtest=EmergencySafetyServiceTest,PetContextServiceTest,GeminiServiceMockTest,Phase2IntegrationTest"
```
*(Tüm testler `BUILD SUCCESS` ve 0 hata ile tamamlanmaktadır).*
