part of 'basket_cubit.dart';

class BasketItem {
  const BasketItem({required this.product, required this.quantity});

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    final p = json['product'] as Map<String, dynamic>;
    return BasketItem(
      product: Product(
        id: p['id'] as String,
        name: p['name'] as String,
        description: p['description'] as String? ?? '',
        unit: p['unit'] as String? ?? 'kg',
        price: (p['price'] as num).toDouble(),
        dailyRate: (p['dailyRate'] as num?)?.toDouble() ?? 0,
        perKgRate: (p['perKgRate'] as num?)?.toDouble() ?? 0,
        tags: (p['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      ),
      quantity: (json['quantity'] as num).toDouble(),
    );
  }

  final Product product;
  final double quantity;

  BasketItem copyWith({double? quantity}) =>
      BasketItem(product: product, quantity: quantity ?? this.quantity);

  double get lineTotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'product': {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'unit': product.unit,
          'price': product.price,
          'dailyRate': product.dailyRate,
          'perKgRate': product.perKgRate,
          'tags': product.tags,
        },
      };
}

class BasketState {
  const BasketState({this.items = const []});
  final List<BasketItem> items;

  double get subtotal => items.fold(0, (s, i) => s + i.lineTotal);
  int get count => items.length;
  bool get isEmpty => items.isEmpty;

  BasketState copyWith({List<BasketItem>? items}) =>
      BasketState(items: items ?? this.items);
}
