import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:tera/core/storages/local_storages.dart';
import 'package:tera/features/profile/domain/entities/address.dart';
import 'package:uuid/uuid.dart';

part 'address_state.dart';

@injectable
class AddressCubit extends Cubit<AddressState> {
  AddressCubit(this._storage) : super(const AddressLoaded([]));

  final LocalStorage _storage;

  Future<void> loadAddresses() async {
    final raw = await _storage.getAddresses();
    emit(AddressLoaded(raw.map(Address.fromJson).toList()));
  }

  Future<void> addAddress({
    required String label,
    required String street,
    required String city,
  }) async {
    final current = _current;
    final updated = [
      ...current,
      Address(id: const Uuid().v4(), label: label, street: street, city: city),
    ];
    await _storage.setAddresses(updated.map((a) => a.toJson()).toList());
    emit(AddressLoaded(updated));
  }

  Future<void> removeAddress(String id) async {
    final updated = _current.where((a) => a.id != id).toList();
    await _storage.setAddresses(updated.map((a) => a.toJson()).toList());
    emit(AddressLoaded(updated));
  }

  List<Address> get _current =>
      state is AddressLoaded ? (state as AddressLoaded).addresses : [];
}
