import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/company_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/company/company_usecase.dart';
import 'package:life_insurance_monitoring_mobile/presentation/providers/company/company_provider.dart';

class _FakeCompanyRepository implements CompanyRepository {
  Future<List<CompanyResponseModel>> Function()? onGetCompanies;
  Future<List<CompanyProductsResponseModel>> Function()? onGetProducts;

  @override
  Future<List<CompanyResponseModel>> getAllCompaniesAndCommissionRates() async {
    return onGetCompanies?.call() ?? <CompanyResponseModel>[];
  }

  @override
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts() async {
    return onGetProducts?.call() ?? <CompanyProductsResponseModel>[];
  }
}

CompanyProvider _buildProvider(_FakeCompanyRepository fakeRepository) {
  return CompanyProvider(
    GetCompanyUseCase(fakeRepository),
    GetCompanyProductsUseCase(fakeRepository),
  );
}

void main() {
  group('CompanyProvider.getAllCompanyNamesAndCommissionRates', () {
    test('maps models to entities and updates success state', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetCompanies =
            () async => [
              CompanyResponseModel(
                id: 'company-1',
                companyName: 'Acme Life',
                commissionRate: 11.5,
              ),
            ];
      final provider = _buildProvider(fakeRepository);

      final result = await provider.getAllCompanyNamesAndCommissionRates();

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isTrue);
      expect(provider.errorMessage, isNull);
      expect(result.single.id, 'company-1');
      expect(result.single.companyName, 'Acme Life');
      expect(result.single.commissionRate, 11.5);
    });

    test('sets loading=true while request is pending', () async {
      final completer = Completer<List<CompanyResponseModel>>();
      final fakeRepository = _FakeCompanyRepository()
        ..onGetCompanies = () => completer.future;
      final provider = _buildProvider(fakeRepository);

      final future = provider.getAllCompanyNamesAndCommissionRates();

      expect(provider.isLoading, isTrue);
      expect(provider.isSuccess, isFalse);

      completer.complete([
        CompanyResponseModel(
          id: 'company-1',
          companyName: 'Acme Life',
          commissionRate: 10,
        ),
      ]);
      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isTrue);
    });

    test('stores AppException message and rethrows', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetCompanies =
            () => Future<List<CompanyResponseModel>>.error(
              const ValidationException('Invalid company lookup'),
            );
      final provider = _buildProvider(fakeRepository);

      await expectLater(
        provider.getAllCompanyNamesAndCommissionRates(),
        throwsA(isA<ValidationException>()),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.errorMessage, 'Invalid company lookup');
    });

    test('stores unknown exception text and rethrows', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetCompanies =
            () => Future<List<CompanyResponseModel>>.error(Exception('boom'));
      final provider = _buildProvider(fakeRepository);

      await expectLater(
        provider.getAllCompanyNamesAndCommissionRates(),
        throwsA(isA<Exception>()),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.errorMessage, contains('Exception: boom'));
    });
  });

  group('CompanyProvider.getCompanyInsuranceProducts', () {
    test('stores products and marks success', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetProducts =
            () async => [
              CompanyProductsResponseModel(
                id: 'product-1',
                insuranceProductName: 'Starter Plan',
                productContents: 'Life cover',
                productAmount: 1100,
                paymentTerms: const ['Monthly'],
              ),
            ];
      final provider = _buildProvider(fakeRepository);

      final result = await provider.getCompanyInsuranceProducts();

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isTrue);
      expect(provider.errorMessage, isNull);
      expect(provider.companyProducts, hasLength(1));
      expect(provider.companyProducts.single.id, 'product-1');
      expect(result.single.productAmount, 1100);
    });

    test('sets loading=true while products request is pending', () async {
      final completer = Completer<List<CompanyProductsResponseModel>>();
      final fakeRepository = _FakeCompanyRepository()
        ..onGetProducts = () => completer.future;
      final provider = _buildProvider(fakeRepository);

      final future = provider.getCompanyInsuranceProducts();

      expect(provider.isLoading, isTrue);
      expect(provider.isSuccess, isFalse);

      completer.complete([
        CompanyProductsResponseModel(
          id: 'product-1',
          insuranceProductName: 'Starter Plan',
          productContents: 'Life cover',
          productAmount: 500,
          paymentTerms: const ['Monthly'],
        ),
      ]);
      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isTrue);
    });

    test('sets AppException message and rethrows', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetProducts =
            () => Future<List<CompanyProductsResponseModel>>.error(
              const AuthException('Unauthorized product request'),
            );
      final provider = _buildProvider(fakeRepository);

      await expectLater(
        provider.getCompanyInsuranceProducts(),
        throwsA(isA<AuthException>()),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.errorMessage, 'Unauthorized product request');
    });

    test('sets unknown exception text and rethrows', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetProducts =
            () => Future<List<CompanyProductsResponseModel>>.error(
              Exception('product boom'),
            );
      final provider = _buildProvider(fakeRepository);

      await expectLater(
        provider.getCompanyInsuranceProducts(),
        throwsA(isA<Exception>()),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.isSuccess, isFalse);
      expect(provider.errorMessage, contains('Exception: product boom'));
    });
  });
}

