import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utlis.dart';

/// A utility class for date and time operations, providing formatting,
/// parsing, and conversion methods for DateTime and TimeOfDay objects.
class DateUtil {
  // Date format constants
  static const String dateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSSSSZ';
  static const String dateFormat1 = 'yyyy-MM-dd HH:mm'; // "2022-02-21 04:14"
  static const String dateFormat2 = 'dd-MM-yyyy HH:mm'; // "21-02-2022 04:14"
  static const String dateFormat3 = 'dd-MMM-yyyy HH:mm'; // "21-Feb-2022 04:14"
  static const String dateFormat4 = 'yy-MM-dd hh:mm:ss aaa'; // "22-02-21 04:15:03 AM"
  static const String dateFormat5 = 'MM-dd-yy hh:mm:ss aaa'; // "02-21-22 04:15:03 AM"
  static const String dateFormat6 = 'dd-MM-yy hh:mm:ss aaa'; // "21-02-22 04:15:03 AM"
  static const String dateFormat7 = 'yyyy-MM-dd'; // "2022-02-21"
  static const String dateFormat8 = 'MM-dd-yyyy'; // "02-21-2022"
  static const String dateFormat9 = 'dd-MM-yyyy'; // "21-02-2022"
  static const String dateFormat10 = 'dd-MMM-yyyy'; // "21-Feb-2022"
  static const String dateFormat11 = 'dd/MM/yyyy hh:mm:ss aaa'; // "11/02/2022 04:16:58 AM"
  static const String dateFormat12 = 'eeee'; // "Friday"
  static const String dateFormat13 = 'EEE'; // "Fri"
  static const String dateFormat14 = 'MMMM'; // "February"
  static const String dateFormat15 = 'dd-MM-yyyy hh:mm:ss aaa'; // "11-02-2022 04:16:58 AM"
  static const String dateFormat16 = 'dd-MM-yyyy hh:mm aaa'; // "11-02-2022 04:16 AM"

  // Time format constants
  static const String timeFormat1 = 'hh:mm:ss aaa'; // "04:16:58 AM"
  static const String timeFormat2 = 'hh:mm aaa'; // "04:16 AM"

  /// Current timestamp in UTC ISO 8601 format.
  static String get currentTimestamp => DateTime.now().toUtc().toIso8601String();

  /// Formats a UTC time string to local time using the specified date format.
  /// Returns null if the input is null or parsing fails.
  static String? localFormat(String? utcTime, String dateFormat) {
    try {
      if (utcTime != null) {
        final DateTime strToDateTime = DateTime.parse(utcTime);
        final DateTime convertLocal = strToDateTime.toLocal();
        return DateFormat(dateFormat).format(convertLocal);
      }
    } catch (e) {
      Constants.debugLog(DateUtil, 'localFormat: error - ${e.toString()}');
    }
    return null;
  }

  /// Formats a UTC DateTime to local time using the specified date format.
  /// Returns null if the input is null or formatting fails.
  static String? localFormatDateTime(DateTime? utcTime, String dateFormat) {
    try {
      if (utcTime != null) {
        final DateTime convertLocal = utcTime.toLocal();
        return DateFormat(dateFormat).format(convertLocal);
      }
    } catch (e) {
      Constants.debugLog(DateUtil, 'localFormatDateTime: error - ${e.toString()}');
    }
    return null;
  }

  /// Parses a date string using the specified format and converts it to local DateTime.
  /// Returns null if the input is null or parsing fails.
  static DateTime? stringToLocalDate(String? utcTime, String dateFormat) {
    try {
      if (utcTime != null) {
        return DateFormat(dateFormat).parse(utcTime).toLocal();
      }
    } catch (e) {
      Constants.debugLog(DateUtil, 'stringToLocalDate: error - ${e.toString()}');
    }
    return null;
  }

  /// Parses a date string using the specified format.
  /// Throws an exception if parsing fails and time is not null.
  static DateTime? stringToDate(String? time, String dateFormat) {
    try {
      if (time != null) {
        return DateFormat(dateFormat).parse(time);
      }
    } catch (e) {
      Constants.debugLog(DateUtil, 'stringToDate: error - ${e.toString()}');
    }
    return null;
  }

  /// Formats a DateTime to a string using the specified format.
  /// Returns null if the input is null or formatting fails.
  static String? dateToString(DateTime? time, String? dateFormat) {
    if (time == null || dateFormat == null) {
      return null;
    }
    try {
      return DateFormat(dateFormat).format(time);
    } catch (e) {
      Constants.debugLog(DateUtil, 'dateToString: error - ${e.toString()}');
      return null;
    }
  }

  /// Changes the format of a DateTime by formatting and re-parsing it.
  /// Returns null if input is null or operation fails.
  static DateTime? simpleDateFormatChanger(
    DateTime? inputDate,
    String? dateFormat,
  ) {
    if (inputDate == null || dateFormat == null) return null;

    try {
      final String formattedDate = DateFormat(dateFormat).format(inputDate);
      return DateFormat(dateFormat).parse(formattedDate);
    } catch (e) {
      return null;
    }
  }

  /// Changes the format of a date string by parsing and re-formatting it.
  /// Returns null if input is null or operation fails.
  static String? simpleStringFormatChanger(
    String? inputDate,
    String? dateFormat,
  ) {
    if (inputDate == null || dateFormat == null) return null;
    try {
      final DateTime parsed = DateFormat(dateFormat).parse(inputDate);
      return DateFormat(dateFormat).format(parsed);
    } catch (e) {
      return null;
    }
  }

  /// Checks if a DateTime can be formatted with the given date format.
  static bool isDateHasValidDateFormat(DateTime? time, String? dateFormat) {
    if (time == null || dateFormat == null) return false;
    try {
      DateFormat(dateFormat).format(time);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Checks if a string can be parsed with the given date format.
  static bool isStringHasCorrectDateFormat(String? time, String? dateFormat) {
    if (time == null || dateFormat == null) return false;
    try {
      DateFormat(dateFormat).parse(time);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parses a date string using the specified format and converts it to local DateTime.
  /// Returns null if the input is null or parsing fails.
  static DateTime? stringToLocalDateTime(String? utcTime, String dateFormat) {
    try {
      if (utcTime != null) {
        final DateTime parsedDateTime = DateFormat(dateFormat).parse(utcTime);
        return parsedDateTime.toLocal();
      }
    } catch (e) {
      Constants.debugLog(DateUtil, 'stringToLocalDateTime: error - ${e.toString()}');
    }
    return null;
  }

  /// Parses a date string using the specified format.
  /// Returns null if the input is null or parsing fails.
  static DateTime? stringToDateTime(String? date, String dateFormat) {
    try {
      if (date != null) {
        return DateFormat(dateFormat).tryParse(date);
      }
    } catch (e) {
      Constants.debugLog(DateUtil, 'stringToDateTime: error - ${e.toString()}');
    }
    return null;
  }

  /// Converts a DateTime to TimeOfDay.
  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  /// Converts a TimeOfDay to DateTime using today's date.
  static DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final DateTime now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  /// Formats a TimeOfDay as a string using the specified pattern.
  static String formatTimeOfDay(TimeOfDay timeOfDay, String pattern) {
    final DateTime dateTime = timeOfDayToDateTime(timeOfDay);
    return DateFormat(pattern).format(dateTime);
  }

  /// Parses a time string to TimeOfDay using the specified format.
  static TimeOfDay parseTimeOfDay(String time, String? format) {
    final DateTime? dateTime = DateFormat(
      format ?? timeFormat2,
    ).tryParse(time);
    return TimeOfDay(hour: dateTime?.hour ?? 0, minute: dateTime?.minute ?? 0);
  }

  /// Formats a Duration as "HH:mm".
  static String formatDuration(Duration duration) {
    final String hours = (duration.inHours % 24).toString().padLeft(2, '0');
    final String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Calculates the remaining time between two time strings in a human-readable format.
  /// Returns a string like "2 days, 3 hours, 15 minutes" or null if parsing fails.
  static String? calculateRemainingTime({
    required String? format,
    required String? fromTime,
   required  String? toTime,
    String? localeTxtDays,
    String? localeTxtHours,
    String? localeTxtMinutes,
  }) {
    try {
      if (format == null || fromTime == null || toTime == null) return null;
      final DateTime? startDateTime = DateFormat(format).tryParse(fromTime);
      final DateTime? endDateTime = DateFormat(format).tryParse(toTime);
      if (startDateTime == null || endDateTime == null) return null;

      final Duration difference = startDateTime.difference(endDateTime);
      final int days = difference.inDays;
      final int hours = difference.inHours % 24;
      final int minutes = difference.inMinutes % 60;
      final StringBuffer stringBuffer = StringBuffer();
      if (days != 0) {
        stringBuffer.write('$days ${localeTxtDays ?? 'days'}');
      }
      if (hours != 0) {
        if (stringBuffer.isNotEmpty) stringBuffer.write(', ');
        stringBuffer.write('$hours ${localeTxtHours ?? 'hours'}');
      }
      if (minutes != 0) {
        if (stringBuffer.isNotEmpty) stringBuffer.write(', ');
        stringBuffer.write('$minutes ${localeTxtMinutes ?? 'minutes'}');
      }
      return stringBuffer.toString();
    } catch (e) {
      Constants.debugLog(DateUtil, 'calculateRemainingTime: error - $e');
      return null;
    }
  }

  /// Calculates the time difference in seconds between check-in and check-out times.
  /// Returns null if parsing fails.
  static int? calculateTimeDifferenceInSeconds(
    String checkInTime,
    String checkOutTime,
  ) {
    try {
      final DateTime checkInDateTime = DateFormat.jm().parse(checkInTime);
      final DateTime checkOutDateTime = DateFormat.jm().parse(checkOutTime);
      final Duration difference = checkOutDateTime.difference(checkInDateTime);
      Constants.debugLog(
        DateUtil,
        'calculateTimeDifferenceInSeconds: difference - ${difference.inSeconds} seconds',
      );
      return difference.inSeconds;
    } catch (error) {
      Constants.debugLog(
        DateUtil,
        'calculateTimeDifferenceInSeconds: error - $error',
      );
      return null;
    }
  }
}
