/// Payment lifecycle as reported by the backend (NabooPay-backed).
///
/// Mirrors the `PaymentStatus` enum in the payments integration guide:
/// `PENDING`, `PAID`, `PAID_AND_BLOCKED`, `REFUNDED`, `CANCELLED`, `FAILED`.
enum PaymentStatus {
  pending,
  paid,
  paidAndBlocked,
  refunded,
  cancelled,
  failed;

  static PaymentStatus fromString(String s) => switch (s.toUpperCase()) {
    'PAID' => paid,
    'PAID_AND_BLOCKED' => paidAndBlocked,
    'REFUNDED' => refunded,
    'CANCELLED' => cancelled,
    'FAILED' => failed,
    _ => pending,
  };

  /// Money has been collected — escrow-held funds still count as paid for UX.
  bool get isPaid => this == paid || this == paidAndBlocked;

  /// No further polling is useful once the payment reaches one of these.
  bool get isTerminal =>
      this == paid ||
      this == paidAndBlocked ||
      this == cancelled ||
      this == failed ||
      this == refunded;
}
