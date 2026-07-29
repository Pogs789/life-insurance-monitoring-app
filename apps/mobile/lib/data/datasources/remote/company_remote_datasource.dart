import 'package:dio/dio.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/api_endpoints.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_response_model.dart';

abstract class CompanyRemoteDataSource {
  Future<List<CompanyResponseModel>> getAllCompaniesAndCommissionRates();
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts();
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  CompanyRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<CompanyResponseModel>> getAllCompaniesAndCommissionRates() async {
    try {
      final result = await dio.get(ApiEndpoints.getCompanyNamesAndCommissionRates);

      if (result.statusCode == 200) {
        return CompanyResponseModel.fromJsonList(result.data as List<dynamic>);
      }

      throw Exception(
        'An Error Occurred While Sending the Request: \n\n Status Code: ${result.statusCode} \n\n Error Message: ${result.statusMessage}',
      );
    }catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }

  @override
  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts() async {
    try {
      final AuthLocalDataSourceImpl dataSourceImpl = AuthLocalDataSourceImpl();
      final user = await dataSourceImpl.getFullNameAndCompany();

      if(user.isNotEmpty) {
        final companyId = user[2];
        final result = await dio.get(
            ApiEndpoints.getCompanyInsuranceProductsApi,
            queryParameters: {
              'companyId': companyId,
            }
        );

        if (result.statusCode == 200) {
          return CompanyProductsResponseModel.fromJsonList(result.data as List<dynamic>);
        }

        throw Exception(
          'An Error Occurred While Sending the Request: \n\n Status Code: ${result.statusCode} \n\n Error Message: ${result.statusMessage}',
        );
      }

      throw Exception(
        'An Error Occurred While Processing this Request. Please Try Again.',
      );
    }catch (e, stackTrace) {
      throw mapToAppException(e, stackTrace);
    }
  }

}