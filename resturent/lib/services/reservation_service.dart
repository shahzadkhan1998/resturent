import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resturent/models/reservation.dart';
import 'package:resturent/services/notification_service.dart';
import 'package:resturent/services/reminder_service.dart';
import 'package:resturent/services/preferences_service.dart';
import 'package:uuid/uuid.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final _notificationService = NotificationService();
  final _reminderService = ReminderService();
  final _preferencesService = PreferencesService();

  // Create a new reservation
  Future<Reservation> createReservation({
    required String userId,
    required DateTime date,
    required String time,
    required int numberOfPeople,
    String? specialRequests,
  }) async {
    final reservation = Reservation(
      id: _uuid.v4(),
      userId: userId,
      date: date,
      time: time,
      numberOfPeople: numberOfPeople,
      specialRequests: specialRequests ?? '',
    );

    await _firestore
        .collection('reservations')
        .doc(reservation.id)
        .set(reservation.toJson());

    // Get user preferences for notifications
    final preferences = await _preferencesService.getUserPreferences(userId);

    if (preferences.enableNotifications) {
      await _notificationService.showReservationConfirmation(
        'Reservation Received',
        'Your reservation request for ${reservation.time} on ${_formatDate(date)} has been received.',
      );

      // Schedule reminder based on user preferences
      if (date.isAfter(DateTime.now())) {
        await _reminderService.scheduleReservationReminder(
          reservation,
          preferences.reminderMinutesBefore,
        );
      }
    }

    return reservation;
  }

  // Get user's reservations
  Stream<List<Reservation>> getUserReservations(String userId) {
    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromJson(doc.data()))
            .toList());
  }

  // Update reservation status
  Future<void> updateReservationStatus(
      String reservationId, String status) async {
    final docRef = _firestore.collection('reservations').doc(reservationId);
    final reservationDoc = await docRef.get();

    if (!reservationDoc.exists) return;

    final reservation = Reservation.fromJson(reservationDoc.data()!);
    await docRef.update({'status': status});

    // Get user preferences for notifications
    final preferences =
        await _preferencesService.getUserPreferences(reservation.userId);

    if (preferences.enableNotifications) {
      String notificationTitle;
      String notificationBody;

      switch (status) {
        case 'confirmed':
          notificationTitle = 'Reservation Confirmed!';
          notificationBody =
              'Your reservation for ${reservation.time} on ${_formatDate(reservation.date)} has been confirmed.';
          // Schedule reminder for confirmed reservation
          if (reservation.date.isAfter(DateTime.now())) {
            await _reminderService.scheduleReservationReminder(
              reservation,
              preferences.reminderMinutesBefore,
            );
          }
          break;
        case 'cancelled':
          notificationTitle = 'Reservation Cancelled';
          notificationBody =
              'Your reservation for ${reservation.time} on ${_formatDate(reservation.date)} has been cancelled.';
          // Cancel any existing reminders
          await _reminderService.cancelReservationReminder(reservationId);
          break;
        default:
          return;
      }

      await _notificationService.showReservationConfirmation(
        notificationTitle,
        notificationBody,
      );
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId) async {
    await updateReservationStatus(reservationId, 'cancelled');
  }

  // Check availability for a given date and time
  Future<bool> checkAvailability(DateTime date, String time) async {
    final existingReservations = await _firestore
        .collection('reservations')
        .where('date', isEqualTo: date.toIso8601String())
        .where('time', isEqualTo: time)
        .where('status', isEqualTo: 'confirmed')
        .get();

    // Assuming maximum 20 tables available per time slot
    return existingReservations.docs.length < 20;
  }

  // Get available time slots for a given date
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    const allTimeSlots = [
      '11:00',
      '11:30',
      '12:00',
      '12:30',
      '13:00',
      '13:30',
      '14:00',
      '14:30',
      '17:00',
      '17:30',
      '18:00',
      '18:30',
      '19:00',
      '19:30',
      '20:00',
      '20:30',
      '21:00',
      '21:30',
    ];

    final availableSlots = <String>[];

    for (final time in allTimeSlots) {
      final isAvailable = await checkAvailability(date, time);
      if (isAvailable) {
        availableSlots.add(time);
      }
    }

    return availableSlots;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
