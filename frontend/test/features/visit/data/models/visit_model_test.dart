import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/features/visit/data/models/visit_model.dart';

void main() {
  group('VisitModel.fromJson', () {
    test('should parse correctly when all fields are valid with camelCase keys', () {
      final json = {
        'id': 'v1',
        'petId': 'p1',
        'vetStaffId': 'vs1',
        'vetStaffName': 'Dr. House',
        'status': 'ongoing',
        'startedAt': '2026-08-19T12:00:00.000Z',
        'endedAt': '2026-08-19T13:00:00.000Z',
        'chiefComplaint': 'Coughing',
      };

      final result = VisitModel.fromJson(json);

      expect(result.id, 'v1');
      expect(result.petId, 'p1');
      expect(result.vetStaffId, 'vs1');
      expect(result.vetStaffName, 'Dr. House');
      expect(result.status, 'ongoing');
      expect(result.startedAt, DateTime.parse('2026-08-19T12:00:00.000Z'));
      expect(result.endedAt, DateTime.parse('2026-08-19T13:00:00.000Z'));
      expect(result.chiefComplaint, 'Coughing');
    });

    test('should parse correctly with snake_case keys', () {
      final json = {
        'id': 123,
        'pet_id': 'p2',
        'vet_staff_id': 'vs2',
        'vet_staff_name': 'Dr. Watson',
        'status': 'completed',
        'started_at': '2026-08-19T14:00:00.000Z',
        'ended_at': '2026-08-19T15:00:00.000Z',
        'chief_complaint': 'Checkup',
      };

      final result = VisitModel.fromJson(json);

      expect(result.id, '123');
      expect(result.petId, 'p2');
      expect(result.vetStaffId, 'vs2');
      expect(result.vetStaffName, 'Dr. Watson');
      expect(result.status, 'completed');
      expect(result.startedAt, DateTime.parse('2026-08-19T14:00:00.000Z'));
      expect(result.endedAt, DateTime.parse('2026-08-19T15:00:00.000Z'));
      expect(result.chiefComplaint, 'Checkup');
    });

    test('should throw FormatException when startedAt is missing', () {
      final json = {
        'id': 'v2',
        'petId': 'p2',
        'vetStaffId': 'vs2',
        'status': 'ongoing',
      };

      expect(() => VisitModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when startedAt is null', () {
      final json = {
        'id': 'v3',
        'petId': 'p3',
        'vetStaffId': 'vs3',
        'status': 'ongoing',
        'startedAt': null,
      };

      expect(() => VisitModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when startedAt is malformed', () {
      final json = {
        'id': 'v4',
        'petId': 'p4',
        'vetStaffId': 'vs4',
        'status': 'ongoing',
        'startedAt': 'not-a-date',
      };

      expect(() => VisitModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when startedAt is not a String type', () {
      final json = {
        'id': 'v5',
        'petId': 'p5',
        'vetStaffId': 'vs5',
        'status': 'ongoing',
        'startedAt': 123456789,
      };

      expect(() => VisitModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when endedAt is malformed', () {
      final json = {
        'id': 'v6',
        'petId': 'p6',
        'vetStaffId': 'vs6',
        'status': 'ongoing',
        'startedAt': '2026-08-19T12:00:00.000Z',
        'endedAt': 'not-a-date',
      };

      expect(() => VisitModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should throw FormatException when endedAt is not a String type', () {
      final json = {
        'id': 'v7',
        'petId': 'p7',
        'vetStaffId': 'vs7',
        'status': 'ongoing',
        'startedAt': '2026-08-19T12:00:00.000Z',
        'endedAt': true,
      };

      expect(() => VisitModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should parse correctly when endedAt is null or missing', () {
      final json = {
        'id': 'v8',
        'petId': 'p8',
        'vetStaffId': 'vs8',
        'status': 'ongoing',
        'startedAt': '2026-08-19T12:00:00.000Z',
        'endedAt': null,
      };

      final result = VisitModel.fromJson(json);

      expect(result.id, 'v8');
      expect(result.startedAt, DateTime.parse('2026-08-19T12:00:00.000Z'));
      expect(result.endedAt, isNull);
    });
  });

  group('VisitModel.toJson', () {
    test('should serialize correctly', () {
      final model = VisitModel(
        id: 'v9',
        petId: 'p9',
        vetStaffId: 'vs9',
        vetStaffName: 'Dr. Gregory',
        status: 'completed',
        startedAt: DateTime.parse('2026-08-19T10:00:00.000Z'),
        endedAt: DateTime.parse('2026-08-19T11:00:00.000Z'),
        chiefComplaint: 'Limping',
      );

      final json = model.toJson();

      expect(json['id'], 'v9');
      expect(json['petId'], 'p9');
      expect(json['vetStaffId'], 'vs9');
      expect(json['vetStaffName'], 'Dr. Gregory');
      expect(json['status'], 'completed');
      expect(json['startedAt'], '2026-08-19T10:00:00.000Z');
      expect(json['endedAt'], '2026-08-19T11:00:00.000Z');
      expect(json['chiefComplaint'], 'Limping');
    });
  });
}
