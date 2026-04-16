import 'package:cafe_mamagement_system/utils/components/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as ft;
import 'package:lottie/lottie.dart' as lottie;
import '../../app_config/config/app_localizations.dart';
import '../../app_config/config/app_string_value.dart';
import '../../gen/assets.gen.dart';

class UiUtils {
  static Future<void> showTransparentLoader(
    BuildContext context, {
    bool fullscreenDialog = false,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      fullscreenDialog: fullscreenDialog,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: lottie.Lottie.asset(
            Assets.lottie.loading,
            fit: BoxFit.scaleDown,
            width: MediaQuery.of(context).size.width * .65,
            height: MediaQuery.of(context).size.height * .5,
          ),
        );
      },
    );
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(
      context.mounted ? context : global.navigatorKey.currentContext!,
    ).clearSnackBars();
    ScaffoldMessenger.of(
      context.mounted ? context : global.navigatorKey.currentContext!,
    ).showSnackBar(
      SnackBar(
        content: Text(message),

        backgroundColor: isError
            ? Theme.of(
                context.mounted ? context : global.navigatorKey.currentContext!,
              ).colorScheme.error
            : Theme.of(
                context.mounted ? context : global.navigatorKey.currentContext!,
              ).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void showToastMsg({
    required String? msg,
    bool? isForShortDuration,
    ft.ToastGravity? gravity = ft.ToastGravity.BOTTOM,
  }) {
    ft.Fluttertoast.showToast(
      msg: '$msg',
      gravity: gravity,
      timeInSecForIosWeb:
          isForShortDuration == null || isForShortDuration == true ? 3 : 5,
      toastLength: isForShortDuration == null || isForShortDuration == true
          ? ft.Toast.LENGTH_SHORT
          : ft.Toast.LENGTH_LONG,
      fontSize: 16,
      textColor: Theme.of(
        global.navigatorKey.currentContext!,
      ).colorScheme.onPrimaryContainer,
      backgroundColor: Theme.of(
        global.navigatorKey.currentContext!,
      ).colorScheme.primaryContainer,
    );
  }

  static MaterialBanner showErrorMaterialBanner(
    final BuildContext context,
    String? msg, {
    final Widget? leadingWidget,
    final List<Widget>? actions,
  }) {
    return MaterialBanner(
      leading: leadingWidget ?? const Icon(Icons.error),
      content: Row(children: [Expanded(child: Text(msg ?? ''))]),
      actions:
          actions ??
          <Widget>[
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(
                  reason: MaterialBannerClosedReason.hide,
                );
              },
              child: Text(
                context.tr(AppStringValue.commonOk, track: 'common') ?? 'Ok',
              ),
            ),
          ],
    );
  }
}
