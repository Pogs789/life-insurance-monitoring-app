import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/app_constants.dart';
import 'package:life_insurance_monitoring_mobile/core/themes/app_colors.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/remote/company_remote_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/repositories/company_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/company/company_usecase.dart';
import 'package:life_insurance_monitoring_mobile/presentation/providers/company/company_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_insurance_monitoring_mobile/core/network/interceptors.dart';

class PolicyListPage extends StatefulWidget {
  const PolicyListPage({super.key});

  @override
  State<PolicyListPage> createState() => _PolicyListPageState();
}

class _PolicyListPageState extends State<PolicyListPage> {
  bool _didRequestProducts = false;

  Future<void> _loadProducts(BuildContext providerContext) async {
    try {
      await providerContext.read<CompanyProvider>().getCompanyInsuranceProducts();
    } catch (_) {
      // Provider already stores the error message for UI rendering.
    }
  }

  String _formatAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final wholeWithCommas = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$wholeWithCommas.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CompanyProvider>(
       create: (_) {
         final secureStorage = const FlutterSecureStorage();
         final dio = Dio();

         dio.interceptors.add(AuthInterceptor(secureStorage, dio));

         final repository = CompanyRepositoryImpl(
          CompanyRemoteDataSourceImpl(dio: dio),
        );

        return CompanyProvider(
          GetCompanyUseCase(repository),
          GetCompanyProductsUseCase(repository),
        );
      },
      child: Builder(
        builder: (providerContext) {
          final provider = providerContext.watch<CompanyProvider>();

          if (!_didRequestProducts) {
            _didRequestProducts = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!providerContext.mounted) return;
              _loadProducts(providerContext);
            });
          }

          if (provider.isLoading && provider.companyProducts.isEmpty) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.errorMessage != null && provider.companyProducts.isEmpty) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spaceMD),
                      ElevatedButton(
                        onPressed: () => _loadProducts(providerContext),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (provider.companyProducts.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No insurance products available yet.')),
            );
          }

          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () => _loadProducts(providerContext),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                itemCount: provider.companyProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spaceMD),
                itemBuilder: (context, index) {
                  final policy = provider.companyProducts[index];
                  return Card(
                    elevation: 2,
                    color: AppColors.colorInfoContainer.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                      side: BorderSide(
                        color: AppColors.colorInfo.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppConstants.spaceSM,
                            children: [
                              Text(
                                policy.insuranceProductName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: AppConstants.fontSizeXXL,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              Text(
                                '(Tap for more details)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textPrimary.withValues(alpha: 0.5),
                                      fontSize: AppConstants.fontSizeXS,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceMD),
                          _PolicyDetailRow(
                            label: 'Contract Price',
                            value: _formatAmount(policy.productAmount),
                            isCurrency: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PolicyDetailRow extends StatelessWidget {
  const _PolicyDetailRow({
    required this.label,
    required this.value,
    this.isCurrency = false,
  });

  final String label;
  final String value;
  final bool isCurrency;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
              fontSize: AppConstants.fontSizeMD,
                ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceMD),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isCurrency)
                Text(
                  '₱',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.colorInfo,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.amountFontSizeMobile,
                      ),
                ),
              if (isCurrency) const SizedBox(width: 2),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.amountFontSizeMobile,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}