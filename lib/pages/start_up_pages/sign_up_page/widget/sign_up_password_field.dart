import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../app_config/app_config.dart';
import '../../../../bloc/bloc.dart';
import '../../../../utils/components/constants.dart';

class SignUpPasswordField extends StatelessWidget {
  const SignUpPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<SignUpCubit>().passwordObscureTextController,
      builder: (context, isPasswordVisibleSnapshot) {
        return StreamBuilder(
          stream: context.watch<SignUpCubit>().passwordController,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 15,
                        ),
                        child: TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.text,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) => FocusScope.of(
                            context,
                          ).requestFocus(nextFocusNode),
                          validator: (value) {
                            if (snapshot.hasError) {
                              return snapshot.error.toString();
                            } else {
                              return null;
                            }
                          },
                          obscureText: isPasswordVisibleSnapshot.data ?? true,
                          autofillHints: const <String>[AutofillHints.password],
                          onChanged: (value) {
                            context.read<SignUpCubit>().updatePassword(value);
                            context.read<SignUpCubit>().checkPassword(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(20),
                            hintText:
                                context.tr(
                                  AppStringValue.commonPasswordLabel,
                                  track: Constants.commonTrack,
                                ) ??
                                'Password',
                            labelText:
                                context.tr(
                                  AppStringValue.commonPasswordHint,
                                  track: Constants.commonTrack,
                                ) ??
                                'Password',
                            isDense: true,
                            suffixIcon: IconButton(
                              onPressed: () async {
                                Constants.debugLog(
                                  SignUpPasswordField,
                                  'onPressed:${isPasswordVisibleSnapshot.data}',
                                );

                                context
                                    .read<SignUpCubit>()
                                    .updatePasswordObscureText(
                                      isPasswordVisibleSnapshot.data!,
                                    );
                              },
                              icon: FaIcon(
                                isPasswordVisibleSnapshot.data == true
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
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: focusNode.hasFocus,
                  replacement: const SizedBox.shrink(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                      top: 8.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _RequirementItem(
                          stream: context
                              .watch<SignUpCubit>()
                              .isPasswordSizeRequire,
                          label:
                              context.tr(
                                AppStringValue.signUpPasswordSizeRequireText,
                                track: Constants.signUpTrack,
                              ) ??
                              'Contains at least 8 characters',
                        ),
                        const SizedBox(height: 5),
                        _RequirementItem(
                          stream: context
                              .watch<SignUpCubit>()
                              .isPasswordOneLowerCase,
                          label:
                              context.tr(
                                AppStringValue.signUpPasswordOneLowerCaseText,
                                track: Constants.signUpTrack,
                              ) ??
                              'Contains at least 1 LowerCase character',
                        ),
                        const SizedBox(height: 5),
                        _RequirementItem(
                          stream: context
                              .watch<SignUpCubit>()
                              .isPasswordOneUpperCase,
                          label:
                              context.tr(
                                AppStringValue.signUpPasswordOneUpperCaseText,
                                track: Constants.signUpTrack,
                              ) ??
                              'Contains at least 1 Uppercase character',
                        ),
                        const SizedBox(height: 5),
                        _RequirementItem(
                          stream: context
                              .watch<SignUpCubit>()
                              .isPasswordOneNumCase,
                          label:
                              context.tr(
                                AppStringValue.signUpPasswordOneNumCaseText,
                                track: Constants.signUpTrack,
                              ) ??
                              'Contains at least 1 number',
                        ),
                        const SizedBox(height: 5),
                        _RequirementItem(
                          stream: context
                              .watch<SignUpCubit>()
                              .isPasswordOneSpecialChar,
                          label:
                              'Contains at least 1 special character like !@#\$&*~+-',
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.stream, required this.label});

  final Stream stream;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: snapshot.data ?? false
                    ? Colors.green
                    : Colors.transparent,
                border: snapshot.data ?? false
                    ? Border.all(color: Colors.transparent)
                    : Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(Icons.check, color: Colors.white, size: 15),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        Flexible(child: Text(label)),
      ],
    );
  }
}
