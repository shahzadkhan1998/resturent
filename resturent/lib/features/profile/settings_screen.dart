import 'package:flutter/material.dart';
import 'package:resturent/models/user_preferences.dart';
import 'package:resturent/services/preferences_service.dart';
import 'package:resturent/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _preferencesService = PreferencesService();
  final _authService = AuthService();
  bool _isLoading = true;
  late UserPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = _authService.currentUser;
    if (user != null) {
      final prefs = await _preferencesService.getUserPreferences(user.id);
      setState(() {
        _preferences = prefs;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences(UserPreferences newPreferences) async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await _preferencesService.updateUserPreferences(
            user.id, newPreferences);
        setState(() => _preferences = newPreferences);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSettings(),
          const SizedBox(height: 16),
          _buildDietaryPreferences(),
          const SizedBox(height: 16),
          _buildAppPreferences(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: _preferences.enableNotifications,
              onChanged: (value) {
                _updatePreferences(
                  _preferences.copyWith(enableNotifications: value),
                );
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive email notifications'),
              value: _preferences.enableEmailNotifications,
              onChanged: (value) {
                _updatePreferences(
                  _preferences.copyWith(enableEmailNotifications: value),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Reminder Timing'),
              subtitle: Text(
                '${_preferences.reminderMinutesBefore} minutes before reservation',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showReminderTimeDialog(),
            ),
            if (_preferences.enableNotifications) ...[
              const Divider(),
              ListTile(
                title: const Text('Notification Types'),
                subtitle: const Text('Customize what you get notified about'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showNotificationTypesDialog(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dietary Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _updatePreferences(
                      _preferences.copyWith(dietaryPreferences: []),
                    );
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Vegetarian',
                'Vegan',
                'Gluten-Free',
                'Dairy-Free',
                'Nut-Free',
                'Halal',
                'Kosher',
              ].map((preference) {
                final isSelected =
                    _preferences.dietaryPreferences.contains(preference);
                return FilterChip(
                  selected: isSelected,
                  label: Text(preference),
                  onSelected: (selected) {
                    final newPreferences = List<String>.from(
                      _preferences.dietaryPreferences,
                    );
                    if (selected) {
                      newPreferences.add(preference);
                    } else {
                      newPreferences.remove(preference);
                    }
                    _updatePreferences(
                      _preferences.copyWith(
                        dietaryPreferences: newPreferences,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text(_getLanguageName(_preferences.preferredLanguage)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency'),
              subtitle: Text(_getCurrencyName(_preferences.currencyCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCurrencyDialog(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme'),
              subtitle: const Text('Light'), // TODO: Implement theme switching
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement theme dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      default:
        return code.toUpperCase();
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar (USD)';
      case 'EUR':
        return 'Euro (EUR)';
      case 'GBP':
        return 'British Pound (GBP)';
      default:
        return code;
    }
  }

  Future<void> _showNotificationTypesDialog() async {
    final currentTypes = _preferences.notificationTypes;
    NotificationTypes updatedTypes = currentTypes;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Types'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Reservation Confirmations'),
              subtitle:
                  const Text('Get notified when your reservation is confirmed'),
              value: currentTypes.reservationConfirmations,
              onChanged: (value) {
                setState(() {
                  updatedTypes = updatedTypes.copyWith(
                    reservationConfirmations: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Reservation Reminders'),
              subtitle: const Text('Get reminded before your reservation'),
              value: currentTypes.reservationReminders,
              onChanged: (value) {
                setState(() {
                  updatedTypes = updatedTypes.copyWith(
                    reservationReminders: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Special Offers'),
              subtitle: const Text('Receive promotions and special deals'),
              value: currentTypes.specialOffers,
              onChanged: (value) {
                setState(() {
                  updatedTypes = updatedTypes.copyWith(
                    specialOffers: value,
                  );
                });
              },
            ),
            SwitchListTile(
              title: const Text('Order Updates'),
              subtitle: const Text('Get updates about your orders'),
              value: currentTypes.orderUpdates,
              onChanged: (value) {
                setState(() {
                  updatedTypes = updatedTypes.copyWith(
                    orderUpdates: value,
                  );
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updatePreferences(
                _preferences.copyWith(notificationTypes: updatedTypes),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReminderTimeDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many minutes before the reservation?'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [15, 30, 45, 60, 120].map((minutes) {
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: _preferences.reminderMinutesBefore == minutes,
                  onSelected: (selected) {
                    if (selected) {
                      Navigator.pop(context, minutes);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      _updatePreferences(
        _preferences.copyWith(reminderMinutesBefore: result),
      );
    }
  }

  Future<void> _showLanguageDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: _preferences.preferredLanguage == 'en'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, 'en'),
            ),
            ListTile(
              title: const Text('Spanish'),
              trailing: _preferences.preferredLanguage == 'es'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, 'es'),
            ),
            ListTile(
              title: const Text('French'),
              trailing: _preferences.preferredLanguage == 'fr'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, 'fr'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      _updatePreferences(
        _preferences.copyWith(preferredLanguage: result),
      );
    }
  }

  Future<void> _showCurrencyDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD - US Dollar'),
              trailing: _preferences.currencyCode == 'USD'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, 'USD'),
            ),
            ListTile(
              title: const Text('EUR - Euro'),
              trailing: _preferences.currencyCode == 'EUR'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, 'EUR'),
            ),
            ListTile(
              title: const Text('GBP - British Pound'),
              trailing: _preferences.currencyCode == 'GBP'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, 'GBP'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      _updatePreferences(
        _preferences.copyWith(currencyCode: result),
      );
    }
  }
}
