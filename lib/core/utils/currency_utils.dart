String formatFee(double amount) {
  if (amount == amount.truncateToDouble()) {
    return '৳${amount.toInt()}';
  }
  return '৳${amount.toStringAsFixed(2)}';
}
