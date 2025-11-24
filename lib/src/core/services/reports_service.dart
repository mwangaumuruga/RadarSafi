import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing reports in Firestore
class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a report to Firestore
  Future<void> saveReport({
    required String reportType, // 'Image', 'Phone Number', 'Link', 'Email/Message'
    required Map<String, dynamic> reportData,
    required Map<String, dynamic> verificationResult,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be logged in to submit reports';
      }

      final report = {
        'userId': user.uid,
        'userEmail': user.email,
        'reportType': reportType,
        'reportData': reportData,
        'verificationResult': verificationResult,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, reviewed, resolved
      };

      await _firestore.collection('reports').add(report);
    } catch (e) {
      throw 'Failed to save report: ${e.toString()}';
    }
  }

  /// Get reports for the current user
  Stream<List<Map<String, dynamic>>> getUserReports() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
              };
            }).toList());
  }

  /// Get all reports (for admin purposes)
  Stream<List<Map<String, dynamic>>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                ...data,
                'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
              };
            }).toList());
  }

  /// Get report statistics
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final snapshot = await _firestore.collection('reports').get();
      
      final totalReports = snapshot.docs.length;
      final reportsByType = <String, int>{};
      final reportsByStatus = <String, int>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['reportType'] as String? ?? 'Unknown';
        final status = data['status'] as String? ?? 'pending';
        
        reportsByType[type] = (reportsByType[type] ?? 0) + 1;
        reportsByStatus[status] = (reportsByStatus[status] ?? 0) + 1;
      }
      
      return {
        'totalReports': totalReports,
        'reportsByType': reportsByType,
        'reportsByStatus': reportsByStatus,
      };
    } catch (e) {
      throw 'Failed to get statistics: ${e.toString()}';
    }
  }
}

