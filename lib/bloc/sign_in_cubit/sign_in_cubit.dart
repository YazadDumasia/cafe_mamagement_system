import '../../model/ip_info_model.dart';
import '../../services/services.dart';
import '../../utils/components/platform_utils.dart';
import '../../widgets/country_pickers/country.dart';
import '../../widgets/country_pickers/utils/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';

part 'sign_in_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial()) {
    InternetConnection().onStatusChange.listen((result) {
      if (result == InternetStatus.connected) {
        fetchInitialInfo();
      } else {
        emit(SignUpNoInternetState());
      }
    });
  }

  Future<void> fetchInitialInfo() async {
    emit(SignUpLoadingState());
    if (PlatformUtils.isMobileApp() == true) {
      try {
       final List<Locale> systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
        final String? isoCountryCode = systemLocales.first.countryCode;
        PlatformUtils.debugLog(
          SignUpCubit,
          'isoCountryCode:${isoCountryCode!}',
        );
        _phoneNumberIosCodeController.add(
          CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
        );
      } catch (e) {
        PlatformUtils.debugLog(
          SignUpCubit,
          'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
        );
        final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
        _phoneNumberIosCodeController.add(data);
      }
    } else {
      getPublicIp();
    }

    emit(SignUpLoadedState());
  }

  //define controllers

  final BehaviorSubject<String> _firstNameController =
      BehaviorSubject<String>();
  final BehaviorSubject<String> _lastNameController = BehaviorSubject<String>();
  final BehaviorSubject<String> _userNameController = BehaviorSubject<String>();
  final BehaviorSubject<String> _emailController = BehaviorSubject<String>();
  final BehaviorSubject<Country?> _phoneNumberIosCodeController =
      BehaviorSubject<Country?>();
  final BehaviorSubject<String> _phoneNumberController =
      BehaviorSubject<String>();
  final BehaviorSubject<String> _genderController = BehaviorSubject<String>();
  final BehaviorSubject<String> _dobController = BehaviorSubject<String>();

  final BehaviorSubject<String> _passwordController = BehaviorSubject<String>();
  final BehaviorSubject<bool> _passwordObscureTextController =
      BehaviorSubject<bool>();
  final BehaviorSubject<String> _confirmPasswordController =
      BehaviorSubject<String>();
  final BehaviorSubject<bool> _confirmPasswordObscureTextController =
      BehaviorSubject<bool>();

  final BehaviorSubject<bool> _isPasswordOneNumCase = BehaviorSubject<bool>();
  final BehaviorSubject<bool> _isPasswordOneUpperCase = BehaviorSubject<bool>();
  final BehaviorSubject<bool> _isPasswordOneLowerCase = BehaviorSubject<bool>();
  final BehaviorSubject<bool> _isPasswordOneSpecialChar =
      BehaviorSubject<bool>();
  final BehaviorSubject<bool> _isPasswordSizeRequire = BehaviorSubject<bool>();

  final BehaviorSubject<bool> _buttonLoading = BehaviorSubject<bool>();

  void dispose() {
    updateDob('');
    checkPassword('');
    updatePhoneNumber('');
    updateConfirmPassword('');
    updateGender(' ');
    updatePasswordObscureText(false);
    updateConfirmPasswordObscureText(false);
    updateButtonLoading(false);
  }

  Stream<String> get passwordController => _passwordController.stream;

  Stream<bool> get isPasswordOneNumCase => _isPasswordOneNumCase.stream;

  Stream<bool> get isPasswordOneUpperCase => _isPasswordOneUpperCase.stream;

  Stream<bool> get isPasswordOneLowerCase => _isPasswordOneLowerCase.stream;

  Stream<bool> get isPasswordOneSpecialChar => _isPasswordOneSpecialChar.stream;

  Stream<bool> get isPasswordSizeRequire => _isPasswordSizeRequire.stream;

  Stream<String> get confirmPasswordController =>
      _confirmPasswordController.stream;

  Stream<String> get firstNameController => _firstNameController.stream;

  Stream<String> get lastNameController => _lastNameController.stream;

  Stream<String> get userNameController => _userNameController.stream;

  Stream<String> get emailController => _emailController.stream;

  ValueStream<Country?> get phoneNumberIosCodeController =>
      _phoneNumberIosCodeController.stream;

  Stream<String> get phoneNumberController => _phoneNumberController.stream;

  Stream<String> get genderController => _genderController.stream;

  Stream<String?> get dobController => _dobController.stream;

  Stream<bool> get passwordObscureTextController =>
      _passwordObscureTextController.stream;

  Stream<bool> get confirmPasswordObscureTextController =>
      _confirmPasswordObscureTextController.stream;

  Stream<bool> get buttonLoadingStream => _buttonLoading.stream;

  void updateGender(String gender) {
    if (gender != ' ') {
      _genderController.sink.add(gender);
    } else {
      _genderController.sink.addError('Please select your gender.');
    }
  }

  Future<void> updateCountryIosCode(Country? country) async {
    if (country == null) {
      if (PlatformUtils.isMobileApp() == true) {
        try {
        final List<Locale> systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
          final String? isoCountryCode = systemLocales.first.countryCode;
          PlatformUtils.debugLog(
            SignUpCubit,
            'isoCountryCode:${isoCountryCode!}',
          );
          _phoneNumberIosCodeController.add(
            CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
          );
        } catch (e) {
          PlatformUtils.debugLog(
            SignUpCubit,
            'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
          );
          final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
          _phoneNumberIosCodeController.add(data);
        }
      } else {
        getPublicIp();
      }
    } else {
      _phoneNumberIosCodeController.sink.add(country);
      // print("done");
    }
  }

  void updateDob(String pick) {
    _dobController.sink.add(pick);
  }

  void updatePasswordObscureText(bool data) {
    _passwordObscureTextController.sink.add(!data);
  }

  void updateConfirmPasswordObscureText(bool data) {
    _confirmPasswordObscureTextController.sink.add(!data);
  }

  // should contain at least one upper case
  // should contain at least one lower case
  // should contain at least one digit
  // should contain at least one Special character
  // Must be at least 8 characters in length
  void updatePassword(String password) {
    final RegExp regExp = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~+-]).{8,}$',
    );
    if (regExp.hasMatch(password)) {
      _passwordController.sink.add(password);
    } else {
      _passwordController.sink.addError('Please fill password properly.');
    }
  }

  void checkPassword(String password) {
    final RegExp numericRegex = RegExp('^(?=.*[0-9])');
    final RegExp oneUpperCaseRegex = RegExp('^(?=.*[A-Z])');
    final RegExp oneLowerCaseRegex = RegExp('^(?=.*[a-z])');
    final RegExp oneSpeficCaseRegex = RegExp('^(?=.*[!@#\$&*~+-])');

    if (password.isEmpty) {
      _passwordController.addError('Please enter a valid email');
      _isPasswordOneLowerCase.sink.add(false);
      _isPasswordOneUpperCase.sink.add(false);
      _isPasswordOneNumCase.sink.add(false);
      _isPasswordOneSpecialChar.sink.add(false);
      _isPasswordSizeRequire.sink.add(false);
    } else {
      if (!oneLowerCaseRegex.hasMatch(password)) {
        _isPasswordOneLowerCase.sink.add(false);
      } else {
        _isPasswordOneLowerCase.sink.add(true);
      }

      if (!oneUpperCaseRegex.hasMatch(password)) {
        _isPasswordOneUpperCase.sink.add(false);
      } else {
        _isPasswordOneUpperCase.sink.add(true);
      }

      if (!numericRegex.hasMatch(password)) {
        _isPasswordOneNumCase.sink.add(false);
      } else {
        _isPasswordOneNumCase.sink.add(true);
      }

      if (!oneSpeficCaseRegex.hasMatch(password)) {
        _isPasswordOneSpecialChar.sink.add(false);
      } else {
        _isPasswordOneSpecialChar.sink.add(true);
      }
      if (password.length >= 8) {
        _isPasswordSizeRequire.sink.add(true);
      } else {
        _isPasswordSizeRequire.sink.add(false);
      }

      if (password.length >= 8) {
        _isPasswordSizeRequire.sink.add(true);
      } else {
        _isPasswordSizeRequire.sink.add(false);
      }
    }
  }

  Future<void> updateConfirmPassword(String? confirmPassword) async {
    if (confirmPassword?.isNotEmpty??false) {
      String? password = '';
      try {
        password = _passwordController.valueOrNull;
      } catch (e) {
        password = '';
      }
      // print("password:$password");
      if (confirmPassword?.compareTo(password ?? '') == 0) {
        _confirmPasswordController.sink.add(confirmPassword??'');
      } else {
        _confirmPasswordController.sink.addError('Password is not match up..');
      }
    } else {
      _confirmPasswordController.sink.addError(
        'Please fill password properly.',
      );
    }
  }

  void updateButtonLoading(bool? isloading) {
    _buttonLoading.sink.add(isloading!);
  }

  void updatePhoneNumber(String phNumber) {
    if (phNumber.isEmpty) {
      _phoneNumberController.addError('Please enter a valid phone number.');
    } else {
      _phoneNumberController.sink.add(phNumber);
    }
  }

  Future<void> getPublicIp() async {
    try {
      final IpTrackerService ipTrackerService = IpTrackerService();
      final IpInfoModel ipInfo = await ipTrackerService.getIpInfo();

      if (ipInfo.countryCode != null) {
        PlatformUtils.debugLog(
          SignUpCubit,
          ':getPublicIp:country_code:${ipInfo.countryCode}',
        );
        final Country data = CountryPickerUtils.getCountryByIsoCode(
          ipInfo.countryCode!,
        );
        _phoneNumberIosCodeController.sink.add(data);
      } else {
        // print("No Ip Founded");
        final Country data = CountryPickerUtils.getCountryByIsoCode('IND');
        _phoneNumberIosCodeController.sink.add(data);
      }
    } catch (e) {
      PlatformUtils.debugLog(SignUpCubit, ':getPublicIp:Error:$e');
      final Country data = CountryPickerUtils.getCountryByIsoCode('IND');
      _phoneNumberIosCodeController.sink.add(data);
    }
  }
  // ...existing code...

  void clearFirstName() {
    _firstNameController.sink.add('');
  }

  void clearLastName() {
    _lastNameController.sink.add('');
  }

  void clearUserName() {
    _userNameController.sink.add('');
  }

  void clearEmail() {
    _emailController.sink.add('');
  }

  void clearPhoneNumberIosCode() {
    _phoneNumberIosCodeController.sink.add(null);
  }

  void clearPhoneNumber() {
    _phoneNumberController.sink.add('');
  }

  void clearGender() {
    _genderController.sink.add('');
  }

  void clearDob() {
    _dobController.sink.add('');
  }

  void clearPassword() {
    _passwordController.sink.add('');
    checkPassword('');
  }

  void clearConfirmPassword() {
    _confirmPasswordController.sink.add('');
  }

  void clearButtonLoading() {
    _buttonLoading.sink.add(false);
  }

  void clearAllFields() {
    clearFirstName();
    clearLastName();
    clearUserName();
    clearEmail();
    clearPhoneNumberIosCode();
    clearPhoneNumber();
    clearGender();
    clearDob();
    clearPassword();
    clearConfirmPassword();
    clearButtonLoading();
  }

  @override
  Future<void> close() {
    _firstNameController.close();
    _lastNameController.close();
    _userNameController.close();
    _emailController.close();
    _phoneNumberIosCodeController.close();
    _phoneNumberController.close();
    _genderController.close();
    _dobController.close();
    _passwordController.close();
    _passwordObscureTextController.close();
    _confirmPasswordController.close();
    _confirmPasswordObscureTextController.close();
    _isPasswordOneNumCase.close();
    _isPasswordOneUpperCase.close();
    _isPasswordOneLowerCase.close();
    _isPasswordOneSpecialChar.close();
    _isPasswordSizeRequire.close();
    _buttonLoading.close();
    return super.close();
  }
}
