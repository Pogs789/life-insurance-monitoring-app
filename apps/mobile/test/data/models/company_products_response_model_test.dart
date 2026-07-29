import 'package:flutter_test/flutter_test.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';

void main() {
  group('CompanyProductsResponseModel.fromJson', () {
    test('parses valid payload with string amount', () {
      final model = CompanyProductsResponseModel.fromJson({
        'id': 'product-1',
        'insuranceProductName': 'Starter Plan',
        'productContents': 'Life cover',
        'amount': '1250.50',
        'paymentTerms': ['Monthly', 'Annual'],
      });

      expect(model.id, 'product-1');
      expect(model.insuranceProductName, 'Starter Plan');
      expect(model.productAmount, 1250.50);
      expect(model.paymentTerms, containsAll(<String>['Monthly', 'Annual']));
    });

    test('throws FormatException for invalid amount string', () {
      expect(
        () => CompanyProductsResponseModel.fromJson({
          'id': 'product-1',
          'insuranceProductName': 'Starter Plan',
          'productContents': 'Life cover',
          'amount': 'invalid-number',
          'paymentTerms': ['Monthly'],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when amount is non-string numeric type', () {
      expect(
        () => CompanyProductsResponseModel.fromJson({
          'id': 'product-1',
          'insuranceProductName': 'Starter Plan',
          'productContents': 'Life cover',
          'amount': 500,
          'paymentTerms': ['Monthly'],
        }),
        throwsA(anyOf(isA<TypeError>(), isA<ArgumentError>())),
      );
    });

    test('throws when paymentTerms cannot be cast to List<String>', () {
      expect(
        () => CompanyProductsResponseModel.fromJson({
          'id': 'product-1',
          'insuranceProductName': 'Starter Plan',
          'productContents': 'Life cover',
          'amount': '500',
          'paymentTerms': [1, 2, 3],
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('CompanyProductsResponseModel.fromJsonList', () {
    test('parses multiple products', () {
      final result = CompanyProductsResponseModel.fromJsonList([
        {
          'id': 'product-1',
          'insuranceProductName': 'Starter Plan',
          'productContents': 'Life cover',
          'amount': '1000',
          'paymentTerms': ['Monthly'],
        },
        {
          'id': 'product-2',
          'insuranceProductName': 'Premium Plan',
          'productContents': 'Life + accident',
          'amount': '2000',
          'paymentTerms': ['Monthly', 'Quarterly'],
        },
      ]);

      expect(result, hasLength(2));
      expect(result[0].productAmount, 1000);
      expect(result[1].paymentTerms, contains('Quarterly'));
    });

    test('returns empty list when source list is empty', () {
      final result = CompanyProductsResponseModel.fromJsonList(const <dynamic>[]);

      expect(result, isEmpty);
    });

    test('throws when list item is not a map', () {
      expect(
        () => CompanyProductsResponseModel.fromJsonList(const <dynamic>['bad-item']),
        throwsA(isA<TypeError>()),
      );
    });
  });
}

