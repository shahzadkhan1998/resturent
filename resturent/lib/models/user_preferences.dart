class UserPreferences {
  final bool enableNotifications;
  final int reminderMinutesBefore;
  final bool enableEmailNotifications;
  final List<String> dietaryPreferences;
  final String preferredLanguage;
  final String currencyCode;
  final NotificationTypes notificationTypes;
  final String themeMode; // 'system', 'light', or 'dark'

  UserPreferences({
    this.enableNotifications = true,
    this.reminderMinutesBefore = 60,
    this.enableEmailNotifications = false,
    this.dietaryPreferences = const [],
    this.preferredLanguage = 'en',
    this.currencyCode = 'USD',
    NotificationTypes? notificationTypes,
    this.themeMode = 'system',
  }) : notificationTypes = notificationTypes ?? NotificationTypes();

  Map<String, dynamic> toJson() => {
        'enableNotifications': enableNotifications,
        'reminderMinutesBefore': reminderMinutesBefore,
        'enableEmailNotifications': enableEmailNotifications,
        'dietaryPreferences': dietaryPreferences,
        'preferredLanguage': preferredLanguage,
        'currencyCode': currencyCode,
        'notificationTypes': notificationTypes.toJson(),
        'themeMode': themeMode,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        enableNotifications: json['enableNotifications'] ?? true,
        reminderMinutesBefore: json['reminderMinutesBefore'] ?? 60,
        enableEmailNotifications: json['enableEmailNotifications'] ?? false,
        dietaryPreferences: List<String>.from(json['dietaryPreferences'] ?? []),
        preferredLanguage: json['preferredLanguage'] ?? 'en',
        currencyCode: json['currencyCode'] ?? 'USD',
        notificationTypes: json['notificationTypes'] != null
            ? NotificationTypes.fromJson(json['notificationTypes'])
            : null,
        themeMode: json['themeMode'] ?? 'system',
      );

  UserPreferences copyWith({
    bool? enableNotifications,
    int? reminderMinutesBefore,
    bool? enableEmailNotifications,
    List<String>? dietaryPreferences,
    String? preferredLanguage,
    String? currencyCode,
    NotificationTypes? notificationTypes,
    String? themeMode,
  }) =>
      UserPreferences(
        enableNotifications: enableNotifications ?? this.enableNotifications,
        reminderMinutesBefore:
            reminderMinutesBefore ?? this.reminderMinutesBefore,
        enableEmailNotifications:
            enableEmailNotifications ?? this.enableEmailNotifications,
        dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        currencyCode: currencyCode ?? this.currencyCode,
        notificationTypes: notificationTypes ?? this.notificationTypes,
        themeMode: themeMode ?? this.themeMode,
      );
}

class NotificationTypes {
  final bool reservationConfirmations;
  final bool reservationReminders;
  final bool specialOffers;
  final bool orderUpdates;

  NotificationTypes({
    this.reservationConfirmations = true,
    this.reservationReminders = true,
    this.specialOffers = false,
    this.orderUpdates = true,
  });

  Map<String, dynamic> toJson() => {
        'reservationConfirmations': reservationConfirmations,
        'reservationReminders': reservationReminders,
        'specialOffers': specialOffers,
        'orderUpdates': orderUpdates,
      };

  factory NotificationTypes.fromJson(Map<String, dynamic> json) =>
      NotificationTypes(
        reservationConfirmations: json['reservationConfirmations'] ?? true,
        reservationReminders: json['reservationReminders'] ?? true,
        specialOffers: json['specialOffers'] ?? false,
        orderUpdates: json['orderUpdates'] ?? true,
      );

  NotificationTypes copyWith({
    bool? reservationConfirmations,
    bool? reservationReminders,
    bool? specialOffers,
    bool? orderUpdates,
  }) =>
      NotificationTypes(
        reservationConfirmations:
            reservationConfirmations ?? this.reservationConfirmations,
        reservationReminders: reservationReminders ?? this.reservationReminders,
        specialOffers: specialOffers ?? this.specialOffers,
        orderUpdates: orderUpdates ?? this.orderUpdates,
      );
}
