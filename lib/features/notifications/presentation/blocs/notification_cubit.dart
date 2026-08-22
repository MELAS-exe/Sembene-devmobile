import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/notifications/notification_service.dart';
import 'package:tera/features/notifications/domain/entities/notification_item.dart';
import 'package:tera/features/notifications/domain/repositories/i_notification_repository.dart';

part 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repo) : super(const NotificationInitial()) {
    _sub = NotificationService.instance.onForegroundMessage.listen((_) {
      if (state is NotificationsLoaded) unawaited(loadNotifications());
    });
  }

  final INotificationRepository _repo;
  late final StreamSubscription<dynamic> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  Future<void> loadNotifications() async {
    emit(const NotificationLoading());
    final result = await _repo.getNotifications();
    result.fold(
      (f) => emit(NotificationError(_message(f))),
      (items) => emit(NotificationsLoaded(items)),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _repo.markAsRead(notificationId);
    result.fold(
      (_) {},
      (_) {
        final current = state;
        if (current is NotificationsLoaded) {
          final updated = current.notifications.map((n) {
            if (n.id == notificationId) {
              return NotificationItem(
                id: n.id,
                channel: n.channel,
                templateId: n.templateId,
                placeholders: n.placeholders,
                status: NotificationStatus.read,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
          emit(NotificationsLoaded(updated));
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    final unread =
        current.notifications.where((n) => !n.isRead).toList();
    await Future.wait(unread.map((n) => _repo.markAsRead(n.id)));
    await loadNotifications();
  }

  String _message(Failure f) =>
      f is LocalFailure ? f.message : (f as ServerFailure).message;
}
