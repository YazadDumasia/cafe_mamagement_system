import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/bloc.dart';
import '../../../../../utils/utils.dart';
import 'otp_utils.dart';

class LoginPhoneFormHandler {
  static const Type _tag = LoginPhoneFormHandler;

  static Future<void> submitPhoneNumber({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController phoneNumberController,
    required dynamic progressButtonState,
    required Function(String) onPhoneNumberSubmit,
  }) async {
    String? phNumberText = '';
    String? countryCodeText = '';
    String? phoneNumber = '';

    context.read<LoginWithPhoneBloc>().add(
      LoginWithPhoneUpdateButtonLoadingEvent(true),
    );

    progressButtonState?.forward();
    PlatformUtils.debugLog(_tag, 'ProgressButton: start');

    try {
      countryCodeText =
          context
              .watch<LoginWithPhoneBloc>()
              .phoneNumberIosCodeController
              .value
              ?.phoneCode ??
          '+91';
      phNumberText = phoneNumberController.text.toString();

      phoneNumber = OtpUtils.formatPhoneNumber(
        countryCode: countryCodeText,
        phoneNumber: phNumberText,
      );

      PlatformUtils.debugLog(_tag, 'countryCode: $countryCodeText');
      PlatformUtils.debugLog(_tag, 'phNumber: $phNumberText');
      PlatformUtils.debugLog(_tag, 'fullPhoneNumber: $phoneNumber');
    } catch (e) {
      PlatformUtils.debugLog(_tag, 'Error: ${e.toString()}');
    }

    if (formKey.currentState!.validate()) {
      onPhoneNumberSubmit(phoneNumber ?? '');
    } else {
      context.read<LoginWithPhoneBloc>().add(
        LoginWithPhoneUpdateButtonLoadingEvent(false),
      );
      progressButtonState?.reset();
      PlatformUtils.debugLog(_tag, 'ProgressButton: stop - validation failed');

      UiUtils.showToastMsg(msg: 'Please enter a valid phone number.');
    }
  }
}
