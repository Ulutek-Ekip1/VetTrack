# VetTrack - Google Gemini AI Chatbot Entegrasyonu Teknik Dokümantasyonu (v1.3 Prodüksiyon)

Bu doküman, `VetTrack` projesindeki Google Gemini 2.5 Flash (`gemini-2.5-flash`) Yapay Zeka (Chatbot) servisinin mimarisini, atomik Idempotency kısıtlarını, sahiplik kontrollerini, KVKK silme mekanizmalarını ve API uç noktalarını açıklar.

---

## 🏛️ Mimari Katmanlar ve İleri Seviye Güvenlik

1. **Migration Sürüm Yönetimi (`V7__add_chat_messages_table.sql`)**:
   - Migration çakışmalarını önlemek için veritabanı betiği `V7` sürümü olarak adlandırılmıştır.
2. **Rol Uyumu (`owner`, `vet_staff`, `vet`, `admin`)**:
   - Yetkilendirme katmanı projedeki `owner`, `vet_staff`, `vet` ve `admin` rollerinin tamamını destekler.
3. **Çift Yönlü Sahiplik Doğrulaması (Pet & Conversation Ownership)**:
   - Hem `petId` hem de `conversationId` parametreleri isteği atan JWT kullanıcısına ait mi kontrol edilir. Başka kullanıcının oturumuna mesaj eklenmesi engellenir (HTTP 403).
4. **Veritabanı Seviyesinde Atomik Idempotency (`uq_owner_client_message`)**:
   - `chat_messages` tablosundaki `UNIQUE (owner_id, client_message_id)` kısıtı eşzamanlı mobil ağ tekrarlarında veritabanı seviyesinde yarış koşullarını (race condition) engeller.
5. **Idempotency Key Reuse Kontrolü (HTTP 409 Conflict)**:
   - Aynı `clientMessageId` farklı bir mesaj içeriği veya petId ile tekrar kullanılırsa `409 IDEMPOTENCY_KEY_REUSED` hatası döndürülür.
6. **Prompt Injection Koruması & Sanitize**:
   - Mesaj metinleri enjeksiyon ifadelerinden arındırılır.
7. **KVKK Veri Saklama ve Unutulma Hakkı (Deletion & Retention)**:
   - Kullanıcıların sohbet geçmişini sayfalamalı olarak çekebileceği ve dilediklerinde oturum veya tüm geçmişlerini kalıcı olarak silebileceği (`DELETE`) uç noktalar tanımlanmıştır.

---

## 🔌 API Uç Noktaları ve Parametreler

### 1. Yapay Zeka Asistanı İle Sohbet Et
- **Uç Nokta**: `POST /api/ai/chat` (veya `/ai/chat`)
- **Headers**: `Authorization: Bearer <JWT_TOKEN>`

#### Request Body (`AiChatRequest`):
```json
{
  "conversationId": "3deebadb-76e3-40d1-8836-462e6c5800df",
  "clientMessageId": "msg-client-98765",
  "petId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "message": "Kedim bugün az mama yedi ne yapmalıyım?",
  "history": []
}
```

#### Response Body (`AiChatResponse`):
```json
{
  "messageId": "e5d4c3b2-a109-8765-4321-fedcba987654",
  "conversationId": "3deebadb-76e3-40d1-8836-462e6c5800df",
  "emergency": false,
  "reply": "Kedinizin iştahsızlığı için taze su erişimi sağladıktan sonra yaş mamasını ılık su ile nemlendirerek sunabilirsiniz...",
  "disclaimer": "YASAL UYARI: Bu yapay zeka asistanı tarafından verilen bilgiler yalnızca genel rehberlik amaçlıdır. Klinik teşhis veya reçeteli tedavi yerine geçmez. Lütfen kesin tanı için veteriner hekiminize başvurunuz.",
  "model": "gemini-2.5-flash",
  "promptVersion": "v1.2-mvp",
  "createdAt": "2026-08-12T13:45:12.104Z"
}
```

---

### 2. Sayfalamalı Sohbet Geçmişi Getir
- `GET /api/ai/chat/history?page=0&limit=50`
- `GET /api/ai/chat/history/{petId}?page=0&limit=50`

---

### 3. Konuşma / Geçmiş Silme (KVKK)
- `DELETE /api/ai/chat/history/conversation/{conversationId}`: Oturumu siler.
- `DELETE /api/ai/chat/history`: Kullanıcının tüm sohbet geçmişini siler.
