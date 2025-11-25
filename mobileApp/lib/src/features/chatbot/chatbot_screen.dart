import 'package:flutter/material.dart';

import '../../core/services/chatbot_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/radar_logo.dart';
import 'widgets/chat_message_bubble.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String agentName;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.agentName = 'RadarSafi Agent',
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  final ChatbotService _chatbotService = ChatbotService();
  bool _isLoading = false;

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = messageController.text.trim();
    setState(() {
      messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });
    messageController.clear();

    // Scroll to show user message
    _scrollToBottom();

    try {
      // Get response from chatbot service
      final response = await _chatbotService.getResponse(userMessage);

      if (mounted) {
        setState(() {
          messages.add(
            ChatMessage(
              text: response,
              isUser: false,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final errorMsg = e.toString();
          messages.add(
            ChatMessage(
              text: 'I apologize, but I\'m having trouble processing your request right now.\n\n'
                  'Error details: ${errorMsg.contains("Exception:") ? errorMsg.split("Exception:")[1].trim() : errorMsg}\n\n'
                  'Please try again, or use the Report feature to verify suspicious content.',
              isUser: false,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundMid, AppColors.backgroundDeep],
            ),
          ),
          child: Column(
        children: [
          // Top Section - Logo
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RadarLogo(size: 40),
                const SizedBox(width: 12),
                const Text(
                  'RadarSafi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area - Messages or Welcome Screen
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Robot Image
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Image.asset(
                            'assets/images/robot.jpeg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  size: 100,
                                  color: AppColors.accentGreen,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Welcome Message
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Welcome to RadarSafi, your No. 1 security bot',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && _isLoading) {
                        // Show loading indicator
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.smart_toy,
                                  color: AppColors.backgroundDeep,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accentGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ChatMessageBubble(
                        message: messages[index].text,
                        isUser: messages[index].isUser,
                        agentName: messages[index].agentName,
                      );
                    },
                  ),
          ),
          // Chat Input Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.outline,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: messageController,
                      enabled: !_isLoading,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _isLoading ? 'RadarSafi Agent is typing...' : 'Ask me about cybersecurity...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.mic,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  // Handle voice input
                                },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isLoading ? AppColors.surfaceAlt : AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textSecondary,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: AppColors.backgroundDeep,
                          ),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    ),
    );
  }
}

