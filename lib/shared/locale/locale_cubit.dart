import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:tera/core/storages/local_storages.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(Locale(_storage.getLocale()));

  final LocalStorage _storage;

  Future<void> setLocale(String lang) async {
    await _storage.setLocale(lang);
    emit(Locale(lang));
  }
}
