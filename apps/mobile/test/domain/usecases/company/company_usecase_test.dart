import 'package:flutter_test/flutter_test.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/company_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/company/company_usecase.dart';

class _FakeCompanyRepository implements CompanyRepository {
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
  group('GetCompanyUseCase', () {
    test('returns companies from repository', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetCompanies =
            () async => [
              CompanyResponseModel(
                id: 'company-1',
                companyName: 'Acme Life',
                commissionRate: 12.5,
              ),
            ];

      final useCase = GetCompanyUseCase(fakeRepository);

      final result = await useCase();

      expect(fakeRepository.getCompaniesCalls, 1);
      expect(result, hasLength(1));
      expect(result.first.companyName, 'Acme Life');
      expect(result.first.commissionRate, 12.5);
    });

    test('rethrows repository exception', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetCompanies =
            () => Future<List<CompanyResponseModel>>.error(
              const ValidationException('Invalid payload'),
            );

      final useCase = GetCompanyUseCase(fakeRepository);

      await expectLater(useCase(), throwsA(isA<ValidationException>()));
      expect(fakeRepository.getCompaniesCalls, 1);
    });
  });

  group('GetCompanyProductsUseCase', () {
    test('returns products from repository', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetProducts =
            () async => [
              CompanyProductsResponseModel(
                id: 'product-1',
                insuranceProductName: 'Term Protect',
                productContents: 'Base coverage',
                productAmount: 1500,
                paymentTerms: const ['Monthly', 'Quarterly'],
              ),
            ];

      final useCase = GetCompanyProductsUseCase(fakeRepository);

      final result = await useCase();

      expect(fakeRepository.getProductsCalls, 1);
      expect(result, hasLength(1));
      expect(result.first.insuranceProductName, 'Term Protect');
      expect(result.first.paymentTerms, contains('Monthly'));
    });

    test('rethrows repository exception', () async {
      final fakeRepository = _FakeCompanyRepository()
        ..onGetProducts =
            () => Future<List<CompanyProductsResponseModel>>.error(
              const ServerException('Server unavailable'),
            );

      final useCase = GetCompanyProductsUseCase(fakeRepository);

      await expectLater(useCase(), throwsA(isA<ServerException>()));
      expect(fakeRepository.getProductsCalls, 1);
    });
  });
}

