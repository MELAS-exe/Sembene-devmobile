part of 'warehouse_cubit.dart';

sealed class WarehouseState {
  const WarehouseState();
}

class WarehouseInitial extends WarehouseState {
  const WarehouseInitial();
}

class WarehouseLoading extends WarehouseState {
  const WarehouseLoading();
}

class WarehousesLoaded extends WarehouseState {
  const WarehousesLoaded(this.warehouses);
  final List<Warehouse> warehouses;
}

class WarehouseError extends WarehouseState {
  const WarehouseError(this.message);
  final String message;
}
