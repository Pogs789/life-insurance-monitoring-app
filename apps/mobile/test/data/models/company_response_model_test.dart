import 'package:flutter_test/flutter_test.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';

void main() {
  group('CompanyResponseModel.fromJson', () {
    test('parses commissionRate from string', () {
      final model = CompanyResponseModel.fromJson({
        'id': 'company-1',
        'companyName': 'Acme Life',
        'commissionRate': '12.75',
      });

      expect(model.id, 'company-1');
      expect(model.companyName, 'Acme Life');
      expect(model.commissionRate, 12.75);
    });

    test('parses commissionRate from numeric values', () {
      final fromInt = CompanyResponseModel.fromJson({
        'id': 'company-1',
        'companyName': 'Acme Life',
        'commissionRate': 10,
      });
      final fromDouble = CompanyResponseModel.fromJson({
        'id': 'company-2',
        'companyName': 'Bravo Life',
        'commissionRate': 15.5,
      });

      expect(fromInt.commissionRate, 10);
      expect(fromDouble.commissionRate, 15.5);
    });

    test('defaults commissionRate to 0.0 when value is invalid', () {
      final model = CompanyResponseModel.fromJson({
        'id': 'company-1',
        'companyName': 'Acme Life',
        'commissionRate': 'not-a-number',
      });

      expect(model.commissionRate, 0.0);
    });

    test('defaults commissionRate to 0.0 when value is null', () {
      final model = CompanyResponseModel.fromJson({
        'id': 'company-1',
        'companyName': 'Acme Life',
        'commissionRate': null,
      });

      expect(model.commissionRate, 0.0);
    });
  });

  group('CompanyResponseModel.fromJsonList', () {
    test('parses multiple records', () {
      final result = CompanyResponseModel.fromJsonList([
        {
          'id': 'company-1',
          'companyName': 'Acme Life',
          'commissionRate': '10',
        },
        {
          'id': 'company-2',
          'companyName': 'Bravo Life',
          'commissionRate': 15,
        },
      ]);

      expect(result, hasLength(2));
      expect(result.map((e) => e.id), containsAll(<String>['company-1', 'company-2']));
    });

    test('returns empty list when source list is empty', () {
      final result = CompanyResponseModel.fromJsonList(const <dynamic>[]);

      expect(result, isEmpty);
    });

    test('throws when list item is not a JSON map', () {
      expect(
        () => CompanyResponseModel.fromJsonList(const <dynamic>['bad-item']),
        throwsA(isA<TypeError>()),
      );
    });
  });
}

