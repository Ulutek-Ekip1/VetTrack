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
}
