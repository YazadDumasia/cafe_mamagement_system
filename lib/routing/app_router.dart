import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'app_route_path.dart';
import '../pages/pages.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    PlatformUtils.debugLog(AppRouter, 'Route Name:${settings.name}');
    PlatformUtils.debugLog(AppRouter, 'Route arguments:$args');

    switch (settings.name) {
      case '/':
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashPage());

      case AppRoutePath.splashRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const SplashPage());
      case AppRoutePath.loginRoute:
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          settings: settings,
          curve: Curves.easeInOut,
          child: LoginScreen(isFirstTime: args as bool?),
        );
      case AppRoutePath.registrationRoute:
        return MaterialPageRoute<dynamic>(builder: (_) => const SignUpPage());

      case AppRoutePath.loginViaPhoneNumberRoute:
        final bool isForLogin = args as bool;
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          settings: settings,
          curve: Curves.easeInOut,
          child: LoginViaPhoneNumberPage(isUseForLogin: isForLogin),
        );

      case AppRoutePath.otpScreenRoute:
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          settings: settings,
          curve: Curves.easeInOut,
          child: Container(),
        );

      case AppRoutePath.licenseRoute:
        final argMap = args as Map<String, dynamic>?;
        final String? applicationName = argMap?['applicationName'] ?? '';
        final String? applicationVersion = argMap?['applicationVersion'] ?? '';
        final Widget? applicationIcon = argMap?['applicationIcon'];
        final String? applicationLegalese =
            argMap?['applicationLegalese'] ?? '';
        return PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          settings: settings,
          curve: Curves.easeInOut,
          child: LicensePage(
            key: UniqueKey(),
            applicationName: applicationName,
            applicationVersion: applicationVersion,
            applicationIcon: applicationIcon,
            applicationLegalese: applicationLegalese,
          ),
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute<dynamic>(
      builder: (_) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(leadingWidth: 24, title: const Text('Error')),
            body: const Center(child: Text('ERROR')),
          ),
        );
      },
    );
  }
}
