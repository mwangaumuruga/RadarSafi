import 'dart:typed_data';
import '../config/api_config.dart';
import 'llm_service.dart';

class VerificationResult {
  final bool isScam;
  final String agentResponse;
  final int reportCount;
  final String? advice;
  final double confidence;

  VerificationResult({
    required this.isScam,
    required this.agentResponse,
    required this.reportCount,
    this.advice,
    this.confidence = 0.0,
  });
}

class VerificationService {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  /// Verify email/message content for scam indicators
  Future<VerificationResult> verifyEmailMessage({
    required String senderEmail,
    required String messageContent,
  }) async {
    try {
      ApiConfig.validate();

      // Extract domain from sender email
      final emailDomain = senderEmail.contains('@')
          ? senderEmail.split('@')[1]
          : senderEmail;

      // Analyze message content for scam indicators
      final scamIndicators = _analyzeScamIndicators(messageContent, emailDomain);

      // Check domain reputation (using Google Safe Browsing API or custom logic)
      final domainCheck = await _checkDomainReputation(emailDomain);

      // Combine results
      final isScam = (scamIndicators['isScam'] as bool? ?? false) ||
          (domainCheck['isSuspicious'] as bool? ?? false);
      final scamConfidence = scamIndicators['confidence'] as double? ?? 0.0;
      final domainConfidence = domainCheck['confidence'] as double? ?? 0.0;
      final confidence = (scamConfidence + domainConfidence) / 2;

      // Generate agent response
      final agentResponse = _generateAgentResponse(
        isScam: isScam,
        senderEmail: senderEmail,
        indicators: scamIndicators,
        domainInfo: domainCheck,
        confidence: confidence,
      );

      // Get report count (simulated - in production, fetch from database)
      final reportCount = isScam ? _getSimulatedReportCount() : 0;

      // Generate advice
      final advice = isScam
          ? _generateScamAdvice(scamIndicators, domainCheck)
          : _generateSafeAdvice();

      return VerificationResult(
        isScam: isScam,
        agentResponse: agentResponse,
        reportCount: reportCount,
        advice: advice,
        confidence: confidence,
      );
    } catch (e) {
      // Fallback response on error
      return VerificationResult(
        isScam: false,
        agentResponse:
            'RadarSafi Agent: Unable to complete verification at this time. Please exercise caution and verify the sender through official channels.',
        reportCount: 0,
        advice: 'If you are unsure about this message, contact the organization directly through their official website or phone number.',
        confidence: 0.0,
      );
    }
  }

  /// Analyze message content for common scam indicators
  Map<String, dynamic> _analyzeScamIndicators(
    String messageContent,
    String domain,
  ) {
    final content = messageContent.toLowerCase();
    int scamScore = 0;
    final List<String> detectedIndicators = [];

    // Common scam phrases
    final scamPhrases = [
      'urgent action required',
      'click here immediately',
      'your account will be closed',
      'verify your account now',
      'suspended account',
      'limited time offer',
      'congratulations you won',
      'claim your prize',
      'wire transfer',
      'send money immediately',
      'verify your identity',
      'update your payment information',
      'tax refund',
      'inheritance',
      'lottery winner',
    ];

    // Check for scam phrases
    for (final phrase in scamPhrases) {
      if (content.contains(phrase)) {
        scamScore += 2;
        detectedIndicators.add(phrase);
      }
    }

    // Check for suspicious URLs
    final urlPattern = RegExp(r'https?://[^\s]+');
    final urls = urlPattern.allMatches(content);
    for (final match in urls) {
      final url = match.group(0) ?? '';
      if (!url.contains(domain.toLowerCase()) &&
          !_isKnownSafeDomain(url)) {
        scamScore += 3;
        detectedIndicators.add('Suspicious link detected');
      }
    }

    // Check for excessive urgency
    final urgencyWords = ['urgent', 'immediately', 'asap', 'now', 'today'];
    int urgencyCount = 0;
    for (final word in urgencyWords) {
      if (content.contains(word)) {
        urgencyCount++;
      }
    }
    if (urgencyCount >= 3) {
      scamScore += 2;
      detectedIndicators.add('Excessive urgency');
    }

    // Check for spelling/grammar errors (common in scams)
    final errorPattern = RegExp(r'\b(recieve|recieved|seperate|occured)\b',
        caseSensitive: false);
    if (errorPattern.hasMatch(content)) {
      scamScore += 1;
      detectedIndicators.add('Poor grammar/spelling');
    }

    // Check for requests for personal information
    final personalInfoPattern = RegExp(
        r'\b(password|ssn|social security|credit card|cvv|pin|account number)\b',
        caseSensitive: false);
    if (personalInfoPattern.hasMatch(content)) {
      scamScore += 3;
      detectedIndicators.add('Request for personal information');
    }

    final isScam = scamScore >= 5;
    final confidence = (scamScore / 15).clamp(0.0, 1.0);

    return {
      'isScam': isScam,
      'confidence': confidence,
      'score': scamScore,
      'indicators': detectedIndicators,
    };
  }

  /// Check domain reputation
  Future<Map<String, dynamic>> _checkDomainReputation(String domain) async {
    try {
      // In production, you would use Google Safe Browsing API or similar
      // For now, we'll use a simple heuristic check
      
      // Known legitimate domains (you can expand this list)
      final knownLegitimateDomains = [
        'gmail.com',
        'yahoo.com',
        'outlook.com',
        'hotmail.com',
        'icloud.com',
        'aol.com',
        'protonmail.com',
        'mail.com',
      ];

      // Check if domain is in known legitimate list
      if (knownLegitimateDomains.contains(domain.toLowerCase())) {
        return {
          'isSuspicious': false,
          'confidence': 0.2,
          'reputation': 'Known legitimate domain',
        };
      }

      // Check for suspicious domain patterns
      bool isSuspicious = false;
      double confidence = 0.5;

      // Check for typosquatting patterns
      if (domain.length < 5) {
        isSuspicious = true;
        confidence = 0.7;
      }

      // Check for random character strings
      final randomPattern = RegExp(r'^[a-z0-9]{10,}$');
      if (randomPattern.hasMatch(domain.split('.')[0])) {
        isSuspicious = true;
        confidence = 0.6;
      }

      return {
        'isSuspicious': isSuspicious,
        'confidence': confidence,
        'reputation': isSuspicious ? 'Suspicious domain pattern' : 'Unknown domain',
      };
    } catch (e) {
      return {
        'isSuspicious': false,
        'confidence': 0.5,
        'reputation': 'Unable to verify domain',
      };
    }
  }

  /// Check if URL is from a known safe domain
  bool _isKnownSafeDomain(String url) {
    final safeDomains = [
      'google.com',
      'microsoft.com',
      'apple.com',
      'amazon.com',
      'paypal.com',
      'bankofamerica.com',
      'chase.com',
      'wellsfargo.com',
    ];

    return safeDomains.any((domain) => url.toLowerCase().contains(domain));
  }

  /// Generate agent response based on analysis
  String _generateAgentResponse({
    required bool isScam,
    required String senderEmail,
    required Map<String, dynamic> indicators,
    required Map<String, dynamic> domainInfo,
    required double confidence,
  }) {
    if (isScam) {
      final indicatorList = indicators['indicators'] as List<String>;
      
      String response = 'RadarSafi Agent: This message appears to be a SCAM. ';
      response += 'Confidence level: ${(confidence * 100).toStringAsFixed(0)}%. ';
      
      if (indicatorList.isNotEmpty) {
        response += 'Detected indicators: ${indicatorList.take(3).join(", ")}. ';
      }
      
      response += 'The sender email "$senderEmail" and message content show multiple red flags. ';
      response += 'DO NOT click any links, provide personal information, or send money.';
      
      return response;
    } else {
      return 'RadarSafi Agent: This message appears to be legitimate. '
          'The sender email "$senderEmail" and message content do not show significant scam indicators. '
          'However, always verify important communications through official channels.';
    }
  }

  /// Generate advice for scam messages
  String _generateScamAdvice(
    Map<String, dynamic> indicators,
    Map<String, dynamic> domainInfo,
  ) {
    return '⚠️ This message is likely a scam. Do not respond, click links, or provide any personal information. '
        'If you believe this is from a legitimate organization, contact them directly through their official website or phone number. '
        'Report this message to help protect others.';
  }

  /// Generate advice for safe messages
  String _generateSafeAdvice() {
    return '✅ This message appears safe, but always verify important communications through official channels. '
        'Be cautious of unexpected requests for personal information or money transfers.';
  }

  /// Get simulated report count (in production, fetch from database)
  int _getSimulatedReportCount() {
    // Simulate report count based on scam likelihood
    return (3 + (DateTime.now().millisecond % 10));
  }

  final LLMService _llmService = LLMService();

  /// Verify image using LLM analysis
  Future<VerificationResult> verifyImage({
    required Uint8List imageBytes,
    String? imageMimeType,
  }) async {
    try {
      ApiConfig.validate();

      // Call LLM service to analyze image
      final llmResult = await _llmService.analyzeImage(
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );

      final isScam = llmResult['isScam'] as bool;
      final confidence = llmResult['confidence'] as double;
      final indicators = llmResult['indicators'] as List<String>;
      final company = llmResult['company'] as String?;
      final analysis = llmResult['analysis'] as String;
      final advice = llmResult['advice'] as String;

      // Generate agent response
      String agentResponse = 'RadarSafi Agent: ';
      if (isScam) {
        agentResponse += 'This image appears to be a SCAM. ';
        agentResponse += 'Confidence level: ${(confidence * 100).toStringAsFixed(0)}%. ';
        if (indicators.isNotEmpty) {
          agentResponse += 'Detected indicators: ${indicators.take(3).join(", ")}. ';
        }
        agentResponse += analysis;
      } else {
        agentResponse += 'This image appears to be legitimate. ';
        if (company != null) {
          agentResponse += 'Detected company: $company. ';
        }
        agentResponse += analysis;
      }

      final reportCount = isScam ? _getSimulatedReportCount() : 0;

      return VerificationResult(
        isScam: isScam,
        agentResponse: agentResponse,
        reportCount: reportCount,
        advice: advice.isNotEmpty ? advice : _generateScamAdvice({}, {}),
        confidence: confidence,
      );
    } catch (e) {
      return VerificationResult(
        isScam: false,
        agentResponse:
            'RadarSafi Agent: Unable to complete image verification at this time. Please exercise caution.',
        reportCount: 0,
        advice: 'If you are unsure about this image, verify through official channels.',
        confidence: 0.0,
      );
    }
  }

  /// Verify link/URL using LLM analysis
  Future<VerificationResult> verifyLink({
    required String url,
  }) async {
    try {
      ApiConfig.validate();

      // Call LLM service to analyze link
      final llmResult = await _llmService.analyzeLink(url: url);

      final isScam = llmResult['isScam'] as bool;
      final confidence = llmResult['confidence'] as double;
      final indicators = llmResult['indicators'] as List<String>;
      final company = llmResult['company'] as String?;
      final analysis = llmResult['analysis'] as String;
      final advice = llmResult['advice'] as String;

      // Generate agent response
      String agentResponse = 'RadarSafi Agent: ';
      if (isScam) {
        agentResponse += 'This link appears to be a SCAM. ';
        agentResponse += 'Confidence level: ${(confidence * 100).toStringAsFixed(0)}%. ';
        if (indicators.isNotEmpty) {
          agentResponse += 'Detected indicators: ${indicators.take(3).join(", ")}. ';
        }
        agentResponse += analysis;
      } else {
        agentResponse += 'This link appears to be legitimate. ';
        if (company != null) {
          agentResponse += 'Detected company: $company. ';
        }
        agentResponse += analysis;
      }

      final reportCount = isScam ? _getSimulatedReportCount() : 0;

      return VerificationResult(
        isScam: isScam,
        agentResponse: agentResponse,
        reportCount: reportCount,
        advice: advice.isNotEmpty ? advice : _generateScamAdvice({}, {}),
        confidence: confidence,
      );
    } catch (e) {
      // Provide a more helpful error message
      final errorMsg = e.toString().contains('404')
          ? 'RadarSafi Agent: API endpoint not found. Please ensure the Google Gemini API is enabled for your API key.'
          : 'RadarSafi Agent: Unable to complete link verification at this time. Please exercise caution.';
      
      return VerificationResult(
        isScam: false,
        agentResponse: errorMsg,
        reportCount: 0,
        advice: 'If you are unsure about this link, verify through official channels.',
        confidence: 0.0,
      );
    }
  }

  /// Verify phone number using LLM analysis
  Future<VerificationResult> verifyPhoneNumber({
    required String phoneNumber,
    String? claimedCompany,
    String? reason,
  }) async {
    try {
      ApiConfig.validate();

      // Call LLM service to analyze phone number
      final llmResult = await _llmService.analyzePhoneNumber(
        phoneNumber: phoneNumber,
        claimedCompany: claimedCompany,
        reason: reason,
      );

      final isScam = llmResult['isScam'] as bool;
      final confidence = llmResult['confidence'] as double;
      final indicators = llmResult['indicators'] as List<String>;
      final company = llmResult['company'] as String?;
      final analysis = llmResult['analysis'] as String;
      final advice = llmResult['advice'] as String;

      // Generate agent response
      String agentResponse = 'RadarSafi Agent: ';
      if (isScam) {
        agentResponse += 'This phone number appears to be associated with a SCAM. ';
        agentResponse += 'Confidence level: ${(confidence * 100).toStringAsFixed(0)}%. ';
        if (indicators.isNotEmpty) {
          agentResponse += 'Detected indicators: ${indicators.take(3).join(", ")}. ';
        }
        agentResponse += analysis;
      } else {
        agentResponse += 'This phone number appears to be legitimate. ';
        if (company != null) {
          agentResponse += 'Detected company: $company. ';
          if (claimedCompany != null && company.toLowerCase() != claimedCompany.toLowerCase()) {
            agentResponse += 'Note: The claimed company "$claimedCompany" does not match the detected company "$company". ';
          }
        }
        agentResponse += analysis;
      }

      final reportCount = isScam ? _getSimulatedReportCount() : 0;

      return VerificationResult(
        isScam: isScam,
        agentResponse: agentResponse,
        reportCount: reportCount,
        advice: advice.isNotEmpty ? advice : _generateScamAdvice({}, {}),
        confidence: confidence,
      );
    } catch (e) {
      return VerificationResult(
        isScam: false,
        agentResponse:
            'RadarSafi Agent: Unable to complete phone number verification at this time. Please exercise caution.',
        reportCount: 0,
        advice: 'If you are unsure about this phone number, verify through official channels.',
        confidence: 0.0,
      );
    }
  }
}

