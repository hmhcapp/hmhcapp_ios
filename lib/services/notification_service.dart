import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import '../routes.dart';

const _broadcastTopic = 'all_users';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final ValueNotifier<bool> notificationsEnabled = ValueNotifier(false);

  GlobalKey<NavigatorState>? _navigatorKey;
  GlobalKey<ScaffoldMessengerState>? _messengerKey;
  StreamSubscription<String>? _tokenSubscription;
  RemoteMessage? _pendingInitialMessage;
  Future<bool>? _subscriptionTask;

  static const _allowedRoutes = <String>{
    Routes.home,
    Routes.installerTools,
    Routes.heatingMatPlanner,
    Routes.productCategorySelection,
    Routes.productInstructionCategorySelection,
    Routes.caseStudies,
    Routes.getAQuoteCategorySelection,
    Routes.registerWarranty,
  };

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required GlobalKey<ScaffoldMessengerState> messengerKey,
  }) async {
    _navigatorKey = navigatorKey;
    _messengerKey = messengerKey;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);
    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((
      _,
    ) async {
      if (notificationsEnabled.value) {
        await _subscribeToBroadcasts();
      }
    });

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    notificationsEnabled.value = _isAllowed(settings.authorizationStatus);

    if (notificationsEnabled.value) {
      unawaited(_subscribeToBroadcasts());
    }

    _pendingInitialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
  }

  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final allowed = _isAllowed(settings.authorizationStatus);
      notificationsEnabled.value = allowed;

      if (allowed) {
        return await _subscribeToBroadcasts();
      }

      return false;
    } catch (_) {
      notificationsEnabled.value = false;
      return false;
    }
  }

  void handlePendingLaunchMessage() {
    final message = _pendingInitialMessage;
    if (message == null) return;

    _pendingInitialMessage = null;
    _openMessage(message);
  }

  Future<bool> _subscribeToBroadcasts() {
    final existingTask = _subscriptionTask;
    if (existingTask != null) return existingTask;

    final task = _performBroadcastSubscription();
    _subscriptionTask = task;
    return task.whenComplete(() {
      if (identical(_subscriptionTask, task)) {
        _subscriptionTask = null;
      }
    });
  }

  Future<bool> _performBroadcastSubscription() async {
    final messaging = FirebaseMessaging.instance;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      String? apnsToken;

      // Apple can return notification permission before it supplies the APNs
      // token. FCM calls made during that gap fail, so wait explicitly.
      for (var attempt = 0; attempt < 20; attempt++) {
        try {
          apnsToken = await messaging.getAPNSToken();
        } catch (_) {
          // Retry transient native registration errors below.
        }

        if (apnsToken != null && apnsToken.isNotEmpty) break;
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null || apnsToken.isEmpty) return false;
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        // Topic subscription requires an existing FCM registration token.
        final fcmToken = await messaging.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await messaging.subscribeToTopic(_broadcastTopic);
          return true;
        }
      } catch (_) {
        // Retry below with a short backoff.
      }

      await Future<void>.delayed(Duration(seconds: attempt + 1));
    }

    return false;
  }

  void _showForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? 'Heat Mat';
    final body = notification?.body ?? '';

    _messengerKey?.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(body.isEmpty ? title : '$title\n$body'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: () => _openMessage(message),
          ),
        ),
      );
  }

  void _openMessage(RemoteMessage message) {
    final requestedRoute = message.data['route'];
    final route =
        requestedRoute is String && _allowedRoutes.contains(requestedRoute)
        ? requestedRoute
        : Routes.home;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey?.currentState?.pushNamed(route);
    });
  }

  bool _isAllowed(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  void dispose() {
    _tokenSubscription?.cancel();
    notificationsEnabled.dispose();
  }
}
