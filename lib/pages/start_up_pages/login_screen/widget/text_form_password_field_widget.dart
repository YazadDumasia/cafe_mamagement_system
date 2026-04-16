import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app_config/app_config.dart';
import '../../../../bloc/login_cubit/login_screen_cubit.dart';
import '../../../../utils/components/global.dart';
import '../../../../utils/components/platform_utils.dart';

class TextFormPasswordFieldWidget extends StatefulWidget {
  final FocusNode? passwordFocusNode;
  final TextEditingController? passwordTextEditingController;
  const TextFormPasswordFieldWidget({
    super.key,
    required this.passwordFocusNode,
    required this.passwordTextEditingController,
  });

  @override
  State<TextFormPasswordFieldWidget> createState() =>
      _TextFormPasswordFieldWidgetState();
}

class _TextFormPasswordFieldWidgetState
    extends State<TextFormPasswordFieldWidget> {
  @override
  Widget build(final BuildContext context) {
    return StreamBuilder(
      stream: context.read<LoginScreenCubit>().passwordStream,
      builder: (context, snapshot) {
        return TextFormField(
          controller: widget.passwordTextEditingController!,
          focusNode: widget.passwordFocusNode,
          textInputAction: PlatformUtils.isMobileApp()
              ? TextInputAction.done
              : TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          autofillHints: const <String>[AutofillHints.password],
          decoration: InputDecoration(
            prefixIcon: Icon(FontAwesomeIcons.userLock.data),
            label: Text(
              // "Password",
              AppLocalizations.of(
                    context,
                  )?.translate(AppStringValue.loginPasswordLabel) ??
                  'Password',
            ),
            hintText:
                AppLocalizations.of(
                  context,
                )?.translate(AppStringValue.loginPasswordHint) ??
                'Enter your password.',
            isDense: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            disabledBorder: InputBorder.none,
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
          onChanged: (text) {
            context.read<LoginScreenCubit>().updatePassword(text);
          },
          validator: (value) {
            // r'^
            //   (?=.*[A-Z])          // should contain at least one upper case
            //   (?=.*[a-z])          // should contain at least one lower case
            //   (?=.*?[0-9])         // should contain at least one digit
            //   (?=.*?[!@#\$&*~+-])    // should contain at least one Special character
            //     .{8,}             // Must be at least 8 characters in length
            // $
            final RegExp regex = RegExp(
              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~+-]).{8,}$',
            );
            if (value!.isEmpty) {
              // return "Please enter password";
              return AppLocalizations.of(context)?.translate(
                    AppStringValue.loginPasswordValidatorErrorEmptyMsg,
                  ) ??
                  'Please enter password';
            } else if (!regex.hasMatch(value)) {
              // return 'Enter valid password';
              return AppLocalizations.of(
                    context,
                  )?.translate(AppStringValue.loginPasswordValidatorErrorMsg) ??
                  'Enter your password.';
            } else {
              return null;
            }
          },
          onFieldSubmitted: (value) {
            Future.microtask(
              () => FocusScope.of(
                context.mounted ? context : navigatorKey.currentContext!,
              ).unfocus(),
            );
          },
        ).inExpandedRow();
      },
    );
  }
}
