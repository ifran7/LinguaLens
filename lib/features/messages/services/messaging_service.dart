import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/phone_formatter.dart';
import '../domain/entities/message_enums.dart';

class MessagingService {
  const MessagingService();

  Future<MessagingResult> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    if (!PhoneFormatter.isValidPhone(phone)) {
      return MessagingResult.invalidPhone;
    }
    final uri = Uri.parse(
      'https://wa.me/${PhoneFormatter.toInternational(phone)}?text=${Uri.encodeComponent(message)}',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched ? MessagingResult.success : MessagingResult.appNotFound;
    } catch (_) {
      return MessagingResult.error;
    }
  }

  Future<MessagingResult> launchSMS({
    required String phone,
    required String message,
  }) async {
    if (!PhoneFormatter.isValidPhone(phone)) {
      return MessagingResult.invalidPhone;
    }
    final uri = Uri(
      scheme: 'sms',
      path: PhoneFormatter.forSms(phone),
      queryParameters: {'body': message},
    );
    try {
      final launched = await launchUrl(uri);
      return launched ? MessagingResult.success : MessagingResult.appNotFound;
    } catch (_) {
      return MessagingResult.error;
    }
  }
}
