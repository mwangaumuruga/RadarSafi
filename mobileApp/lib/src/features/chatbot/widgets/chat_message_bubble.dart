import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.agentName = 'RadarSafi Agent',
  });

  final String message;
  final bool isUser;
  final String agentName;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      // User message - right side, light grey
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // User avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Agent message - left side, dark blue-green
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent avatar
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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agentName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _parseMessage(message),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _parseMessage(String message) {
    // Parse formatted messages with icons and bullet points
    final lines = message.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (line.isEmpty) {
        if (i < lines.length - 1) {
          widgets.add(const SizedBox(height: 8));
        }
        continue;
      }

      // Handle bullet points
      if (line.startsWith('• ') || line.startsWith('- ')) {
        final bulletText = line.startsWith('• ') ? line.substring(2) : line.substring(2);
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                Expanded(
                  child: Text(
                    bulletText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.contains('NOT legitimate')) {
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cancel,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (line.contains('reported') || line.contains('confirmed')) {
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.accentGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (line.startsWith('Advice:') || line.toLowerCase().contains('important:')) {
        widgets.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lock,
                color: AppColors.accentGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Regular text - check if it should be bold (starts with uppercase word or contains key phrases)
        final isBold = line.split(' ').isNotEmpty && 
                       (line.split(' ')[0].toUpperCase() == line.split(' ')[0] ||
                        line.toLowerCase().contains('warning') ||
                        line.toLowerCase().contains('caution'));
        
        widgets.add(
          Text(
            line,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        );
      }
      if (i < lines.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

