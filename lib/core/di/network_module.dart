import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/network/dio_client.dart';
import 'package:tera/core/network/session_manager.dart';
import 'package:tera/core/storages/local_storages.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(LocalStorage storage, SessionManager sessionManager) =>
      createDio(storage, sessionManager);
}
