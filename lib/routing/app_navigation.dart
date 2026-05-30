import 'package:flutter/material.dart';

import 'app_route_path.dart';
import 'navigation_service.dart';

class AppNavigation {
  AppNavigation._();

  /// Navigate to the pop back to previous screen.
  static void pop() => Navigator.canPop(NavigationService.context)
      ? Navigator.pop(NavigationService.context)
      : null;

  ///Splash page to login Page
  static void goLogin({required final bool isFirstTime}) =>
      Navigator.pushNamedAndRemoveUntil(
        NavigationService.context,
        AppRoutePath.loginRoute,
        arguments: false,
        (route) => false,
      );

  ///From login Page to  loginViaPhoneNumber page and go backPress go back to Login page
  static void pushLoginViaPhoneNumberRoute({
    required final bool? isUseForLogin,
  }) => Navigator.pushNamed(
    NavigationService.context,
    AppRoutePath.loginViaPhoneNumberRoute,
    arguments: isUseForLogin ?? false,
  );

  ///From login Page to SignUp page and go backPress go back to Login page
  static void pushRegistration() => Navigator.pushNamed(
    NavigationService.context,
    AppRoutePath.registrationRoute,
  );

  ///From Home page Drawer section to show license page
  Future showLicensePage({
    required String? applicationName,
    required String? applicationVersion,
    required Widget? applicationIcon,
    String? applicationLegalese,
  }) async => await Navigator.pushNamed(
    NavigationService.context,
    AppRoutePath.licenseRoute,
    arguments: <String, dynamic>{
      "applicationName": applicationName,
      "applicationVersion": applicationVersion,
      "applicationIcon": applicationIcon,
      "applicationLegalese": applicationLegalese,
    },
  );

  // async {
  //   await navigatorKey.currentState?.push(
  //     MaterialPageRoute<void>(
  //       builder: (BuildContext context) => LicensePage(
  //         key: UniqueKey(),
  //         applicationName: applicationName,
  //         applicationVersion: applicationVersion,
  //         applicationIcon: applicationIcon,
  //         applicationLegalese: applicationLegalese,
  //       ),
  //     ),
  //   );
  // }
}
