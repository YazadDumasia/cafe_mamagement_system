import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app_config/app_config.dart';
import '../../model/model.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';

part 'login_with_phone_event.dart';
part 'login_with_phone_state.dart';

class LoginWithPhoneBloc
    extends Bloc<LoginWithPhoneEvent, LoginWithPhoneState> {
  LoginWithPhoneBloc() : super(LoginWithPhoneInitialState()) {
    on<LoginWithPhoneFetchInitialInfoEvent>(_onFetchInitialInfo);
    on<LoginWithPhoneUpdateButtonLoadingEvent>(_onUpdateButtonLoading);
    on<LoginWithPhoneUpdatePhoneNumberEvent>(_onUpdatePhoneNumber);
    on<LoginWithPhoneUpdateCountryIosCodeEvent>(_onUpdateCountryIosCode);
    on<LoginWithPhoneDisposeEvent>(_onDispose);

    add(LoginWithPhoneFetchInitialInfoEvent());
  }

  final BehaviorSubject<Country?> _phoneNumberIosCodeController =
      BehaviorSubject<Country?>();

  final BehaviorSubject<String> _phoneNumberController =
      BehaviorSubject<String>();

  final BehaviorSubject<bool> _buttonLoading = BehaviorSubject<bool>();

  Stream<bool> get buttonLoadingStream => _buttonLoading.stream;

  Stream<String> get phoneNumberController => _phoneNumberController.stream;

  ValueStream<Country?> get phoneNumberIosCodeController =>
      _phoneNumberIosCodeController.stream;

  // ----------------------------
  // EVENTS HANDLERS
  // ----------------------------

  Future<void> _onFetchInitialInfo(
    LoginWithPhoneFetchInitialInfoEvent event,
    Emitter<LoginWithPhoneState> emit,
  ) async {
    emit(LoginWithPhoneLoadingState());

    final InternetStatus connectionStatus =
        await InternetConnection().internetStatus;

    if (connectionStatus == InternetStatus.connected) {
      if (PlatformUtils.isMobileApp() == true) {
        try {
          final List<Locale> systemLocales =
              PlatformDispatcher.instance.locales;

          final String? isoCountryCode = systemLocales.first.countryCode;

          PlatformUtils.debugLog(
            LoginWithPhoneBloc,
            'isoCountryCode:${isoCountryCode!}',
          );

          _phoneNumberIosCodeController.add(
            CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
          );

          emit(LoginWithPhoneLoadedState());
        } catch (e) {
          PlatformUtils.debugLog(
            LoginWithPhoneBloc,
            'fetchInitialInfo:getIsMobileApp:Error:${e.toString()}',
          );

          final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
          _phoneNumberIosCodeController.add(data);

          emit(LoginWithPhoneLoadedState());
        }
      } else {
        await _getPublicIp();
        emit(LoginWithPhoneLoadedState());
      }
    } else {
      emit(LoginWithPhoneNoInternetState());
    }
  }

  void _onUpdateButtonLoading(
    LoginWithPhoneUpdateButtonLoadingEvent event,
    Emitter<LoginWithPhoneState> emit,
  ) {
    _buttonLoading.sink.add(event.isLoading);
  }

  void _onUpdatePhoneNumber(
    LoginWithPhoneUpdatePhoneNumberEvent event,
    Emitter<LoginWithPhoneState> emit,
  ) {
    if (event.phoneNumber.isEmpty) {
      _phoneNumberController.addError(
        AppLocalizations.of(event.context)?.translate(
              AppStringValue.commonCommonPhoneNumberValidatorErrorMsg,
              track: Constants.commonTrack,
            ) ??
            'Please enter a valid phone number.',
      );
    } else {
      _phoneNumberController.sink.add(event.phoneNumber);
    }
  }

  Future<void> _onUpdateCountryIosCode(
    LoginWithPhoneUpdateCountryIosCodeEvent event,
    Emitter<LoginWithPhoneState> emit,
  ) async {
    final Country? country = event.country;

    if (country == null) {
      if (PlatformUtils.isMobileApp() == true) {
        try {
          final List<Locale> systemLocales =
              PlatformDispatcher.instance.locales;

          final String? isoCountryCode = systemLocales.first.countryCode;

          PlatformUtils.debugLog(
            LoginWithPhoneBloc,
            'isoCountryCode:${isoCountryCode!}',
          );

          _phoneNumberIosCodeController.sink.add(
            CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
          );
        } catch (e) {
          PlatformUtils.debugLog(
            LoginWithPhoneBloc,
            'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
          );

          final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
          _phoneNumberIosCodeController.sink.add(data);
        }
      } else {
        await _getPublicIp();
      }
    } else {
      _phoneNumberIosCodeController.add(country);
    }
  }

  void _onDispose(
    LoginWithPhoneDisposeEvent event,
    Emitter<LoginWithPhoneState> emit,
  ) {
    _buttonLoading.sink.add(false);
    _phoneNumberIosCodeController.sink.add(null);

    add(
      LoginWithPhoneUpdatePhoneNumberEvent(
        phoneNumber: '',
        context: event.context,
      ),
    );
  }

  // ----------------------------
  // HELPER METHODS
  // ----------------------------

  Future<void> _getPublicIp() async {
    try {
      final IpTrackerService ipTrackerService = IpTrackerService();
      final IpInfoModel ipInfo = await ipTrackerService.getIpInfo();

      if (ipInfo.countryCode != null) {
        PlatformUtils.debugLog(
          LoginWithPhoneBloc,
          ':getPublicIp:country_code:${ipInfo.countryCode}',
        );

        final Country data = CountryPickerUtils.getCountryByIsoCode(
          ipInfo.countryCode!,
        );

        _phoneNumberIosCodeController.sink.add(data);
      } else {
        final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
        _phoneNumberIosCodeController.sink.add(data);
      }
    } catch (e) {
      PlatformUtils.debugLog(LoginWithPhoneBloc, ':getPublicIp:Error:$e');
      final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
      _phoneNumberIosCodeController.sink.add(data);
    }
  }

  @override
  Future<void> close() {
    _phoneNumberIosCodeController.close();
    _phoneNumberController.close();
    _buttonLoading.close();
    return super.close();
  }
}
