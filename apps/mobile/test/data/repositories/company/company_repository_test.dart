import 'package:flutter_test/flutter_test.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/remote/company_remote_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';
import 'package:life_insurance_monitoring_mobile/data/repositories/company_repository.dart';

class _FakeCompanyRemoteDataSource implements CompanyRemoteDataSource {
  int getCompaniesCalls = 0;
  int getProductsCalls = 0;

  Future<List<CompanyResponseModel>> Function()? onGetCompanies;
  Future<List<CompanyProductsResponseModel>> Function()? onGetProducts;

  @override
  Future<List<CompanyResponseModel>> getAllCompaniesAndCommissionRates() async {
    getCompaniesCalls++;
    return onGetCompanies?.call() ?? <CompanyResponseModel>[];
  }

  @override
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts() async {
    getProductsCalls++;
    return onGetProducts?.call() ?? <CompanyProductsResponseModel>[];
  }
}

void main() {
  group('CompanyRepositoryImpl', () {
    test('delegates company list retrieval to remote datasource', () async {
      final fakeRemote = _FakeCompanyRemoteDataSource()
        ..onGetCompanies =
            () async => [
              CompanyResponseModel(
                id: 'company-1',
                companyName: 'Acme Life',
                commissionRate: 9,
              ),
            ];

      final repository = CompanyRepositoryImpl(fakeRemote);

      final result = await repository.getAllCompaniesAndCommissionRates();

      expect(fakeRemote.getCompaniesCalls, 1);
      expect(result.single.id, 'company-1');
    });

    test('delegates company products retrieval to remote datasource', () async {
      final fakeRemote = _FakeCompanyRemoteDataSource()
        ..onGetProducts =
            () async => [
              CompanyProductsResponseModel(
                id: 'product-1',
                insuranceProductName: 'Family Shield',
                productContents: 'Accident and life',
                productAmount: 2000,
                paymentTerms: const ['Monthly'],
              ),
            ];

      final repository = CompanyRepositoryImpl(fakeRemote);

      final result = await repository.getCompanyInsuranceProducts();

      expect(fakeRemote.getProductsCalls, 1);
      expect(result.single.insuranceProductName, 'Family Shield');
    });

    test('propagates remote exceptions for companies', () async {
      final fakeRemote = _FakeCompanyRemoteDataSource()
        ..onGetCompanies =
            () => Future<List<CompanyResponseModel>>.error(
              const NetworkException('No network'),
            );

      final repository = CompanyRepositoryImpl(fakeRemote);

      await expectLater(
        repository.getAllCompaniesAndCommissionRates(),
        throwsA(isA<NetworkException>()),
      );
      expect(fakeRemote.getCompaniesCalls, 1);
    });

    test('propagates remote exceptions for products', () async {
      final fakeRemote = _FakeCompanyRemoteDataSource()
        ..onGetProducts =
            () => Future<List<CompanyProductsResponseModel>>.error(
              const AuthException('Unauthorized'),
            );

      final repository = CompanyRepositoryImpl(fakeRemote);

      await expectLater(
        repository.getCompanyInsuranceProducts(),
        throwsA(isA<AuthException>()),
      );
      expect(fakeRemote.getProductsCalls, 1);
    });
  });
}

