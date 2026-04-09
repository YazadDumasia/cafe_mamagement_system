import '../utlis.dart'; // Ensure Constants is available here
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LaunchReview {
  // Launch method with dynamic iOS App ID and optional custom error message
  Future<void> launch({
    required String iOSAppId,
    bool writeReview = false,
    String? customErrorMessage,
  }) async {
    // Fetch app package info
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appId =
        packageInfo.packageName; // This is the app ID for Android

    // Android URIs
    final Uri androidUri = Uri.parse('market://details?id=$appId');
    final Uri androidWebUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$appId',
    );

    // iOS URIs
    final String appStoreLink = 'https://apps.apple.com/app/id$iOSAppId';
    final Uri iOSUri = Uri.parse(
      writeReview ? '$appStoreLink?action=write-review' : appStoreLink,
    );
    final Uri testFlightUri = Uri.parse(
      'itms-beta://beta.itunes.apple.com/v1/app/id$iOSAppId',
    );

    try {
      if (Constants.isIOS()) {
        // Check if the app is running in TestFlight
        final bool isTestFlight = await _isRunningInTestFlight();

        if (isTestFlight) {
          // Launch TestFlight URL if available
          if (await canLaunchUrl(testFlightUri)) {
            await launchUrl(testFlightUri);
          } else if (await canLaunchUrl(iOSUri)) {
            await launchUrl(iOSUri);
          } else {
            throw 'Could not launch App Store or TestFlight';
          }
        } else {
          // Launch regular App Store URL
          if (await canLaunchUrl(iOSUri)) {
            await launchUrl(iOSUri);
          } else {
            throw 'Could not launch App Store';
          }
        }
      } else if (Constants.isAndroid()) {
        // Try to open the Play Store app first
        if (await canLaunchUrl(androidUri)) {
          await launchUrl(androidUri);
        } else {
          // Fallback to Play Store link in browser if Play Store app is unavailable
          await launchUrl(androidWebUri);
        }
      } else {
        // Log for unsupported platforms
        final String plf = await Constants.getCurrentPlatform();
        Constants.debugLog(LaunchReview, 'Other Platform review opening: $plf');
      }
    } catch (e) {
      // Show user-friendly message if an error occurs
      final String message =
          customErrorMessage ??
          'Failed to launch the review page. Please try again.';
      Constants.showToastMsg(msg: message);
      Constants.debugLog(LaunchReview, 'Error launching review page: $e');
    }
  }

  // Method to check if the app is running in TestFlight
  Future<bool> _isRunningInTestFlight() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;

    // TestFlight detection using iOS version or custom logic
    return iosInfo.systemName == 'iOS' &&
        iosInfo.systemVersion.contains('TestFlight');
  }
}

/*
 LaunchReview().launch(
  writeReview: true,
  iOSAppId: '1234567890',
  customErrorMessage: 'Oops! Something went wrong while opening the review page.'
);

or

LaunchReview().launch(
  writeReview: true,
  iOSAppId: '1234567890'
);

*/
