import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  const Warehouse({
    required this.id,
    required this.name,
    required this.capacity,
    required this.usedCapacity,
    this.city = '',
  });

  final String id;
  final String name;
  final double capacity;
  final double usedCapacity;
  final String city;

  double get usedPercent =>
      capacity > 0 ? (usedCapacity / capacity).clamp(0.0, 1.0) : 0;

  @override
  List<Object?> get props => [id];
}
