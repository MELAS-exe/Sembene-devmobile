/// Which "account" the caller draws a withdrawal from, resolved server-side
/// from the caller's role.
enum BalanceSource {
  /// Sellers (CONSUMER / PRODUCER) withdrawing their sales earnings.
  sellerEarnings,

  /// Platform admins withdrawing accrued platform profit.
  platformProfit,

  /// Caller isn't permitted to withdraw — hide the feature.
  unavailable;

  static BalanceSource fromString(String? s) => switch (s?.toUpperCase()) {
    'SELLER_EARNINGS' => sellerEarnings,
    'PLATFORM_PROFIT' => platformProfit,
    _ => unavailable,
  };
}
