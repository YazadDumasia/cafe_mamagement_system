import 'package:flutter/material.dart';
import '../../../../app_config/app_config.dart';
import '../../../../utils/components/constants.dart';

class SignUpHeaderWidget extends StatelessWidget {
  const SignUpHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 15,
                ),
                child: Text(
                  context.tr(
                        AppStringValue.signUpWelcomeTitleMessage,
                        track: Constants.signUpTrack,
                      ) ??
                      'Hey there,',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 15,
                ),
                child: Text(
                  context.tr(
                        AppStringValue.createAnAccountMsg,
                        track: Constants.signUpTrack,
                      ) ??
                      'Create an Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
