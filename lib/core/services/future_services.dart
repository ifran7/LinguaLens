import 'package:url_launcher/url_launcher.dart';

class MessagingService {
  Future<bool> launchWhatsApp(String phone, String message) async {
    final uri = Uri.parse(
      'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9+]'), '')}?text=${Uri.encodeComponent(message)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> launchSms(String phone, String message) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    return launchUrl(uri);
  }
}

class SupabaseAuthService {
  Future<void> signInWithGoogle() async {
    // Reserved for the future Supabase Google OAuth adapter.
  }

  Future<void> signOut() async {
    // Reserved for the future Supabase session adapter.
  }

  Future<Object?> getCurrentUser() async => null;
}

class SubscriptionService {
  bool isPremiumUser() => false;

  List<String> getPremiumFeatures() => const [
    'unlimited_students',
    'advanced_reports',
    'cloud_sync',
    'premium_message_templates',
  ];

  Future<void> unlockBySubscriptionPlaceholder() async {
    // Billing integration remains intentionally disabled in this phase.
  }
}
