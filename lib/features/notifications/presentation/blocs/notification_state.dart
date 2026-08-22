part of 'notification_cubit.dart';

sealed class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  const NotificationsLoaded(this.notifications);
  final List<NotificationItem> notifications;
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
}
