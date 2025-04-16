import 'package:flutter/material.dart';
import 'package:resturent/models/reservation.dart';
import 'package:resturent/services/reservation_service.dart';
import 'package:resturent/services/auth_service.dart';
import 'package:resturent/features/reservation/reservation_screen.dart';
import 'package:intl/intl.dart';

class ReservationHistoryScreen extends StatelessWidget {
  ReservationHistoryScreen({super.key});

  final _reservationService = ReservationService();
  final _authService = AuthService();

  Future<bool> _showCancelConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Reservation'),
            content: const Text(
              'Are you sure you want to cancel this reservation? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No, Keep it'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Center(
        child: Text('Please login to view your reservations'),
      );
    }

    return StreamBuilder<List<Reservation>>(
      stream: _reservationService.getUserReservations(user.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reservations = snapshot.data ?? [];
        if (reservations.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Reservations')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reservations found',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Make a reservation to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReservationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Make Reservation'),
            ),
          );
        }

        final upcomingReservations = reservations
            .where((res) =>
                res.date.isAfter(DateTime.now()) && res.status != 'cancelled')
            .toList();
        final pastReservations = reservations
            .where((res) =>
                res.date.isBefore(DateTime.now()) || res.status == 'cancelled')
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('My Reservations'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _ReservationList(
                  reservations: upcomingReservations,
                  isUpcoming: true,
                  onCancel: (reservationId) async {
                    if (await _showCancelConfirmation(context)) {
                      await _reservationService
                          .cancelReservation(reservationId);
                    }
                  },
                ),
                _ReservationList(
                  reservations: pastReservations,
                  isUpcoming: false,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReservationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Make Reservation'),
            ),
          ),
        );
      },
    );
  }
}

class _ReservationList extends StatelessWidget {
  const _ReservationList({
    required this.reservations,
    required this.isUpcoming,
    this.onCancel,
  });

  final List<Reservation> reservations;
  final bool isUpcoming;
  final Function(String)? onCancel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        final dateFormat = DateFormat('EEEE, MMMM d, y');

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateFormat.format(reservation.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(reservation.status),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      'Time: ${reservation.time}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 8),
                    Text(
                      'People: ${reservation.numberOfPeople}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                if (reservation.specialRequests.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.note),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: ${reservation.specialRequests}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
                if (isUpcoming && reservation.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cancel Reservation'),
                              content: const Text(
                                'Are you sure you want to cancel this reservation?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    onCancel?.call(reservation.id);
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Yes, Cancel'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel Reservation'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
