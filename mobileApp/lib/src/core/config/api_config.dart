import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String? get googleApiKey => dotenv.env['GOOGLE_API_KEY'];

  static bool get isConfigured => googleApiKey != null && googleApiKey!.isNotEmpty;

  static void validate() {
    if (!isConfigured) {
      throw Exception(
        'Google API key is not configured. Please check your .env file.',
      );
    }
  }
}

