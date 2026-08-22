import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tera/core/utils/app_colors.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    required this.price,
    required this.dailyRate,
    required this.perKgRate,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final String unit;
  final double price;
  final double dailyRate;
  final double perKgRate;
  final List<String> tags;

  String get emoji => _emojiFor(name);
  Color get tint => _tintFor(name);
  String get category => _categoryFromTags(tags) ?? _categoryFor(name);

  @override
  List<Object?> get props => [id];

  static String? _categoryFromTags(List<String> tags) {
    if (tags.contains('cereale')) return 'Céréale';
    if (tags.contains('legumineuse')) return 'Légumineuse';
    if (tags.contains('tubercule')) return 'Tubercule';
    if (tags.contains('fruit')) return 'Fruit';
    if (tags.contains('legume')) return 'Légume';
    return null;
  }

  static String _emojiFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pomme') || lower.contains('potato')) return '🥔';
    if (lower.contains('oignon') || lower.contains('onion')) return '🧅';
    if (lower.contains('arachide') || lower.contains('peanut')) return '🥜';
    if (lower.contains('carotte') || lower.contains('carrot')) return '🥕';
    if (lower.contains('tomate') || lower.contains('tomato')) return '🍅';
    if (lower.contains('piment') || lower.contains('chili')) return '🌶️';
    if (lower.contains('chou') || lower.contains('cabbage')) return '🥬';
    if (lower.contains('riz') || lower.contains('rice')) return '🌾';
    if (lower.contains('manguier') || lower.contains('mango')) return '🥭';
    if (lower.contains('mais') || lower.contains('corn')) return '🌽';
    if (lower.contains('gombo') || lower.contains('okra')) return '🫑';
    if (lower.contains('banane') || lower.contains('banana')) return '🍌';
    return '🌿';
  }

  static Color _tintFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pomme') || lower.contains('potato')) {
      return AppColors.goldPale;
    }
    if (lower.contains('oignon') || lower.contains('onion')) {
      return AppColors.terraPale;
    }
    if (lower.contains('arachide') || lower.contains('peanut')) {
      return const Color(0xFFF0E1C0);
    }
    if (lower.contains('carotte') || lower.contains('carrot')) {
      return const Color(0xFFFAD7B2);
    }
    if (lower.contains('tomate') || lower.contains('tomato')) {
      return const Color(0xFFF5CFC0);
    }
    if (lower.contains('piment') || lower.contains('chili')) {
      return const Color(0xFFF5D0C4);
    }
    if (lower.contains('chou') || lower.contains('cabbage')) {
      return AppColors.greenPale;
    }
    if (lower.contains('riz') || lower.contains('rice')) {
      return const Color(0xFFF3E6B8);
    }
    return AppColors.paper2;
  }

  static String _categoryFor(String name) {
    final lower = name.toLowerCase();
    if (['riz', 'mais', 'mil', 'sorgho', 'fonio'].any(lower.contains)) {
      return 'Céréale';
    }
    if (['pomme', 'manioc', 'igname', 'patate'].any(lower.contains)) {
      return 'Tubercule';
    }
    if (['arachide', 'niébé', 'soja'].any(lower.contains)) {
      return 'Légumineuse';
    }
    if (['manguier', 'banane', 'ananas', 'papaye'].any(lower.contains)) {
      return 'Fruit';
    }
    return 'Légume';
  }
}
