import 'package:flutter/material.dart';

// 1. Profil sayfasındaki butona tıklandığında bu fonksiyonu çağıracaksın
void showFAQBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Alt pencerenin ekranın %85'ini kaplayabilmesi için gerekli
    backgroundColor: Colors.transparent, // Köşeleri yuvarlatabilmemiz için arka planı şeffaf yapıyoruz
    builder: (BuildContext context) {
      return const FAQBottomSheet();
    },
  );
}

// 2. Alttan açılan pencerenin (BottomSheet) ana tasarımı
class FAQBottomSheet extends StatelessWidget {
  const FAQBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC), 
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1, color: Color(0xFFE2E8F0)), 
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // KATEGORİ 1: GİRİŞ VE PROFİL İŞLEMLERİ
                _buildCategoryHeader('Giriş ve Profil İşlemleri'), //[cite: 3]
                _buildFAQItem(
                  'VetTrack nedir ve nasıl kullanılır?', //[cite: 3]
                  'VetTrack, minik dostunuzun sağlık bilgilerini cep telefonunuza getiren bir uygulamadır. Tüm bilgiler sadece telefonunuzdan kolayca takip edilir.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Şifremi veya 6 haneli kodumu unutursam ne olur?', //[cite: 3]
                  'Şifrenizi e-postanıza gelen bir bağlantıyla sıfırlayabilirsiniz. 6 haneli kod ise hayvanınızın sayfasında hep yazar; göremezseniz destek ekibi e-posta adresinizi doğrulayıp kodu size söyler.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Birden fazla evcil hayvanım varsa ne yapmalıyım?', //[cite: 3]
                  'Tek bir hesap açıp tüm hayvanlarınızı ayrı ayrı ekleyebilirsiniz. Her birinin kendine ait özel bir kodu olur.', //[cite: 3]
                ),

                // KATEGORİ 2: ERİŞİM KODU VE KİMLİK BİLGİLERİ
                _buildCategoryHeader('Erişim Kodu ve Kimlik Bilgileri'), //[cite: 3]
                _buildFAQItem(
                  '6 haneli erişim kodu nedir?', //[cite: 3]
                  'Hayvanınıza özel bir "okul numarası" gibidir. Kliniğe gittiğinizde bu numarayı doktora söylersiniz, doktor da kendi bilgisayarına yazarak minik dostunuzun eski tüm sağlık bilgilerini anında görür.', //[cite: 3]
                ),
                _buildFAQItem(
                  '6 haneli kod ile deri altındaki mikroçip aynı şey mi?', //[cite: 3]
                  'Hayır. 6 haneli kod sadece bu uygulamanın verdiği bir numaradır. Deri altındaki mikroçip numarasıyla bir bağlantısı yoktur.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Mikroçip bir GPS takip cihazı mıdır? Haritada yerini görebilir miyim?', //[cite: 3]
                  'Hayır, uygulamada veya çipte haritadan canlı konum takip etme (GPS) özelliği yoktur.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Uygulamadaki bilgiler devletin sistemleriyle (PETVET / E-Devlet) eşleşir mi?', //[cite: 3]
                  'Hayır, VetTrack tamamen bağımsız bir uygulamadır. Buradaki adres veya telefon güncellemeleri devlete otomatik gitmez veya e- Devletteki bilgileriniz buraya gelmez.', //[cite: 3]
                ),

                // KATEGORİ 3: KLİNİK İLETİŞİMİ VE RANDEVULAR
                _buildCategoryHeader('Klinik İletişimi ve Randevular'), //[cite: 3]
                _buildFAQItem(
                  'Uygulamadan randevu alabilir miyim?', //[cite: 3]
                  'Hayır, bu sürümde randevu alma veya değiştirme özelliği bulunmamaktadır.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Doktoruma 7/24 mesaj atabilir veya görüntülü arayabilir miyim?', //[cite: 3]
                  'Hayır, doğrudan mesajlaşma, sesli veya görüntülü arama yoktur. Doktor sisteme bir bilgi veya not girdiğinde bu size bildirim olarak gelir.', //[cite: 3]
                ),

                // KATEGORİ 4: SAĞLIK GEÇMİŞİ VE TEDAVİ KAYITLARI
                _buildCategoryHeader('Sağlık Geçmişi ve Tedavi Kayıtları'), //[cite: 3]
                _buildFAQItem(
                  'Geçmiş aşıları ve tahlilleri görebilir miyim?', //[cite: 3]
                  'Evet, yapılan tüm aşı ve tedavileri sırayla görebilirsiniz.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Eski aşıları veya tedavileri kendim ekleyebilir miyim?', //[cite: 3]
                  'Evet, ekleyebilirsiniz! Minik dostunuzun geçmişte yaptırdığı aşıları ve gördüğü tedavileri uygulamaya kendiniz yükleyebilirsiniz. Böylece kliniğe gittiğinizde veteriner hekiminiz bu eski kayıtları inceleyip dostunuzun geçmişte nasıl bir tedavi gördüğünü kolayca öğrenebilir. Ancak yeni yapılan muayene, aşı ve tıbbi teşhis kayıtları resmiyet taşıdığı için sadece veteriner hekiminiz tarafından sisteme işlenir.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Kliniğe verdiğim tahlil ve röntgen sonuçları ne zaman görünür?', //[cite: 3]
                  'Doktor bilgisayarından sonucu sisteme yüklediği an telefonunuza bir bildirim gelir ve uygulamadan inceleyebilirsiniz.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Eski bir muayene kaydı sonradan değiştirilebilir mi?', //[cite: 3]
                  'Doktor kaydı girdikten sonra sadece 15 dakika içinde düzeltebilir. Sonrasında kayıt kilitlenir ve değiştirilemez.', //[cite: 3]
                ),

                // KATEGORİ 5: YAPAY ZEKA VE ACİL DURUMLAR
                _buildCategoryHeader('Yapay Zeka ve Acil Durumlar'), //[cite: 3]
                _buildFAQItem(
                  'Acil bir durumda yapay zekadan yardım alabilir miyim?', //[cite: 3]
                  'Yapay zeka asistanımız tıpkı bilgili bir rehber gibidir. Evcil hayvanınızın günlük bakımı, beslenmesi veya aklınıza takılan genel sorular için ona dilediğiniz zaman danışabilirsiniz.\n\nAncak kanama, nefes darlığı, zehirlenme gibi hayati durumlarda yapay zeka durumun tehlikeli olduğunu anlar ve size vakit kaybetmeden "Hemen bir veteriner hekime gidin!" uyarısı verir. Yapay zeka bu uyarıyı yapıyorsa bunu kesin bir talimat olarak kabul etmeli ve bir saniye bile beklemeden minik dostunuzu en yakın kliniğe götürmelisiniz. Çünkü hiçbir uygulama veya yapay zeka, gerçek bir veteriner hekimin yapacağı acil müdahalenin yerini tutamaz.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Yapay zeka teşhis koyup reçete yazabilir mi?', //[cite: 3]
                  'Hayır, yapay zeka bir doktor değildir. İlaç yazamaz veya doktorun verdiği tedaviyi değiştiremez. Sadece genel bakım ve beslenme gibi konularda bilgi verir.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Uygulama otomatik hastalık takibi yapıp hatırlatma gönderir mi?', //[cite: 3]
                  'Hayır, otomatik aşı, test veya ilaç dozajı hatırlatıcıları sistemde yer almamaktadır.', //[cite: 3]
                ),

                // KATEGORİ 6: ÖDEME, SİGORTA VE YASAL SÜREÇLER
                _buildCategoryHeader('Ödeme, Sigorta ve Yasal Süreçler'), //[cite: 3]
                _buildFAQItem(
                  'Fatura, ödeme veya sigorta işlemlerini buradan yapabilir miyim?', //[cite: 3]
                  'Hayır, uygulamada fatura görüntüleme, ödeme yapma, taksitlendirme veya sigorta takibi özellikleri bulunmamaktadır.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Ameliyat izin formlarını uygulamadan imzalayabilir miyim?', //[cite: 3]
                  'Hayır, yasal belge veya form imzalama özelliği yoktur.', //[cite: 3]
                ),

                // KATEGORİ 7: VERİ GÜVENLİĞİ VE TEKNİK KONULAR
                _buildCategoryHeader('Veri Güvenliği ve Teknik Konular'), //[cite: 3]
                _buildFAQItem(
                  'Görseller ve tıbbi veriler nerede saklanır?', //[cite: 3]
                  'Dosyalarınız özel ve güvenli bir dijital depoda saklanır. Hesabınızı silseniz bile yasal zorunluluk nedeniyle geçmiş sağlık kayıtları sistemde kilitli tutulmaya devam eder.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Verilerim güvende mi?', //[cite: 3]
                  'Evet, özel dosyalarınızı sadece siz ve veteriner hekiminiz görebilir.', //[cite: 3]
                ),
                _buildFAQItem(
                  'İnternetim yoksa uygulamayı kullanabilir miyim?', //[cite: 3]
                  'Hayır, uygulamanın çalışması için aktif bir internet bağlantısı gereklidir.', //[cite: 3]
                ),
                _buildFAQItem(
                  'Uygulama çökerse ne olur?', //[cite: 3]
                  'Sistemdeki teknik hatalar otomatik olarak kaydedilir ve yazılım ekibi tarafından düzeltilir.', //[cite: 3]
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BottomSheet'in üst kısmındaki tutamaç (drag handle) ve başlık tasarımı
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sıkça Sorulan Sorular',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(context), 
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2563EB), 
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1), 
      ),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
