import 'package:equatable/equatable.dart';

enum NotificationKind { order, storage, payment, general }

enum NotificationStatus {
  pending,
  sent,
  delivered,
  failed,
  read;

  static NotificationStatus fromString(String s) =>
      switch (s.toUpperCase()) {
        'SENT' => sent,
        'DELIVERED' => delivered,
        'FAILED' => failed,
        'READ' => read,
        _ => pending,
      };
}

class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.channel,
    required this.templateId,
    required this.placeholders,
    required this.status,
    required this.createdAt,
    this.routeData = const {},
  });

  final String id;
  final String channel;
  final String templateId;
  final Map<String, dynamic> placeholders;
  final NotificationStatus status;
  final DateTime createdAt;
  final Map<String, String> routeData;

  bool get isRead => status == NotificationStatus.read;

  NotificationKind get kind {
    final t = templateId.toUpperCase();
    if (t.contains('ORDER') || t.contains('COMMANDE')) {
      return NotificationKind.order;
    }
    if (t.contains('STORAGE') ||
        t.contains('WAREHOUSE') ||
        t.contains('ENTREPOT')) {
      return NotificationKind.storage;
    }
    if (t.contains('PAYMENT') || t.contains('PAIEMENT')) {
      return NotificationKind.payment;
    }
    return NotificationKind.general;
  }

  String get displayTitle {
    const known = <String, String>{
      // Order status (backend templateIds)
      'ORDER_STATUS_CREATED': 'Nouvelle commande créée',
      'ORDER_STATUS_CONFIRMED': 'Commande confirmée',
      'ORDER_STATUS_SHIPPING': 'Commande en préparation',
      'ORDER_STATUS_SHIPPED': 'Commande en route',
      'ORDER_STATUS_DELIVERED': 'Commande livrée',
      'ORDER_STATUS_CANCELLED': 'Commande annulée',
      // Storage — client
      'CLIENT_STORAGE_PENDING': 'Réservation en attente',
      'CLIENT_STORAGE_APPROVED': 'Réservation approuvée',
      'CLIENT_STORAGE_REJECTED': 'Réservation refusée',
      'CLIENT_STORAGE_COMPLETED': 'Stockage terminé',
      'CLIENT_STORAGE_CANCELLED': 'Réservation annulée',
      // Storage — warehouse admin
      'MANAGER_STORAGE_NEW_REQUEST': 'Nouvelle demande de stockage',
      'MANAGER_STORAGE_COMPLETED': 'Stockage terminé',
    };
    if (known.containsKey(templateId)) return known[templateId]!;
    return templateId
        .split('_')
        .map((w) => w.isEmpty
            ? ''
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String get displayBody {
    if (placeholders.isEmpty) return '';
    return placeholders.values.map((v) => v.toString()).join(' · ');
  }

  @override
  List<Object?> get props => [id];

  String? get targetRoute => routeData['route'];
  String? get targetEntityId => routeData['entityId'];
}
