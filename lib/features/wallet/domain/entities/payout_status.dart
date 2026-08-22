enum PayoutStatus {
  pending,
  completed,
  failed;

  static PayoutStatus fromString(String? s) => switch (s?.toUpperCase()) {
    'COMPLETED' => completed,
    'FAILED' => failed,
    _ => pending,
  };
}
