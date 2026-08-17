// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'VetTrack';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get offline => 'Çevrimdışısınız';

  @override
  String get offlineMode => 'Çevrimdışı moddasınız';

  @override
  String get connectionErrorTitle => 'Bağlantı Hatası';

  @override
  String get retryConnection => 'Bağlantıyı tekrar dene';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsLoading => 'Bildirimler yükleniyor';

  @override
  String get noNotifications => 'Henüz bildiriminiz yok';

  @override
  String get markAllNotificationsRead => 'Tümünü Okundu Yap';

  @override
  String get doctorPanelTitle => 'Veteriner Hekim Paneli';

  @override
  String get patientSearchTitle => 'Hasta Arama ve Muayene';

  @override
  String get accessCodeInstructions =>
      'Hasta sahibinin paylaştığı erişim kodunu giriniz.';

  @override
  String get accessCodeLabel => 'Geçici Erişim Kodu';

  @override
  String get accessCodeHint => 'Örn: A8X23J';

  @override
  String get searchPatient => 'Hastayı Ara';

  @override
  String get openVisitFound => 'Açık muayene bulundu';

  @override
  String get openVisitActionMessage =>
      'Bu hasta için açık bir muayene bulundu. Devam etmek için aşağıdaki aksiyonu kullanın.';

  @override
  String get openVisitBlockedMessage =>
      'Yeni muayene başlatılamaz. Devam eden muayeneyi açarak işlemlere devam edin.';

  @override
  String get goToOpenVisit => 'Açık Muayeneye Git';

  @override
  String pastVisitCount(int count) => '$count geçmiş ziyaret bulundu.';

  @override
  String get deletePetTitle => 'Evcil Hayvanı Sil';

  @override
  String get softDeletePetDescription =>
      'Bu evcil hayvan uygulama listelerinden kaldırılacak. Bu işlemi uygulama içinde geri alamazsınız. Sağlık geçmişi güvenli biçimde soft-delete olarak saklanır.';

  @override
  String get confirmDelete => 'Evet, Sil';

  @override
  String get cancel => 'İptal';

  @override String get addPetTitle => 'Yeni Hayvan Ekle';
  @override String get editPetTitle => 'Dostu Düzenle';
  @override String get deletePetTooltip => 'Evcil Hayvanı Sil';
  @override String get petNameLabel => 'Adı *';
  @override String get genderLabel => 'Cinsiyet *';
  @override String get male => 'Erkek';
  @override String get female => 'Dişi';
  @override String get unknown => 'Bilinmiyor';
  @override String get speciesLabel => 'Türü * (örn. Kedi, Köpek)';
  @override String get breedLabel => 'Cinsi / Irkı (örn. Tekir, Golden)';
  @override String get ageLabel => 'Yaş';
  @override String get saving => 'Kaydediliyor...';
  @override String get save => 'Kaydet';
  @override String get updating => 'Güncelleniyor...';
  @override String get update => 'Güncelle';
  @override String get emailAddress => 'E-posta Adresi';
  @override String get emailHint => 'E-posta adresinizi giriniz';
  @override String get password => 'Şifre';
  @override String get passwordHint => 'Şifrenizi giriniz';
  @override String get fullName => 'Ad Soyad';
  @override String get fullNameHint => 'Adınızı ve soyadınızı giriniz';
  @override String get phoneOptional => 'Telefon (Opsiyonel)';
  @override String get passwordRequirements => 'En az 8 karakter, harf ve rakam içermelidir';
  @override String get kvkkTitle => 'KVKK Aydınlatma Metni';
  @override String get explicitConsentTitle => 'Açık Rıza Metni';
  @override String get acknowledge => 'Okudum, Anladım';
  @override String get register => 'Kayıt Ol';
  @override String get alreadyHaveAccount => 'Zaten hesabınız var mı?';
  @override String get signIn => 'Giriş Yap';
  @override
  String get kvkkBody => '''VETTRACK KİŞİSEL VERİLERİN İŞLENMESİ AYDINLATMA METNİ

1. Veri Sorumlusunun Kimliği
VetTrack ("Şirket/Geliştirici") olarak, 6698 sayılı Kişisel Verileri Koruma Kanunu (“KVKK”) uyarınca, veri sorumlusu sıfatıyla kişisel verilerinizi aşağıda açıklanan kapsamda işlemekteyiz.

2. İşlenen Kişisel Verileriniz ve İşleme Amaçları
VetTrack platformuna kayıt olmanız ve hizmetlerimizi kullanmanız kapsamında,
- Kimlik Verileri: Ad, soyad
- İletişim Verileri: E-posta adresi, telefon numarası
- İşlem Güvenliği Verileri: Şifre, IP adresi, giriş kayıtları
- Hizmet/Sistem Verileri: Evcil hayvan profilleri, aşı ve muayene takip takvimleri

Bu veriler, üyelik kayıt süreçlerinin yürütülmesi, evcil hayvan sağlık ve bakım takibinin sağlanması, kullanıcı hesabının güvenliğinin temini ve sistem hatalarının giderilmesi amaçlarıyla işlenmektedir.

3. Kişisel Verilerin Aktarılması
Kişisel verileriniz, kanunen yetkili kamu kurum ve kuruluşları ile uygulamanın teknik altyapısını sağlayan güvenli sunucu (hosting/cloud) hizmet sağlayıcıları dışında üçüncü şahıslarla paylaşılmamaktadır.

4. Toplama Yöntemi ve Hukuki Sebebi
Verileriniz, elektronik ortamda kayıt formu aracılığıyla; "Bir sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması" ve "Veri sorumlusunun hukuki yükümlülüğünü yerine getirebilmesi" hukuki sebeplerine dayanarak toplanmaktadır.

5. KVKK Madde 11 Kapsamındaki Haklarınız
Veri sahibi olarak; verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, silinmesini veya düzeltilmesini isteme haklarına sahipsiniz. Haklarınızı kullanmak için destek@vettrack.com adresi üzerinden bizimle iletişime geçebilirsiniz.''';
  @override
  String get explicitConsentBody => '''VETTRACK AÇIK RIZA METNİ

VetTrack tarafından, sunulan hizmetlerin iyileştirilmesi, kampanya,
bildirim ve hatırlatmaların (aşı günü, parazit takibi vb.) e-posta
veya mobil bildirim yoluyla tarafıma iletilmesi amacıyla iletişim
verilerimin işlenmesine ve kampanya/bilgilendirme iletileri gönderilmesine
özgür irademle onay veriyorum.''';
  @override String get forgotPasswordTitle => 'Şifremi Unuttum';
  @override String get forgotPasswordDescription => 'E-posta adresinizi girin, size bir şifre sıfırlama bağlantısı gönderelim.';
  @override String get sendResetLink => 'Sıfırlama Bağlantısı Gönder';
  @override String get backToLogin => 'Giriş Ekranına Dön';
  @override String passwordResetEmailSent(String email) => '$email adresine şifre sıfırlama bağlantısı gönderildi!';
  @override String get copyright => '© 2026 VetTrack Health Systems. Tüm hakları saklıdır.';
  @override String get verificationEmailResent => 'Doğrulama e-postası tekrar gönderildi.';
  @override String get verifyEmailTitle => 'Lütfen e-postanızı doğrulayın';
  @override String get verifyEmailDescription => 'Hesabınızı aktifleştirmek için gelen kutunuzu kontrol edin.';
  @override String get checkSpamTitle => 'Spam klasörüne bakın';
  @override String get checkSpamDescription => 'Eğer e-posta 2 dakika içinde gelmezse lütfen gereksiz (spam) klasörünüzü kontrol edin.';
  @override String get returnToLogin => 'Giriş ekranına dön';
  @override String get emailNotReceived => 'E-postayı almadınız mı?';
  @override String get resendVerificationEmail => 'E-postayı tekrar gönder';
  @override String get resetPasswordTitle => 'Yeni Şifre Belirle';
  @override String get resetPasswordDescription => 'Hesabınızı güvende tutmak için lütfen güçlü ve benzersiz bir şifre seçin.';
  @override String get newPassword => 'Yeni Şifre';
  @override String get newPasswordHint => 'Yeni şifrenizi giriniz';
  @override String get confirmNewPassword => 'Yeni Şifre (Tekrar)';
  @override String get confirmNewPasswordHint => 'Yeni şifrenizi tekrar giriniz';
  @override String get updatePassword => 'Şifreyi Güncelle';
  @override String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';
  @override String get success => 'Başarılı';
  @override String get passwordUpdateErrorTitle => 'Şifre Güncelleme Hatası';
  @override String get passwordUpdatedMessage => 'Şifreniz başarıyla güncellendi. Yeni şifrenizle giriş yapabilirsiniz.';
  @override String get passwordResetSessionMissing => 'Geçerli bir şifre yenileme oturumu bulunamadı. Lütfen e-postanıza gönderilen sıfırlama bağlantısına tıklayarak tekrar deneyiniz.';
  @override String get passwordMustDiffer => 'Yeni şifreniz eski şifrenizle aynı olamaz.';
  @override String get passwordResetLinkExpired => 'Şifre sıfırlama bağlantısının süresi dolmuş. Lütfen yeni bir bağlantı talep ediniz.';
  @override String get passwordUpdateGenericError => 'Şifre güncellenirken bir sorun oluştu. Lütfen tekrar deneyin.';
  @override String get signInBlocked => 'Giriş Engellendi';
  @override String welcomeUser(String name) => 'Hoş geldiniz, $name';
  @override String get vetStaffLogin => 'Veteriner Personel Girişi';
  @override String get signInDescription => 'Devam etmek için e-posta ve şifrenizle giriş yapın';
  @override String get vetLoginDescription => 'Klinik yönetim paneline erişmek için personel hesabınızı kullanın.';
  @override String get enterPassword => 'Lütfen şifrenizi girin';
  @override String get rememberMe => 'Beni Hatırla';
  @override String get forgotPasswordQuestion => 'Şifremi Unuttum?';
  @override String get or => 'veya';
  @override String get signInWithGoogle => 'Google ile Giriş Yap';
  @override String get noAccount => 'Hesabınız yok mu?';
  @override String get personalInformation => 'Kişisel Bilgiler';
  @override String get profileUpdated => 'Profiliniz başarıyla güncellendi!';
  @override String get profileLoadFailed => 'Profil bilgileri yüklenemedi.';
  @override String get firstName => 'Ad';
  @override String get lastName => 'Soyad';
  @override String get emailReadOnly => 'E-posta Adresi (Değiştirilemez)';
  @override String get phoneNumber => 'Telefon Numarası';
  @override String get phoneHint => '05XX XXX XX XX';
  @override String get address => 'Adres';
  @override String get profileViewDescription => "Kişisel profil bilgilerinizi aşağıdan inceleyebilirsiniz. Değişiklik yapmak için aşağıdaki 'Bilgileri Düzenle' butonuna tıklayın.";
  @override String get profileEditDescription => 'Aşağıdaki alanları güncelleyerek profilinizi güncel tutabilirsiniz.';
  @override String get editInformation => 'Bilgileri Düzenle';
  @override String get saveChanges => 'Değişiklikleri Kaydet';
  @override String get myProfile => 'Profilim';
  @override String get petOwner => 'Hayvan Sahibi';
  @override String get accountSettings => 'Hesap Ayarları';
  @override String get myPets => 'Evcil Hayvanlarım';
  @override String get myPetsDescription => 'Kayıtlı evcil hayvanların listesi';
  @override String get personalInformationDescription => 'Ad soyad, telefon ve e-posta ayarları';
  @override String get supportAndInformation => 'Destek ve Bilgi';
  @override String get frequentlyAskedQuestions => 'Sıkça Sorulan Sorular';
  @override String get frequentlyAskedQuestionsDescription => 'Uygulama kullanımı hakkında yardımlar';
  @override String get privacyAndSecurity => 'Gizlilik ve Güvenlik Sözleşmesi';
  @override String get privacyAndSecurityDescription => 'Verilerin korunması ve yasal maddeler';
  @override String get signOut => 'Hesaptan Çıkış Yap';
  @override String get vetProfileTitle => 'Veteriner Hekim Profili';
  @override String get vetSpecialist => 'Uzman Veteriner Hekim';
  @override String get welcomeDescription => 'Evcil hayvanınızın sağlık, bakım ve muayene süreçlerini tek bir yerden kolayca takip edin.';
  @override String get quickGoogleSignIn => 'Google ile Hızlı Giriş';
  @override String get myAnimals => 'Hayvanlarım';
  @override String get searchPetByNameOrCode => 'İsim veya 6 haneli kod ile ara...';
  @override String get edit => 'Düzenle';
  @override String get delete => 'Sil';
  @override String get addNewPet => 'Yeni Hayvan Ekle';
  @override String get noPetsYet => 'Henüz bir evcil hayvan eklemedin';
  @override String get noPetsDescription => "Aşağıdaki 'Yeni Hayvan Ekle' butonuna basarak ilk evcil hayvanınızın profilini oluşturun.";
  @override String get petNotFound => 'Pet bulunamadı.';
  @override String get discardChangesTitle => 'Kaydetmeden Çık?';
  @override String get discardChangesDescription => 'Değişiklikleri kaydetmeden çıkmak istiyor musunuz?';
  @override String get exitWithoutSaving => 'Evet, Çık';
  @override String get petPhotoTitle => 'Dost resmi';
  @override String get camera => 'Kamera';
  @override String get gallery => 'Galeri';
  @override String addRecommendation(String visitId) => 'Öneri Ekle ($visitId)';
  @override String get recommendationType => 'Öneri Türü';
  @override String get recommendationDescription => 'Öneri Detayı ve Açıklaması';
  @override String get recommendationRequired => 'Lütfen öneri detayını yazın';
  @override String get saveRecommendation => 'Öneriyi Kaydet';
  @override String get saving => 'Kaydediliyor...';
  @override String get nutrition => 'Beslenme / Mama';
  @override String get hygiene => 'Kum / Hijyen';
  @override String get generalCare => 'Genel Bakım & Diğer';
  @override String addTreatment(String visitId) => 'Tedavi/Reçete Ekle ($visitId)';
  @override String get treatmentType => 'İşlem Türü';
  @override String get treatmentName => 'Tedavi Adı/ Aşı Adı';
  @override String get treatmentRequired => 'Lütfen tedavi adını girin';
  @override String get dosageFrequency => 'Doz / Kullanım Sıklığı';
  @override String get treatmentInstructions => 'Kullanım Talimatı ve Açıklama';
  @override String get saveTreatment => 'Tedaviyi Kaydet';
  @override String get savingTreatment => 'Tedavi Kaydediliyor...';
  @override String get treatmentsAndPrescriptions => 'Tedaviler & Reçeteler';
  @override String get treatmentHistoryLoading => 'Tedavi geçmişi yükleniyor';
  @override String get treatmentHistoryLoadFailed => 'Tedavi geçmişi yüklenemedi.';
  @override String get noTreatmentRecords => 'Henüz tedavi kaydı yok.';
  @override String get aiAnalysis => 'AI Analizi';
  @override String get recommendationsLoading => 'Öneriler yükleniyor';
}
