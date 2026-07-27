import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      await _subscribeToBroadcasts();
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
        await _subscribeToBroadcasts();
      }

      return allowed;
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

  Future<void> _subscribeToBroadcasts() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(_broadcastTopic);
    } catch (_) {
      // APNs can still be registering on a fresh iOS install. The token
      // refresh listener retries the subscription as soon as it is ready.
    }
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
