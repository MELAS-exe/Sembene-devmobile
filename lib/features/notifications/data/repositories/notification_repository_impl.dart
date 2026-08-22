import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/domain/failures/failure.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:tera/features/notifications/domain/entities/notification_item.dart';
import 'package:tera/features/notifications/domain/repositories/i_notification_repository.dart';

@LazySingleton(as: INotificationRepository)
class NotificationRepositoryImpl implements INotificationRepository {
  const NotificationRepositoryImpl(this._remote);
  final NotificationRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<NotificationItem>>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final models =
          await _remote.getNotifications(page: page, size: size);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(dioToFailure(e));
    } catch (e) {
      return Left(Failure.serverFailure(message: e.toString()));
    }
  }
}
