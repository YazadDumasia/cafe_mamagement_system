import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;

import '../../../../app_config/app_config.dart' as config;
import '../../../../app_config/config/app_localizations.dart' as localizations;
import '../../../../utils/components/constants.dart' as ct;
import '../../../../widgets/widgets.dart' as widgets;

class SocialMediaLoginRowWidget extends StatelessWidget {
  const SocialMediaLoginRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Tooltip(
            message:
                // "Login Via Facebook",
                context.tr(
                  config.AppStringValue.loginViaFacebookTooltip,
                  track: ct.Constants.loginPageTrack,
                ) ??
                'Login Via Facebook',
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 2),
            padding: const EdgeInsets.all(10),
            preferBelow: true,
            child: widgets.HoverUpDownWidget(
              animationDuration: const Duration(milliseconds: 1500),
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: const EdgeInsets.only(left: 8),
                  backgroundColor: Theme.of(context).primaryColorLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Center(
                  child: Icon(
                    faf.FontAwesomeIcons.facebookF.data,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                label: const Text(''),
              ),
            ),
          ),
          Tooltip(
            message:
                // "Login Via Google",
                context.tr(
                  config.AppStringValue.loginViaGoogleTooltip,
                  track: ct.Constants.loginPageTrack,
                ) ??
                'Login Via Google',
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 2),
            padding: const EdgeInsets.all(10),
            preferBelow: true,
            child: widgets.HoverUpDownWidget(
              animationDuration: const Duration(milliseconds: 1800),
              child: ElevatedButton.icon(
                onPressed: () => _handleGoogleSignIn(context),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: const EdgeInsets.only(left: 8),
                  backgroundColor: Theme.of(context).primaryColorLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Center(
                  child: Icon(faf.FontAwesomeIcons.google.data, size: 24),
                ),
                label: const Text(''),
              ),
            ),
          ),
          Tooltip(
            message:
                // "Login Via Phone Number",
                context.tr(
                  config.AppStringValue.loginViaPhoneNumberTooltip,
                  track: ct.Constants.loginPageTrack,
                ) ??
                'Login Via Phone Number',
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 2),
            padding: const EdgeInsets.all(10),
            preferBelow: true,
            child: widgets.HoverUpDownWidget(
              animationDuration: const Duration(milliseconds: 2000),
              child: ElevatedButton.icon(
                onPressed: () async {
                  // navigationRoutes.navigateToSignInViaPhoneNumberPage(
                  //   isForLogin: true,
                  // );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: const EdgeInsets.only(left: 8),
                  backgroundColor: Theme.of(context).primaryColorLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Center(child: Icon(Icons.smartphone, size: 26)),
                label: const Text(''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(final BuildContext context) async {
    try {
      /*  GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );*/

      // Use the `credential` to sign in to your app.
      // For example, you can use FirebaseAuth to sign in the user:
      // final User user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    } catch (error) {
      ScaffoldMessenger.of(context)
        ..removeCurrentMaterialBanner()
        ..showMaterialBanner(
          MaterialBanner(
            content: Text(
              context.tr(
                    config.AppStringValue.loginGoogleLoginError,
                    track: ct.Constants.loginPageTrack,
                  ) ??
                  'Unable to SignIn with google',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: const Text('DISMISS'),
              ),
            ],
          ),
        );
    }
  }
}
