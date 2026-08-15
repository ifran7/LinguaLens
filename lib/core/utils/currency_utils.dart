import 'package:intl/intl.dart';

String formatFee(double amount, {bool includeSymbol = true}) {
  final decimals = amount == amount.roundToDouble() ? 0 : 2;
  final formatter = NumberFormat(decimals == 0 ? '#,##0' : '#,##0.00', 'en_US');
  final value = formatter.format(amount);
  return includeSymbol ? '৳ $value' : value;
}

String formatFeeNumber(double amount) =>
    formatFee(amount, includeSymbol: false);
