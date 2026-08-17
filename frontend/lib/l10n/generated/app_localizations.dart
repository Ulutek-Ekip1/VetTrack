import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'VetTrack'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @offline.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışısınız'**
  String get offline;

  /// No description provided for @offlineMode.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı moddasınız'**
  String get offlineMode;

  /// No description provided for @connectionErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Hatası'**
  String get connectionErrorTitle;

  /// No description provided for @retryConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı tekrar dene'**
  String get retryConnection;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @notificationsLoading.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler yükleniyor'**
  String get notificationsLoading;

  /// No description provided for @noNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bildiriminiz yok'**
  String get noNotifications;

  /// No description provided for @markAllNotificationsRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Okundu Yap'**
  String get markAllNotificationsRead;

  /// No description provided for @doctorPanelTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veteriner Hekim Paneli'**
  String get doctorPanelTitle;

  /// No description provided for @patientSearchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hasta Arama ve Muayene'**
  String get patientSearchTitle;

  /// No description provided for @accessCodeInstructions.
  ///
  /// In tr, this message translates to:
  /// **'Hasta sahibinin paylaştığı erişim kodunu giriniz.'**
  String get accessCodeInstructions;

  /// No description provided for @accessCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Geçici Erişim Kodu'**
  String get accessCodeLabel;

  /// No description provided for @accessCodeHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: A8X23J'**
  String get accessCodeHint;

  /// No description provided for @searchPatient.
  ///
  /// In tr, this message translates to:
  /// **'Hastayı Ara'**
  String get searchPatient;

  /// No description provided for @openVisitFound.
  ///
  /// In tr, this message translates to:
  /// **'Açık muayene bulundu'**
  String get openVisitFound;

  /// No description provided for @openVisitActionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu hasta için açık bir muayene bulundu. Devam etmek için aşağıdaki aksiyonu kullanın.'**
  String get openVisitActionMessage;

  /// No description provided for @openVisitBlockedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yeni muayene başlatılamaz. Devam eden muayeneyi açarak işlemlere devam edin.'**
  String get openVisitBlockedMessage;

  /// No description provided for @goToOpenVisit.
  ///
  /// In tr, this message translates to:
  /// **'Açık Muayeneye Git'**
  String get goToOpenVisit;

  /// No description provided for @pastVisitCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} geçmiş ziyaret bulundu.'**
  String pastVisitCount(int count);

  /// No description provided for @deletePetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Evcil Hayvanı Sil'**
  String get deletePetTitle;

  /// No description provided for @softDeletePetDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu evcil hayvan uygulama listelerinden kaldırılacak. Bu işlemi uygulama içinde geri alamazsınız. Sağlık geçmişi güvenli biçimde soft-delete olarak saklanır.'**
  String get softDeletePetDescription;

  /// No description provided for @confirmDelete.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Sil'**
  String get confirmDelete;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @addPetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hayvan Ekle'**
  String get addPetTitle;

  /// No description provided for @editPetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dostu Düzenle'**
  String get editPetTitle;

  /// No description provided for @deletePetTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Evcil Hayvanı Sil'**
  String get deletePetTooltip;

  /// No description provided for @petNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adı *'**
  String get petNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet *'**
  String get genderLabel;

  /// No description provided for @male.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get male;

  /// No description provided for @female.
  ///
  /// In tr, this message translates to:
  /// **'Dişi'**
  String get female;

  /// No description provided for @unknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get unknown;

  /// No description provided for @speciesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Türü * (örn. Kedi, Köpek)'**
  String get speciesLabel;

  /// No description provided for @breedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Cinsi / Irkı (örn. Tekir, Golden)'**
  String get breedLabel;

  /// No description provided for @ageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yaş'**
  String get ageLabel;

  /// No description provided for @saving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get saving;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @updating.
  ///
  /// In tr, this message translates to:
  /// **'Güncelleniyor...'**
  String get updating;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @emailAddress.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi giriniz'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In tr, this message translates to:
  /// **'Şifrenizi giriniz'**
  String get passwordHint;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Adınızı ve soyadınızı giriniz'**
  String get fullNameHint;

  /// No description provided for @phoneOptional.
  ///
  /// In tr, this message translates to:
  /// **'Telefon (Opsiyonel)'**
  String get phoneOptional;

  /// No description provided for @passwordRequirements.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter, harf ve rakam içermelidir'**
  String get passwordRequirements;

  /// No description provided for @kvkkTitle.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni'**
  String get kvkkTitle;

  /// No description provided for @explicitConsentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık Rıza Metni'**
  String get explicitConsentTitle;

  /// No description provided for @acknowledge.
  ///
  /// In tr, this message translates to:
  /// **'Okudum, Anladım'**
  String get acknowledge;

  /// No description provided for @register.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabınız var mı?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get signIn;

  /// No description provided for @kvkkBody.
  ///
  /// In tr, this message translates to:
  /// **'VETTRACK KİŞİSEL VERİLERİN İŞLENMESİ AYDINLATMA METNİ\n\n1. Veri Sorumlusunun Kimliği\nVetTrack (\"Şirket/Geliştirici\") olarak, 6698 sayılı Kişisel Verileri Koruma Kanunu (“KVKK”) uyarınca, veri sorumlusu sıfatıyla kişisel verilerinizi aşağıda açıklanan kapsamda işlemekteyiz.\n\n2. İşlenen Kişisel Verileriniz ve İşleme Amaçları\nVetTrack platformuna kayıt olmanız ve hizmetlerimizi kullanmanız kapsamında,\n- Kimlik Verileri: Ad, soyad\n- İletişim Verileri: E-posta adresi, telefon numarası\n- İşlem Güvenliği Verileri: Şifre, IP adresi, giriş kayıtları\n- Hizmet/Sistem Verileri: Evcil hayvan profilleri, aşı ve muayene takip takvimleri\n\nBu veriler, üyelik kayıt süreçlerinin yürütülmesi, evcil hayvan sağlık ve bakım takibinin sağlanması, kullanıcı hesabının güvenliğinin temini ve sistem hatalarının giderilmesi amaçlarıyla işlenmektedir.\n\n3. Kişisel Verilerin Aktarılması\nKişisel verileriniz, kanunen yetkili kamu kurum ve kuruluşları ile uygulamanın teknik altyapısını sağlayan güvenli sunucu (hosting/cloud) hizmet sağlayıcıları dışında üçüncü şahıslarla paylaşılmamaktadır.\n\n4. Toplama Yöntemi ve Hukuki Sebebi\nVerileriniz, elektronik ortamda kayıt formu aracılığıyla; \"Bir sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması\" ve \"Veri sorumlusunun hukuki yükümlülüğünü yerine getirebilmesi\" hukuki sebeplerine dayanarak toplanmaktadır.\n\n5. KVKK Madde 11 Kapsamındaki Haklarınız\nVeri sahibi olarak; verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, silinmesini veya düzeltilmesini isteme haklarına sahipsiniz. Haklarınızı kullanmak için destek@vettrack.com adresi üzerinden bizimle iletişime geçebilirsiniz.'**
  String get kvkkBody;

  /// No description provided for @explicitConsentBody.
  ///
  /// In tr, this message translates to:
  /// **'VETTRACK AÇIK RIZA METNİ\n\nVetTrack tarafından, sunulan hizmetlerin iyileştirilmesi, kampanya,\nbildirim ve hatırlatmaların (aşı günü, parazit takibi vb.) e-posta\nveya mobil bildirim yoluyla tarafıma iletilmesi amacıyla iletişim\nverilerimin işlenmesine ve kampanya/bilgilendirme iletileri gönderilmesine\nözgür irademle onay veriyorum.'**
  String get explicitConsentBody;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin, size bir şifre sıfırlama bağlantısı gönderelim.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama Bağlantısı Gönder'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Ekranına Dön'**
  String get backToLogin;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine şifre sıfırlama bağlantısı gönderildi!'**
  String passwordResetEmailSent(String email);

  /// No description provided for @copyright.
  ///
  /// In tr, this message translates to:
  /// **'© 2026 VetTrack Health Systems. Tüm hakları saklıdır.'**
  String get copyright;

  /// No description provided for @verificationEmailResent.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama e-postası tekrar gönderildi.'**
  String get verificationEmailResent;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen e-postanızı doğrulayın'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailDescription.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı aktifleştirmek için gelen kutunuzu kontrol edin.'**
  String get verifyEmailDescription;

  /// No description provided for @checkSpamTitle.
  ///
  /// In tr, this message translates to:
  /// **'Spam klasörüne bakın'**
  String get checkSpamTitle;

  /// No description provided for @checkSpamDescription.
  ///
  /// In tr, this message translates to:
  /// **'Eğer e-posta 2 dakika içinde gelmezse lütfen gereksiz (spam) klasörünüzü kontrol edin.'**
  String get checkSpamDescription;

  /// No description provided for @returnToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş ekranına dön'**
  String get returnToLogin;

  /// No description provided for @emailNotReceived.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı almadınız mı?'**
  String get emailNotReceived;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı tekrar gönder'**
  String get resendVerificationEmail;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre Belirle'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı güvende tutmak için lütfen güçlü ve benzersiz bir şifre seçin.'**
  String get resetPasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifrenizi giriniz'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre (Tekrar)'**
  String get confirmNewPassword;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifrenizi tekrar giriniz'**
  String get confirmNewPasswordHint;

  /// No description provided for @updatePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get updatePassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor'**
  String get passwordsDoNotMatch;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @passwordUpdateErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Güncelleme Hatası'**
  String get passwordUpdateErrorTitle;

  /// No description provided for @passwordUpdatedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz başarıyla güncellendi. Yeni şifrenizle giriş yapabilirsiniz.'**
  String get passwordUpdatedMessage;

  /// No description provided for @passwordResetSessionMissing.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir şifre yenileme oturumu bulunamadı. Lütfen e-postanıza gönderilen sıfırlama bağlantısına tıklayarak tekrar deneyiniz.'**
  String get passwordResetSessionMissing;

  /// No description provided for @passwordMustDiffer.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifreniz eski şifrenizle aynı olamaz.'**
  String get passwordMustDiffer;

  /// No description provided for @passwordResetLinkExpired.
  ///
  /// In tr, this message translates to:
  /// **'Şifre sıfırlama bağlantısının süresi dolmuş. Lütfen yeni bir bağlantı talep ediniz.'**
  String get passwordResetLinkExpired;

  /// No description provided for @passwordUpdateGenericError.
  ///
  /// In tr, this message translates to:
  /// **'Şifre güncellenirken bir sorun oluştu. Lütfen tekrar deneyin.'**
  String get passwordUpdateGenericError;

  /// No description provided for @signInBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Engellendi'**
  String get signInBlocked;

  /// No description provided for @welcomeUser.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldiniz, {name}'**
  String welcomeUser(String name);

  /// No description provided for @vetStaffLogin.
  ///
  /// In tr, this message translates to:
  /// **'Veteriner Personel Girişi'**
  String get vetStaffLogin;

  /// No description provided for @signInDescription.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için e-posta ve şifrenizle giriş yapın'**
  String get signInDescription;

  /// No description provided for @vetLoginDescription.
  ///
  /// In tr, this message translates to:
  /// **'Klinik yönetim paneline erişmek için personel hesabınızı kullanın.'**
  String get vetLoginDescription;

  /// No description provided for @enterPassword.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen şifrenizi girin'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In tr, this message translates to:
  /// **'Beni Hatırla'**
  String get rememberMe;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum?'**
  String get forgotPasswordQuestion;

  /// No description provided for @or.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get or;

  /// No description provided for @signInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Giriş Yap'**
  String get signInWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınız yok mu?'**
  String get noAccount;

  /// No description provided for @personalInformation.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Bilgiler'**
  String get personalInformation;

  /// No description provided for @profileUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profiliniz başarıyla güncellendi!'**
  String get profileUpdated;

  /// No description provided for @profileLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil bilgileri yüklenemedi.'**
  String get profileLoadFailed;

  /// No description provided for @firstName.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get lastName;

  /// No description provided for @emailReadOnly.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi (Değiştirilemez)'**
  String get emailReadOnly;

  /// No description provided for @phoneNumber.
  ///
  /// In tr, this message translates to:
  /// **'Telefon Numarası'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In tr, this message translates to:
  /// **'05XX XXX XX XX'**
  String get phoneHint;

  /// No description provided for @address.
  ///
  /// In tr, this message translates to:
  /// **'Adres'**
  String get address;

  /// No description provided for @profileViewDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel profil bilgilerinizi aşağıdan inceleyebilirsiniz. Değişiklik yapmak için aşağıdaki \'Bilgileri Düzenle\' butonuna tıklayın.'**
  String get profileViewDescription;

  /// No description provided for @profileEditDescription.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdaki alanları güncelleyerek profilinizi güncel tutabilirsiniz.'**
  String get profileEditDescription;

  /// No description provided for @editInformation.
  ///
  /// In tr, this message translates to:
  /// **'Bilgileri Düzenle'**
  String get editInformation;

  /// No description provided for @saveChanges.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri Kaydet'**
  String get saveChanges;

  /// No description provided for @myProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profilim'**
  String get myProfile;

  /// No description provided for @petOwner.
  ///
  /// In tr, this message translates to:
  /// **'Hayvan Sahibi'**
  String get petOwner;

  /// No description provided for @accountSettings.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Ayarları'**
  String get accountSettings;

  /// No description provided for @myPets.
  ///
  /// In tr, this message translates to:
  /// **'Evcil Hayvanlarım'**
  String get myPets;

  /// No description provided for @myPetsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı evcil hayvanların listesi'**
  String get myPetsDescription;

  /// No description provided for @personalInformationDescription.
  ///
  /// In tr, this message translates to:
  /// **'Ad soyad, telefon ve e-posta ayarları'**
  String get personalInformationDescription;

  /// No description provided for @supportAndInformation.
  ///
  /// In tr, this message translates to:
  /// **'Destek ve Bilgi'**
  String get supportAndInformation;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In tr, this message translates to:
  /// **'Sıkça Sorulan Sorular'**
  String get frequentlyAskedQuestions;

  /// No description provided for @frequentlyAskedQuestionsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama kullanımı hakkında yardımlar'**
  String get frequentlyAskedQuestionsDescription;

  /// No description provided for @privacyAndSecurity.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik Sözleşmesi'**
  String get privacyAndSecurity;

  /// No description provided for @privacyAndSecurityDescription.
  ///
  /// In tr, this message translates to:
  /// **'Verilerin korunması ve yasal maddeler'**
  String get privacyAndSecurityDescription;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Hesaptan Çıkış Yap'**
  String get signOut;

  /// No description provided for @vetProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Veteriner Hekim Profili'**
  String get vetProfileTitle;

  /// No description provided for @vetSpecialist.
  ///
  /// In tr, this message translates to:
  /// **'Uzman Veteriner Hekim'**
  String get vetSpecialist;

  /// No description provided for @welcomeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Evcil hayvanınızın sağlık, bakım ve muayene süreçlerini tek bir yerden kolayca takip edin.'**
  String get welcomeDescription;

  /// No description provided for @quickGoogleSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Hızlı Giriş'**
  String get quickGoogleSignIn;

  /// No description provided for @myAnimals.
  ///
  /// In tr, this message translates to:
  /// **'Hayvanlarım'**
  String get myAnimals;

  /// No description provided for @searchPetByNameOrCode.
  ///
  /// In tr, this message translates to:
  /// **'İsim veya 6 haneli kod ile ara...'**
  String get searchPetByNameOrCode;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @addNewPet.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hayvan Ekle'**
  String get addNewPet;

  /// No description provided for @noPetsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir evcil hayvan eklemedin'**
  String get noPetsYet;

  /// No description provided for @noPetsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Aşağıdaki \'Yeni Hayvan Ekle\' butonuna basarak ilk evcil hayvanınızın profilini oluşturun.'**
  String get noPetsDescription;

  /// No description provided for @petNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Pet bulunamadı.'**
  String get petNotFound;

  /// No description provided for @discardChangesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydetmeden Çık?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri kaydetmeden çıkmak istiyor musunuz?'**
  String get discardChangesDescription;

  /// No description provided for @exitWithoutSaving.
  ///
  /// In tr, this message translates to:
  /// **'Evet, Çık'**
  String get exitWithoutSaving;

  /// No description provided for @petPhotoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dost resmi'**
  String get petPhotoTitle;

  /// No description provided for @camera.
  ///
  /// In tr, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @addRecommendation.
  ///
  /// In tr, this message translates to:
  /// **'Öneri Ekle ({visitId})'**
  String addRecommendation(String visitId);

  /// No description provided for @recommendationType.
  ///
  /// In tr, this message translates to:
  /// **'Öneri Türü'**
  String get recommendationType;

  /// No description provided for @recommendationDescription.
  ///
  /// In tr, this message translates to:
  /// **'Öneri Detayı ve Açıklaması'**
  String get recommendationDescription;

  /// No description provided for @recommendationRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen öneri detayını yazın'**
  String get recommendationRequired;

  /// No description provided for @saveRecommendation.
  ///
  /// In tr, this message translates to:
  /// **'Öneriyi Kaydet'**
  String get saveRecommendation;

  /// No description provided for @nutrition.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme / Mama'**
  String get nutrition;

  /// No description provided for @hygiene.
  ///
  /// In tr, this message translates to:
  /// **'Kum / Hijyen'**
  String get hygiene;

  /// No description provided for @generalCare.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakım & Diğer'**
  String get generalCare;

  /// No description provided for @addTreatment.
  ///
  /// In tr, this message translates to:
  /// **'Tedavi/Reçete Ekle ({visitId})'**
  String addTreatment(String visitId);

  /// No description provided for @treatmentType.
  ///
  /// In tr, this message translates to:
  /// **'İşlem Türü'**
  String get treatmentType;

  /// No description provided for @treatmentName.
  ///
  /// In tr, this message translates to:
  /// **'Tedavi Adı/ Aşı Adı'**
  String get treatmentName;

  /// No description provided for @treatmentRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tedavi adını girin'**
  String get treatmentRequired;

  /// No description provided for @dosageFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Doz / Kullanım Sıklığı'**
  String get dosageFrequency;

  /// No description provided for @treatmentInstructions.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Talimatı ve Açıklama'**
  String get treatmentInstructions;

  /// No description provided for @saveTreatment.
  ///
  /// In tr, this message translates to:
  /// **'Tedaviyi Kaydet'**
  String get saveTreatment;

  /// No description provided for @savingTreatment.
  ///
  /// In tr, this message translates to:
  /// **'Tedavi Kaydediliyor...'**
  String get savingTreatment;

  /// No description provided for @treatmentsAndPrescriptions.
  ///
  /// In tr, this message translates to:
  /// **'Tedaviler & Reçeteler'**
  String get treatmentsAndPrescriptions;

  /// No description provided for @treatmentHistoryLoading.
  ///
  /// In tr, this message translates to:
  /// **'Tedavi geçmişi yükleniyor'**
  String get treatmentHistoryLoading;

  /// No description provided for @treatmentHistoryLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Tedavi geçmişi yüklenemedi.'**
  String get treatmentHistoryLoadFailed;

  /// No description provided for @noTreatmentRecords.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tedavi kaydı yok.'**
  String get noTreatmentRecords;

  /// No description provided for @aiAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'AI Analizi'**
  String get aiAnalysis;

  /// No description provided for @recommendationsLoading.
  ///
  /// In tr, this message translates to:
  /// **'Öneriler yükleniyor'**
  String get recommendationsLoading;

  /// No description provided for @noRecommendations.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı Öneri Bulunamadı'**
  String get noRecommendations;

  /// No description provided for @noRecommendationsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Evcil hayvanınız için şu anda tanımlanmış bir öneri bulunmamaktadır. Muayene sonrası veteriner hekiminiz öneriler ekleyebilir.'**
  String get noRecommendationsDescription;

  /// No description provided for @aiQuestionPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Kafanıza takılan bir soru mu var?'**
  String get aiQuestionPrompt;

  /// No description provided for @aiChatDescription.
  ///
  /// In tr, this message translates to:
  /// **'AI Sohbet Asistanımız ile evcil hayvanınızın sağlığı hakkında her şeyi anında konuşabilirsiniz.'**
  String get aiChatDescription;

  /// No description provided for @chatWithAiAssistant.
  ///
  /// In tr, this message translates to:
  /// **'AI Asistan ile Sohbet Et'**
  String get chatWithAiAssistant;

  /// No description provided for @all.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  /// No description provided for @health.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get health;

  /// No description provided for @general.
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get general;

  /// No description provided for @nutritionRecommendation.
  ///
  /// In tr, this message translates to:
  /// **'Beslenme Önerisi'**
  String get nutritionRecommendation;

  /// No description provided for @hygieneRecommendation.
  ///
  /// In tr, this message translates to:
  /// **'Kum & Hijyen Önerisi'**
  String get hygieneRecommendation;

  /// No description provided for @generalRecommendation.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bakım & Diğer Öneriler'**
  String get generalRecommendation;

  /// No description provided for @recommendedFoods.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen Mamalar'**
  String get recommendedFoods;

  /// No description provided for @askAiAssistant.
  ///
  /// In tr, this message translates to:
  /// **'AI Asistan\'a Sor'**
  String get askAiAssistant;

  /// No description provided for @details.
  ///
  /// In tr, this message translates to:
  /// **'Detaylar'**
  String get details;

  /// No description provided for @openPetProfile.
  ///
  /// In tr, this message translates to:
  /// **'{name} profili'**
  String openPetProfile(String name);

  /// No description provided for @healthHistory.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık Geçmişi'**
  String get healthHistory;

  /// No description provided for @notes.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notes;

  /// No description provided for @generalInformation.
  ///
  /// In tr, this message translates to:
  /// **'Genel Bilgiler'**
  String get generalInformation;

  /// No description provided for @uniqueCode.
  ///
  /// In tr, this message translates to:
  /// **'Benzersiz Kod'**
  String get uniqueCode;

  /// No description provided for @species.
  ///
  /// In tr, this message translates to:
  /// **'Türü'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In tr, this message translates to:
  /// **'Cinsi / Irkı'**
  String get breed;

  /// No description provided for @age.
  ///
  /// In tr, this message translates to:
  /// **'Yaş'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get gender;

  /// No description provided for @weightChart.
  ///
  /// In tr, this message translates to:
  /// **'Kilo Grafiği'**
  String get weightChart;

  /// No description provided for @recentActivity.
  ///
  /// In tr, this message translates to:
  /// **'Son Aktivite'**
  String get recentActivity;

  /// No description provided for @deleteChat.
  ///
  /// In tr, this message translates to:
  /// **'Sohbeti Sil'**
  String get deleteChat;

  /// No description provided for @deleteChatDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu sohbet oturumunu ve tüm mesajlarını silmek istediğinize emin misiniz? Bu işlem geri alınamaz (KVKK).'**
  String get deleteChatDescription;

  /// No description provided for @chatDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet oturumu başarıyla silindi.'**
  String get chatDeleted;

  /// No description provided for @chatDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet silinirken bir hata oluştu.'**
  String get chatDeleteFailed;

  /// No description provided for @deleteAllHistory.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Geçmişi Sil'**
  String get deleteAllHistory;

  /// No description provided for @deleteAllHistoryDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm AI sohbet geçmişinizi kalıcı olarak silmek istediğinize emin misiniz? Tüm konuşmalarınız temizlenecek ve bu işlem geri alınamayacaktır (KVKK Unutulma Hakkı).'**
  String get deleteAllHistoryDescription;

  /// No description provided for @deleteAllHistoryPermanently.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Geçmişi Kalıcı Olarak Sil'**
  String get deleteAllHistoryPermanently;

  /// No description provided for @chatHistoryDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm AI sohbet geçmişiniz kalıcı olarak silindi.'**
  String get chatHistoryDeleted;

  /// No description provided for @chatHistoryDeleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş silinirken bir hata oluştu.'**
  String get chatHistoryDeleteFailed;

  /// No description provided for @enableNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimleri açın'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Cihaz ayarlarından VetTrack uygulamasını açıp Bildirimler iznini etkinleştirin. İzin vermeseniz de güncellemeleri uygulama içindeki Bildirimler ekranından takip edebilirsiniz.'**
  String get enableNotificationsDescription;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @doNotMissVisitUpdates.
  ///
  /// In tr, this message translates to:
  /// **'Muayene güncellemelerini kaçırmayın'**
  String get doNotMissVisitUpdates;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'İzin reddedildi. Güncellemeleri uygulama içindeki Bildirimler ekranından takip edebilirsiniz.'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationPermissionPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Tedavi ve muayene güncellemeleri için bildirim izni verin.'**
  String get notificationPermissionPrompt;

  /// No description provided for @openSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Aç'**
  String get openSettings;

  /// No description provided for @enable.
  ///
  /// In tr, this message translates to:
  /// **'Etkinleştir'**
  String get enable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
