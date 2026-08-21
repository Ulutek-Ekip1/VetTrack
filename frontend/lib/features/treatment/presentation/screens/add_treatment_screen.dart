import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import '../../presentation/utils/treatment_category_localization.dart';
import '../cubit/treatment_cubit.dart';
import '../cubit/treatment_state.dart';

class AddTreatmentScreen extends StatefulWidget {
  final String visitId;

  const AddTreatmentScreen({
    super.key,
    required this.visitId,
  });

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _treatmentTitleController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Aşı';

  @override
  void dispose() {
    _treatmentTitleController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _showDosageField =>
      _selectedCategory == 'Aşı' || _selectedCategory == 'İlaç';

  String get _titleLabel {
    switch (_selectedCategory) {
      case 'Aşı':
        return 'Aşı Adı';
      case 'İlaç':
        return 'İlaç / Reçete Adı';
      case 'Operasyon':
        return 'Operasyon / Ameliyat Adı';
      case 'Röntgen':
        return 'Çekim / Röntgen Adı';
      case 'Laboratuvar':
        return 'Tahlil / Test Adı';
      case 'Not':
        return 'Not Başlığı';
      default:
        return 'İşlem Adı';
    }
  }

  String get _titleHint {
    switch (_selectedCategory) {
      case 'Aşı':
        return 'Örn: Karma Aşı, Kuduz Aşısı';
      case 'İlaç':
        return 'Örn: Amoksisilin 250mg, Veteriner Şurup';
      case 'Operasyon':
        return 'Örn: Dişi Kısırlaştırma, Kırık Operasyonu';
      case 'Röntgen':
        return 'Örn: Göğüs Röntgeni, Sol Arka Bacak';
      case 'Laboratuvar':
        return 'Örn: Tam Kan Sayımı (Hemogram), Biyokimya';
      case 'Not':
        return 'Örn: Genel Muayene Değerlendirmesi';
      default:
        return 'Örn: Yapılan işlem adı';
    }
  }

  IconData get _titleIcon {
    switch (_selectedCategory) {
      case 'Aşı':
        return Icons.vaccines_rounded;
      case 'İlaç':
        return Icons.medication_rounded;
      case 'Operasyon':
        return Icons.content_cut_rounded;
      case 'Röntgen':
        return Icons.camera_rounded;
      case 'Laboratuvar':
        return Icons.science_rounded;
      case 'Not':
        return Icons.note_alt_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  String get _notesLabel {
    switch (_selectedCategory) {
      case 'Aşı':
        return 'Uygulama Notları & Açıklama';
      case 'İlaç':
        return 'Kullanım Talimatı ve Reçete Notları';
      case 'Operasyon':
        return 'Operasyon Notları & Detaylar';
      case 'Röntgen':
        return 'Röntgen Bulguları ve Değerlendirme';
      case 'Laboratuvar':
        return 'Tahlil Sonuçları & Değerlendirme';
      case 'Not':
        return 'Açıklama ve Detaylar';
      default:
        return 'Açıklama ve Detaylar';
    }
  }

  String get _notesHint {
    switch (_selectedCategory) {
      case 'Aşı':
        return 'Örn: Sağ kürek kemiği altı SC uygulandı. Yan etki gözlenmedi.';
      case 'İlaç':
        return 'Örn: Günde 2 defa tok karnına verilecek. 7 gün sürecek.';
      case 'Operasyon':
        return 'Örn: Anestezi altında başarıyla yapıldı. Dikişler 10 gün sonra alınacak.';
      case 'Röntgen':
        return 'Örn: Sol femurda kırık hattı izlendi, eklem aralığı normal.';
      case 'Laboratuvar':
        return 'Örn: WBC ve RBC değerleri normal referans aralığında.';
      case 'Not':
        return 'Örn: Hasta sahibine evde bakım talimatları aktarıldı.';
      default:
        return 'Açıklama ekleyebilirsiniz...';
    }
  }

  String get _titleValidationError {
    switch (_selectedCategory) {
      case 'Aşı':
        return 'Lütfen aşı adını girin';
      case 'İlaç':
        return 'Lütfen ilaç adını girin';
      case 'Operasyon':
        return 'Lütfen operasyon adını girin';
      case 'Röntgen':
        return 'Lütfen röntgen / çekim adını girin';
      case 'Laboratuvar':
        return 'Lütfen tahlil / test adını girin';
      default:
        return 'Lütfen başlık bilgisini girin';
    }
  }

  void _onSaveTreatment() {
    if (_formKey.currentState!.validate()) {
      final description = [
        if (_showDosageField && _dosageController.text.trim().isNotEmpty)
          'Doz/Sıklık: ${_dosageController.text.trim()}',
        if (_notesController.text.trim().isNotEmpty)
          'Açıklama: ${_notesController.text.trim()}',
      ].join('\n');

      context.read<TreatmentCubit>().addTreatment(
            visitId: widget.visitId,
            type:
                TreatmentCategoryLocalization.categoryToType(_selectedCategory),
            title: _treatmentTitleController.text.trim(),
            description: description.isNotEmpty ? description : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<TreatmentCubit, TreatmentState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is TreatmentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is TreatmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tedavi & Reçete Ekle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form Header & Visit Tag
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _titleIcon,
                                  color: theme.colorScheme.primary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Medikal İşlem Girişi',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Ziyaret #${widget.visitId.toShortId()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),

                          // İşlem Türü Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'İşlem Türü',
                              prefixIcon: const Icon(Icons.category_rounded),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Aşı', child: Text('Aşı Uygulaması')),
                              DropdownMenuItem(
                                  value: 'İlaç',
                                  child: Text('İlaç Tedavisi / Reçete')),
                              DropdownMenuItem(
                                  value: 'Operasyon',
                                  child: Text('Cerrahi Operasyon')),
                              DropdownMenuItem(
                                  value: 'Röntgen',
                                  child: Text('Röntgen / Görüntüleme')),
                              DropdownMenuItem(
                                  value: 'Laboratuvar',
                                  child: Text('Laboratuvar / Tahlil')),
                              DropdownMenuItem(
                                  value: 'Not', child: Text('Diğer Notlar')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Dinamik İşlem / Tedavi Adı
                          TextFormField(
                            controller: _treatmentTitleController,
                            decoration: InputDecoration(
                              labelText: _titleLabel,
                              hintText: _titleHint,
                              prefixIcon: Icon(_titleIcon),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? _titleValidationError
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Sadece Aşı ve İlaç seçildiğinde görünen Doz / Kullanım Sıklığı
                          if (_showDosageField) ...[
                            TextFormField(
                              controller: _dosageController,
                              decoration: InputDecoration(
                                labelText: 'Doz / Kullanım Sıklığı',
                                hintText: 'Örn: Günde 2 defa 1 tablet (7 gün)',
                                prefixIcon: const Icon(
                                    Icons.medical_services_outlined),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Dinamik Kullanım Talimatı ve Açıklama Notu
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: _notesLabel,
                              hintText: _notesHint,
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 40),
                                child: Icon(Icons.description_rounded),
                              ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Action Buttons
                          BlocBuilder<TreatmentCubit, TreatmentState>(
                            builder: (context, state) {
                              final isLoading = state is TreatmentLoading;
                              return Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => Navigator.of(context).pop(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'İptal',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          isLoading ? null : _onSaveTreatment,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        theme.colorScheme
                                                            .onPrimary),
                                              ),
                                            )
                                          : const Icon(Icons.check_circle_rounded),
                                      label: Text(
                                        isLoading
                                            ? 'Kaydediliyor...'
                                            : 'İşlemi Kaydet',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


