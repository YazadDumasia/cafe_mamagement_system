import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app_config/app_config.dart';
import '../../../../bloc/bloc.dart';
import '../../../../utils/components/constants.dart';

// Assuming RadioGroup is a custom widget provided by the project or a library.
// If it's not found, it might be a part of a generic implementation.
// Note: In the original file, it was used with a child containing Radio buttons.

class SignUpGenderField extends StatelessWidget {
  const SignUpGenderField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? selectedGender;
  final Function(String) onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<SignUpCubit>().genderController,
      builder: (context, snapshot) {
        return Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: TextFormField(
                focusNode: focusNode,
                controller: controller,
                cursorColor: Colors.transparent,
                readOnly: true,
                onChanged: (value) {
                  onGenderChanged(selectedGender ?? ' ');
                },
                validator: (value) {
                  if (snapshot.hasError == true) {
                    return snapshot.error.toString();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  labelText:
                      context.tr(
                        AppStringValue.commonGenderLabel,
                        track: Constants.commonTrack,
                      ) ??
                      'Gender',
                  isDense: true,
                  contentPadding: const EdgeInsets.all(20),
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
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      // Using a simple Row if RadioGroup is not globally available,
                      // but keeping the Radio architecture.
                      child: RadioGroup(
                        groupValue: selectedGender,
                        onChanged: (value) => onGenderChanged(value!),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          primary: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: 'Male',
                              ),
                              Flexible(
                                child: Text(
                                  context.tr(
                                        AppStringValue.commonGenderMaleLabel,
                                        track: Constants.commonTrack,
                                      ) ??
                                      'Male',
                                ),
                              ),
                              Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: 'Female',
                              ),
                              Flexible(
                                child: Text(
                                  context.tr(
                                        AppStringValue.commonGenderFemaleLabel,
                                        track: Constants.commonTrack,
                                      ) ??
                                      'Female',
                                ),
                              ),
                              Radio<String>(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: 'Other',
                              ),
                              Flexible(
                                child: Text(
                                  context.tr(
                                        AppStringValue.commonGenderOtherLabel,
                                        track: Constants.commonTrack,
                                      ) ??
                                      'Other',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
