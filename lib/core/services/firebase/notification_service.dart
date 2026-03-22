// lib/core/services/firebase/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';

/// Service for handling notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor for singleton pattern
  factory NotificationService() => _instance;

  NotificationService._internal();

  // Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Flutter Local Notifications Plugin for Android
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // SharedPreferences for storing notification data
  late SharedPreferences _prefs;

  // Android notification channel ID
  static const String _channelId = 'high_importance_channel';

  // FCM token storage
  String? _fcmToken;

  // Flag to track initialization
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> init() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    try {
      debugPrint('Initializing NotificationService...');

      // Initialize timezone information for scheduled notifications
      tz.initializeTimeZones();

      // Set local timezone
      tz.setLocalLocation(tz.getLocation('America/New_York'));

      // Initialize shared preferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _logPermissionStatus(settings);

      // Get and store FCM token
      await _getAndSaveFCMToken();

      // Configure Firebase Messaging handlers
      _configureFirebaseMessaging();

      // Clean expired notifications
      await _cleanExpiredNotifications();

      // Set initialization flag
      _isInitialized = true;

      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      // Reset flag in case of failure
      _isInitialized = false;
    }
  }

  // Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Complete initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize local notifications
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
        _handleLocalNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Create notification channel for Android 8.0+
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    debugPrint('Android notification channel created');
  }

  // Get and save FCM token
  Future<void> _getAndSaveFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      if (_fcmToken != null) {
        debugPrint('FCM Token: $_fcmToken');
        await _prefs.setString('fcm_token', _fcmToken!);
      } else {
        debugPrint('Failed to get FCM token');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  // Schedule a workout reminder notification
  Future<bool> scheduleWorkoutReminder(
    String workoutPlanId,
    String workoutName,
    String reminderTime,
    DateTime workoutDate,
  ) async {
    try {
      debugPrint(
        'Scheduling workout reminder: $workoutName (ID: $workoutPlanId)',
      );
      debugPrint('Reminder time: $reminderTime, Date: $workoutDate');

      // Parse and validate the reminder time
      final DateTime? scheduledTime = _parseReminderTime(
        reminderTime,
        workoutDate,
      );

      if (scheduledTime == null) {
        debugPrint('Invalid reminder time format: $reminderTime');
        return false;
      }

      // Check if time is in the past
      if (scheduledTime.isBefore(DateTime.now())) {
        debugPrint('Reminder time is in the past: $scheduledTime');
        // If it's today but in the past, schedule for tomorrow at the same time
        if (scheduledTime.day == DateTime.now().day &&
            scheduledTime.month == DateTime.now().month &&
            scheduledTime.year == DateTime.now().year) {
          debugPrint('Rescheduling for tomorrow at the same time');
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final newScheduledTime = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            scheduledTime.hour,
            scheduledTime.minute,
          );
          return await _scheduleWorkoutReminderInternal(
            workoutPlanId,
            workoutName,
            newScheduledTime,
          );
        }
        return false;
      }

      // Schedule for the exact time
      return await _scheduleWorkoutReminderInternal(
        workoutPlanId,
        workoutName,
        scheduledTime,
      );
    } catch (e) {
      debugPrint('Error scheduling workout reminder: $e');
      return false;
    }
  }

  // Internal method to schedule workout reminder
  Future<bool> _scheduleWorkoutReminderInternal(
    String workoutPlanId,
    String workoutName,
    DateTime scheduledTime,
  ) async {
    try {
      // Create a unique ID for this reminder
      final int notificationId = 'workout_$workoutPlanId'.hashCode;

      // Store the notification data
      final Map<String, dynamic> notificationData = {
        'id': notificationId.toString(),
        'type': 'workout',
        'title': 'Time for your workout!',
        'body': 'Get ready for your $workoutName workout',
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'workoutPlanId': workoutPlanId,
        'workoutName': workoutName,
      };

      // Save to persistent storage
      await _saveScheduledNotification(
        notificationId.toString(),
        notificationData,
      );

      // Convert to TZDateTime for the scheduler
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      // Schedule local notification
      await _localNotifications.zonedSchedule(
        notificationId,
        'Time for your workout!',
        'Get ready for your $workoutName workout',
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: json.encode(notificationData),
      );

      debugPrint(
        'Scheduled workout reminder for $workoutName at $scheduledTime (ID: $notificationId)',
      );
      return true;
    } catch (e) {
      debugPrint('Error in _scheduleWorkoutReminderInternal: $e');
      return false;
    }
  }

  // Schedule a meal reminder notification
  Future<bool> scheduleMealReminder(
    String mealPlanId,
    String mealName,
    String reminderTime,
    DateTime mealDate,
  ) async {
    try {
      // Add detailed logs for debugging
      debugPrint('Scheduling meal reminder: $mealName (ID: $mealPlanId)');
      debugPrint('Reminder time: $reminderTime, Date: $mealDate');

      // Parse and validate the reminder time
      final DateTime? scheduledTime = _parseReminderTime(
        reminderTime,
        mealDate,
      );

      if (scheduledTime == null) {
        debugPrint('Invalid reminder time format: $reminderTime');
        return false;
      }

      // Check if time is in the past
      if (scheduledTime.isBefore(DateTime.now())) {
        debugPrint('Reminder time is in the past: $scheduledTime');
        // If it's today but in the past, schedule for tomorrow at the same time
        if (scheduledTime.day == DateTime.now().day &&
            scheduledTime.month == DateTime.now().month &&
            scheduledTime.year == DateTime.now().year) {
          debugPrint('Rescheduling for tomorrow at the same time');
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          final newScheduledTime = DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            scheduledTime.hour,
            scheduledTime.minute,
          );
          return await _scheduleMealReminderInternal(
            mealPlanId,
            mealName,
            newScheduledTime,
          );
        }
        return false;
      }

      // Schedule for the exact time
      return await _scheduleMealReminderInternal(
        mealPlanId,
        mealName,
        scheduledTime,
      );
    } catch (e) {
      debugPrint('Error scheduling meal reminder: $e');
      return false;
    }
  }

  // Internal method to schedule meal reminder
  Future<bool> _scheduleMealReminderInternal(
    String mealPlanId,
    String mealName,
    DateTime scheduledTime,
  ) async {
    try {
      // Create a unique ID for this reminder
      final int notificationId = 'meal_$mealPlanId'.hashCode;

      debugPrint('Creating meal notification with ID: $notificationId');
      debugPrint('Scheduled time: ${scheduledTime.toString()}');

      // Store the notification data
      final Map<String, dynamic> notificationData = {
        'id': notificationId.toString(),
        'type': 'meal',
        'title': 'Time for your meal!',
        'body': 'Remember to have your $mealName',
        'scheduledTime': scheduledTime.millisecondsSinceEpoch,
        'mealPlanId': mealPlanId,
        'mealName': mealName,
      };

      // Save to persistent storage
      await _saveScheduledNotification(
        notificationId.toString(),
        notificationData,
      );

      // Convert to TZDateTime for the scheduler
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      debugPrint('TZ scheduled time: $tzScheduledTime');

      // Schedule local notification
      await _localNotifications.zonedSchedule(
        notificationId,
        'Time for your meal!',
        'Remember to have your $mealName',
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            playSound: true,
            enableVibration: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: json.encode(notificationData),
      );

      // Print pending notifications for debugging
      await printPendingNotifications();

      debugPrint(
        'Scheduled meal reminder for $mealName at $scheduledTime (ID: $notificationId)',
      );
      return true;
    } catch (e) {
      debugPrint('Error in _scheduleMealReminderInternal: $e');
      return false;
    }
  }

  // Cancel a workout reminder notification
  Future<bool> cancelWorkoutReminder(String workoutPlanId) async {
    try {
      final int notificationId = 'workout_$workoutPlanId'.hashCode;
      await _localNotifications.cancel(notificationId);
      await _removeScheduledNotification(notificationId.toString());
      debugPrint('Cancelled workout reminder: $notificationId');
      return true;
    } catch (e) {
      debugPrint('Error cancelling workout reminder: $e');
      return false;
    }
  }

  // Cancel a meal reminder notification
  Future<bool> cancelMealReminder(String mealPlanId) async {
    try {
      final int notificationId = 'meal_$mealPlanId'.hashCode;
      await _localNotifications.cancel(notificationId);
      await _removeScheduledNotification(notificationId.toString());
      debugPrint('Cancelled meal reminder: $notificationId');
      return true;
    } catch (e) {
      debugPrint('Error cancelling meal reminder: $e');
      return false;
    }
  }

  // Get all scheduled notifications
  Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    try {
      final List<String> keys =
          _prefs
              .getKeys()
              .where((key) => key.startsWith('notification_'))
              .toList();

      return keys
          .map(
            (key) =>
                json.decode(_prefs.getString(key) ?? '{}')
                    as Map<String, dynamic>,
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting scheduled notifications: $e');
      return [];
    }
  }

  // Send a test notification
  Future<bool> sendTestNotification({
    String title = 'Test Notification',
    String body = 'This is a test notification',
  }) async {
    try {
      await _localNotifications.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            sound: RawResourceAndroidNotificationSound('notification_sound'),
            playSound: true,
            enableVibration: true,
          ),
        ),
        payload: json.encode({'type': 'test', 'title': title, 'body': body}),
      );

      debugPrint('Test notification sent');
      return true;
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return false;
    }
  }

  // Configure Firebase Messaging handlers
  void _configureFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when user taps on notification that opened the app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check for initial notification that launched the app
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationOpen(message);
      }
    });

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed: $token');
      _fcmToken = token;
      _prefs.setString('fcm_token', token);
    });
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');

    // Extract notification data
    final Map<String, dynamic> data = message.data;
    final String title =
        message.notification?.title ?? data['title'] ?? 'Notification';
    final String body = message.notification?.body ?? data['body'] ?? '';

    // Show a local notification for foreground messages
    _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: json.encode(data),
    );
  }

  // Handle notification open events
  void _handleNotificationOpen(RemoteMessage message) {
    debugPrint('FCM notification opened: ${message.messageId}');
    _handleNotificationNavigation(message.data);
  }

  // Handle notification tap from local notifications
  void _handleLocalNotificationTap(String? payload) {
    if (payload == null) return;

    try {
      final Map<String, dynamic> data = json.decode(payload);
      _handleNotificationNavigation(data);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  // Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    debugPrint('Handling notification navigation for type: $type');

    if (type == 'meal') {
      final String? mealPlanId = data['mealPlanId'];
      if (mealPlanId != null) {
        debugPrint('Navigate to meal plan: $mealPlanId');
        Get.toNamed('/meal_plan_detail', arguments: {'id': mealPlanId});
      }
    } else if (type == 'workout') {
      final String? workoutPlanId = data['workoutPlanId'];
      if (workoutPlanId != null) {
        debugPrint('Navigate to workout plan: $workoutPlanId');
        Get.toNamed('/workout_plan_detail', arguments: {'id': workoutPlanId});
      }
    }
  }

  // Log notification permission status
  void _logPermissionStatus(NotificationSettings settings) {
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        debugPrint('User granted permission for notifications');
        break;
      case AuthorizationStatus.provisional:
        debugPrint('User granted provisional permission for notifications');
        break;
      case AuthorizationStatus.denied:
        debugPrint('User declined permission for notifications');
        break;
      default:
        debugPrint('Unknown notification permission status');
    }
  }

  // Show a confirmation snackbar
  void _showConfirmationSnackBar(String message) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show an error snackbar
  void _showErrorSnackBar(String message) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Save scheduled notification to persistent storage
  Future<void> _saveScheduledNotification(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _prefs.setString('notification_$id', json.encode(data));
      debugPrint('Saved notification data for ID: $id');
    } catch (e) {
      debugPrint('Error saving notification data: $e');
    }
  }

  // Remove scheduled notification from persistent storage
  Future<void> _removeScheduledNotification(String id) async {
    try {
      await _prefs.remove('notification_$id');
      debugPrint('Removed notification data for ID: $id');
    } catch (e) {
      debugPrint('Error removing notification data: $e');
    }
  }

  // Clean expired notifications
  Future<void> _cleanExpiredNotifications() async {
    try {
      final List<Map<String, dynamic>> notifications =
          await getScheduledNotifications();
      final DateTime now = DateTime.now();
      int cleanedCount = 0;

      for (final notification in notifications) {
        final int scheduledTime = notification['scheduledTime'] ?? 0;
        if (scheduledTime > 0) {
          final DateTime notificationTime = DateTime.fromMillisecondsSinceEpoch(
            scheduledTime,
          );

          if (notificationTime.isBefore(now)) {
            final String? id = notification['id'];
            if (id != null) {
              await _removeScheduledNotification(id);
              await _localNotifications.cancel(int.parse(id));
              cleanedCount++;
            }
          }
        }
      }

      if (cleanedCount > 0) {
        debugPrint('Cleaned $cleanedCount expired notifications');
      }
    } catch (e) {
      debugPrint('Error cleaning expired notifications: $e');
    }
  }

  // Parse reminder time string to DateTime
  DateTime? _parseReminderTime(String reminderTime, DateTime baseDate) {
    try {
      debugPrint('Parsing reminder time: $reminderTime for date: $baseDate');

      // Handle specialized formats from meal/workout planner
      if (reminderTime == '5 minutes before') {
        return baseDate.subtract(const Duration(minutes: 5));
      } else if (reminderTime == '15 minutes before') {
        return baseDate.subtract(const Duration(minutes: 15));
      } else if (reminderTime == '30 minutes before') {
        return baseDate.subtract(const Duration(minutes: 30));
      } else if (reminderTime == '1 hour before') {
        return baseDate.subtract(const Duration(hours: 1));
      }

      // Handle if reminderTime is in minutes format (e.g., "10")
      if (RegExp(r'^\d+$').hasMatch(reminderTime)) {
        int minutes = int.tryParse(reminderTime) ?? 0;
        // If this is minutes before the meal/workout, calculate from baseDate
        return baseDate.subtract(Duration(minutes: minutes));
      }

      // Standard time format handling (HH:MM AM/PM)
      reminderTime = reminderTime.trim().toUpperCase();
      bool isPM = reminderTime.contains('PM');
      bool isAM = reminderTime.contains('AM');

      // Remove AM/PM if present
      reminderTime =
          reminderTime
              .replaceAll(' AM', '')
              .replaceAll('AM', '')
              .replaceAll(' PM', '')
              .replaceAll('PM', '')
              .trim();

      List<String> timeParts = reminderTime.split(':');
      if (timeParts.length != 2) {
        debugPrint('Invalid time format: $reminderTime, expected HH:MM');
        return null;
      }

      int hour = int.tryParse(timeParts[0]) ?? 0;
      int minute = int.tryParse(timeParts[1]) ?? 0;

      // Validate hour and minute
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        debugPrint('Invalid time: $hour:$minute');
        return null;
      }

      // Convert to 24-hour format if needed
      if (isPM && hour < 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      // Create notification date
      DateTime notificationTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        hour,
        minute,
      );

      debugPrint('Parsed reminder time: $reminderTime to $notificationTime');
      return notificationTime;
    } catch (e) {
      debugPrint('Error parsing reminder time: $e');
      return null;
    }
  }

  // Debug method to print all pending notifications
  Future<void> printPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _localNotifications.pendingNotificationRequests();

      debugPrint(
        '=== Pending Notifications (${pendingNotifications.length}) ===',
      );
      for (final notification in pendingNotifications) {
        debugPrint(
          'ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload}',
        );
      }
      debugPrint('============================================');
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
    }
  }
}
