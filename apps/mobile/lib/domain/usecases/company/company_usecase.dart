import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/company_repository.dart';

class GetCompanyUseCase {
  final CompanyRepository repository;

  GetCompanyUseCase(this.repository);

  Future<List<CompanyResponseModel>> call() async {
    return await repository.getAllCompaniesAndCommissionRates();
  }
}

class GetCompanyProductsUseCase {
  final CompanyRepository repository;

  GetCompanyProductsUseCase(this.repository);

  Future<List<CompanyProductsResponseModel>> call() async {
    return await repository.getCompanyInsuranceProducts();
  }
}
