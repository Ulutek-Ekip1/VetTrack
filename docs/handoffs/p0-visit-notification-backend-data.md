# P0 frontend entegrasyonu: backend ve veri teslim notu

Bu branch, doktorun kodla hasta araması, aktif ziyaret ekranı ve bildirim akışını gerçek API sözleşmesine bağlar. Aşağıdaki maddeler, `main`e alım ve ortam dağıtımı öncesinde backend/veri ekiplerinin doğrulaması veya tamamlaması gereken sözleşmelerdir.

## 1. Ziyaret ve hasta arama API'leri

İstek yapan veteriner kullanıcısı doğrulanmış olmalıdır; sahip kullanıcıları başka hayvanların kodunu, ziyaretini veya zaman çizelgesini görememelidir.

| İşlem | İstek | Beklenen yanıt |
| --- | --- | --- |
| Kodla hasta ara | `GET /visits/code/{code}` | `200 { pet, visits }`; kod yoksa anlamlı gövdeli `404` |
| Ziyaret başlat | `POST /visits`, gövde: `{ "petId": "UUID" }` | `201 Visit`; aynı hayvan için açık ziyaret varsa yeni kayıt oluşturmayın, mevcut açık ziyareti döndürün ya da sözleşmeli `409` verin |
| Aktif ziyaret bağlamı | `GET /visits/{visitId}/context` | `200 { visit, pet, owner, history }` |
| Ziyareti kapat | `PUT /visits/{visitId}/close` | `200 Visit`; kapatılmış ziyaret ikinci kez kapatılamamalı |
| Hayvan ziyaret geçmişi | `GET /pets/{petId}/visits` | `200 Visit[]`, yalnız ilgili sahip/veteriner için |
| Sahip/veteriner geçmişi | `GET /visits/owner`, `GET /visits/vet` | Oturumdaki role göre filtrelenmiş `200 Visit[]` |

`visit`, `history` ve arama sonucundaki `visits` alanlarında en az `id`, `petId`, `vetStaffId`, `startedAt`, `endedAt` ve açık ziyaret tespiti için gerekli durum alanı bulunmalıdır. Tarihler ISO-8601 UTC olarak dönmelidir. `owner` içinde frontend'in kullandığı `name` ve isteğe bağlı `phone`, `pet` içinde `id`, `name`, `uniqueCode`, `ownerId` dönmelidir.

## 2. Aktif ziyarette tedavi ve öneri kayıtları

| İşlem | İstek | Beklenen yanıt |
| --- | --- | --- |
| Ziyaret tedavileri | `GET /visits/{visitId}/treatments` | `200 TreatmentEntry[]` |
| Tedavi ekle | `POST /visits/{visitId}/treatments` | Gövde: `entryType`, `title`, isteğe bağlı `description`, `attachmentUrl`; `201 TreatmentEntry` |
| Hayvan tedavi geçmişi | `GET /pets/{petId}/treatments` | `200 TreatmentEntry[]` |
| Ziyaret önerileri | `GET /visits/{visitId}/recommendations` | `200 Recommendation[]` |
| Öneri ekle | `POST /visits/{visitId}/recommendations` | Gövde: `type`, `description`; `201 Recommendation` |

Tedavi enumu tek kaynakta tanımlanmalıdır: Flutter `entryType` gönderir; backend Türkçe serbest metin değil sabit enum değeri kabul etmelidir. Backend, düzenleme/silme için `editableUntil` (veya eşdeğer `isEditable`) döndürmeli; 15 dakika kuralını yalnız UI'a bırakmadan sunucuda da zorlamalıdır. Ziyaret kapandıktan sonra tedavi/öneri eklemeyi engelleyip `409` ile açıklamalıdır.

## 3. Bildirim, FCM ve derin bağlantı

### Şema ve migration

`V7__add_notification_navigation_context.sql` dağıtıma dahil edilmelidir:

- `notifications.pet_id UUID NULL`
- `notifications.visit_id UUID NULL`
- `idx_notifications_pet_id`

Ziyaret kapatma bildiriminde bu iki alan kaydedilmelidir. Eski bildirimlerde `petId` bulunmaması normaldir; Flutter bu bildirimleri yalnız liste içinde gösterir ve derin bağlantı yapmaz.

### API sözleşmesi

| İşlem | İstek | Beklenen yanıt |
| --- | --- | --- |
| Liste | `GET /notifications?page=0&size=20` | `{ notifications, unreadCount }` |
| Rozet | `GET /notifications/unread-count` | `{ "unreadCount": number }` |
| Tek bildirimi oku | `PATCH /notifications/{id}/read` | `200/204` |
| Tümünü oku | `PATCH /notifications/read-all` | `200/204` |
| Cihaz kaydı | `POST /devices/register` | `{ fcmToken, platform }` |
| Cihaz silme | `POST /devices/unregister` | `{ fcmToken }` |

Bildirim JSON'u `id`, `type`, `title`, `body`, `isRead`, `sentAt` ile birlikte `petId` ve `visitId` döndürmelidir. FCM `data` payload'ında da aynı anahtarlar string olarak yer almalıdır: `notificationId`, `petId`, `visitId`, `type`, `title`, `body`. Böylece kullanıcı push'a dokunduğunda `/owner/pets/{petId}/treatments` ekranına gider.

Token kaydı idempotent olmalı, token yenilenince sahibine yeniden bağlanmalı; çıkışta yalnız mevcut kullanıcının cihaz kaydı kaldırılmalıdır. Geçersiz/son kullanımı geçmiş FCM tokenları gönderim hatasında silinmelidir.

## 4. Veri kalitesi ve kabul kontrolleri

- `pets.unique_code` boş olmayan, tekil ve indeksli olmalı; üretimde mevcut hayvanlar için geri doldurulmalıdır.
- `pet.owner_id`, `visit.pet_id`, `visit.vet_staff_id` ilişkileri geçerli yabancı anahtarlarla korunmalıdır.
- Açık ziyaret tanımı tek olmalıdır (örneğin `ended_at IS NULL`); aynı pet için eşzamanlı iki açık ziyaret DB kısıtı veya transaction ile engellenmelidir.
- Ziyaret kapatma transaction'ı, `ended_at` güncellemesi ile sahibi için bildirim oluşturmayı birlikte tamamlamalıdır.
- Rol ve sahiplik kontrolleri tüm ID içeren uçlarda zorunludur; UUID tahmini başka kullanıcı verisine erişim sağlamamalıdır.
- Staging'de en az şu akışlar doğrulanmalıdır: geçerli/geçersiz kod, açık ziyaret yeniden kullanımı, tedavi/öneri ekleme, ziyaret kapatma sonrası bildirim listesi-rozet-FCM derin bağlantısı ve token yenileme/çıkış.

Bu başlıkların API contract dokümanı, backend DTO'ları ve Flutter modelleri ile birlikte tek sürümlü olarak tutulması gereklidir.

