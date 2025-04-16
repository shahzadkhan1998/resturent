import 'package:flutter/material.dart';
import 'package:resturent/models/reservation.dart';
import 'package:resturent/services/reservation_service.dart';
import 'package:resturent/services/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _reservationService = ReservationService();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final _peopleController = TextEditingController(text: '2');
  final _requestsController = TextEditingController();
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  @override
  void dispose() {
    _peopleController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  Future<void> _loadTimeSlots() async {
    setState(() => _isLoading = true);
    try {
      final slots =
          await _reservationService.getAvailableTimeSlots(_selectedDate);
      setState(() {
        _availableTimeSlots = slots;
        if (_selectedTime != null && !slots.contains(_selectedTime)) {
          _selectedTime = null;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeReservation() async {
    if (!_formKey.currentState!.validate() || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to make a reservation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _reservationService.createReservation(
        userId: user.id,
        date: _selectedDate,
        time: _selectedTime!,
        numberOfPeople: int.parse(_peopleController.text),
        specialRequests: _requestsController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = null;
      _peopleController.text = '2';
      _requestsController.clear();
    });
    _loadTimeSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Reservation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 30)),
                        focusedDay: _selectedDate,
                        selectedDayPredicate: (day) =>
                            isSameDay(day, _selectedDate),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _selectedTime = null;
                          });
                          _loadTimeSlots();
                        },
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Available Time Slots',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_availableTimeSlots.isEmpty)
                      const Center(
                        child: Text(
                          'No available time slots for this date',
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableTimeSlots.map((time) {
                          final isSelected = time == _selectedTime;
                          return FilterChip(
                            selected: isSelected,
                            label: Text(time),
                            onSelected: (selected) {
                              setState(() {
                                _selectedTime = selected ? time : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _peopleController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of People',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of people';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1 || number > 20) {
                          return 'Please enter a valid number (1-20)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _requestsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Special Requests (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _makeReservation,
                        child: const Text('Make Reservation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
