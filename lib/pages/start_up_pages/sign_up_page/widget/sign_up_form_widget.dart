import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config/app_config.dart';
import '../../../../bloc/bloc.dart';
import '../../../../utils/components/constants.dart';
import 'sign_up_button_widget.dart';
import 'sign_up_confirm_password_field.dart';
import 'sign_up_dob_field.dart';
import 'sign_up_gender_field.dart';
import 'sign_up_header_widget.dart';
import 'sign_up_password_field.dart';
import 'sign_up_phone_number_field.dart';
import 'sign_up_text_form_stream_widget.dart';

class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.userNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.genderController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.birthDateController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.userNameFocusNode,
    required this.emailFocusNode,
    required this.phoneNumberFocusNode,
    required this.genderFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.birthDateFocusNode,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onDobTap,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController genderController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController birthDateController;

  final FocusNode firstNameFocusNode;
  final FocusNode lastNameFocusNode;
  final FocusNode userNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode phoneNumberFocusNode;
  final FocusNode genderFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final FocusNode birthDateFocusNode;

  final String? selectedGender;
  final Function(String) onGenderChanged;
  final VoidCallback onDobTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SignUpHeaderWidget(),
          Row(
            children: [
              SignUpTextFormStreamWidget(
                controller: firstNameController,
                focusNode: firstNameFocusNode,
                hintText:
                    context.tr(
                      AppStringValue.commonfirstNameFieldHint,
                      track: Constants.commonTrack,
                    ) ??
                    'First Name',
                labelText:
                    context.tr(
                      AppStringValue.commonfirstNameFieldLabel,
                      track: Constants.commonTrack,
                    ) ??
                    'First Name',
                autofillHints: const [AutofillHints.givenName],
                textInputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(lastNameFocusNode),
                stream: context.watch<SignUpCubit>().firstNameController,
              ),
              SignUpTextFormStreamWidget(
                controller: lastNameController,
                focusNode: lastNameFocusNode,
                hintText:
                    context.tr(
                      AppStringValue.commonLastNameFieldHint,
                      track: Constants.commonTrack,
                    ) ??
                    'Last Name',
                labelText:
                    context.tr(
                      AppStringValue.commonLastNameFieldLabel,
                      track: Constants.commonTrack,
                    ) ??
                    'Last Name',
                autofillHints: const [AutofillHints.familyName],
                textInputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(userNameFocusNode),
                stream: context.watch<SignUpCubit>().lastNameController,
              ),
            ],
          ),
          Row(
            children: [
              SignUpTextFormStreamWidget(
                controller: userNameController,
                focusNode: userNameFocusNode,
                hintText:
                    context.tr(
                      AppStringValue.commonUserNameFieldHint,
                      track: Constants.commonTrack,
                    ) ??
                    'User Name',
                labelText:
                    context.tr(
                      AppStringValue.commonUserNameFieldLabel,
                      track: Constants.commonTrack,
                    ) ??
                    'User Name',
                autofillHints: const [AutofillHints.username],
                textInputType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(emailFocusNode),
                stream: context.watch<SignUpCubit>().userNameController,
              ),
              SignUpTextFormStreamWidget(
                controller: emailController,
                focusNode: emailFocusNode,
                hintText:
                    context.tr(
                      AppStringValue.commonEmailHint,
                      track: Constants.commonTrack,
                    ) ??
                    'Email Address',
                labelText:
                    context.tr(
                      AppStringValue.commonEmailLabel,
                      track: Constants.commonTrack,
                    ) ??
                    'Email Address',
                autofillHints: const [AutofillHints.email],
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) =>
                    FocusScope.of(context).requestFocus(passwordFocusNode),
                stream: context.watch<SignUpCubit>().emailController,
              ),
            ],
          ),
          SignUpPasswordField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            nextFocusNode: confirmPasswordFocusNode,
          ),
          SignUpConfirmPasswordField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
          ),
          SignUpPhoneNumberField(
            controller: phoneNumberController,
            focusNode: phoneNumberFocusNode,
            onSubmitted: (value) =>
                FocusScope.of(context).requestFocus(birthDateFocusNode),
          ),
          SignUpDobField(
            controller: birthDateController,
            focusNode: birthDateFocusNode,
            onTap: onDobTap,
          ),
          SignUpGenderField(
            controller: genderController,
            focusNode: genderFocusNode,
            selectedGender: selectedGender,
            onGenderChanged: onGenderChanged,
          ),
          const SizedBox(height: 10),
          SignUpButtonWidget(onPressed: onSubmit),
        ],
      ),
    );
  }
}
