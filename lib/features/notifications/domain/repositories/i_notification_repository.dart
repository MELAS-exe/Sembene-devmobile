import 'package:dartz/dartz.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/features/notifications/domain/entities/notification_item.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationItem>>> getNotifications({
    int page = 0,
    int size = 20,
  });
  Future<Either<Failure, void>> markAsRead(String notificationId);
}
