import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:vettrack_frontend/features/pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/patient_search_result.dart';
import 'package:vettrack_frontend/features/visit/domain/entities/visit_entity.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_cubit.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_state.dart';
import 'package:vettrack_frontend/features/visit/presentation/screens/doctor_search_screen.dart';

class FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  FakeAuthCubit(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeVisitCubit extends Cubit<VisitState> implements VisitCubit {
  String? lastSearchedCode;
  String? lastSearchedClinicId;
  String? lastStartedPetId;

  FakeVisitCubit([VisitState? initialState]) : super(initialState ?? VisitInitial());

  @override
  Future<void> searchByCode(String code, String clinicId) async {
    lastSearchedCode = code;
    lastSearchedClinicId = clinicId;
  }

  @override
  Future<void> startVisit(String petId) async {
    lastStartedPetId = petId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAuthCubit fakeAuthCubit;
  late FakeVisitCubit fakeVisitCubit;

  final testPet = PetEntity(
    id: 'pet-123',
    ownerId: 'owner-123',
    name: 'Pamuk',
    gender: Gender.female,
    breed: 'Kedi / Van Kedisi',
    age: 3,
    weight: 4.2,
    uniqueCode: 'A8X23J',
    createdAt: DateTime(2025, 1, 1),
  );

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: fakeAuthCubit),
          BlocProvider<VisitCubit>.value(value: fakeVisitCubit),
        ],
        child: const DoctorSearchScreen(),
      ),
    );
  }

  setUp(() {
    fakeAuthCubit = FakeAuthCubit(
      Authenticated(
        UserEntity(
          id: 'vet-1',
          authId: 'auth-1',
          email: 'vet@vettrack.com',
          name: 'Dr. Ahmet',
          role: UserRole.vet,
          createdAt: DateTime.now(),
          clinicId: 'clinic-123',
        ),
      ),
    );
    fakeVisitCubit = FakeVisitCubit();
  });

  testWidgets('DoctorSearchScreen renders initial UI components', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Hasta Kabul & Arama'), findsOneWidget);
    expect(find.text('Hasta Erişim Kodu'), findsOneWidget);
    expect(find.text('Örn: A8X23J'), findsOneWidget);
    expect(find.text('Hastayı Bul & Getir'), findsOneWidget);
  });

  testWidgets('Submitting empty code shows warning SnackBar', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final searchButton = find.text('Hastayı Bul & Getir');
    await tester.tap(searchButton);
    await tester.pump();

    expect(find.text('Lütfen geçerli bir hasta erişim kodu girin.'), findsOneWidget);
    expect(fakeVisitCubit.lastSearchedCode, isNull);
  });

  testWidgets('Submitting code with less than 6 characters shows length warning', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'ABC');
    final searchButton = find.text('Hastayı Bul & Getir');
    await tester.tap(searchButton);
    await tester.pump();

    expect(find.text('Hasta erişim kodu 6 haneli olmalıdır (Örn: A8X23J).'), findsOneWidget);
    expect(fakeVisitCubit.lastSearchedCode, isNull);
  });

  testWidgets('Submitting 6-character code triggers searchByCode with auto-detected or provided clinicId', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'a8x23j');
    final searchButton = find.text('Hastayı Bul & Getir');
    await tester.tap(searchButton);
    await tester.pump();

    expect(fakeVisitCubit.lastSearchedCode, 'A8X23J');
    expect(fakeVisitCubit.lastSearchedClinicId, 'clinic-123');
  });

  testWidgets('Renders patient summary card and Start Visit button when patient found with no active visit', (tester) async {
    final searchResult = PatientSearchResult(
      pet: testPet,
      visits: [
        VisitEntity(
          id: 'v1',
          petId: 'pet-123',
          vetStaffId: 'vet-1',
          status: 'completed',
          startedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
    );

    fakeVisitCubit = FakeVisitCubit(VisitSearchResult(searchResult));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Pamuk'), findsOneWidget);
    expect(find.text('Kedi / Van Kedisi'), findsOneWidget);
    expect(find.text('Dişi • 3 Yaşında • 4.2 kg'), findsOneWidget);
    expect(find.text('1 geçmiş muayene kaydı bulundu.'), findsOneWidget);
    expect(find.text('Yeni Muayene Başlat'), findsOneWidget);

    final startButton = find.text('Yeni Muayene Başlat');
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();
    await tester.tap(startButton);
    await tester.pump();
    expect(fakeVisitCubit.lastStartedPetId, 'pet-123');
  });

  testWidgets('Renders active visit warning banner when active visit exists', (tester) async {
    final searchResult = PatientSearchResult(
      pet: testPet,
      visits: [
        VisitEntity(
          id: 'v-active',
          petId: 'pet-123',
          vetStaffId: 'vet-1',
          status: 'ongoing',
          startedAt: DateTime.now(),
        ),
      ],
    );

    fakeVisitCubit = FakeVisitCubit(VisitSearchResult(searchResult));
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Devam Eden Aktif Muayene Var'), findsOneWidget);
    expect(find.text('Aktif Muayeneye Git'), findsOneWidget);
    expect(find.text('Yeni Muayene Başlat'), findsNothing);
  });

  testWidgets('Clear button clears code input and search result', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'A8X23J');
    await tester.pump();

    final clearButton = find.byIcon(Icons.clear_rounded);
    expect(clearButton, findsOneWidget);

    await tester.tap(clearButton);
    await tester.pump();

    expect(find.text('A8X23J'), findsNothing);
  });

  testWidgets('When user has no clinicId, search still proceeds with empty clinicId (backend auto-detect fallback)', (tester) async {
    fakeAuthCubit = FakeAuthCubit(
      Authenticated(
        UserEntity(
          id: 'vet-2',
          authId: 'auth-2',
          email: 'vet2@vettrack.com',
          name: 'Dr. Zeynep',
          role: UserRole.vet,
          createdAt: DateTime.now(),
          clinicId: null, // No clinicId in user entity
        ),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'A8X23J');
    final searchButton = find.text('Hastayı Bul & Getir');
    await tester.tap(searchButton);
    await tester.pump();

    expect(fakeVisitCubit.lastSearchedCode, 'A8X23J');
    expect(fakeVisitCubit.lastSearchedClinicId, ''); // empty fallback passed to backend for auto-detect
  });
}
