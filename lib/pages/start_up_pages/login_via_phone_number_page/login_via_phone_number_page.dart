import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../utils/utils.dart';
import '../../../widgets/widgets.dart';
import 'widgets/login_phone_mobile_widget.dart';
import 'utils/otp_utils.dart';
import 'utils/login_phone_form_handler.dart';
import 'widgets/login_phone_tablet_widget.dart';

class LoginViaPhoneNumberPage extends StatefulWidget {
  const LoginViaPhoneNumberPage({required this.isUseForLogin, super.key});
  final bool isUseForLogin;

  @override
  State<LoginViaPhoneNumberPage> createState() =>
      _LoginViaPhoneNumberPageState();
}

class _LoginViaPhoneNumberPageState extends State<LoginViaPhoneNumberPage> {
  Size? size;
  late GlobalKey<FormState> _formKey;
  late TextEditingController _phoneNumberController;
  late FocusNode _phoneNumberFocusNode;
  dynamic _progressButtonState;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _phoneNumberController = TextEditingController(text: '');
    _phoneNumberFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          PlatformUtils.debugLog(
            LoginViaPhoneNumberPage,
            "Back button pressed. Did pop: $didPop",
          );
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: ResponsiveLayout(
            mobile: _buildMobileWidget(),
            tablet: _buildTabletWidget(),
            desktop: _buildMobileWidget(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return LoginPhoneMobileWidget(
            phoneNumberController: _phoneNumberController,
            phoneNumberFocusNode: _phoneNumberFocusNode,
            formKey: _formKey,
            progressController: null,
            onSubmit: (dynamic progressButtonState) =>
                _handleFormSubmit(progressButtonState, context),
          );
        } else {
          return LoginPhoneTabletWidget(
            phoneNumberController: _phoneNumberController,
            phoneNumberFocusNode: _phoneNumberFocusNode,
            formKey: _formKey,
            progressController: null,
            onSubmit: (dynamic progressButtonState) =>
                _handleFormSubmit(progressButtonState, context),
          );
        }
      },
    );
  }

  Widget _buildTabletWidget() {
    return LoginPhoneTabletWidget(
      phoneNumberController: _phoneNumberController,
      phoneNumberFocusNode: _phoneNumberFocusNode,
      formKey: _formKey,
      progressController: null,
      onSubmit: (dynamic progressButtonState) =>
          _handleFormSubmit(progressButtonState, context),
    );
  }

  Future<void> _handleFormSubmit(
    dynamic progressButtonState,
    final BuildContext context,
  ) async {
    _progressButtonState = progressButtonState;
    await LoginPhoneFormHandler.submitPhoneNumber(
      context: context,
      formKey: _formKey,
      phoneNumberController: _phoneNumberController,
      progressButtonState: progressButtonState,
      onPhoneNumberSubmit: (String phoneNumber) =>
          _verifySubmitPhoneNumber(phoneNumber: phoneNumber, context: context),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  void _verifySubmitPhoneNumber({
    required final String phoneNumber,
    required final BuildContext context,
  }) {
    PlatformUtils.debugLog(
      LoginViaPhoneNumberPage,
      'verifySubmit: phoneNumber: $phoneNumber',
    );

    try {
      if (PlatformUtils.isMobileApp() == true) {
        OtpUtils.createMobileSmsBMessage(OtpUtils.generateOtpCode()).then((
          final String smsMessage,
        ) {
          _sendOtp(phoneNumber: phoneNumber, smsMessage: smsMessage);
        });
      } else {
        final String otpCode = OtpUtils.generateOtpCode();
        final String smsMessage = OtpUtils.createWebSmsMessage(otpCode);
        PlatformUtils.debugLog(LoginViaPhoneNumberPage, smsMessage);
        _sendOtp(phoneNumber: phoneNumber, smsMessage: smsMessage);
      }
    } catch (e) {
      PlatformUtils.debugLog(LoginViaPhoneNumberPage, 'Error: ${e.toString()}');
      _progressButtonState?.reset();
      context.read<LoginWithPhoneBloc>().add(
        LoginWithPhoneUpdateButtonLoadingEvent(false),
      );
    }
  }

  Future<void> _sendOtp({
    required String phoneNumber,
    required String smsMessage,
  }) async {
    final String params = OtpUtils.encodeSmsParams(
      phoneNumber: phoneNumber,
      messageBody: smsMessage,
    );

    PlatformUtils.debugLog(LoginViaPhoneNumberPage, 'SMS params: $params');

    // TODO: Implement OTP sending logic
    // This should navigate to OTP verification page or call your OTP service
    _phoneNumberController.clear();
    _progressButtonState?.reset();
    context.read<LoginWithPhoneBloc>().add(
      LoginWithPhoneUpdateButtonLoadingEvent(false),
    );
  }
}
