part of 'address_cubit.dart';

sealed class AddressState {
  const AddressState();
}

class AddressLoaded extends AddressState {
  const AddressLoaded(this.addresses);
  final List<Address> addresses;
}
