enum PaymentReferenceType {
  order,
  storageRequest;

  String toApiString() => switch (this) {
    PaymentReferenceType.order => 'ORDER',
    PaymentReferenceType.storageRequest => 'STORAGE_REQUEST',
  };
}
