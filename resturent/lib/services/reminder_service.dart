import 'package:resturent/models/reservation.dart';
import 'package:resturent/services/notification_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._();
  factory ReminderService() => _instance;
  ReminderService._();

  final _notificationService = NotificationService();

  Future<void> scheduleReservationReminder(
    Reservation reservation,
    int minutesBefore,
  ) async {
    await _notificationService.scheduleReservationReminder(
      reservation.id,
      reservation.time,
      reservation.date,
      minutesBefore,
    );
  }

  Future<void> cancelReservationReminder(String reservationId) async {
    await _notificationService.cancelReservationReminder(reservationId);
  }

  Future<void> cancelAllReminders() async {
    await _notificationService.cancelAll();
  }
}
