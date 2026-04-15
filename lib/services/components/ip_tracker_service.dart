import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../model/ip_info_model.dart';
import '../../utils/components/constants.dart';

class IpTrackerService {
  // Base URL for the IP API
  static const String _baseUrl = 'http://ip-api.com/json/';

  // Fields to request from the API
  static const String _fields =
      'status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query';

  // Timeout for HTTP requests
  static const Duration _timeout = Duration(seconds: 10);

  Future<String?> _getPublicIp(String url) async {
    try {
      final http.Response response = await http
          .get(Uri.parse(url))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'] as String?;
      } else {
        throw HttpException(
          'Failed to get public IP address. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getPublicIp4() async {
    return _getPublicIp('https://api.ipify.org?format=json');
  }

  Future<String?> getPublicIp6() async {
    return _getPublicIp('https://api64.ipify.org/?format=json');
  }

  /// Fetches IP information.
  /// If [query] is provided, it fetches info for that specific IP or domain.
  /// If [query] is null or empty, it fetches info for the current IP.
  Future<IpInfoModel> getIpInfo({String? ipAddress}) async {
    if (ipAddress == null || ipAddress.isEmpty) {
      final String? ipaddress4Value = await getPublicIp4();
      if (ipaddress4Value != null) {
        ipAddress = ipaddress4Value;
      } else {
        final String? ipaddress6Value = await getPublicIp6();
        if (ipaddress6Value != null) {
          ipAddress = ipaddress6Value;
        } else {
          throw const SocketException('No Internet connection');
        }
      }
    }
    try {
      final String url = '$_baseUrl$ipAddress?lang=en&fields=$_fields';
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final ipInfoModel = IpInfoModel.fromJson(jsonResponse);
        Constants.debugLog(
          IpTrackerService,
          "Ipaddress: ${ipInfoModel.toString()}",
        );
        return ipInfoModel;
      } else {
        throw HttpException(
          'Failed to load IP info. Status code: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw const SocketException('No Internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } catch (e) {
      rethrow;
    }
  }
}
