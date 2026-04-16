import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_config/app_config.dart';
import '../../../../bloc/login_cubit/login_screen_cubit.dart';
import '../../../../utils/components/local_keys_enum.dart';
import '../../../../utils/components/local_manager.dart';

class SignInButtonWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Future<void> Function() callLoginApi;
  const SignInButtonWidget({
    super.key,
    required this.formKey,
    required this.callLoginApi,
  });

  @override
  State<SignInButtonWidget> createState() => _SignInButtonWidgetState();
}

class _SignInButtonWidgetState extends State<SignInButtonWidget> {
  @override
  Widget build(final BuildContext context) {
    return StreamBuilder(
      stream: context.watch<LoginScreenCubit>().buttonLoadingStream,
      builder: (final context, final snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    context.read<LoginScreenCubit>().updateButtonLoading(true);
                    if (widget.formKey.currentState!.validate()) {
                      widget.formKey.currentState!.save();
                      await widget.callLoginApi();
                    } else {
                      await LocalManager.instance.setBoolValue(
                        key: PreferencesKeys.isLoggedIn,
                        value: false,
                      );

                      if (context.mounted) {
                        context.read<LoginScreenCubit>().updateButtonLoading(
                          false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  child: (snapshot.data == null || snapshot.data == false)
                      ? Text(
                          // "Login",
                          AppLocalizations.of(
                                context,
                              )?.translate(AppStringValue.loginInactiveBtn) ??
                              'Login',
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              // "Please Wait...",
                              AppLocalizations.of(context)?.translate(
                                    AppStringValue.loginLoadingInactiveBtn,
                                  ) ??
                                  'Please Wait...',
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
