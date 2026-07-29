import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';

abstract class CompanyRepository {
  Future<List<CompanyResponseModel>> getAllCompaniesAndCommissionRates();
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts();
}