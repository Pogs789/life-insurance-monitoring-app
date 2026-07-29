import 'package:flutter/material.dart';
import 'package:life_insurance_monitoring_mobile/core/errors/exceptions.dart';
import 'package:life_insurance_monitoring_mobile/data/models/company_prroducts_reponse_model.dart';
import 'package:life_insurance_monitoring_mobile/domain/entities/company.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/company/company_usecase.dart';

class CompanyProvider extends ChangeNotifier {
  CompanyProvider(this._getCompanyUseCase, this._getCompanyProductsUseCase);
  final GetCompanyUseCase _getCompanyUseCase;
  final GetCompanyProductsUseCase _getCompanyProductsUseCase;

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  List<CompanyProductsResponseModel> companyProducts = [];

  Future<List<CompanyModel>> getAllCompanyNamesAndCommissionRates() async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      final result = await _getCompanyUseCase();
      isSuccess = true;

      return result
          .map(
            (company) => CompanyModel(
              id: company.id,
              companyName: company.companyName,
              commissionRate: company.commissionRate,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error in CompanyProvider: $e');
      errorMessage = e is AppException ? e.message : e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<CompanyProductsResponseModel>> getCompanyInsuranceProducts() async {
    isLoading = true;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();

    try {
      final result = await _getCompanyProductsUseCase();
      companyProducts = result;
      isSuccess = true;
      return result;
    } catch (e) {
      debugPrint('Error in CompanyProvider (products): $e');
      errorMessage = e is AppException ? e.message : e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}