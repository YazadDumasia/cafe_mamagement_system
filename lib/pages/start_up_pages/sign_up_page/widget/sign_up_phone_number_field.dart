import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config/app_config.dart';
import '../../../../bloc/bloc.dart';
import '../../../../utils/components/constants.dart';
import '../../../../widgets/widgets.dart';

class SignUpPhoneNumberField extends StatelessWidget {
  const SignUpPhoneNumberField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<SignUpCubit>().phoneNumberIosCodeController,
      builder: (context, phoneIosCodeSnapshot) {
        return Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, top: 15),
          child: PhoneNumberTextFormField(
            controller: controller,
            focusNode: focusNode,
            showDropdownIcon: true,
            showCountryFlag: true,
            isCountryButtonPersistent: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(9),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).disabledColor),
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
              isDense: true,
              labelText:
                  context.tr(
                    AppStringValue.commonPhoneNumberLabel,
                    track: Constants.commonTrack,
                  ) ??
                  'Phone Number',
              hintText:
                  context.tr(
                    AppStringValue.commonCommonPhoneNumberHint,
                    track: Constants.commonTrack,
                  ) ??
                  'Enter your phone number',
            ),
            onCountryChanged: (Country country) => Constants.debugLog(
              SignUpPhoneNumberField,
              'Country changed to:  + ${country.name}',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            invalidNumberMessage:
                context.tr(
                  AppStringValue.commonCommonPhoneNumberValidatorErrorMsg,
                  track: Constants.commonTrack,
                ) ??
                'Please enter a valid phone number.',
            onChanged: (number) {
              context.read<SignUpCubit>().updatePhoneNumber(
                number.completeNumber,
              );
            },
            initialCountryCode: phoneIosCodeSnapshot.data?.isoCode ?? 'IN',
            priorityList: <Country>[
              CountryPickerUtils.getCountryByIsoCode('IN'),
              CountryPickerUtils.getCountryByIsoCode('US'),
            ],
            onSubmitted: onSubmitted,
          ),
        );
      },
    );
  }
}
