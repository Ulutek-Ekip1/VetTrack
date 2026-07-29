# VetTrack API Sözleşmesi

> **Sürüm:** 1.0  
> **Tarih:** 29 Temmuz 2026  
> **Dayanak:** VetTrack PRD v1.0 + 4 Haftalık Yol Haritası  
> **Teknik detay:** `docs/openapi.yaml` (Swagger UI ile görüntülenebilir)

## Genel kurallar

- Tüm korumalı endpoint'ler `Authorization: Bearer <JWT>` header'ı ister.
- JSON alan isimleri **camelCase** formatındadır (`ownerId`, `uniqueCode`, `createdAt`).
- Tarih/saat alanları ISO 8601 formatındadır, UTC (`2026-07-29T14:32:11Z`).
- ID'ler UUID formatındadır.
- Liste endpoint'leri yeniden eskiye (DESC) sıralı döner.
- Tüm hatalar aynı formatta döner (aşağıdaki "Hata formatı" bölümüne bakın).

## Hata formatı (tüm endpoint'ler için geçerli)

```json
{
  "status": 400,
  "error": "VALIDATION_ERROR",
  "message": "name alanı zorunludur",
  "timestamp": "2026-07-29T14:32:11Z"
}
```

| Alan | Tip | Açıklama |
|---|---|---|
| `status` | Integer | HTTP status kodu |
| `error` | String | Makine-okunur hata kodu (UPPER_SNAKE_CASE) |
| `message` | String | İnsan-okunur mesaj (Türkçe) |
| `timestamp` | String | Hatanın zamanı (ISO 8601) |

### Hata kodu tablosu

| Kod | Status | Açıklama | PRD |
|---|---|---|---|
| `VALIDATION_ERROR` | 400 | Zorunlu alan eksik veya format hatalı | — |
| `UNAUTHORIZED` | 401 | JWT eksik veya geçersiz | — |
| `INVALID_CREDENTIALS` | 401 | E-posta veya şifre hatalı | FR-01 |
| `FORBIDDEN` | 403 | Rol yetkisiz (owner/vet_staff ayrımı) | FR-02 |
| `EDIT_WINDOW_EXPIRED` | 403 | 15 dakikalık düzenleme süresi doldu | EC-08 |
| `NOT_FOUND` | 404 | Kayıt bulunamadı | — |
| `PET_NOT_FOUND` | 404 | Kod ile arama sonuçsuz | EC-01 |
| `EMAIL_ALREADY_EXISTS` | 409 | E-posta zaten kayıtlı | FR-01 |
| `VISIT_ALREADY_OPEN` | 409 | Hayvanın açık ziyareti var | EC-02 |
| `VISIT_ALREADY_CLOSED` | 409 | Ziyaret zaten kapatılmış | — |
| `VISIT_CLOSED` | 409 | Kapalı ziyarete giriş/öneri yapılamaz | — |
| `FILE_TOO_LARGE` | 413 | Dosya 15MB sınırını aşıyor | EC-06 |
| `UNSUPPORTED_FILE_TYPE` | 415 | Sadece JPEG, PNG, WebP kabul edilir | EC-06 |

---

## Endpoint özeti (20 endpoint)

| # | Method | Path | Açıklama | Rol |
|---|---|---|---|---|
| 1 | POST | `/auth/register` | Kayıt ol | Herkese açık |
| 2 | POST | `/auth/login` | Giriş yap | Herkese açık |
| 3 | POST | `/auth/forgot-password` | Şifre sıfırlama | Herkese açık |
| 4 | GET | `/auth/me` | Mevcut kullanıcı bilgisi | owner, vet_staff |
| 5 | POST | `/pets` | Hayvan ekle | owner |
| 6 | GET | `/pets` | Sahibin hayvanları | owner |
| 7 | GET | `/pets/{id}` | Hayvan detayı | owner |
| 8 | PUT | `/pets/{id}` | Hayvan güncelle | owner |
| 9 | POST | `/pets/{id}/photo` | Fotoğraf yükle | owner |
| 10 | GET | `/pets/{id}/visits` | Hayvanın ziyaret geçmişi | owner |
| 11 | GET | `/pets/{id}/recommendations` | Hayvanın önerileri | owner |
| 12 | GET | `/visits/code/{code}` | Kod ile hasta bul | vet_staff |
| 13 | POST | `/visits` | Yeni ziyaret başlat | vet_staff |
| 14 | PUT | `/visits/{id}/close` | Ziyareti kapat | vet_staff |
| 15 | POST | `/visits/{visitId}/treatments` | Tedavi girişi ekle | vet_staff |
| 16 | GET | `/visits/{visitId}/treatments` | Ziyaretin tedavileri | owner, vet_staff |
| 17 | PUT | `/treatments/{id}` | Tedavi düzenle (15 dk) | vet_staff |
| 18 | DELETE | `/treatments/{id}` | Tedavi sil (15 dk) | vet_staff |
| 19 | POST | `/visits/{visitId}/recommendations` | Öneri gir | vet_staff |
| 20 | GET | `/notifications` | Bildirim listesi | owner |
| 21 | PUT | `/notifications/{id}/read` | Okundu işaretle | owner |
| 22 | POST | `/devices/register` | FCM token kaydet | owner |

---

## Auth modülü

### POST /auth/register — Kayıt ol

**Kim:** Herkese açık. **PRD:** FR-01, FR-02.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `email` | String (email) | Evet | E-posta adresi |
| `password` | String (min 8) | Evet | Şifre |
| `name` | String (1-100) | Evet | Ad soyad |
| `phone` | String (max 20) | Hayır | Telefon |
| `role` | Enum | Evet | `owner` veya `vet_staff` |

**Response (201):**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "v1.MjQ1...",
  "expiresIn": 3600,
  "user": {
    "id": "550e8400-...",
    "authId": "660e8400-...",
    "email": "ayse@example.com",
    "name": "Ayşe Yılmaz",
    "phone": "+905551234567",
    "role": "owner",
    "createdAt": "2026-07-29T14:32:11Z"
  }
}
```

**Hatalar:** 400 (validation), 409 (`EMAIL_ALREADY_EXISTS`)

---

### POST /auth/login — Giriş yap

**Kim:** Herkese açık. **PRD:** FR-01.

**Request body:**

| Alan | Tip | Zorunlu |
|---|---|---|
| `email` | String (email) | Evet |
| `password` | String | Evet |

**Response (200):** `AuthResponse` (register ile aynı format)

**Hatalar:** 400, 401 (`INVALID_CREDENTIALS`)

---

### POST /auth/forgot-password — Şifre sıfırlama

**Kim:** Herkese açık. **PRD:** US-15.

**Request body:**

| Alan | Tip | Zorunlu |
|---|---|---|
| `email` | String (email) | Evet |

**Response (200):**

```json
{ "message": "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi" }
```

> Not: E-posta kayıtlı olmasa bile 200 döner (güvenlik gereği).

---

### GET /auth/me — Mevcut kullanıcı bilgisi

**Kim:** JWT gerekli (her iki rol). **PRD:** FR-02.

**Response (200):**

```json
{
  "id": "550e8400-...",
  "authId": "660e8400-...",
  "email": "ayse@example.com",
  "name": "Ayşe Yılmaz",
  "phone": "+905551234567",
  "role": "owner",
  "createdAt": "2026-07-29T14:32:11Z"
}
```

---

## Pets modülü

### POST /pets — Yeni hayvan ekle

**Kim:** Sadece `owner`. **PRD:** FR-03, FR-04.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `name` | String (1-100) | Evet | Hayvan adı |
| `age` | Integer (0-50) | Hayır | Yaş, null olabilir |
| `gender` | Enum | Evet | `male`, `female`, `unknown` |
| `breed` | String (max 100) | Hayır | Cins, null olabilir |

**Response (201):** `PetResponse`

**Hatalar:** 400, 401, 403

> Not: `uniqueCode` request'te alınmaz — sistem 6 haneli kod üretir (FR-04).

---

### GET /pets — Sahibin hayvanları

**Kim:** Sadece `owner`. **PRD:** FR-13.

**Response (200):** `PetResponse[]`

> Not: Soft-deleted hayvanlar döndürülmez (EC-05).

---

### GET /pets/{id} — Hayvan detayı

**Kim:** Sadece hayvanın sahibi. **PRD:** FR-03.

**Response (200):** `PetResponse`

**Hatalar:** 401, 403 (başkasının hayvanı), 404

---

### PUT /pets/{id} — Hayvan güncelle

**Kim:** Sadece hayvanın sahibi. **PRD:** FR-03.

**Request body:** `PetCreateRequest` ile aynı alanlar, hepsi opsiyonel. `uniqueCode` ve `photoUrl` güncellenemez.

**Response (200):** `PetResponse`

---

### POST /pets/{id}/photo — Fotoğraf yükle

**Kim:** Sadece hayvanın sahibi. **PRD:** FR-09.

**Content-Type:** `multipart/form-data`

**Form alanı:** `file` — image/jpeg, image/png veya image/webp, max 15MB

**Response (200):**

```json
{ "photoUrl": "https://xxx.supabase.co/storage/v1/pets/abc123.jpg" }
```

**Hatalar:** 401, 403, 404, 413 (`FILE_TOO_LARGE`), 415 (`UNSUPPORTED_FILE_TYPE`)

---

### PetResponse şeması

```json
{
  "id": "550e8400-...",
  "ownerId": "660e8400-...",
  "name": "Boncuk",
  "age": 3,
  "gender": "male",
  "breed": "Golden Retriever",
  "uniqueCode": "7K4R9M",
  "photoUrl": "https://xxx.supabase.co/storage/v1/pets/abc.jpg",
  "createdAt": "2026-07-29T14:32:11Z"
}
```

---

## Visits modülü

### GET /visits/code/{code} — Kod ile hasta bul

**Kim:** Sadece `vet_staff`. **PRD:** FR-05, EC-01.

**Path param:** `code` — 6 haneli kod (case-insensitive, boşluk temizlenir)

**Response (200):** `PetResponse` + iç içe `visits[]` (her biri `treatments[]` ve `recommendations[]` dahil)

```json
{
  "id": "...",
  "name": "Boncuk",
  "uniqueCode": "7K4R9M",
  "visits": [
    {
      "id": "...",
      "vetStaffName": "Dr. Mehmet Yılmaz",
      "status": "completed",
      "startedAt": "...",
      "endedAt": "...",
      "treatments": [...],
      "recommendations": [...]
    }
  ]
}
```

**Hatalar:** 401, 403, 404 (`PET_NOT_FOUND`)

> Not: Benzer kod önerisi sunulmaz — güvenlik gereği (EC-01).

---

### GET /pets/{id}/visits — Hayvanın ziyaret geçmişi (sahip tarafı)

**Kim:** Sadece hayvanın sahibi (`owner`). **PRD:** US-04.

**Response (200):** `VisitDetailResponse[]` — yeniden eskiye sıralı, tedaviler ve öneriler dahil

---

### POST /visits — Yeni ziyaret başlat

**Kim:** Sadece `vet_staff`. **PRD:** FR-06, EC-02.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `petId` | UUID | Evet | Hayvan ID'si |

**Response (201):** `VisitResponse`

**Hatalar:** 400, 401, 403, 404, 409 (`VISIT_ALREADY_OPEN`)

> Not: `vetStaffId` JWT'den çıkarılır. `status` otomatik `ongoing`, `startedAt` otomatik şu an.

---

### PUT /visits/{id}/close — Ziyareti kapat

**Kim:** Ziyareti başlatan `vet_staff`. **PRD:** FR-06.

**Request body:** Yok.

**Response (200):** `VisitResponse` (status: `completed`, endedAt dolu)

**Hatalar:** 401, 403, 404, 409 (`VISIT_ALREADY_CLOSED`)

> Not: Kapatma anında sahibe FCM push bildirimi asenkron tetiklenir (FR-10).

---

### VisitResponse şeması

```json
{
  "id": "...",
  "petId": "...",
  "vetStaffId": "...",
  "status": "ongoing",
  "startedAt": "2026-07-29T14:32:11Z",
  "endedAt": null
}
```

### VisitDetailResponse şeması

```json
{
  "id": "...",
  "vetStaffId": "...",
  "vetStaffName": "Dr. Mehmet Yılmaz",
  "status": "completed",
  "startedAt": "...",
  "endedAt": "...",
  "treatments": [...],
  "recommendations": [...]
}
```

---

## Treatments modülü

### POST /visits/{visitId}/treatments — Tedavi girişi ekle

**Kim:** Sadece `vet_staff`. **PRD:** FR-07, FR-10.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `type` | Enum | Evet | `medication`, `xray`, `lab_result`, `note` |
| `title` | String (1-200) | Evet | Kısa başlık |
| `description` | String | Hayır | Detaylı açıklama |
| `attachmentUrl` | String (URI) | Hayır | Supabase Storage URL'si |

**Response (201):** `TreatmentEntryResponse`

**Hatalar:** 400, 401, 403, 404, 409 (`VISIT_CLOSED`)

> Not: Dosya yükleme iki adımlı — önce dosyayı Storage'a yükle, URL al, sonra bu endpoint'e gönder.

---

### GET /visits/{visitId}/treatments — Ziyaretin tedavileri

**Kim:** `vet_staff` (kendi ziyareti) veya `owner` (kendi hayvanı). **PRD:** FR-07.

**Response (200):** `TreatmentEntryResponse[]`

---

### PUT /treatments/{id} — Tedavi düzenle (15 dk pencere)

**Kim:** Kaydı giren `vet_staff`, sadece 15 dakika içinde. **PRD:** EC-08.

**Request body:** Tüm alanlar opsiyonel (type, title, description, attachmentUrl).

**Response (200):** `TreatmentEntryResponse`

**Hatalar:** 400, 401, 403 (`EDIT_WINDOW_EXPIRED`), 404

---

### DELETE /treatments/{id} — Tedavi sil (15 dk pencere)

**Kim:** Kaydı giren `vet_staff`, sadece 15 dakika içinde. **PRD:** EC-08.

**Response:** `204 No Content`

**Hatalar:** 401, 403 (`EDIT_WINDOW_EXPIRED`), 404

> Not: Hard delete + denetim izi (audit log) tutulur.

---

### TreatmentEntryResponse şeması

```json
{
  "id": "...",
  "visitId": "...",
  "type": "medication",
  "title": "Amoksisilin 250mg",
  "description": "Günde 2 kez, 7 gün süreyle",
  "attachmentUrl": "https://xxx.supabase.co/.../rontgen.jpg",
  "enteredBy": "...",
  "editable": true,
  "createdAt": "2026-07-29T14:32:11Z"
}
```

> `editable`: `true` ise 15 dakikalık pencere açık — düzenle/sil butonları gösterilir.

---

## Recommendations modülü

### POST /visits/{visitId}/recommendations — Öneri gir

**Kim:** Sadece `vet_staff`. **PRD:** FR-08.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `type` | Enum | Evet | `food`, `litter`, `other` |
| `description` | String | Evet | Öneri açıklaması |

**Response (201):** `RecommendationResponse`

**Hatalar:** 400, 401, 403, 404, 409 (`VISIT_CLOSED`)

---

### GET /pets/{id}/recommendations — Hayvanın tüm önerileri

**Kim:** Sadece hayvanın sahibi (`owner`). **PRD:** US-07.

**Response (200):** `RecommendationDetailResponse[]`

```json
{
  "id": "...",
  "visitId": "...",
  "vetStaffName": "Dr. Mehmet Yılmaz",
  "type": "food",
  "description": "Royal Canin Gastrointestinal, günde 2 öğün, 200g",
  "createdAt": "2026-07-29T14:32:11Z"
}
```

---

## Notifications modülü

### GET /notifications — Bildirim listesi

**Kim:** Sadece `owner`. **PRD:** FR-11.

**Query params:**

| Param | Tip | Varsayılan | Açıklama |
|---|---|---|---|
| `page` | Integer | 0 | Sayfa numarası |
| `size` | Integer | 20 | Sayfa başına bildirim (max 50) |

**Response (200):**

```json
{
  "content": [
    {
      "id": "...",
      "ownerId": "...",
      "treatmentEntryId": "...",
      "title": "Boncuk için yeni tedavi kaydı",
      "body": "Dr. Mehmet Yılmaz tarafından ilaç kaydı girildi",
      "isRead": false,
      "sentAt": "2026-07-29T14:32:11Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 47,
  "totalPages": 3
}
```

---

### PUT /notifications/{id}/read — Okundu işaretle

**Kim:** Bildirim sahibi (`owner`). **PRD:** FR-11.

**Response (200):** `NotificationResponse` (`isRead: true`)

> Not: İdempotent — zaten okunmuşsa tekrar 200 döner.

---

## Devices modülü

### POST /devices/register — FCM token kaydet

**Kim:** Sadece `owner`. **PRD:** FR-12.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `fcmToken` | String | Evet | Firebase token |
| `platform` | Enum | Evet | `ios`, `android` |

**Response (200):** `DeviceTokenResponse`

> Not: İdempotent — aynı owner + token varsa sessizce 200 döner. `ownerId` JWT'den çıkarılır.

---

## Rol-endpoint matrisi (FR-02)

| Endpoint | owner | vet_staff | Açık |
|---|---|---|---|
| POST /auth/register | — | — | ✅ |
| POST /auth/login | — | — | ✅ |
| POST /auth/forgot-password | — | — | ✅ |
| GET /auth/me | ✅ | ✅ | — |
| POST /pets | ✅ | — | — |
| GET /pets | ✅ | — | — |
| GET /pets/{id} | ✅ | — | — |
| PUT /pets/{id} | ✅ | — | — |
| POST /pets/{id}/photo | ✅ | — | — |
| GET /pets/{id}/visits | ✅ | — | — |
| GET /pets/{id}/recommendations | ✅ | — | — |
| GET /visits/code/{code} | — | ✅ | — |
| POST /visits | — | ✅ | — |
| PUT /visits/{id}/close | — | ✅ | — |
| POST /visits/{visitId}/treatments | — | ✅ | — |
| GET /visits/{visitId}/treatments | ✅ | ✅ | — |
| PUT /treatments/{id} | — | ✅ | — |
| DELETE /treatments/{id} | — | ✅ | — |
| POST /visits/{visitId}/recommendations | — | ✅ | — |
| GET /notifications | ✅ | — | — |
| PUT /notifications/{id}/read | ✅ | — | — |
| POST /devices/register | ✅ | — | — |

---

## Bekleyen teknik kararlar

1. **V2 migration gerekli:** `owners` ve `vet_staff` tablolarına `auth_id` (UUID) kolonu eklenmeli — Supabase Auth kullanıcısıyla eşleşme için.
2. **EC-05 soft delete:** `pets` tablosuna `deleted_at` kolonu eklenmeli.
3. **EC-08 audit log:** Tedavi silme/düzenleme denetim izi için `audit_logs` tablosu veya `treatment_entries`'e `updated_at` kolonu.
4. **Dosya yükleme akışı:** Tedavi eki (röntgen/tahlil) nasıl yüklenecek? Ayrı bir `POST /uploads` endpoint'i mi, yoksa frontend doğrudan Supabase Storage SDK'sıyla mı yükleyecek?
