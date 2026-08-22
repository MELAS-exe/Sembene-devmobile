import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/features/notifications/data/models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
  });
  Future<void> markAsRead(String notificationId);
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    final list =
        (response.data?['content'] as List<dynamic>?) ?? [];
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _dio.post<void>('/api/notifications/$notificationId');
  }
}
