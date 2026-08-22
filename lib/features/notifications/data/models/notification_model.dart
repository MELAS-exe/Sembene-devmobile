import 'package:tera/features/notifications/domain/entities/notification_item.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.channel,
    required this.templateId,
    required this.templatePlaceholders,
    required this.status,
    required this.createdAt,
    this.routeData = const {},
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final raw = json['routeData'];
    final routeData = raw is Map
        ? raw.map((k, v) => MapEntry(k.toString(), v.toString()))
        : <String, String>{};
    return NotificationModel(
      id: json['id'] as String,
      channel: json['channel'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      templatePlaceholders:
          (json['templatePlaceholders'] as Map<String, dynamic>?) ?? {},
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] as String? ?? '',
      routeData: routeData,
    );
  }

  final String id;
  final String channel;
  final String templateId;
  final Map<String, dynamic> templatePlaceholders;
  final String status;
  final String createdAt;
  final Map<String, String> routeData;

  NotificationItem toEntity() => NotificationItem(
        id: id,
        channel: channel,
        templateId: templateId,
        placeholders: templatePlaceholders,
        status: NotificationStatus.fromString(status),
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        routeData: routeData,
      );
}
