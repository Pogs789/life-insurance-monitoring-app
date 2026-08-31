import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:life_insurance_monitoring_mobile/core/constants/app_constants.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:life_insurance_monitoring_mobile/data/repositories/agent_repository.dart';
import 'package:life_insurance_monitoring_mobile/data/repositories/auth_repository.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/agent/agent_usecase.dart';
import 'package:life_insurance_monitoring_mobile/domain/usecases/auth/auth_usecases.dart';
import 'package:life_insurance_monitoring_mobile/presentation/providers/auth/auth_provider.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/auth/registration_page.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/auth/login_page.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/dashboard/dashboard_page.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/remittance/remittance_form_page.dart';
import 'package:life_insurance_monitoring_mobile/presentation/pages/splash/splash_page.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:life_insurance_monitoring_mobile/core/network/interceptors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = buildRealAuthProvider();

  runApp(AppBootstrap(authProvider: authProvider));
}

AuthProvider buildRealAuthProvider() {
  // Single secure storage instance
  final secureStorage = const FlutterSecureStorage();

  // Single shared Dio instance
  final dio = Dio();

  // Attach interceptor once so all requests can auto-add Bearer token
  dio.interceptors.add(AuthInterceptor(secureStorage, dio));

  // ...existing code...
  final authRemote = AuthRemoteDataSourceImpl(dio: dio);
  final authLocal = AuthLocalDataSourceImpl();

  // Repositories
  final authRepository = AuthRepositoryImpl(authRemote, authLocal);
  final agentRepository = AgentRepositoryImpl(authRemote);

  // Use cases
  final submitAgentUseCase = AgentUseCase(agentRepository);
  final loginUseCase = LoginUseCase(authRepository);
  final refreshTokenUseCase = RefreshTokenUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final isLoggedInUseCase = IsLoggedInUseCase(authRepository);

  // Provider
  return AuthProvider(
    submitAgentUseCase,
    loginUseCase,
    refreshTokenUseCase,
    logoutUseCase,
    isLoggedInUseCase,
  );
}

class AppBootstrap extends StatelessWidget {
  final AuthProvider authProvider;
  const AppBootstrap({super.key, required this.authProvider});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: const MyAppShell(),
    );
  }
}

class MyAppShell extends StatefulWidget {
  const MyAppShell({super.key});

  @override
  State<MyAppShell> createState() => _MyAppShellState();
}

class _MyAppShellState extends State<MyAppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeAuth();
    });
  }

  bool _isProtectedRoute(String routeName) {
    return routeName == '/dashboard' || routeName == '/remittance-history';
  }

  Route<dynamic> _generateRoute(RouteSettings settings, AuthProvider authProvider) {
    final requestedRoute = settings.name ?? '/';
    final isCheckingAuth =
        authProvider.authStatus == AuthStatus.unknown || authProvider.isLoading;
    final isAuthenticated = authProvider.isLoggedInSync;
    String resolvedRoute = requestedRoute;

    if (isCheckingAuth && requestedRoute != '/splash') {
      resolvedRoute = '/splash';
    } else if (isAuthenticated &&
        (requestedRoute == '/' ||
            requestedRoute == '/login' ||
            requestedRoute == '/register' ||
            requestedRoute == '/splash')) {
      resolvedRoute = '/dashboard';
    } else if (!isAuthenticated && requestedRoute == '/splash') {
      resolvedRoute = '/';
    } else if (!isAuthenticated && _isProtectedRoute(requestedRoute)) {
      resolvedRoute = '/login';
    }

    return MaterialPageRoute(
      settings: RouteSettings(name: resolvedRoute, arguments: settings.arguments),
      builder: (_) {
        switch (resolvedRoute) {
          case '/splash':
            return const SplashPage();
          case '/':
            return const RemittanceFormPage();
          case '/register':
            return const RegistrationPage();
          case '/login':
            return const LoginPage();
          case '/dashboard':
            return const DashboardPage();
          case '/remittance-history':
            return const Placeholder();
          default:
            return const RemittanceFormPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          onGenerateRoute: (settings) => _generateRoute(settings, authProvider),
          initialRoute: '/',
        );
      },
    );
  }
}
