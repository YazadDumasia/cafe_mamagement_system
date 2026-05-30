import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../../bloc/bloc.dart';
import '../../../../../utils/utils.dart';
import '../../../../widgets/widgets.dart';

class CountryPickerSheet extends StatelessWidget {
  final Size? size;

  const CountryPickerSheet({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: CountryPickerDialog(
        contentPadding: const EdgeInsets.all(8.0),
        titlePadding: const EdgeInsets.all(8.0),
        searchCursorColor: Theme.of(context).primaryColorLight,
        searchInputDecoration: InputDecoration(
          hintText: 'Search...',
          label: const Text('Search'),
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 24),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
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
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        isSearchable: true,
        searchEmptyView: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 10,
            bottom: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  child: Lottie.asset(
                    'assets/lottie/country_location.json',
                    repeat: true,
                    alignment: Alignment.center,
                    fit: BoxFit.fitHeight,
                    height: size?.height != null ? size!.height * 0.30 : 200,
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Please enter proper country name..',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        title: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                'Select your phone code',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        onValuePicked: (country) {
          PlatformUtils.debugLog(
            CountryPickerSheet,
            'onValuePicked:country:${country.phoneCode}',
          );
          context.read<LoginWithPhoneBloc>().add(
            LoginWithPhoneUpdateCountryIosCodeEvent(country),
          );
        },
        itemBuilder: _buildDialogItem,
        priorityList: <Country>[
          CountryPickerUtils.getCountryByIsoCode('IN'),
          CountryPickerUtils.getCountryByIsoCode('US'),
        ],
      ),
    );
  }

  static Widget _buildDialogItem(Country country) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      CountryPickerUtils.getDefaultFlagImage(country),
      const SizedBox(width: 8.0),
      Expanded(child: Text(country.name, style: const TextStyle(fontSize: 16))),
      const SizedBox(width: 8.0),
      Text('+${country.phoneCode}'),
    ],
  );
}
