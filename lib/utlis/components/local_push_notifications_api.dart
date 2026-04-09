import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utlis.dart';

class NotificationApi {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final BehaviorSubject<String?> onNotification =
      BehaviorSubject<String?>();

  static Future init({bool initSchedluled = false}) async {
    const DarwinInitializationSettings iosSetting =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestCriticalPermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    const AndroidInitializationSettings andriodSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: andriodSetting,
      iOS: iosSetting,
    );
    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) async {
        onNotification.add(details.payload.toString());
      },
      onDidReceiveBackgroundNotificationResponse: (details) async {
        onNotification.add(details.payload.toString());
      },
    );

    if (initSchedluled) {
      try {
        tz.initializeTimeZones();
        final locationTimezone = await FlutterTimezone.getLocalTimezone();
        final locationName = locationTimezone.identifier;
        Constants.debugLog(
          NotificationApi,
          'FlutterNativeTimezone:Location:\t${locationTimezone.localizedName?.name ?? ''}',
        );
        Constants.debugLog(
          NotificationApi,
          'FlutterNativeTimezone:Location:\t$locationName',
        );
        tz.setLocalLocation(tz.getLocation(locationName));
      } catch (e) {
        Constants.debugLog(NotificationApi, 'FlutterNativeTimezone:Error:\t$e');
      }
    }
  }

  static Future<void> requestNotificationPermission() async {
    if (Constants.isAndroid()) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Constants.isIOS()) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Constants.isMacOS()) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /*
   * NotificationApi.showNotification("title","body",payload:"payload"??"");
   */
  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: await _notificationDetails(),
      payload: payload,
    );
  }

  /*
   * NotificationApi.showProgressNotification("title","body",progress: 10, maxProgress: 100);
   */
  static Future showProgressNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required int progress,
    required int maxProgress,
  }) async {
    _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
          threadIdentifier: 'coozy_the_cafe_app_progress',
        ),

        android: AndroidNotificationDetails(
          'coozy_the_cafe_app_notification_progress',
          'Database Backup Progress',
          channelDescription: 'Shows progress for database backups',
          priority: Priority
              .low, // Lower priority so it doesn't pop over the screen repeatedly
          category: AndroidNotificationCategory.progress,
          importance: Importance.low,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          onlyAlertOnce: true,
        ),
      ),
      payload: payload,
    );
  }

  /*
   * NotificationApi.showScheduledNotification("title","body",payload:"payload"??"",scheduledDate:DateTime.now().add(Duration(seconds:12)));
   */
  static Future showScheduledNotification({
    required DateTime scheduledDate,
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: await _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
      // uiLocalNotificationDateInterpretation:UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /*
   * NotificationApi.showScheduledNotification("title","body",payload:"payload"??"",scheduledDate:DateTime.now().add(Duration(seconds:12)));
   */
  static Future showScheduledNotificationDailyBase({
    required DateTime time,
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // tz.TZDateTime.from(scheduledDate, tz.local),
      scheduledDate: _scheduledDaily(time),
      notificationDetails: await _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static tz.TZDateTime _scheduledDaily(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  static Future _notificationDetails() async {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'coozy_the_cafe_app',
      ),
      android: AndroidNotificationDetails(
        'coozy_the_cafe_app_notification', //channel id
        'coozy_the_cafe_app_Notification',
        channelDescription: 'Coozy the cafe all Notification from thee app',
        priority: Priority.high,
        category: AndroidNotificationCategory.service,
        importance: Importance.max,
      ),
    );
  }
}
