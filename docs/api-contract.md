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
| `MALFORMED_JSON` | 400 | İstek gövdesi (JSON) okunamadı veya bozuk | — |
| `UNAUTHORIZED` | 401 | JWT eksik veya geçersiz | — |
| `INVALID_CREDENTIALS` | 401 | E-posta veya şifre hatalı | FR-01 |
| `EMAIL_NOT_VERIFIED` | 401 | E-posta doğrulanmamış, giriş engellendi | FR-01 |
| `REAUTHENTICATION_REQUIRED` | 401 | JWT yeterince taze değil (son 5 dk), tekrar giriş gerekli | EC-05 |
| `FORBIDDEN` | 403 | Rol yetkisiz (owner/vet_staff ayrımı) | FR-02 |
| `ROLE_MISMATCH` | 403 | JWT rolü ile erişilen profil endpoint'i uyumsuz | FR-02 |
| `EDIT_WINDOW_EXPIRED` | 403 | 15 dakikalık düzenleme süresi doldu | EC-08 |
| `AI_CONSENT_REQUIRED` | 403 | Yapay zeka asistanı için açık rıza (opt-in) onayı gerekli | — |
| `NOT_FOUND` | 404 | Kayıt bulunamadı | — |
| `PET_NOT_FOUND` | 404 | Kod ile arama sonuçsuz | EC-01 |
| `EMAIL_ALREADY_EXISTS` | 409 | E-posta zaten kayıtlı | FR-01 |
| `CONFLICT` | 409 | Generic DB constraint ihlali (örn. EC-02'de yarış durumu) | EC-02 |
| `VISIT_ALREADY_OPEN` | 409 | Hayvanın açık ziyareti var | EC-02 |
| `VISIT_ALREADY_CLOSED` | 409 | Ziyaret zaten kapatılmış | — |
| `VISIT_CLOSED` | 409 | Kapalı ziyarete giriş/öneri yapılamaz | — |
| `FILE_TOO_LARGE` | 413 | Dosya 15MB sınırını aşıyor | EC-06 |
| `UNSUPPORTED_FILE_TYPE` | 415 | Sadece JPEG, PNG, WebP kabul edilir | EC-06 |
| `TOO_MANY_REQUESTS` | 429 | İstek limiti aşıldı (rate limit / Supabase e-posta limiti) | — |

---

## Endpoint özeti (24 endpoint)

| # | Method | Path | Açıklama | Rol |
|---|---|---|---|---|
| 1 | POST | `/auth/register` | Kayıt ol | Herkese açık |
| 2 | POST | `/auth/login` | Giriş yap | Herkese açık |
| 3 | POST | `/auth/forgot-password` | Şifre sıfırlama | Herkese açık |
| 3a | POST | `/auth/resend-verification` | Doğrulama e-postasını tekrar gönder | Herkese açık |
| 4 | GET | `/auth/me` | Mevcut kullanıcı bilgisi | owner, vet_staff |
| 4a | GET | `/owners/me` | Kullanıcı profil bilgisi | owner |
| 4b | PUT | `/owners/me` | Profil güncelle | owner |
| 5 | POST | `/pets` | Hayvan ekle | owner |
| 6 | GET | `/pets` | Sahibin hayvanları | owner |
| 7 | GET | `/pets/{id}` | Hayvan detayı | owner |
| 8 | PUT | `/pets/{id}` | Hayvan güncelle | owner |
| 9 | POST | `/pets/{id}/photo` | Fotoğraf yükle | owner |
| 9a | DELETE | `/pets/{id}/photo` | Fotoğraf sil | owner |
| 10 | GET | `/pets/{id}/visits` | Hayvanın ziyaret geçmişi | owner |
| 10a | GET | `/visits/owner` | Sahibin tüm aktif petlerinin ziyaret geçmişi | owner |
| 11 | GET | `/pets/{id}/recommendations` | Hayvanın önerileri | owner |
| 12 | GET | `/visits/code/{code}` | Kod ile hasta bul | vet_staff |
| 13 | POST | `/visits` | Yeni ziyaret başlat | vet_staff |
| 14 | PUT | `/visits/{id}/close` | Ziyareti kapat | vet_staff |
| 14a | GET | `/visits/vet` | Hekime atanmış tüm ziyaretler | vet_staff |
| 15 | POST | `/visits/{visitId}/treatments` | Tedavi girişi ekle | vet_staff |
| 16 | GET | `/visits/{visitId}/treatments` | Ziyaretin tedavileri | owner, vet_staff |
| 17 | PUT | `/treatments/{id}` | Tedavi düzenle (15 dk) | vet_staff |
| 18 | DELETE | `/treatments/{id}` | Tedavi sil (15 dk) | vet_staff |
| 19 | POST | `/visits/{visitId}/recommendations` | Öneri gir | vet_staff |
| 20 | GET | `/notifications` | Bildirim listesi + okunmamış sayısı | owner |
| 21 | GET | `/notifications/unread-count` | Okunmamış sayısı (badge için) | owner |
| 22 | PATCH | `/notifications/{id}/read` | Okundu işaretle | owner |
| 23 | PATCH | `/notifications/read-all` | Tümünü okundu işaretle | owner |
| 24 | POST | `/devices/register` | FCM token kaydet | owner |
| 25 | POST | `/devices/unregister` | FCM token sil (logout) | owner |

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

### POST /auth/resend-verification — Doğrulama e-postasını tekrar gönder

**Kim:** Herkese açık. **PRD:** US-16 (E-posta doğrulama akışı).

**Request body:**

| Alan | Tip | Zorunlu |
|---|---|---|
| `email` | String (email) | Evet |

**Response (200):**

```json
{ "message": "Doğrulama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin." }
```

**Response (400):** Validation hatası (geçersiz e-posta formatı veya boş alan).

**Response (429):** Rate limit aşıldı. Endpoint IP başına saatte 3 istek ile sınırlıdır.

> Not: E-posta sistemde kayıtlı olmasa veya zaten doğrulanmış olsa bile 200 döner (kullanıcı enumeration'ını önlemek için). Frontend'e "doğrulama gönderildi" mesajı gösterilir; gerçek durum kullanıcıya sızdırılmaz.

---

### GET /auth/me — Mevcut kullanıcı bilgisi

**Kim:** JWT gerekli (her iki rol). **PRD:** FR-02, US-14 (Google OAuth).

Kullanıcının kimlik bilgisini ve JIT (Just-In-Time) senkronize edilmiş profilini döner. Frontend uygulamayı her açtığında veya login sonrasında bu endpoint'i çağırır.

**JIT Provisioning & Profil Yönetimi (Kart #8):** Kullanıcının profil kaydı veritabanında yoksa (ör. Google ile ilk giriş), JWT claim'lerinden (`user_metadata.name` / `full_name`, `email`) otomatik olarak `profiles` tablosuna kaydedilir (`OwnerService`).
- Kullanıcının `vet_staff` rolü `clinic_memberships` tablosundaki aktif üyeliklerine göre belirlenir (`status = 'active'` üyeliği varsa rol `vet_staff` döner ve aktif üyelikler `clinicMemberships` listesinde sunulur).
- Profil nesnesi (`profile`) her iki rol için de `profiles` tablosundan `OwnerResponse` formatında güvenli bir şekilde döner.

**Response (200) — owner:**

```json
{
  "id": "550e8400-...",
  "email": "ayse@example.com",
  "role": "owner",
  "profile": {
    "id": "550e8400-...",
    "fullName": "Ayşe Yılmaz",
    "email": "ayse@example.com",
    "phone": "+905551234567",
    "createdAt": "2026-07-29T14:32:11Z",
    "updatedAt": "2026-07-29T14:32:11Z"
  }
}
```

**Response (200) — vet_staff:**

```json
{
  "id": "660e8400-...",
  "email": "dr.mehmet@vetklinik.com",
  "role": "vet_staff",
  "clinicMemberships": [
    {
      "id": "880e8400-...",
      "clinicId": "990e8400-...",
      "userId": "660e8400-...",
      "role": "doctor",
      "status": "active",
      "isClinicAdmin": false,
      "joinedAt": "2026-08-11T12:00:00Z",
      "createdAt": "2026-08-11T12:00:00Z",
      "updatedAt": "2026-08-11T12:00:00Z"
    }
  ],
  "profile": {
    "id": "660e8400-...",
    "fullName": "Dr. Mehmet Yılmaz",
    "email": "dr.mehmet@vetklinik.com",
    "phone": "+905559998877",
    "createdAt": "2026-08-11T12:00:00Z",
    "updatedAt": "2026-08-11T12:00:00Z"
  }
}
```

**Response (401):** JWT eksik veya geçersiz.

**Response (403 `ROLE_MISMATCH`):** JWT `user_metadata.role` alanı ile erişilen profil endpoint'i uyumsuz (örn. `vet_staff` bir kullanıcı doğrudan `/owners/me` çağırırsa).

> Not: Top-level `id`, `email`, `role` alanları geriye dönük uyumluluk için korunur. Yeni frontend kodu `profile` alanını kullanmalıdır.

> Güvenlik notu: `user_metadata` Supabase'de kullanıcı tarafından değiştirilebilir bir alandır. İleride rol belirleme mantığı `app_metadata`'ya taşınmalıdır (backend-only). Şu anki tasarım frontend'in doğru rolü set ettiği varsayımına dayanır.

---

## Owners modülü

### GET /owners/me — Kullanıcı profil bilgisi

**Kim:** Sadece `owner`. JWT gerekli.

**Response (200) — `OwnerResponse`:**

```json
{
  "id": "550e8400-...",
  "fullName": "Ayşe Yılmaz",
  "email": "ayse@example.com",
  "phone": "+905551234567",
  "surname": "Yılmaz",
  "address": "Kadıköy, İstanbul",
  "createdAt": "2026-07-29T14:32:11Z",
  "updatedAt": "2026-07-29T14:32:11Z"
}
```

**Hatalar:** 401, 404

---

### PUT /owners/me — Profil güncelle

**Kim:** Sadece `owner`. JWT gerekli.

**Request body:** Tüm alanlar opsiyoneldir (partial update). `email` bu endpoint üzerinden güncellenemez.

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `fullName` | String | Hayır | Ad Soyad (Birlikte güncellemek için) |
| `name` | String | Hayır | Ad |
| `surname` | String | Hayır | Soyad |
| `phone` | String | Hayır | Telefon |
| `address` | String | Hayır | Adres |

**Response (200):** Güncellenmiş `OwnerResponse` (yukarıdaki şemayla aynı)

**Hatalar:** 400, 401, 404

---

## Pets modülü

### POST /pets — Yeni hayvan ekle

**Kim:** Sadece `owner`. **PRD:** FR-03, FR-04.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `name` | String | Evet | Hayvan adı |
| `species` | String | Evet | Tür (Kedi, Köpek vb.) |
| `breed` | String | Hayır | Cins, null olabilir |
| `gender` | Enum | Evet | `male`, `female`, `unknown` |
| `birthDate` | Date | Hayır | Doğum tarihi (`YYYY-MM-DD`) |
| `estimatedBirthYear` | Short | Hayır | Tahmini doğum yılı |
| `photoUrl` | String | Hayır | Fotoğraf URL |
| `weight` | Double | Hayır | Güncel Kilo (kg), örn: 23.0 |
| `microchipNo` | String | Hayır | Mikroçip Numarası |
| `isSpayedOrNeutered` | Boolean | Hayır | Kısırlaştırılma durumu (true/false) |
| `bloodType` | String | Hayır | Kan grubu, örn: "DEA 1.1 (+)" |
| `color` | String | Hayır | Renk / Kürk Rengi |
| `allergies` | String | Hayır | Alerjiler |
| `chronicIllnesses` | String | Hayır | Kronik Rahatsızlıklar |

**Response (201) — `PetResponse`:**

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "ownerId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Pamuk",
  "species": "Kedi",
  "breed": "Tekir",
  "gender": "female",
  "birthDate": "2022-04-15",
  "estimatedBirthYear": 2022,
  "photoUrl": "https://xxx.supabase.co/storage/v1/object/public/pet-photos/...",
  "weight": 23.0,
  "microchipNo": "900215000123456",
  "isSpayedOrNeutered": true,
  "bloodType": "DEA 1.1 (+)",
  "color": "Golden",
  "allergies": "Tavuk proteinine alerjik.",
  "chronicIllnesses": "Yok",
  "uniqueCode": "ABC123",
  "createdAt": "2026-07-29T14:32:11Z",
  "updatedAt": "2026-07-29T14:32:11Z"
}
```

**Hatalar:** 400, 401, 403

> Not: `uniqueCode`, `createdAt`, `updatedAt` sistem tarafından üretilir. `isActive` ve `deletedAt` gibi dahili alanlar response'a dahil edilmez.

---

### GET /pets — Sahibin hayvanları

**Kim:** Sadece `owner`. **PRD:** FR-13.

**Response (200):** `PetResponse[]`

> Not: Soft-deleted hayvanlar döndürülmez (EC-05).

---

### GET /pets/{id} — Hayvan detayı

**Kim:** Sadece hayvanın sahibi veya `vet_staff`. **PRD:** FR-03.

**Response (200):** `PetResponse`

**Hatalar:** 401, 403 (başkasının hayvanı), 404

---

### GET /pets/{id}/weight-history — Kilo Geçmişi (Seçenek A)

**Kim:** Hayvanın sahibi veya aktif `vet_staff`.

Zamana bağlı kilo geçmişini kronolojik (`date ASC`) olarak listeler. Parametre verilmediğinde mobil kilo grafiği için doğrudan JSON dizisi döner; `page` veya `size` parametresi verildiğinde sayfalandırılmış `Page` nesnesi döner.

**Query Parametreleri (Opsiyonel):**
- `page`: Sayfa numarası (0-indexed, örn: 0)
- `size`: Sayfa boyutu (örn: 20)
- `sort`: Sıralama (varsayılan: `recordedAt,asc`)

**Response (200) — Standart Dizi (Parametresiz Çağrı):**

```json
[
  {
    "date": "2026-03-15",
    "weight": 21.0
  },
  {
    "date": "2026-04-15",
    "weight": 22.0
  },
  {
    "date": "2026-05-15",
    "weight": 23.0
  }
]
```

**Response (200) — Sayfalandırılmış (`?page=0&size=10`):**

```json
{
  "content": [
    {
      "date": "2026-03-15",
      "weight": 21.0
    }
  ],
  "totalPages": 1,
  "totalElements": 1,
  "size": 10,
  "number": 0,
  "first": true,
  "last": true,
  "empty": false
}
```

**Hatalar:** 401, 403, 404

---

### PUT /pets/{id} — Hayvan güncelle

**Kim:** Sadece hayvanın sahibi. **PRD:** FR-03.

**Request body:** `PetUpdateRequest` (tüm alanlar opsiyonel). `uniqueCode` ve `photoUrl` güncellenemez. `weight` güncellendiğinde `pet_weight_history` tablosuna da otomatik kayıt eklenir.

**Response (200):** `PetResponse`

---

### POST /pets/{id}/photo — Fotoğraf yükle

**Kim:** Sadece hayvanın sahibi. **PRD:** FR-09.

**Content-Type:** `multipart/form-data`

**Form alanı:** `file` — image/jpeg, image/jpg, image/png veya image/webp, max 15MB

**Response (200):**

```json
{ "photoUrl": "https://xxx.supabase.co/storage/v1/pets/abc123.jpg?v=1755000000000" }
```

> Not: `photoUrl` her yüklemede değişen bir `?v=` versiyon parametresi taşır — aynı hayvan için
> fotoğraf güncellendiğinde URL de değişir, böylece CDN/istemci önbelleği eski fotoğrafı göstermeye devam etmez.

**Hatalar:** 401, 403, 404, 413 (`FILE_TOO_LARGE`), 415 (`UNSUPPORTED_FILE_TYPE`)

---

### DELETE /pets/{id}/photo — Fotoğraf sil

**Kim:** Sadece hayvanın sahibi.

**Response:** `204 No Content`

**Hatalar:** 401, 403 (başkasının hayvanı), 404

**Notlar:**
- Hayvanın zaten fotoğrafı yoksa hata fırlatılmaz, yine `204` döner (idempotent silme).
- Supabase Storage'daki dosya da silinir, `pets.photo_url` `null`'a çekilir.

---

### PetResponse şeması

```json
{
  "id": "550e8400-...",
  "ownerId": "660e8400-...",
  "name": "Boncuk",
  "species": "Kedi",
  "breed": "Tekir",
  "gender": "male",
  "birthDate": "2022-04-15",
  "estimatedBirthYear": 2022,
  "photoUrl": "https://xxx.supabase.co/storage/v1/pets/abc.jpg",
  "weight": 23.0,
  "microchipNo": "900215000123456",
  "isSpayedOrNeutered": true,
  "bloodType": "DEA 1.1 (+)",
  "color": "Golden",
  "allergies": "Tavuk proteinine alerjik.",
  "chronicIllnesses": "Yok",
  "uniqueCode": "7K4R9M",
  "createdAt": "2026-07-29T14:32:11Z",
  "updatedAt": "2026-07-29T14:32:11Z"
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
      "chiefComplaint": "Akut kusma ve iştahsızlık",
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

### GET /visits/owner — Sahibin tüm aktif petlerinin ziyaret geçmişi

**Kim:** Giriş yapmış `owner`. **Amaç:** Genel ziyaret geçmişi ekranı (tüm hayvanlar tek listede) — N+1 istek önleme.

**Path/query param:** Yok. Sahip JWT subject'inden belirlenir.

**Response (200):** `VisitResponse[]` — sahibin **aktif** (soft-delete edilmemiş, `isActive=true`) tüm petlerinin ziyaretleri, `startedAt` DESC sıralı.

> Not: Silinmiş/pasif petlerin ziyaretleri dahil edilmez. Kayıt yoksa `null` değil **boş dizi (`[]`)** döner (200). Sayfalama yok — düz liste.

---

### POST /visits — Yeni ziyaret başlat

**Kim:** Sadece `vet_staff`. **PRD:** FR-06, EC-02.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `petId` | UUID | Evet | Hayvan ID'si |

**Response (201):** `VisitResponse`

**Hatalar:** 400, 401, 403, 404, 409 (`VISIT_ALREADY_OPEN` veya `CONFLICT`)

> Not: `vetStaffId` JWT'den çıkarılır. `status` otomatik `ongoing`, `startedAt` otomatik şu an.
>
> **EC-02 — 409 davranışı:** Normalde uygulama seviyesindeki kontrol açık ziyareti erkenden yakalar ve `VISIT_ALREADY_OPEN` döner. Aynı hayvana eş zamanlı iki istek gelirse (nadir bir yarış durumu), uygulama kontrolü ikisini de geçebilir — bu durumda DB seviyesindeki partial unique index (`idx_visits_active_pet`) ikinciyi reddeder ve generic `CONFLICT` error code'u döner (spesifik `VISIT_ALREADY_OPEN` değil). Frontend her iki 409 durumunda da aynı şekilde davranmalı: "bu hayvanın zaten açık bir ziyareti var" mesajı gösterip mevcut açık ziyareti tekrar çekmeli (retry ile otomatik tekrar oluşturmaya çalışmamalı).

---

### PUT /visits/{id}/close — Ziyareti kapat

**Kim:** Ziyareti başlatan `vet_staff`. **PRD:** FR-06.

**Request body:** Yok.

**Response (200):** `VisitResponse` (status: `completed`, endedAt dolu)

**Hatalar:** 401, 403, 404, 409 (`VISIT_ALREADY_CLOSED`)

> Not: Kapatma anında sahibe FCM push bildirimi asenkron tetiklenir (FR-10).

---

### GET /visits/vet — Hekime atanmış tüm ziyaretler

**Kim:** Giriş yapmış `vet_staff` (veya `admin`). **Amaç:** Hekimin iş takibi — geçmişte gerçekleştirdiği tüm muayene/ziyaretler tek listede.

**Path/query param:** Yok. Hekim JWT subject'inden belirlenir.

**Response (200):** `VisitResponse[]` — hekime atanmış (`vetStaffId` = JWT subject) tüm ziyaretler, `startedAt` DESC sıralı.

> Not: Silinmiş/pasif petlerin ziyaretleri dahil edilmez (Değ.4). Kayıt yoksa `null` değil **boş dizi (`[]`)** döner (200). Sayfalama yok — düz liste. Sadece `VET_STAFF`/`ADMIN` erişebilir; `owner` rolü **403** alır.

---

### VisitResponse şeması

```json
{
  "id": "...",
  "petId": "...",
  "vetStaffId": "...",
  "status": "ongoing",
  "chiefComplaint": "Akut kusma ve iştahsızlık",
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
  "chiefComplaint": "Akut kusma ve iştahsızlık",
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
| `type` | Enum | Evet | `medication`, `xray`, `lab_result`, `note`, `vaccine`, `surgery` |
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

Sahibin tüm bildirimlerini `sentAt` (yeniden eskiye) sırasıyla döner. Toplam okunmamış sayısı da aynı cevapta gelir; frontend badge için ayrıca istek atmak zorunda değil.

**Response (200):**

```json
{
  "notifications": [
    {
      "id": "3f2e...",
      "type": "TREATMENT",
      "title": "Boncuk için yeni tedavi kaydı",
      "body": "Dr. Mehmet Yılmaz tarafından ilaç kaydı girildi",
      "treatmentEntryId": "8a1b...",
      "isRead": false,
      "readAt": null,
      "sentAt": "2026-07-29T14:32:11Z"
    }
  ],
  "unreadCount": 5
}
```

**`type` değerleri:** `VACCINE` · `VISIT` · `TREATMENT` · `RECOMMENDATION` · `SYSTEM`
Frontend bu değere göre ikon ve renk seçer. FCM push bildiriminde de `data.type` alanı olarak gönderilir.

---

### GET /notifications/unread-count — Okunmamış sayısı

**Kim:** Sadece `owner`. **PRD:** FR-11.

Sadece okunmamış bildirim sayısını döner. Badge güncellemesi gibi listeyi çekmeye gerek olmayan durumlar için hafif endpoint.

**Response (200):**

```json
{ "unreadCount": 5 }
```

---

### PATCH /notifications/{id}/read — Okundu işaretle

**Kim:** Bildirim sahibi (`owner`). **PRD:** FR-11.

**Response (204):** No Content

> Not: İdempotent — zaten okunmuşsa hiçbir işlem yapılmadan 204 döner. Bildirim başkasına aitse 404 döner (kaynak varlığı sızdırılmaz).

---

### PATCH /notifications/read-all — Tümünü okundu işaretle

**Kim:** Sadece `owner`. **PRD:** FR-11.

Sahibin tüm okunmamış bildirimlerini tek istekte okundu işaretler. Bildirimler listesi ekranı açıldığında toplu işaretleme için kullanılır.

**Response (200):**

```json
{ "unreadCount": 0 }
```

---

## Devices modülü

### POST /devices/register — FCM token kaydet

**Kim:** Sadece `owner`. **PRD:** FR-12.

Uygulama açılışında veya login sonrası cihazın FCM token'ı sunucuya kaydedilir.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `fcmToken` | String | Evet | Firebase Cloud Messaging token |
| `platform` | Enum | Evet | `ios`, `android` |

**Response (201):** No Content

> Not: İdempotent — aynı token varsa mevcut kayıt yeni `userId` ve `platform` ile güncellenir, `lastSeen` yenilenir. `userId` JWT'den çıkarılır.

---

### POST /devices/unregister — FCM token sil (logout)

**Kim:** Sadece `owner`. **PRD:** FR-12.

Kullanıcı logout olurken çağrılır. İlgili cihaz token'ı silinerek eski cihaza bildirim gitmesi engellenir. Frontend logout akışında bu endpoint'i çağırdıktan sonra JWT'yi temizler.

**Request body:**

| Alan | Tip | Zorunlu | Açıklama |
|---|---|---|---|
| `fcmToken` | String | Evet | Silinecek Firebase token |
| `platform` | Enum | Evet | `ios`, `android` (form uyumluluğu için; silme işleminde kullanılmaz) |

**Response (204):** No Content

> Not: İdempotent — token zaten yoksa yine 204 döner. Silme sadece token + `userId` eşleşmesinde gerçekleşir; başka kullanıcının token'ı silinmez.

---

## Rol-endpoint matrisi (FR-02)

| Endpoint | owner | vet_staff | Açık |
|---|---|---|---|
| POST /auth/register | — | — | ✅ |
| POST /auth/login | — | — | ✅ |
| POST /auth/forgot-password | — | — | ✅ |
| POST /auth/resend-verification | — | — | ✅ |
| GET /auth/me | ✅ | ✅ | — |
| GET /owners/me | ✅ | — | — |
| PUT /owners/me | ✅ | — | — |
| POST /pets | ✅ | — | — |
| GET /pets | ✅ | — | — |
| GET /pets/{id} | ✅ | — | — |
| PUT /pets/{id} | ✅ | — | — |
| POST /pets/{id}/photo | ✅ | — | — |
| DELETE /pets/{id}/photo | ✅ | — | — |
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
| GET /notifications/unread-count | ✅ | — | — |
| PATCH /notifications/{id}/read | ✅ | — | — |
| PATCH /notifications/read-all | ✅ | — | — |
| POST /devices/register | ✅ | — | — |
| POST /devices/unregister | ✅ | — | — |
---

## Bekleyen teknik kararlar

1. **V2 migration gerekli:** `owners` ve `vet_staff` tablolarına `auth_id` (UUID) kolonu eklenmeli — Supabase Auth kullanıcısıyla eşleşme için.
2. **EC-05 soft delete:** `pets` tablosuna `deleted_at` kolonu eklenmeli.
3. **EC-08 audit log:** Tedavi silme/düzenleme denetim izi için `audit_logs` tablosu veya `treatment_entries`'e `updated_at` kolonu.
4. **Dosya yükleme akışı:** Tedavi eki (röntgen/tahlil) nasıl yüklenecek? Ayrı bir `POST /uploads` endpoint'i mi, yoksa frontend doğrudan Supabase Storage SDK'sıyla mı yükleyecek?

---

### DELETE /pets/{id} — Hayvan sil (soft delete)

**Kim:** Sadece hayvanın sahibi (`owner`). **PRD:** EC-05.

**Path param:** `id` (UUID)

**Response:** `204 No Content`

**Hatalar:** 401, 403 (başkasının hayvanı), 404

**Notlar:**
- Hayvan tamamen silinmez, `deleted_at` alanı doldurulur (soft delete)
- Silinen hayvan `GET /pets` ve `GET /visits/code/{code}` sorgularında görünmez
- Tıbbi geçmiş (ziyaretler, tedaviler) saklanır

---

### DELETE /auth/me — Hesap sil

**Kim:** JWT gerekli (kendi hesabını siler). **PRD:** EC-05.

**Response:** `204 No Content`

**Hatalar:** 401 (`UNAUTHORIZED` veya `REAUTHENTICATION_REQUIRED`)

**Notlar:**
- Kullanıcının tüm hayvanları da soft delete olur
- Supabase Auth'tan kullanıcı deaktive edilir
- Tıbbi geçmiş saklanır (KVKK ve kayıt zorunluluğu)
- **Re-authentication zorunlu:** JWT'nin `iat` (issued-at) claim'i son 5 dakika içinde olmalı, yoksa `REAUTHENTICATION_REQUIRED` (401) döner. Frontend, silme isteğinden hemen önce kullanıcıya şifresini tekrar girdirip Supabase'den taze bir token almalı (şifre backend'e hiç gönderilmez, sadece Supabase'in ürettiği taze JWT kullanılır). Bu, çalıntı/sızmış eski bir token'ın şifre bilinmeden hesap silmek için kullanılmasını engeller.