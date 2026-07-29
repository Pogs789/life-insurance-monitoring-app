import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';

/// Handles company-product caching once offline-first support is added.
abstract class CompanyLocalDataSource {
  Future<void> saveCompanyInsuranceProducts(
    List<CompanyProductsResponseModel> products,
  );

  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts();
}

class CompanyLocalDataSourceImpl implements CompanyLocalDataSource {
  @override
  Future<void> saveCompanyInsuranceProducts(
    List<CompanyProductsResponseModel> products,
  ) {
    // TODO: implement local caching for company products.
    throw UnimplementedError();
  }

  @override
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts() {
    // TODO: implement local read for company products.
    throw UnimplementedError();
  }
}

