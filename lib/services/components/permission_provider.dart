import 'package:cafe_mamagement_system/utils/components/global.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

import '../../utils/components/platform_utils.dart';

class PermissionProvider {
  static PermissionStatus locationPermission = PermissionStatus.denied;

  static bool isServiceOn = false;

  static DialogRoute? permissionDialogRoute;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /// This method is used to get the device information.
  static Map<String, dynamic> deviceData = <String, dynamic>{};

  /// This method is used to get the device information.
  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  /// This method is used to get the device information.
  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  /// This method is used to get the device information.
  static Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  /// This method is used to get the device information.
  static Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  /// This method is used to get the device information.
  static Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  /// This method is used to get the device information.
  static Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  /// This method is used to get the device information.
  static Future<Map<String, dynamic>?> initPlatformState() async {
    Map<String, dynamic> deviceInfo = <String, dynamic>{};
    final String currentPlatform = await PlatformUtils.getCurrentPlatform();
    try {
      if (currentPlatform == 'web') {
        deviceInfo = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceInfo = switch (currentPlatform) {
          'Android' => _readAndroidBuildData(
            await deviceInfoPlugin.androidInfo,
          ),
          'iOS' => _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          'Linux' => _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          'Windows' => _readWindowsDeviceInfo(
            await deviceInfoPlugin.windowsInfo,
          ),
          'macOS' => _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          'Fuchsia' => <String, dynamic>{
            'Error:': "Fuchsia platform isn't supported",
          },
          'IO' => <String, dynamic>{'Error:': "IO platform isn't supported"},
          'Unknown platform' => <String, dynamic>{
            'Error:': "Unknown platform isn't supported",
          },
          _ => <String, dynamic>{'Error:': 'Unsupported platform'},
        };
      }
    } on PlatformException {
      deviceInfo = <String, dynamic>{
        'Error:': 'Failed to get platform version.',
      };
    }

    deviceData = deviceInfo;
    return deviceData;
  }

  /// This method is used to check the location permission status and request it if needed.
  static Future<void> handleLocationPermission() async {
    isServiceOn = await Permission.location.serviceStatus.isEnabled;
    locationPermission = await Permission.location.status;
    if (isServiceOn) {
      switch (locationPermission) {
        case PermissionStatus.permanentlyDenied:
          permissionDialogRoute = myCustomDialogRoute(
            title: 'Location Service',
            text: 'To use navigation, please allow location usage in settings.',
            buttonText: 'Go To Settings',
            onPressed: () {
              Navigator.of(navigatorKey.currentContext!).pop();
              openAppSettings();
            },
          );
          Navigator.of(
            navigatorKey.currentContext!,
          ).push(permissionDialogRoute!);
        case PermissionStatus.denied:
          Permission.location.request().then((value) {
            locationPermission = value;
          });
          break;
        default:
      }
    } else {
      permissionDialogRoute = myCustomDialogRoute(
        title: 'Location Service',
        text: 'To use navigation, please turn location service on.',
        buttonText: PlatformUtils.isAndroid() ? 'Turn It On' : 'Ok',
        onPressed: () {
          Navigator.of(navigatorKey.currentContext!).pop();

          // if (Constants.isAndroid()) {
          //
          //   const AndroidIntent intent = AndroidIntent(
          //     action: 'android.settings.LOCATION_SOURCE_SETTINGS',
          //   );
          //   intent.launch();
          // } else {
          //
          // }
        },
      );
      Navigator.of(navigatorKey.currentContext!).push(permissionDialogRoute!);
    }
  }

  static Future<bool> checkPermissions() async {
    List<Permission>? permissions = <Permission>[
      Permission.camera,
      Permission.ignoreBatteryOptimizations,
      // Permission.photos,
      // Permission.videos,
      // Permission.storage,
      Permission.location,
      Permission.notification,
      Permission.contacts,
      Permission.calendarWriteOnly,
      Permission.calendarFullAccess,
      Permission.scheduleExactAlarm,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
      Permission.systemAlertWindow,
    ].toList(growable: true);

    final List<PermissionWithService> permissionWithService =
        <PermissionWithService>[
          Permission.bluetooth,
          Permission.locationWhenInUse,
        ].toList(growable: true);

    final Map<Permission, PermissionStatus> statuses =
        <Permission, PermissionStatus>{};
    await initPlatformState();

    final List<Permission> permissionsToCheck = <Permission>[];

    if (PlatformUtils.isAndroid()) {
      final AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
      if (build.version.sdkInt > 32) {
        permissionsToCheck.addAll(<Permission>[
          Permission.photos,
          Permission.videos,
        ]);
      } else {
        permissionsToCheck.add(Permission.storage);
      }
    }
    permissionsToCheck.addAll(permissions);

    /// Check if the permission is granted
    permissions = permissionsToCheck;

    final Lock lock = Lock();
    // Check permissions without services
    for (Permission permission in permissionsToCheck) {
      await lock.synchronized(() async {
        statuses[permission] = await permission.status;
      });
    }

    // Check permissions with services
    for (PermissionWithService permission in permissionWithService) {
      if (await permission.serviceStatus.isEnabled) {
        await lock.synchronized(() async {
          statuses[permission] = await permission.status;
        });
      } else {
        await lock.synchronized(() async {
          statuses[permission] = PermissionStatus.denied;
        });
      }
    }

    /// Check if the permission is granted
    if (allPermissionsGranted(statuses)) {
      return true;
    } else {
      return false;
    }
  }

  static bool allPermissionsGranted(
    Map<Permission, PermissionStatus> statuses,
  ) {
    return statuses.values.every((status) => status.isGranted);
  }
}

DialogRoute myCustomDialogRoute({
  required String title,
  required String text,
  required String buttonText,
  required VoidCallback onPressed,
}) {
  return DialogRoute(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: <Widget>[
          TextButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      );
    },
  );
}
