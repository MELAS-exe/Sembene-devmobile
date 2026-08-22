/// Mobile-money rail used for a payout. Serialized as the lowercase slug the
/// backend expects (`wave` / `orange_money`).
enum PayoutMethod {
  wave,
  orangeMoney;

  String toApiString() => switch (this) {
    PayoutMethod.wave => 'wave',
    PayoutMethod.orangeMoney => 'orange_money',
  };

  String get label => switch (this) {
    PayoutMethod.wave => 'Wave',
    PayoutMethod.orangeMoney => 'Orange Money',
  };

  static PayoutMethod fromString(String? s) =>
      switch (s?.toLowerCase().replaceAll('-', '_')) {
        'orange_money' => orangeMoney,
        _ => wave,
      };
}
