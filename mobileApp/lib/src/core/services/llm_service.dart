import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LLMService {
  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  static const String _geminiApiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  /// Analyze image for scam indicators using Gemini Vision
  Future<Map<String, dynamic>> analyzeImage({
    required Uint8List imageBytes,
    String? imageMimeType,
  }) async {
    try {
      ApiConfig.validate();
      final apiKey = ApiConfig.googleApiKey!;

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);
      final mimeType = imageMimeType ?? 'image/jpeg';

      final prompt = '''
Analyze this image and determine if it contains scam indicators. Check for:
1. Suspicious text content (urgent requests, fake logos, phishing attempts)
2. Fake company branding or logos
3. Suspicious URLs or phone numbers visible in the image
4. Common scam patterns (fake invoices, lottery wins, account suspension notices)

Provide a JSON response with this structure:
{
  "isScam": true/false,
  "confidence": 0.0-1.0,
  "indicators": ["list of detected indicators"],
  "company": "detected company name or null",
  "analysis": "detailed analysis of the image",
  "advice": "specific advice for the user"
}

Be thorough and identify any red flags. If legitimate, state that clearly.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Image,
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        }
      };

      // Try with header authentication (preferred method)
      // Using gemini-2.0-flash-001 for image analysis (supports vision)
      final response = await http.post(
        Uri.parse('$_geminiApiBaseUrl/gemini-2.0-flash-001:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return _parseLLMResponse(text, 'image');
      } else {
        final errorBody = response.body;
        throw Exception('LLM API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      return _getFallbackResponse('image', error: e.toString());
    }
  }

  /// Analyze URL/link for scam indicators
  Future<Map<String, dynamic>> analyzeLink({
    required String url,
  }) async {
    try {
      ApiConfig.validate();
      final apiKey = ApiConfig.googleApiKey!;

      final prompt = '''
Analyze this URL/link and determine if it's a scam or legitimate. Check for:
1. Domain reputation and legitimacy
2. URL structure (typosquatting, suspicious patterns)
3. Known scam patterns
4. Whether it belongs to a legitimate company

URL to analyze: $url

Provide a JSON response with this structure:
{
  "isScam": true/false,
  "confidence": 0.0-1.0,
  "indicators": ["list of detected indicators"],
  "company": "detected company name or null",
  "domain": "extracted domain",
  "analysis": "detailed analysis of the URL",
  "advice": "specific advice for the user"
}

Be thorough and identify any red flags. If legitimate, state the company it belongs to.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        }
      };

      // Try with header authentication (preferred method)
      // Using gemini-2.0-flash-001 for text analysis (stable model)
      final response = await http.post(
        Uri.parse('$_geminiApiBaseUrl/gemini-2.0-flash-001:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return _parseLLMResponse(text, 'link');
      } else {
        final errorBody = response.body;
        throw Exception('LLM API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      return _getFallbackResponse('link', error: e.toString());
    }
  }

  /// Analyze phone number for scam indicators
  Future<Map<String, dynamic>> analyzePhoneNumber({
    required String phoneNumber,
    String? claimedCompany,
    String? reason,
  }) async {
    try {
      ApiConfig.validate();
      final apiKey = ApiConfig.googleApiKey!;

      final prompt = '''
Analyze this phone number and determine if it's associated with scams or legitimate businesses. Check for:
1. Phone number format and country code
2. Known scam phone numbers or patterns
3. Whether it matches the claimed company
4. Reported scam activity associated with this number

Phone number: $phoneNumber
Claimed company: ${claimedCompany ?? 'Not specified'}
Reason for contact: ${reason ?? 'Not specified'}

Provide a JSON response with this structure:
{
  "isScam": true/false,
  "confidence": 0.0-1.0,
  "indicators": ["list of detected indicators"],
  "company": "actual company or null",
  "analysis": "detailed analysis of the phone number",
  "advice": "specific advice for the user"
}

Be thorough and identify any red flags. If legitimate, state the company it belongs to.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        }
      };

      // Try with header authentication (preferred method)
      // Using gemini-2.0-flash-001 for text analysis (stable model)
      final response = await http.post(
        Uri.parse('$_geminiApiBaseUrl/gemini-2.0-flash-001:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return _parseLLMResponse(text, 'phone');
      } else {
        throw Exception('LLM API error: ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackResponse('phone', error: e.toString());
    }
  }

  /// Parse LLM response text to extract structured data
  Map<String, dynamic> _parseLLMResponse(String text, String type) {
    try {
      // Try to extract JSON from the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0);
        final parsed = jsonDecode(jsonStr!);
        return {
          'isScam': parsed['isScam'] ?? false,
          'confidence': (parsed['confidence'] as num?)?.toDouble() ?? 0.5,
          'indicators': List<String>.from(parsed['indicators'] ?? []),
          'company': parsed['company'],
          'analysis': parsed['analysis'] ?? text,
          'advice': parsed['advice'] ?? '',
          'rawResponse': text,
        };
      }

      // Fallback: parse from text
      final isScam = text.toLowerCase().contains('scam') ||
          text.toLowerCase().contains('fraud') ||
          text.toLowerCase().contains('suspicious') ||
          text.toLowerCase().contains('not legitimate');

      return {
        'isScam': isScam,
        'confidence': isScam ? 0.7 : 0.3,
        'indicators': _extractIndicators(text),
        'company': _extractCompany(text),
        'analysis': text,
        'advice': _extractAdvice(text),
        'rawResponse': text,
      };
    } catch (e) {
      return _getFallbackResponse(type, error: e.toString());
    }
  }

  List<String> _extractIndicators(String text) {
    final indicators = <String>[];
    final lowerText = text.toLowerCase();

    if (lowerText.contains('phishing')) indicators.add('Phishing attempt');
    if (lowerText.contains('fake')) indicators.add('Fake content');
    if (lowerText.contains('suspicious')) indicators.add('Suspicious activity');
    if (lowerText.contains('urgent')) indicators.add('Urgency tactics');
    if (lowerText.contains('legitimate') && !lowerText.contains('not legitimate')) {
      indicators.add('Appears legitimate');
    }

    return indicators;
  }

  String? _extractCompany(String text) {
    final companyPattern = RegExp(r'company[:\s]+([A-Z][a-zA-Z\s]+)', caseSensitive: false);
    final match = companyPattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String _extractAdvice(String text) {
    if (text.toLowerCase().contains('advice')) {
      final adviceMatch = RegExp(r'advice[:\s]+(.+?)(?:\n|$)', caseSensitive: false).firstMatch(text);
      return adviceMatch?.group(1)?.trim() ?? 'Please verify through official channels.';
    }
    return 'Please verify through official channels.';
  }

  Map<String, dynamic> _getFallbackResponse(String type, {String? error}) {
    return {
      'isScam': false,
      'confidence': 0.5,
      'indicators': <String>[],
      'company': null,
      'analysis': 'Unable to complete analysis. ${error ?? "Please verify through official channels."}',
      'advice': 'Please verify through official channels.',
      'rawResponse': error ?? 'Analysis unavailable',
    };
  }
}

