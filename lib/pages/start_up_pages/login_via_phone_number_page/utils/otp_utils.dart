import 'dart:convert';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../../utils/utils.dart';

class OtpUtils {
  static const Type _tag = OtpUtils;

  /// Generates a 4-digit OTP code
  static String generateOtpCode() {
    return Constants.randomNumberGenerator(1000, 9999).toString();
  }

  /// Creates SMS message for mobile platform (Android/iOS)
  static Future<String> createMobileSmsBMessage(String otpCode) async {
    final String appSignatureId = await SmsAutoFill().getAppSignature;
    PlatformUtils.debugLog(_tag, 'appSignatureId: $appSignatureId');
    return '<#> Your code is $otpCode\n$appSignatureId';
  }

  /// Creates SMS message for non-mobile platforms
  static String createWebSmsMessage(String otpCode) {
    return 'Your code is $otpCode.';
  }

  /// Encodes SMS parameters to JSON
  static String encodeSmsParams({
    required String? phoneNumber,
    required String? messageBody,
  }) {
    final Map<String, dynamic> map = <String, dynamic>{
      'PhoneTo': phoneNumber ?? '',
      'SmsMessage': messageBody ?? '',
    };
    return json.encode(map);
  }

  /// Validates phone number
  static bool isValidPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return false;
    }
    return phoneNumber.length >= 7; // Basic validation
  }

  /// Formats phone number with country code
  static String formatPhoneNumber({
    required String? countryCode,
    required String? phoneNumber,
  }) {
    final String code = countryCode?.replaceFirst('+', '') ?? '91';
    return '+$code $phoneNumber';
  }
}
