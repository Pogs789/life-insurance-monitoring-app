import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/app_constants.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/remote/company_remote_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/repositories/agent_repository.dart';
import 'package:life_insurance_monitoring_mobile/data/repositories/company_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/entities/company.dart';
import 'package:life_insurance_monitoring_mobile/domain/entities/user.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/agent_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/repositories/company_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/agent/agent_usecase.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/company/company_usecase.dart';
import 'package:life_insurance_monitoring_mobile/presentation/providers/company/company_provider.dart';
import 'package:life_insurance_monitoring_mobile/presentation/widgets/auth/auth_dialog.dart';
import 'package:provider/provider.dart';
import 'package:life_insurance_monitoring_mobile/core/themes/app_colors.dart';
import 'package:life_insurance_monitoring_mobile/presentation/providers/auth/auth_provider.dart';
import 'package:flutter/services.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _insuranceCompanyController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _commissionRateController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AgentUseCase agentUseCase;
  late final AgentRepository agentRepository;
  late final AuthRemoteDataSource authRemoteDataSource;
  late final CompanyProvider companyProvider;
  late final GetCompanyUseCase getCompanyUseCase;
  late final CompanyRepository companyRepository;
  late final CompanyRemoteDataSource companyRemoteDataSource;

  DateTime? _birthDate;
  List<CompanyModel> _companyOptions = [];
  CompanyModel? _selectedCompany;
  bool _isLoadingCompanies = false;
  bool _didRequestCompanies = false;
  String? _companyLoadError;

  @override
  void initState() {
    super.initState();
    authRemoteDataSource = AuthRemoteDataSourceImpl(dio: Dio());
    agentRepository = AgentRepositoryImpl(authRemoteDataSource);
    agentUseCase = AgentUseCase(agentRepository);
    companyRemoteDataSource = CompanyRemoteDataSourceImpl(dio: Dio());
    companyRepository = CompanyRepositoryImpl(companyRemoteDataSource);
    getCompanyUseCase = GetCompanyUseCase(companyRepository);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _insuranceCompanyController.dispose();
    _companyIdController.dispose();
    _commissionRateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 20, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String _formatCommissionRate(double rate) {
    return rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2);
  }

  Future<void> _loadCompanies(BuildContext providerContext) async {
    setState(() {
      _isLoadingCompanies = true;
      _companyLoadError = null;
    });

    try {
      final companies = await providerContext
          .read<CompanyProvider>()
          .getAllCompanyNamesAndCommissionRates();

      if (!mounted) return;

      setState(() {
        _companyOptions = companies;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _companyLoadError = 'Unable to load insurance companies.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCompanies = false;
        });
      }
    }
  }

  void _agentSubmit(BuildContext providerContext) async {
    if (_birthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Birth date is required')));
      return;
    }

    if (_insuranceCompanyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insurance company is required')),
      );
      return;
    }

    final commissionRate = double.tryParse(
      _commissionRateController.text.trim(),
    );
    if (commissionRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commission rate must be a valid number')),
      );
      return;
    }

    final user = UserEntity(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      birthDate: _birthDate!,
      companyId: _companyIdController.text.trim(),
      email: _emailController.text.trim(),
      rawPassword: _passwordController.text,
    );

    final provider = providerContext.read<AuthProvider>();

    await provider.newAgentSubmit(user);

    if (!providerContext.mounted) return;

    String error =
        provider.errorMessage ??
        "An Error Occurred while registering your account. Maybe you don't have an internet connection.";

    AuthDialog.show(
      providerContext,
      title: provider.isSuccess
          ? "Successfully Registered"
          : "Registration Failed",
      message: provider.isSuccess
          ? "You have successfully registered. Please check your email to confirm it"
          : error,
      showCancelDialog: false,
      confirmLabel: "Okay"
    );
  }

  @override
  Widget build(BuildContext context) {
    final birthDateText = _birthDate == null
        ? 'Select birth date'
        : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CompanyProvider>(
          create: (_) {
            final repository = CompanyRepositoryImpl(
              CompanyRemoteDataSourceImpl(dio: Dio()),
            );
            return CompanyProvider(
              GetCompanyUseCase(repository),
              GetCompanyProductsUseCase(repository),
            );
          },
        ),
      ],
      child: Builder(
        builder: (providerContext) {
          final provider = providerContext.watch<AuthProvider>();

          if (!_didRequestCompanies) {
            _didRequestCompanies = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!providerContext.mounted) return;
              _loadCompanies(providerContext);
            });
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Registration Form')),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Part 1: Basic Personal Information',
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceLG),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            textEditingController: _firstNameController,
                            labelText: 'First Name',
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: _buildTextFormField(
                            textEditingController: _middleNameController,
                            labelText: 'Middle Name',
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMD),
                        Expanded(
                          child: _buildTextFormField(
                            textEditingController: _lastNameController,
                            labelText: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Birth Date'),
                      subtitle: Text(birthDateText),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickBirthDate,
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildTextFormField(
                      textEditingController: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      customValidator: (value) {
                        final requiredError = _requiredValidator(
                          value,
                          'Email',
                        );
                        if (requiredError != null) return requiredError;

                        final email = value!.trim();
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    _buildTextFormField(
                      textEditingController: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      minLength: 6,
                      validationErrorMessage:
                          'Password must be at least 6 characters',
                    ),
                    const Divider(),
                    Text(
                      'Part 2: About Your Insurance Company',
                      overflow: TextOverflow.fade,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceLG),
                    const SizedBox(height: AppConstants.spaceMD),
                    DropdownMenu<CompanyModel>(
                      expandedInsets: EdgeInsets.zero,
                      hintText:
                          '--Please Select or Search the Insurance Company you are currently working for--',
                      initialSelection: _selectedCompany,
                      enabled: !_isLoadingCompanies,
                      onSelected: (selectedCompany) {
                        if (selectedCompany == null) return;

                        setState(() {
                          _companyIdController.text =
                            selectedCompany.id;
                        });
                      },
                      inputDecorationTheme: const InputDecorationTheme(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      dropdownMenuEntries: _companyOptions
                          .map(
                            (company) => DropdownMenuEntry<CompanyModel>(
                              value: company,
                              label: company.companyName,
                            ),
                          )
                          .toList(),
                    ),
                    if (_isLoadingCompanies)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                    if (_companyLoadError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _companyLoadError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: AppConstants.spaceMD),

                    const SizedBox(height: 20),
                    if (_selectedCompany != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                             color: Colors.grey.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Commission Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_formatCommissionRate(_selectedCompany!.commissionRate)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                            if (AppConstants.isUnderDevelopment) {
                              ScaffoldMessenger.of(providerContext).showSnackBar(
                                  SnackBar(
                                    content: Text("Additional Features are still underway. Please stay tuned for the full version."),
                                    backgroundColor: AppColors.colorInfo,
                                  )
                              );
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              _agentSubmit(providerContext);
                            }
                          },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController textEditingController,
    required String labelText,
    bool obscureText = false,
    int minLength = 1,
    String? validationErrorMessage,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? suffixText,
    String? Function(String?)? customValidator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: textEditingController,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        suffixText: suffixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: obscureText,
      validator:
          customValidator ??
          (value) {
            final requiredError = _requiredValidator(value, labelText);
            if (requiredError != null) return requiredError;

            if (value!.length < minLength) {
              return validationErrorMessage ??
                  '$labelText must be at least $minLength characters';
            }
            return null;
          },
    );
  }
}
