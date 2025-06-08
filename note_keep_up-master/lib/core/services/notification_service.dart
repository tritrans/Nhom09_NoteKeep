import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:note_app/features/domain/entities/reminder.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
    print('[DEBUG] NotificationService initialized.');
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    print('[DEBUG] Notification permission requested.');
  }

  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print('[DEBUG] scheduleNotification START');
    print(
        '[DEBUG] Params: id=$id, title=$title, body=$body, scheduledDate=$scheduledDate');

    try {
      final scheduled = tz.TZDateTime.from(scheduledDate, tz.local);
      print('[DEBUG] TZDateTime scheduled: $scheduled');
      if (scheduled.isBefore(DateTime.now().add(const Duration(seconds: 2)))) {
        print(
            '[DEBUG] Scheduled time is too close or in the past! Notification will NOT be scheduled.');
        return;
      }
      final details = const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel_v10',
          'Deadline Notifications',
          channelDescription: 'Thông báo trước deadline',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
      print('[DEBUG] NotificationDetails created for deadline.');
      print('[DEBUG] Scheduling deadline notification with ID: ${id.hashCode}');

      await _notifications.zonedSchedule(
        id.hashCode,
        title,
        body,
        scheduled,
        details,
        matchDateTimeComponents: null,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('[DEBUG] zonedSchedule called successfully for deadline.');
    } catch (e, stack) {
      print('[ERROR] scheduleNotification exception: $e');
      print(stack);
    }
  }

//test
  Future<void> showInstantNotification({
    required String title,
    required String body,
    required DateTime scheduledDate, // thêm tham số này
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    await _notifications.zonedSchedule(
      0,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Instant Notifications',
          channelDescription: 'Test instant notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  Future<void> scheduleReminderNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required RepeatType repeatType,
  }) async {
    print('[DEBUG] scheduleReminderNotification START');
    print(
        '[DEBUG] Params: id=$id, title=$title, body=$body, scheduledDate=$scheduledDate, repeatType=$repeatType');
    final granted = await checkNotificationPermission();
    if (!granted) {
      print('[ERROR] Không có quyền gửi notification!');
      return;
    }
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    print('[DEBUG] TZDateTime scheduled for reminder: $tzScheduledDate');
    if (tzScheduledDate
        .isBefore(DateTime.now().add(const Duration(seconds: 2)))) {
      print(
          '[DEBUG] Scheduled time is too close or in the past! Reminder notification will NOT be scheduled.');
      return;
    }
    DateTimeComponents? matchDateTimeComponents;
    switch (repeatType) {
      case RepeatType.daily:
        matchDateTimeComponents = DateTimeComponents.time;
        break;
      case RepeatType.weekly:
        matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
      case RepeatType.monthly:
        matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
        break;
      case RepeatType.none:
        matchDateTimeComponents = null;
        break;
    }
    print(
        '[DEBUG] Reminder repeatType: $repeatType, matchDateTimeComponents: $matchDateTimeComponents');
    try {
      print(
          '[DEBUG] scheduleReminderNotification: Gọi zonedSchedule với ID: ${id.hashCode}...');
      await _notifications.zonedSchedule(
        id.hashCode,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder Notifications',
            channelDescription: 'Nhắc nhở ghi chú',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      print('[DEBUG] scheduleReminderNotification: zonedSchedule thành công!');
    } catch (e, stack) {
      print('[ERROR] scheduleReminderNotification exception: $e');
      if (e is PlatformException && e.code == 'exact_alarms_not_permitted') {
        print(
            '[ERROR] Exact Alarm permission NOT granted! Please grant "Báo thức chính xác" (Exact Alarm) for the app in Settings.');
        await openExactAlarmSettings();
      } else {
        print('[ERROR] Other notification scheduling error: $e');
      }
      print(stack);
    }
  }

  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Kiểm tra quyền notification, trả về true nếu đã cấp quyền
  Future<bool> checkNotificationPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.areNotificationsEnabled() ?? false;
    print('[DEBUG] Notification permission granted: $granted');
    return granted;
  }

  Future<void> openExactAlarmSettings() async {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }
}
