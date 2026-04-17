import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../app_config/app_config.dart';
import '../../../../bloc/bloc.dart';
import '../../../../utils/components/constants.dart';

class SignUpConfirmPasswordField extends StatelessWidget {
  const SignUpConfirmPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<SignUpCubit>().confirmPasswordObscureTextController,
      builder: (context, isConfirmPasswordVisibleSnapshot) {
        return StreamBuilder(
          stream: context.watch<SignUpCubit>().confirmPasswordController,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.text,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(FocusNode()),
                validator: (value) {
                  if (snapshot.hasError) {
                    return snapshot.error.toString();
                  } else {
                    return null;
                  }
                },
                obscureText: isConfirmPasswordVisibleSnapshot.data ?? true,
                autofillHints: const <String>[AutofillHints.password],
                onChanged: (value) {
                  context.read<SignUpCubit>().updateConfirmPassword(value);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  hintText:
                      context.tr(
                        AppStringValue.commonComfirmPasswordHint,
                        track: Constants.commonTrack,
                      ) ??
                      'Confirm Password',
                  labelText:
                      context.tr(
                        AppStringValue.commonComfirmPasswordLabel,
                        track: Constants.commonTrack,
                      ) ??
                      'Confirm Password',
                  isDense: true,
                  suffixIcon: IconButton(
                    onPressed: () async {
                      Constants.debugLog(
                        SignUpConfirmPasswordField,
                        'onPressed:${isConfirmPasswordVisibleSnapshot.data}',
                      );

                      context
                          .read<SignUpCubit>()
                          .updateConfirmPasswordObscureText(
                            isConfirmPasswordVisibleSnapshot.data!,
                          );
                    },
                    icon: FaIcon(
                      isConfirmPasswordVisibleSnapshot.data == true
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).disabledColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
