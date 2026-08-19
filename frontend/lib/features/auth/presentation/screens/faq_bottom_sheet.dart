import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

void showFAQBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return const FAQBottomSheet();
    },
  );
}

class FAQBottomSheet extends StatelessWidget {
  const FAQBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXl),
              topRight: Radius.circular(AppDimensions.radiusXl),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, theme),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  children: [
                    _buildCategoryHeader(context, 'Giriş ve Profil İşlemleri'),
                    _buildFAQItem(
                      context,
                      'VetTrack nedir ve nasıl kullanılır?',
                      'VetTrack, minik dostunuzun sağlık bilgilerini cep telefonunuza getiren bir uygulamadır. Tüm bilgiler sadece telefonunuzdan kolayca takip edilir.',
                    ),
                    _buildFAQItem(
                      context,
                      'Şifremi veya 6 haneli kodumu unutursam ne olur?',
                      'Şifrenizi e-postanıza gelen bir bağlantıyla sıfırlayabilirsiniz. 6 haneli kod ise hayvanınızın sayfasında hep yazar; göremezseniz destek ekibi e-posta adresinizi doğrulayıp kodu size söyler.',
                    ),
                    _buildFAQItem(
                      context,
                      'Birden fazla evcil hayvanım varsa ne yapmalıyım?',
                      'Tek bir hesap açıp tüm hayvanlarınızı ayrı ayrı ekleyebilirsiniz. Her birinin kendine ait özel bir kodu olur.',
                    ),
                    
                    _buildCategoryHeader(context, 'Erişim Kodu ve Kimlik Bilgileri'),
                    _buildFAQItem(
                      context,
                      '6 haneli erişim kodu nedir?',
                      'Hayvanınıza özel bir "okul numarası" gibidir. Kliniğe gittiğinizde bu numarayı doktora söylersiniz, doktor da kendi bilgisayarına yazarak minik dostunuzun eski tüm sağlık bilgilerini anında görür.',
                    ),
                    _buildFAQItem(
                      context,
                      '6 haneli kod ile deri altındaki mikroçip aynı şey mi?',
                      'Hayır. 6 haneli kod sadece bu uygulamanın verdiği bir numaradır. Deri altındaki mikroçip numarasıyla bir bağlantısı yoktur.',
                    ),
                    _buildFAQItem(
                      context,
                      'Mikroçip bir GPS takip cihazı mıdır? Haritada yerini görebilir miyim?',
                      'Hayır, uygulamada veya çipte haritadan canlı konum takip etme (GPS) özelliği yoktur.',
                    ),
                    _buildFAQItem(
                      context,
                      'Uygulamadaki bilgiler devletin sistemleriyle (PETVET / E-Devlet) eşleşir mi?',
                      'Hayır, VetTrack tamamen bağımsız bir uygulamadır. Buradaki adres veya telefon güncellemeleri devlete otomatik gitmez veya e- Devletteki bilgileriniz buraya gelmez.',
                    ),
                    
                    _buildCategoryHeader(context, 'Klinik İletişimi ve Randevular'),
                    _buildFAQItem(
                      context,
                      'Uygulamadan randevu alabilir miyim?',
                      'Hayır, bu sürümde randevu alma veya değiştirme özelliği bulunmamaktadır.',
                    ),
                    _buildFAQItem(
                      context,
                      'Doktoruma 7/24 mesaj atabilir veya görüntülü arayabilir miyim?',
                      'Hayır, doğrudan mesajlaşma, sesli veya görüntülü arama yoktur. Doktor sisteme bir bilgi veya not girdiğinde bu size bildirim olarak gelir.',
                    ),

                    _buildCategoryHeader(context, 'Sağlık Geçmişi ve Tedavi Kayıtları'),
                    _buildFAQItem(
                      context,
                      'Geçmiş aşıları ve tahlilleri görebilir miyim?',
                      'Evet, yapılan tüm aşı ve tedavileri sırayla görebilirsiniz.',
                    ),
                    _buildFAQItem(
                      context,
                      'Eski aşıları veya tedavileri kendim ekleyebilir miyim?',
                      'Evet, ekleyebilirsiniz! Minik dostunuzun geçmişte yaptırdığı aşıları ve gördüğü tedavileri uygulamaya kendiniz yükleyebilirsiniz. Böylece kliniğe gittiğinizde veteriner hekiminiz bu eski kayıtları inceleyip dostunuzun geçmişte nasıl bir tedavi gördüğünü kolayca öğrenebilir. Ancak yeni yapılan muayene, aşı ve tıbbi teşhis kayıtları resmiyet taşıdığı için sadece veteriner hekiminiz tarafından sisteme işlenir.',
                    ),
                    _buildFAQItem(
                      context,
                      'Kliniğe verdiğim tahlil ve röntgen sonuçları ne zaman görünür?',
                      'Doktor bilgisayarından sonucu sisteme yüklediği an telefonunuza bir bildirim gelir ve uygulamadan inceleyebilirsiniz.',
                    ),
                    _buildFAQItem(
                      context,
                      'Eski bir muayene kaydı sonradan değiştirilebilir mi?',
                      'Doktor kaydı girdikten sonra sadece 15 dakika içinde düzeltebilir. Sonrasında kayıt kilitlenir ve değiştirilemez.',
                    ),

                    _buildCategoryHeader(context, 'Yapay Zeka ve Acil Durumlar'),
                    _buildFAQItem(
                      context,
                      'Acil bir durumda yapay zekadan yardım alabilir miyim?',
                      'Yapay zeka asistanımız tıpkı bilgili bir rehber gibidir. Evcil hayvanınızın günlük bakımı, beslenmesi veya aklınıza takılan genel sorular için ona dilediğiniz zaman danışabilirsiniz.\n\nAncak kanama, nefes darlığı, zehirlenme gibi hayati durumlarda yapay zeka durumun tehlikeli olduğunu anlar ve size vakit kaybetmeden "Hemen bir veteriner hekime gidin!" uyarısı verir. Yapay zeka bu uyarıyı yapıyorsa bunu kesin bir talimat olarak kabul etmeli ve bir saniye bile beklemeden minik dostunuzu en yakın kliniğe götürmelisiniz. Çünkü hiçbir uygulama veya yapay zeka, gerçek bir veteriner hekimin yapacağı acil müdahalenin yerini tutamaz.',
                    ),
                    _buildFAQItem(
                      context,
                      'Yapay zeka teşhis koyup reçete yazabilir mi?',
                      'Hayır, yapay zeka bir doktor değildir. İlaç yazamaz veya doktorun verdiği tedaviyi değiştiremez. Sadece genel bakım ve beslenme gibi konularda bilgi verir.',
                    ),
                    _buildFAQItem(
                      context,
                      'Uygulama otomatik hastalık takibi yapıp hatırlatma gönderir mi?',
                      'Hayır, otomatik aşı, test veya ilaç dozajı hatırlatıcıları sistemde yer almamaktadır.',
                    ),

                    _buildCategoryHeader(context, 'Ödeme, Sigorta ve Yasal Süreçler'),
                    _buildFAQItem(
                      context,
                      'Fatura, ödeme veya sigorta işlemlerini buradan yapabilir miyim?',
                      'Hayır, uygulamada fatura görüntüleme, ödeme yapma, taksitlendirme veya sigorta takibi özellikleri bulunmamaktadır.',
                    ),
                    _buildFAQItem(
                      context,
                      'Ameliyat izin formlarını uygulamadan imzalayabilir miyim?',
                      'Hayır, yasal belge veya form imzalama özelliği yoktur.',
                    ),

                    _buildCategoryHeader(context, 'Veri Güvenliği ve Teknik Konular'),
                    _buildFAQItem(
                      context,
                      'Görseller ve tıbbi veriler nerede saklanır?',
                      'Dosyalarınız özel ve güvenli bir dijital depoda saklanır. Hesabınızı silseniz bile yasal zorunluluk nedeniyle geçmiş sağlık kayıtları sistemde kilitli tutulmaya devam eder.',
                    ),
                    _buildFAQItem(
                      context,
                      'Verilerim güvende mi?',
                      'Evet, özel dosyalarınızı sadece siz ve veteriner hekiminiz görebilir.',
                    ),
                    _buildFAQItem(
                      context,
                      'İnternetim yoksa uygulamayı kullanabilir miyim?',
                      'Hayır, uygulamanın çalışması için aktif bir internet bağlantısı gereklidir.',
                    ),
                    _buildFAQItem(
                      context,
                      'Uygulama çökerse ne olur?',
                      'Sistemdeki teknik hatalar otomatik olarak kaydedilir ve yazılım ekibi tarafından düzeltilir.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.gutter,
        bottom: AppDimensions.spacingSm,
        left: AppDimensions.spacingMd,
        right: AppDimensions.spacingMd,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
          ),
          const SizedBox(height: AppDimensions.gutter),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sıkça Sorulan Sorular',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
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

  Widget _buildCategoryHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.spacingMd,
        bottom: AppDimensions.spacingSm,
        left: AppDimensions.spacingXs,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Text(
              answer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
