import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/bloc.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../app_config/app_config.dart';
import '../../../../routing/navigation_service.dart';

class PhoneNumberInputWidget extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final FocusNode phoneNumberFocusNode;

  const PhoneNumberInputWidget({
    required this.phoneNumberController,
    required this.phoneNumberFocusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 15),
            child: StreamBuilder(
              stream: context
                  .watch<LoginWithPhoneBloc>()
                  .phoneNumberIosCodeController,
              builder: (context, phoneIosCodeSnapshot) {
                return PhoneNumberTextFormField(
                  controller: phoneNumberController,
                  focusNode: phoneNumberFocusNode,
                  showDropdownIcon: true,
                  showCountryFlag: true,
                  isShowDialog: false,
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
                    isDense: true,
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                  ),
                  onCountryChanged: (Country country) => PlatformUtils.debugLog(
                    PhoneNumberInputWidget,
                    'Country changed to: ${country.name}',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  invalidNumberMessage:
                      context.tr(
                        AppStringValue.commonCommonPhoneNumberValidatorErrorMsg,
                        track: Constants.commonTrack,
                      ) ??
                      'Please enter a valid phone number.',
                  onChanged: (final PhoneNumber number) {
                    PlatformUtils.debugLog(
                      PhoneNumberInputWidget,
                      'number:$number',
                    );
                    context.read<LoginWithPhoneBloc>().add(
                      LoginWithPhoneUpdatePhoneNumberEvent(
                        phoneNumber: number.completeNumber,
                        context: context.mounted
                            ? context
                            : NavigationService.context,
                      ),
                    );
                  },
                  initialCountryCode:
                      phoneIosCodeSnapshot.data?.isoCode ?? 'IN',
                  priorityList: <Country>[
                    CountryPickerUtils.getCountryByIsoCode('IN'),
                    CountryPickerUtils.getCountryByIsoCode('US'),
                  ],
                  onSubmitted: (String value) {
                    Future.microtask(
                      () => FocusScope.of(
                        context.mounted ? context : NavigationService.context,
                      ).requestFocus(FocusNode()),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
