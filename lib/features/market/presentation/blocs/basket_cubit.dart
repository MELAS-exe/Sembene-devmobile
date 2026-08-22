import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tera/features/market/domain/entities/product.dart';

part 'basket_state.dart';

@injectable
class BasketCubit extends Cubit<BasketState> {
  BasketCubit(this._prefs) : super(const BasketState()) {
    _loadSaved();
  }

  final SharedPreferences _prefs;
  static const _kKey = 'basket_state';

  void _loadSaved() {
    final raw = _prefs.getString(_kKey);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>)
          .map((e) => BasketItem.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(BasketState(items: items));
    } catch (_) {
      // corrupted cache — start fresh
    }
  }

  void _save() {
    _prefs.setString(
      _kKey,
      jsonEncode({
        'items': state.items.map((e) => e.toJson()).toList(),
      }),
    );
  }

  void add(Product product, {double quantity = 1}) {
    final items = List<BasketItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      items[idx] =
          items[idx].copyWith(quantity: items[idx].quantity + quantity);
    } else {
      items.add(BasketItem(product: product, quantity: quantity));
    }
    emit(state.copyWith(items: items));
    _save();
  }

  void remove(String productId) {
    emit(state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    ));
    _save();
  }

  void updateQuantity(String productId, double quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    final items = state.items.map((i) {
      if (i.product.id == productId) return i.copyWith(quantity: quantity);
      return i;
    }).toList();
    emit(state.copyWith(items: items));
    _save();
  }

  void clear() {
    emit(const BasketState());
    _save();
  }
}
