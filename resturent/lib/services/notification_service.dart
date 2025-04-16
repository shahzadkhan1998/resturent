import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // no icon for iOS
      [
        NotificationChannel(
          channelKey: 'reservations',
          channelName: 'Reservations',
          channelDescription: 'Notifications for restaurant reservations',
          importance: NotificationImportance.High,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          ledColor: Colors.orange,
        ),
        NotificationChannel(
          channelKey: 'reminders',
          channelName: 'Reminders',
          channelDescription: 'Reminders for upcoming reservations',
          importance: NotificationImportance.High,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          ledColor: Colors.orange,
        ),
      ],
    );

    await requestNotificationPermission();
  }

  Future<bool> requestNotificationPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  Future<void> showReservationConfirmation(
    String title,
    String body, {
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'reservations',
        title: title,
        body: body,
        payload: {'data': payload},
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> scheduleReservationReminder(
    String reservationId,
    String time,
    DateTime date,
    int minutesBefore,
  ) async {
    final scheduledDate = date.subtract(Duration(minutes: minutesBefore));

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reservationId.hashCode,
        channelKey: 'reminders',
        title: 'Upcoming Reservation',
        body: 'Your reservation at $time is in $minutesBefore minutes',
        payload: {'reservationId': reservationId},
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  Future<void> cancelReservationReminder(String reservationId) async {
    await AwesomeNotifications().cancel(reservationId.hashCode);
  }

  Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }
}
