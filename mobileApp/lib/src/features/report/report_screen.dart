import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../core/services/reports_service.dart';
import '../../core/services/verification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/radar_logo.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? selectedItem = 'Image/screenshot';
  String selectedType = 'Image/screenshot';
  XFile? _selectedImage; // Store XFile on all platforms
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _claimedInstitutionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _emailMessageController = TextEditingController();
  final TextEditingController _senderEmailController = TextEditingController();
  String? _selectedCompany;
  String? _selectedReason;
  bool _isVerifying = false;
  bool _verificationComplete = false;
  bool _phoneVerificationComplete = false;
  bool _linkVerificationComplete = false;
  bool _emailMessageVerificationComplete = false;
  
  // Verification results
  String _emailAgentResponse = '';
  int _emailReportCount = 0;
  String? _emailAdvice;
  
  String _imageAgentResponse = '';
  int _imageReportCount = 0;
  String? _imageAdvice;
  
  String _linkAgentResponse = '';
  int _linkReportCount = 0;
  String? _linkAdvice;
  
  String _phoneAgentResponse = '';
  int _phoneReportCount = 0;
  String? _phoneAdvice;
  
  final VerificationService _verificationService = VerificationService();
  final ReportsService _reportsService = ReportsService();

  @override
  void initState() {
    super.initState();
    // Add listeners to update button state
    _phoneNumberController.addListener(() {
      setState(() {});
    });
    _claimedInstitutionController.addListener(() {
      setState(() {});
    });
    _linkController.addListener(() {
      setState(() {});
    });
    _emailMessageController.addListener(() {
      setState(() {});
    });
    _senderEmailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _phoneNumberController.dispose();
    _claimedInstitutionController.dispose();
    _linkController.dispose();
    _emailMessageController.dispose();
    _senderEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
      child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Logo and Brand Name
                  Row(
                    children: [
                      const RadarLogo(size: 40),
                      const SizedBox(width: 12),
                      const Text(
                        'RadarSafi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    (_verificationComplete ||
                            _phoneVerificationComplete ||
                            _linkVerificationComplete ||
                            _emailMessageVerificationComplete)
                        ? 'Verify content'
                        : 'Verify data and report',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Verify suspicious data and report if found malicious to help others',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
                  // Divider
                  const Divider(
                    color: AppColors.outline,
                    thickness: 1,
                  ),
                  const SizedBox(height: 32),
                  // Select item prompt
                  const Text(
                    'Select an item you want to verify',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
            ),
            const SizedBox(height: 16),
                  // Dropdown/Input Field with Thumbnail
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showItemSelectionDialog();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedItem ?? 'Image/screenshot',
                                      style: TextStyle(
                                        color: selectedItem != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImageWidget(_selectedImage!),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Show content when Image/screenshot is selected
                  if (selectedItem == 'Image/screenshot') ...[
                    if (!_verificationComplete) ...[
                      const SizedBox(height: 16),
                      // Image Upload Area
                      Container(
                        width: double.infinity,
                        height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            // Dashed border
                            CustomPaint(
                              size: const Size(double.infinity, 200),
                              painter: _DashedBorderPainter(
                                borderRadius: 12,
                              ),
                            ),
                            // Content
                            InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(12),
                              child: _selectedImage == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.cloud_upload,
                                          size: 64,
                                          color: AppColors.textPrimary,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Click to browse/ upload Image',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 15,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: _buildImageWidget(
                                            _selectedImage!,
                                            width: double.infinity,
                                            height: 200,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundDeep.withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
          icon: const Icon(
                                                Icons.close,
            color: AppColors.textPrimary,
          ),
                                            onPressed: () {
              setState(() {
                                                _selectedImage = null;
                                                _verificationComplete = false;
                                              });
                                            },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedImage == null
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
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Verification Results Section
                      const SizedBox(height: 32),
                      // Agent Response
                      Row(
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
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'RadarSafi Agent:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Agent Response Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Warning
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.cancel,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'This link is NOT legitimate.',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Database report
                            const Text(
                              'Our database shows this message has been reported 324 times as a scam campaign pretending to be from Naivas.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Confirmation
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.accentGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Naivas has confirmed on their official channels that they are not running any voucher promotion online.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Advice
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Advice: Do not click or forward the link. Delete it immediately.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Report Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _handleReport();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.outline,
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Report this Content?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Chat Input
                      Row(
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
                                controller: _chatController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Ask anything else?',
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
                                    onPressed: () {
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
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: AppColors.backgroundDeep,
                              ),
                              onPressed: () {
                                if (_chatController.text.trim().isNotEmpty) {
                                  // Handle send message
                                  _chatController.clear();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ] else if (selectedItem == 'Phone Number') ...[
                    // Phone Number Form
                    const SizedBox(height: 16),
                    // Phone Number Input Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Phone Number:',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1.5,
                              ),
                            ),
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Company Name Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Company Name:',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showCompanySelectionDialog();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedCompany ?? 'Select company',
                                      style: TextStyle(
                                        color: _selectedCompany != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Select Reason Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Select reason:',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showReasonSelectionDialog();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedReason ?? 'Select reason',
                                      style: TextStyle(
                                        color: _selectedReason != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_phoneVerificationComplete) ...[
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _phoneNumberController.text.trim().isEmpty ||
                                  _selectedCompany == null ||
                                  _selectedReason == null
                              ? null
                              : () {
                                  _handlePhoneNumberSubmit();
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
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Verification Results Section
                      const SizedBox(height: 32),
                      // Agent Response
                      Row(
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
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'RadarSafi Agent:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Agent Response Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.cancel,
                              color: AppColors.danger,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _phoneAgentResponse.isNotEmpty
                                    ? _phoneAgentResponse
                                    : 'Verifying...',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_phoneReportCount > 0) ...[
                        const SizedBox(height: 16),
                        // Report Count
                        Text(
                          'This phone number has been reported $_phoneReportCount times',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                      if (_phoneAdvice != null && _phoneAdvice!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Advice Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _phoneAdvice!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Report Button
                      SizedBox(
                        width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleReport();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Report this Phone Number?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                      ),
                    ],
                  ] else if (selectedItem == 'Email/Message') ...[
                    // Email/Message Form
                    const SizedBox(height: 16),
                    // Sender Email/Name Input Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Sender email address or message Sender name::',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _senderEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter sender email or name',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1.5,
                              ),
                            ),
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Paste Message content Input Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Paste Message content',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _emailMessageController,
                          maxLines: 6,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Paste full message or email body here...',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1.5,
                              ),
                            ),
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_emailMessageVerificationComplete) ...[
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _senderEmailController.text.trim().isEmpty ||
                                  _emailMessageController.text.trim().isEmpty
                              ? null
                              : () {
                                  _handleEmailMessageSubmit();
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
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Verification Results Section
                      const SizedBox(height: 32),
                      // Agent Response
                      Row(
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
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'RadarSafi Agent:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Agent Response Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _emailAgentResponse.toLowerCase().contains('scam') ||
                                      _emailAgentResponse.toLowerCase().contains('not legit')
                                  ? Icons.cancel
                                  : Icons.check_circle,
                              color: _emailAgentResponse.toLowerCase().contains('scam') ||
                                      _emailAgentResponse.toLowerCase().contains('not legit')
                                  ? AppColors.danger
                                  : AppColors.accentGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _emailAgentResponse.isNotEmpty
                                    ? _emailAgentResponse
                                    : 'Verifying...',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_emailReportCount > 0) ...[
                        const SizedBox(height: 16),
                        // Report Count
                        Text(
                          'This sender email has been reported $_emailReportCount times',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                      if (_emailAdvice != null && _emailAdvice!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Advice Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _emailAdvice!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Report Button
                      SizedBox(
                        width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleReport();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Report Sender email address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                      ),
                    ],
                  ] else if (selectedItem == 'web Link') ...[
                    // Link/URL Form
                    const SizedBox(height: 16),
                    // Web link Label and Input Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Web link:',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _linkController,
                          keyboardType: TextInputType.url,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Paste the link address',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.outline,
                                width: 1.5,
                              ),
                            ),
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_linkVerificationComplete) ...[
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _linkController.text.trim().isEmpty
                              ? null
                              : () {
                                  _handleLinkSubmit();
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
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // Verification Results Section
                      const SizedBox(height: 32),
                      // Agent Response
                      Row(
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
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'RadarSafi Agent:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Agent Response Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _linkAgentResponse.toLowerCase().contains('scam') ||
                                      _linkAgentResponse.toLowerCase().contains('not legitimate')
                                  ? Icons.cancel
                                  : Icons.check_circle,
                              color: _linkAgentResponse.toLowerCase().contains('scam') ||
                                      _linkAgentResponse.toLowerCase().contains('not legitimate')
                                  ? AppColors.danger
                                  : AppColors.accentGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _linkAgentResponse.isNotEmpty
                                    ? _linkAgentResponse
                                    : 'Verifying...',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_linkReportCount > 0) ...[
                        const SizedBox(height: 16),
                        // Report Count
                        Text(
                          'This link has been reported $_linkReportCount times',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                      if (_linkAdvice != null && _linkAdvice!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Advice Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outline,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _linkAdvice!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Report Button
                      SizedBox(
                        width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _handleReport();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Report this link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showItemSelectionDialog() {
    showModalBottomSheet(
      context: context,
          backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select an item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionItem('Email/Message', Icons.email),
              _buildOptionItem('web Link', Icons.link),
              _buildOptionItem('Image/screenshot', Icons.image),
              _buildOptionItem('Phone Number', Icons.phone),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentGreen),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: () {
        setState(() {
          selectedItem = title;
          // Reset verification state when changing item type
          _verificationComplete = false;
          _phoneVerificationComplete = false;
          _linkVerificationComplete = false;
          _emailMessageVerificationComplete = false;
          _selectedImage = null;
          _selectedCompany = null;
          _selectedReason = null;
          _linkController.clear();
          _emailMessageController.clear();
          _senderEmailController.clear();
          _emailAgentResponse = '';
          _emailReportCount = 0;
          _emailAdvice = null;
          _imageAgentResponse = '';
          _imageReportCount = 0;
          _imageAdvice = null;
          _linkAgentResponse = '';
          _linkReportCount = 0;
          _linkAdvice = null;
          _phoneAgentResponse = '';
          _phoneReportCount = 0;
          _phoneAdvice = null;
          // Set selectedType based on the item selected
          if (title == 'Phone Number') {
            selectedType = 'Phone Number';
          } else if (title == 'Image/screenshot') {
            selectedType = 'Image/screenshot';
          } else if (title == 'web Link') {
            selectedType = 'web Link';
          } else if (title == 'Email/Message') {
            selectedType = 'Email/Message';
          }
        });
        Navigator.pop(context);
      },
    );
  }

  void _handleSubmit() async {
    if (_selectedImage == null) return;

    setState(() {
      _isVerifying = true;
      _verificationComplete = false;
    });

    try {
      // Read image bytes
      final imageBytes = await _selectedImage!.readAsBytes();
      
      // Call verification service
      final result = await _verificationService.verifyImage(
        imageBytes: imageBytes,
        imageMimeType: 'image/jpeg',
      );

      setState(() {
        _isVerifying = false;
        _verificationComplete = true;
        _imageAgentResponse = result.agentResponse;
        _imageReportCount = result.reportCount;
        _imageAdvice = result.advice;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verificationComplete = true;
        _imageAgentResponse =
            'RadarSafi Agent: An error occurred during image verification. Please try again.';
        _imageReportCount = 0;
        _imageAdvice = 'Please verify the image through official channels.';
      });
    }
  }

  void _handlePhoneNumberSubmit() async {
    if (_phoneNumberController.text.trim().isEmpty ||
        _selectedCompany == null ||
        _selectedReason == null) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _phoneVerificationComplete = false;
    });

    try {
      // Call verification service
      final result = await _verificationService.verifyPhoneNumber(
        phoneNumber: _phoneNumberController.text.trim(),
        claimedCompany: _selectedCompany,
        reason: _selectedReason,
      );

      setState(() {
        _isVerifying = false;
        _phoneVerificationComplete = true;
        _phoneAgentResponse = result.agentResponse;
        _phoneReportCount = result.reportCount;
        _phoneAdvice = result.advice;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _phoneVerificationComplete = true;
        _phoneAgentResponse =
            'RadarSafi Agent: An error occurred during phone number verification. Please try again.';
        _phoneReportCount = 0;
        _phoneAdvice = 'Please verify the phone number through official channels.';
      });
    }
  }

  void _handleLinkSubmit() async {
    if (_linkController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _linkVerificationComplete = false;
    });

    try {
      // Call verification service
      final result = await _verificationService.verifyLink(
        url: _linkController.text.trim(),
      );

      setState(() {
        _isVerifying = false;
        _linkVerificationComplete = true;
        _linkAgentResponse = result.agentResponse;
        _linkReportCount = result.reportCount;
        _linkAdvice = result.advice;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _linkVerificationComplete = true;
        _linkAgentResponse =
            'RadarSafi Agent: An error occurred during link verification. Please try again.';
        _linkReportCount = 0;
        _linkAdvice = 'Please verify the link through official channels.';
      });
    }
  }

  void _handleEmailMessageSubmit() async {
    if (_senderEmailController.text.trim().isEmpty ||
        _emailMessageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _emailMessageVerificationComplete = false;
    });

    try {
      // Call verification service
      final result = await _verificationService.verifyEmailMessage(
        senderEmail: _senderEmailController.text.trim(),
        messageContent: _emailMessageController.text.trim(),
      );

      setState(() {
        _isVerifying = false;
        _emailMessageVerificationComplete = true;
        _emailAgentResponse = result.agentResponse;
        _emailReportCount = result.reportCount;
        _emailAdvice = result.advice;
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _emailMessageVerificationComplete = true;
        _emailAgentResponse =
            'RadarSafi Agent: An error occurred during verification. Please try again.';
        _emailReportCount = 0;
        _emailAdvice = 'Please verify the message through official channels.';
      });
    }
  }

  Future<void> _handleReport() async {
    try {
      Map<String, dynamic> reportData = {};
      Map<String, dynamic> verificationResult = {};
      String reportType = '';

      // Collect data based on report type
      if (selectedItem == 'Image/screenshot' && _verificationComplete) {
        reportType = 'Image';
        reportData = {
          'hasImage': _selectedImage != null,
          'imageName': _selectedImage?.name,
        };
        verificationResult = {
          'agentResponse': _imageAgentResponse,
          'reportCount': _imageReportCount,
          'advice': _imageAdvice ?? '',
        };
      } else if (selectedItem == 'Phone Number' && _phoneVerificationComplete) {
        reportType = 'Phone Number';
        reportData = {
          'phoneNumber': _phoneNumberController.text.trim(),
          'claimedInstitution': _selectedCompany ?? '',
          'reason': _selectedReason ?? '',
        };
        verificationResult = {
          'agentResponse': _phoneAgentResponse,
          'reportCount': _phoneReportCount,
          'advice': _phoneAdvice ?? '',
        };
      } else if (selectedItem == 'web Link' && _linkVerificationComplete) {
        reportType = 'Link';
        reportData = {
          'url': _linkController.text.trim(),
        };
        verificationResult = {
          'agentResponse': _linkAgentResponse,
          'reportCount': _linkReportCount,
          'advice': _linkAdvice ?? '',
        };
      } else if (selectedItem == 'Email/Message' && _emailMessageVerificationComplete) {
        reportType = 'Email/Message';
        reportData = {
          'senderEmail': _senderEmailController.text.trim(),
          'messageContent': _emailMessageController.text.trim(),
        };
        verificationResult = {
          'agentResponse': _emailAgentResponse,
          'reportCount': _emailReportCount,
          'advice': _emailAdvice ?? '',
        };
      } else {
        // No verification completed yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please verify the content first before reporting',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Save report to Firestore
      await _reportsService.saveReport(
        reportType: reportType,
        reportData: reportData,
        verificationResult: verificationResult,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'It has been reported successfully',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save report: ${e.toString()}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCompanySelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Company',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              _buildCompanyOption('KPLC Limited'),
              _buildCompanyOption('Safaricom'),
              _buildCompanyOption('Equity Bank'),
              _buildCompanyOption('M-Pesa'),
              _buildCompanyOption('Other'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompanyOption(String company) {
    return ListTile(
      title: Text(
        company,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: () {
        setState(() {
          _selectedCompany = company;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showReasonSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Reason',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              _buildReasonOption('Spam calling'),
              _buildReasonOption('Phishing attempt'),
              _buildReasonOption('Fraudulent activity'),
              _buildReasonOption('Suspicious behavior'),
              _buildReasonOption('Other'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReasonOption(String reason) {
    return ListTile(
      title: Text(
        reason,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildImageWidget(XFile image, {double? width, double? height}) {
    // Use XFile.readAsBytes() for both platforms - this avoids File type issues
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        } else if (snapshot.hasError) {
          return const Icon(Icons.error, color: AppColors.danger);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accentGreen,
            ),
          );
        }
      },
    );
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    // Show dialog to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.accentGreen),
              title: const Text(
                'Gallery',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.accentGreen),
              title: const Text(
                'Camera',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = image; // Store XFile on all platforms
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;

  _DashedBorderPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    // Draw dashed border
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      var distance = 0.0;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

