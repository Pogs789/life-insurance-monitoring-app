import 'package:life_insurance_monitoring_mobile/data/datasources/remote/company_remote_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remote;
  CompanyRepositoryImpl(this.remote);

  @override
  Future<List<CompanyResponseModel>> getAllCompaniesAndCommissionRates() async {
    return await remote.getAllCompaniesAndCommissionRates();
  }

  @override
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts() async {
    return await remote.getCompanyInsuranceProducts();
  }
}