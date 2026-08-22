class Address {
  const Address({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
  });

  final String id;
  final String label;
  final String street;
  final String city;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'street': street,
        'city': city,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        label: json['label'] as String,
        street: json['street'] as String,
        city: json['city'] as String,
      );
}
