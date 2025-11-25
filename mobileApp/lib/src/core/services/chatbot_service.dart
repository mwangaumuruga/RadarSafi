import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  final List<Map<String, String>> _conversationHistory = [];

  /// Get chatbot response using Google Gemini API, filtered for cybersecurity
  Future<String> getResponse(String userMessage) async {
    try {
      ApiConfig.validate();
      final apiKey = ApiConfig.googleApiKey!;

      // Note: We'll add user message to history after successful response

      // Build conversation history for context
      final contents = <Map<String, dynamic>>[];
      
      // Add system instruction as first message
      contents.add({
        'role': 'user',
        'parts': [
          {
            'text': 'You are RadarSafi Agent, a cybersecurity expert assistant. Your role is to help users with:\n'
                '- Identifying and preventing scams, phishing, and fraud\n'
                '- Verifying suspicious links, emails, messages, phone numbers, and images\n'
                '- Providing cybersecurity best practices and advice\n'
                '- Educating users about online safety\n'
                '- Helping users understand security threats\n\n'
                'IMPORTANT: Focus ONLY on cybersecurity topics. Be helpful, professional, and friendly. '
                'Use simple language. Always prioritize user safety.\n\n'
                'FORMATTING: Format your responses clearly without using markdown asterisks (*) or bold symbols. '
                'Use bullet points (•) for lists, and use clear line breaks for readability. '
                'Do not use ** for bold text - just write naturally.'
          }
        ]
      });
      
      // Add previous conversation history (last 5 exchanges)
      final recentHistory = _conversationHistory.length > 10 
          ? _conversationHistory.sublist(_conversationHistory.length - 10)
          : _conversationHistory;
      
      for (var msg in recentHistory) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg['parts'] ?? msg['text'] ?? ''}
          ]
        });
      }
      
      // Add current user message
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ]
      });

      final requestBody = {
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      // Use header authentication (preferred method for Gemini API)
      // Using gemini-2.0-flash-001 (stable model that supports generateContent)
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-001:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check for errors in response
        if (data['error'] != null) {
          throw Exception('API Error: ${data['error']['message']}');
        }
        
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        
        if (text.isEmpty) {
          throw Exception('Empty response from API');
        }
        
        // Filter response to ensure it's cybersecurity-related
        final filteredResponse = _filterForCybersecurity(text, userMessage);
        
        // Clean and format the response (remove markdown asterisks, format nicely)
        final cleanedResponse = _cleanMarkdown(filteredResponse);
        
        // Add user message and assistant response to history
        _conversationHistory.add({
          'role': 'user',
          'parts': userMessage,
        });
        _conversationHistory.add({
          'role': 'model',
          'parts': cleanedResponse,
        });
        
        // Keep conversation history manageable (last 10 exchanges = 20 messages)
        if (_conversationHistory.length > 20) {
          _conversationHistory.removeRange(0, _conversationHistory.length - 20);
        }
        
        return cleanedResponse;
      } else {
        final errorBody = response.body;
        throw Exception('Chatbot API error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      // Log error for debugging (using debugPrint for Flutter)
      debugPrint('Chatbot error: $e');
      
      // Fallback response with more helpful message
      final errorMsg = e.toString();
      if (errorMsg.contains('404')) {
        return 'RadarSafi Agent: API endpoint not found. Please ensure the Google Gemini API is enabled for your API key in Google Cloud Console.';
      } else if (errorMsg.contains('403') || errorMsg.contains('401')) {
        return 'RadarSafi Agent: API authentication failed. Please check your API key configuration.';
      } else if (errorMsg.contains('429')) {
        return 'RadarSafi Agent: API rate limit exceeded. Please try again in a moment.';
      }
      
      return 'I apologize, but I\'m having trouble processing your request right now. '
          'Error: ${errorMsg.contains("Exception:") ? errorMsg.split("Exception:")[1].trim() : "Unknown error"}. '
          'Please try again, or if you have a security concern, you can use the Report feature to verify suspicious content.';
    }
  }

  /// Filter response to ensure it's cybersecurity-related
  String _filterForCybersecurity(String response, String userMessage) {
    // Check if response is already cybersecurity-related
    final securityKeywords = [
      'security', 'scam', 'phishing', 'fraud', 'cyber', 'hack', 'malware',
      'virus', 'password', 'authentication', 'verification', 'safe', 'unsafe',
      'legitimate', 'suspicious', 'threat', 'attack', 'vulnerability', 'privacy',
      'data protection', 'online safety', 'identity theft', 'social engineering'
    ];

    final responseLower = response.toLowerCase();
    final userMessageLower = userMessage.toLowerCase();

    // If response contains security keywords, return as is
    if (securityKeywords.any((keyword) => responseLower.contains(keyword))) {
      return response;
    }

    // If user message is clearly not security-related, redirect
    final nonSecurityTopics = [
      'weather', 'recipe', 'sports', 'entertainment', 'movie', 'music',
      'game', 'joke', 'story', 'history', 'science', 'math'
    ];

    if (nonSecurityTopics.any((topic) => userMessageLower.contains(topic))) {
      return 'I\'m RadarSafi Agent, focused on cybersecurity and online safety. '
          'I can help you with:\n'
          '• Identifying scams and phishing attempts\n'
          '• Verifying suspicious links, emails, or messages\n'
          '• Cybersecurity best practices\n'
          '• Online safety advice\n\n'
          'How can I help you stay safe online today?';
    }

    // If response doesn't seem security-related, add context
    return '$response\n\n[Note: As RadarSafi Agent, I focus on cybersecurity and online safety. '
        'If you have questions about verifying suspicious content, I\'m here to help!]';
  }

  /// Clean markdown formatting from response
  String _cleanMarkdown(String text) {
    // Remove bold markdown (**text** -> text)
    text = text.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1) ?? '',
    );
    
    // Remove single asterisks for emphasis (*text* -> text)
    text = text.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (match) => match.group(1) ?? '',
    );
    
    // Clean up any remaining asterisks at start/end of lines
    text = text.replaceAll(RegExp(r'^\*\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'\s*\*$', multiLine: true), '');
    
    // Format bullet points nicely (convert - or * to bullet)
    text = text.replaceAllMapped(
      RegExp(r'^[\s]*[-*]\s+', multiLine: true),
      (match) => '• ',
    );
    
    // Clean up multiple spaces
    text = text.replaceAll(RegExp(r' {2,}'), ' ');
    
    // Clean up multiple newlines (max 2 consecutive)
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    return text.trim();
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }
}

