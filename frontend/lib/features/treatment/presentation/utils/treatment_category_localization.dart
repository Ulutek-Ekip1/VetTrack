class TreatmentCategoryLocalization {
  TreatmentCategoryLocalization._();

  static const String defaultCategory = 'Diğer';
  static const String defaultType = 'note';

  static const Map<String, String> categoryToTypeMap = {
    'Aşı': 'vaccine',
    'İlaç': 'medication',
    'Operasyon': 'surgery',
    'Röntgen': 'xray',
    'Laboratuvar': 'lab_result',
    'Not': 'note',
  };

  /// `categoryToTypeMap`'ten otomatik türetilir — elle senkron tutmaya gerek yok.
  static final Map<String, String> typeToCategoryMap =
      categoryToTypeMap.map((category, type) => MapEntry(type, category));

  static String typeToCategory(String type) =>
      typeToCategoryMap[type] ?? defaultCategory;

  static String categoryToType(String category) =>
      categoryToTypeMap[category] ?? defaultType;
}
