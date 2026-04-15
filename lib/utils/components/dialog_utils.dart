import 'dart:async';
import 'package:cafe_mamagement_system/gen/assets.gen.dart' as asts;
import 'package:cafe_mamagement_system/utils/components/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;
import 'package:lottie/lottie.dart' as lottie;

class DialogUtils {
  static Future<void> showAutoDismissDialog({
    required BuildContext context,
    required String descriptions,
    String? title,
    Widget? titleIcon,
    Duration showDuration = const Duration(seconds: 3),
  }) async {
    final dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Stack(
        children: <Widget>[
          Positioned(
            left: 20,
            top: 0,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 47,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 65,
              right: 20,
              bottom: 20,
            ),
            margin: const EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(descriptions, textAlign: TextAlign.center),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 2,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: titleIcon ?? Container(),
              ),
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(showDuration, () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return dialog;
      },
    );
  }

  static Future<void> customAutoDismissAlertAppThemeDialog({
    required Type? classObject,
    required BuildContext? context,
    required String? descriptions,
    Duration? showForHowDuration,
    Widget? titleIcon,
    String? title,
    bool? barrierDismissible,
  }) async {
    final AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Stack(
        children: <Widget>[
          Positioned(
            left: 20,
            top: 0,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Theme.of(context!).colorScheme.primary,
              radius: 47,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 45 + 20,
              right: 20,
              bottom: 20,
            ),
            margin: const EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: title?.isNotEmpty ?? false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      bottom: 10,
                      top: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title ?? '',
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: (descriptions == null || descriptions.isEmpty)
                      ? false
                      : true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          descriptions ?? '',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 2,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(45)),
                child: titleIcon ?? Container(),
              ),
            ),
          ),
        ],
      ),
    );
    Timer? counter;

    counter = Timer(showForHowDuration ?? const Duration(seconds: 3), () {
      counter?.cancel();
      Navigator.of(
        context.mounted ? context : global.navigatorKey.currentContext!,
      ).pop();
    });

    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible ?? false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop && counter!.isActive) {
              counter.cancel();
            }
          },
          child: dialog,
        );
      },
    );
  }

  static Future<void> showTransparentLoader(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:
          (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: lottie.Lottie.asset(
                      asts.Assets.lottie.loading,
                      fit: BoxFit.scaleDown,
                      width: MediaQuery.of(context).size.width * .65,
                      height: MediaQuery.of(context).size.height * .5,
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  static void showSimpleLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: .center,
              mainAxisSize: MainAxisSize.min,
              children: [
                spinkit.SpinKitFadingCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 50,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showTimeoutDialog(
    BuildContext context,
    VoidCallback onStayConnected,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.timer_off_outlined, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Session Timeout'),
          ],
        ),
        content: const Text(
          'Your session is about to expire due to inactivity. Would you like to stay connected?',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onStayConnected();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Stay Connected'),
          ),
        ],
      ),
    );
  }

  static Future<void> showTimedDialog({
    required BuildContext context,
    required Widget dialog,
    Duration duration = const Duration(seconds: 3),
    bool barrierDismissible = false,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        Future.delayed(duration, () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext);
          }
        });

        return dialog;
      },
    );
  }
}
