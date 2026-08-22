import 'dart:async';

import 'package:injectable/injectable.dart';

@lazySingleton
class SessionManager {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get sessionExpired => _controller.stream;

  void invalidate() {
    if (!_controller.isClosed) _controller.add(null);
  }

  @disposeMethod
  void dispose() => _controller.close();
}
