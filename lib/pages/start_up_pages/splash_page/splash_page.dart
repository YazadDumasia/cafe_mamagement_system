import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import '../../../gen/assets.gen.dart';
import '../../../routing/routing.dart';
import '../../../utils/utils.dart';
import '../../../widgets/widgets.dart';
import 'widget/splash_screen_desktop_layout.dart';
import 'widget/splash_screen_mobile_layout.dart';
import 'widget/splash_screen_tablet_layout.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final List<String> assetDirectories = <String>['images'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      checkFirstTime();
    });
  }

  Future<void> preloadImages() async {
    final List<String> assetList = Assets.images.values
        .map((asset) => asset.path)
        .toList();

    // Preload all assets from the list and handle errors
    final Lock lock = Lock();
    await Future.forEach(assetList, (asset) async {
      try {
        await lock.synchronized(() async {
          await precacheImage(AssetImage(asset), context);
        });
      } catch (e) {
        PlatformUtils.debugLog(SplashPage, 'Error loading image:$asset');
      }
    });
    PlatformUtils.debugLog(SplashPage, 'preloadImages:Done');
  }

  Future<void> checkFirstTime() async {
    final bool isUserLogin = LocalManager.instance.isLoggedIn;
    if (isUserLogin == false) {
      Future.delayed(const Duration(seconds: 3)).then((value) async {
        await preloadImages();
        final bool isloginFirstTime = LocalManager.instance.getBoolValue(
          key: PreferencesKeys.isAppLoginForFirstTime,
        );
        if (isloginFirstTime) {
          await LocalManager.instance.setBoolValue(
            key: PreferencesKeys.isAppLoginForFirstTime,
            value: false,
          );
        }
        AppNavigation.goLogin(isFirstTime: isloginFirstTime);
      });
    } else {
      Future.delayed(const Duration(seconds: 3)).then((value) async {
        await preloadImages();
        // const HomeScreenRoute().go(context);
        // Navigator.pushNamedAndRemoveUntil(
        //   navigatorKey.currentContext!,
        //   RouteName.homeScreenRoute,
        //   arguments: false,
        //   (route) => false,
        // );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: ResponsiveLayout(
            mobile: SplashScreenMobileLayout(),
            tablet: SplashScreenTabletLayout(),
            desktop: SplashScreenDesktopLayout(),
          ),
        ),
      ),
    );
  }
}
