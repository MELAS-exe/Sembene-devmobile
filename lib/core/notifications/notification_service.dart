import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tera/app/router/app_router.dart';
import 'package:tera/core/utils/constants.dart';
import 'package:tera/features/orders/domain/repositories/i_order_repository.dart';
import 'package:tera/injector.dart';

const _templateTitles = <String, String>{
  'ORDER_STATUS_CREATED': 'Nouvelle commande créée',
  'ORDER_STATUS_CONFIRMED': 'Commande confirmée',
  'ORDER_STATUS_SHIPPING': 'Commande en préparation',
  'ORDER_STATUS_SHIPPED': 'Commande en route',
  'ORDER_STATUS_DELIVERED': 'Commande livrée',
  'ORDER_STATUS_CANCELLED': 'Commande annulée',
  'CLIENT_STORAGE_PENDING': 'Réservation en attente',
  'CLIENT_STORAGE_APPROVED': 'Réservation approuvée',
  'CLIENT_STORAGE_REJECTED': 'Réservation refusée',
  'CLIENT_STORAGE_COMPLETED': 'Stockage terminé',
  'CLIENT_STORAGE_CANCELLED': 'Réservation annulée',
  'MANAGER_STORAGE_NEW_REQUEST': 'Nouvelle demande de stockage',
  'MANAGER_STORAGE_COMPLETED': 'Stockage terminé',
};

String _titleFor(String? templateId) =>
    _templateTitles[templateId] ?? templateId ?? 'Notification';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late final Dio _dio;

  // Emits when a foreground message with deliveryMode IN_APP or BOTH arrives.
  // NotificationCubit subscribes to this to refresh the list in real time.
  final _foregroundController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundController.stream;

  // Entity-specific streams for targeted tab reloads.
  final _orderController = StreamController<void>.broadcast();
  final _storageController = StreamController<void>.broadcast();
  Stream<void> get onOrderUpdate => _orderController.stream;
  Stream<void> get onStorageUpdate => _storageController.stream;

  Future<void> initialize(Dio dio) async {
    _dio = dio;
    await _requestPermission();
    await _configureForegroundPresentation();
    await _registerToken();
    _messaging.onTokenRefresh.listen(_sendToken);
    _listenForeground();
    await _handleInitialMessage();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  // iOS: show banner/badge/sound even when app is in foreground
  Future<void> _configureForegroundPresentation() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _sendToken(token);
  }

  Future<void> registerTokenAfterLogin() => _registerToken();

  Future<void> _sendToken(String token) async {
    log('[FCM] registering token: $token');
    try {
      await _dio.post<void>(
        '/api/notifications/token',
        data: [token],
      );
      log('[FCM] token registered');
    } on DioException catch (e) {
      log('[FCM] token registration failed: ${e.message}');
    }
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((msg) {
      final mode = msg.data['deliveryMode'] as String?;
      log('[FCM] foreground — mode: $mode, template: ${msg.data['templateId']}');

      // Show in-app banner for IN_APP (data-only) and BOTH (system tray +
      // data). For PUSH_NOTIFICATION-only, the OS handles the tray display.
      if (mode == 'IN_APP' || mode == 'BOTH') {
        _showInAppBanner(msg);
        _foregroundController.add(msg);
        final entityType = msg.data['entityType'] as String?;
        if (entityType == 'ORDER') _orderController.add(null);
        if (entityType == 'STORAGE_REQUEST') _storageController.add(null);
      }
    });

    // App was backgrounded and user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleInitialMessage() async {
    // App was terminated and user tapped the notification.
    final msg = await _messaging.getInitialMessage();
    if (msg == null) return;
    // Delay until the widget tree (and GoRouter) are ready.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _handleMessage(msg));
  }

  void _handleMessage(RemoteMessage msg) {
    log('[FCM] opened: ${msg.data}');
    unawaited(_route(msg.data));
  }

  void _showInAppBanner(RemoteMessage msg) {
    final data = msg.data;
    final templateId = data['templateId'] as String?;
    final title = _titleFor(templateId);
    final hasRoute = (data['route'] as String?) != null;

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(title),
        duration: const Duration(seconds: 5),
        action: hasRoute
            ? SnackBarAction(
                label: 'Voir',
                onPressed: () => unawaited(_route(data)),
              )
            : null,
      ),
    );
  }

  /// Navigates to the screen described by [data] (FCM data payload).
  Future<void> _route(Map<String, dynamic> data) async {
    final route = data['route'] as String?;
    final entityId = data['entityId'] as String?;
    if (route == null) return;

    // Match both /orders and /orders/detail variants.
    if (route.startsWith('/orders') && entityId != null) {
      await _navigateToOrder(entityId);
      return;
    }
    if (route.startsWith('/storage-requests')) {
      _navigateTo(AppRouter.storagePath);
      return;
    }
    // Admin routes are not supported in the client app.
  }

  Future<void> _navigateToOrder(String orderId) async {
    final result = await getIt<IOrderRepository>().getOrderById(orderId);
    result.fold(
      (_) => log('[FCM] could not load order $orderId for navigation'),
      (order) => appRouter.push(AppRouter.orderDetailPath, extra: order),
    );
  }

  void _navigateTo(String path) {
    appRouter.go(path);
  }
}
