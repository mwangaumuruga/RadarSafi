import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool answerSubmitted = false;
  bool isCorrect = false;
  int score = 0;
  
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Which one is the correct form of setting up a strong password?',
      'options': [
        'Numbers Only',
        'Characters Only',
        'Numbers & Characters Only',
        'Numbers, Characters and symbols',
      ],
      'correctAnswer': 3, // D
      'explanation': 'A combination of the three will make it hard for the hackers to guess the password.',
    },
    {
      'question': 'What is the safest way to protect your online accounts?',
      'options': [
        'Using the same password everywhere',
        'Writing your password on a notebook',
        'Using strong, unique passwords with 2FA',
        'Sharing your password with a trusted friend',
      ],
      'correctAnswer': 2, // C
      'explanation': 'Using strong, unique passwords combined with two-factor authentication (2FA) provides the best protection for your online accounts.',
    },
    {
      'question': 'How can you avoid falling for phishing scams?',
      'options': [
        'Click the link to see if it works',
        'Reply to confirm if it\'s real',
        'Delete it immediately',
        'Verify the sender before clicking anything',
      ],
      'correctAnswer': 3, // D
      'explanation': 'Always verify the sender\'s identity and check the URL before clicking any links to avoid phishing attacks.',
    },
    {
      'question': 'Why are software updates important?',
      'options': [
        'They only add new colors and themes',
        'They make your device slower',
        'They fix security vulnerabilities',
        'They are optional and not necessary',
      ],
      'correctAnswer': 2, // C
      'explanation': 'Software updates often include critical security patches that fix vulnerabilities that hackers could exploit.',
    },
    {
      'question': 'What is the safest action on public Wi-Fi?',
      'options': [
        'Log in to your bank account',
        'Turn off your antivirus',
        'Use a VPN before accessing sensitive information',
        'Share files with strangers',
      ],
      'correctAnswer': 2, // C
      'explanation': 'Public Wi-Fi networks are often unsecured. Using a VPN encrypts your connection and protects your sensitive data.',
    },
    {
      'question': 'How can you recognize a fake website?',
      'options': [
        'It loads very fast',
        'It has bright colors',
        'The URL looks strange or lacks "https"',
        'It has many animations',
      ],
      'correctAnswer': 2, // C
      'explanation': 'Fake websites often have suspicious URLs, misspellings, or lack the "https" security indicator in the address bar.',
    },
    {
      'question': 'What should you do when an unknown app asks for permissions?',
      'options': [
        'Allow everything immediately',
        'Check if the permissions make sense',
        'Disable your phone security',
        'Install it from multiple websites',
      ],
      'correctAnswer': 1, // B
      'explanation': 'Always review app permissions carefully. Only grant permissions that are necessary for the app\'s functionality.',
    },
    {
      'question': 'What is the best way to protect stored passwords?',
      'options': [
        'Memorize all of them',
        'Save them in plain text',
        'Use a password manager',
        'Use one password for everything',
      ],
      'correctAnswer': 2, // C
      'explanation': 'Password managers securely store and encrypt your passwords, making it easy to use unique, strong passwords for each account.',
    },
    {
      'question': 'How can you reduce the risk of malware?',
      'options': [
        'Download any free app you find',
        'Click ads that promise rewards',
        'Avoid unknown downloads and use antivirus',
        'Disable security alerts',
      ],
      'correctAnswer': 2, // C
      'explanation': 'Avoiding suspicious downloads and using reputable antivirus software helps protect your device from malware infections.',
    },
    {
      'question': 'What should you do if you suspect you\'re being scammed?',
      'options': [
        'Continue talking to gather information',
        'Send money to test the scammer',
        'Block the person and report immediately',
        'Ignore and hope it stops',
      ],
      'correctAnswer': 2, // C
      'explanation': 'If you suspect a scam, immediately block the person and report it to the appropriate authorities to protect yourself and others.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / 10;

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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF9500), // Orange color
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Question Counter
                  Text(
                    '${currentQuestionIndex + 1}/10',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Question Text
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  // Answer Options
                  ...List.generate(
                    currentQuestion['options'].length,
                    (index) {
                      final option = currentQuestion['options'][index];
                      final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
                      final isSelected = selectedAnswer == optionLabel;
                      final isCorrectAnswer = index == currentQuestion['correctAnswer'];
                      
                      // Determine colors based on submission state
                      Color? backgroundColor;
                      Color borderColor;
                      double borderWidth = 1;
                      
                      if (answerSubmitted) {
                        if (isCorrectAnswer) {
                          // Correct answer always in orange
                          backgroundColor = const Color(0xFFFF9500); // Orange
                          borderColor = const Color(0xFFFF9500);
                          borderWidth = 2;
                        } else if (isSelected && !isCorrectAnswer) {
                          // Wrong selected answer in red
                          backgroundColor = AppColors.danger;
                          borderColor = AppColors.danger;
                          borderWidth = 2;
                        } else {
                          // Other options remain default
                          backgroundColor = AppColors.surface;
                          borderColor = AppColors.outline;
                        }
                      } else {
                        // Before submission
                        backgroundColor = isSelected
                            ? AppColors.accentGreen.withOpacity(0.2)
                            : AppColors.surface;
                        borderColor = isSelected
                            ? AppColors.accentGreen
                            : AppColors.outline;
                        borderWidth = isSelected ? 2 : 1;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: answerSubmitted
                                ? null
                                : () {
                                    setState(() {
                                      selectedAnswer = optionLabel;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: borderColor,
                                  width: borderWidth,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$optionLabel. ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Feedback Box (shown after submission)
                  if (answerSubmitted) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A3A4A), // Dark blue
                            Color(0xFF0F4C3A), // Dark green
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Correct/Incorrect indicator
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect
                                    ? AppColors.accentGreen
                                    : AppColors.danger,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCorrect
                                    ? 'Answer is correct'
                                    : 'Answer is incorrect',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Explanation label
                          const Text(
                            'Explanation:',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Explanation text
                          Text(
                            currentQuestion['explanation'],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Submit/Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: answerSubmitted
                          ? () {
                              _handleNext();
                            }
                          : selectedAnswer == null
                              ? null
                              : () {
                                  _handleSubmit();
                                },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppColors.surfaceAlt,
                        disabledForegroundColor: AppColors.textSecondary,
                      ),
                      child: Text(
                        answerSubmitted ? 'Next' : 'Submit',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (selectedAnswer == null) return;

    final currentQuestion = questions[currentQuestionIndex];
    final selectedIndex = selectedAnswer!.codeUnitAt(0) - 65; // Convert A=0, B=1, etc.
    final correctIndex = currentQuestion['correctAnswer'];

    setState(() {
      answerSubmitted = true;
      isCorrect = selectedIndex == correctIndex;
      if (isCorrect) {
        score++;
      }
    });
  }

  void _handleNext() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        answerSubmitted = false;
        isCorrect = false;
      });
    } else {
      // Quiz completed - navigate to results screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultsScreen(
            score: score,
            totalQuestions: questions.length,
          ),
        ),
      );
    }
  }
}

