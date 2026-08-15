class PhoneFormatter {
  const PhoneFormatter._();

  static String digitsOnly(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  static String toInternational(String phone) {
    var digits = digitsOnly(phone);
    if (digits.startsWith('00880')) digits = digits.substring(2);
    if (digits.startsWith('880')) return digits;
    if (digits.startsWith('0')) return '880${digits.substring(1)}';
    if (digits.startsWith('1') && digits.length == 10) return '880$digits';
    return digits;
  }

  static bool isValidPhone(String phone) {
    final normalized = toInternational(phone);
    return RegExp(r'^8801[3-9][0-9]{8}$').hasMatch(normalized);
  }

  static String forSms(String phone) {
    final normalized = toInternational(phone);
    return normalized.isEmpty ? phone : '+$normalized';
  }
}
