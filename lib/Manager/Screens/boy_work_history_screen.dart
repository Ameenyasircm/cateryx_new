import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/ManagerProvider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoyWorkHistoryScreen extends StatelessWidget {
  final String boyId;
  final String boyName;

  const BoyWorkHistoryScreen({
    super.key,
    required this.boyId,
    required this.boyName,
  });

  static const primaryBlue = Color(0xff1A237E);
  static const primaryOrange = Color(0xffE65100);

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Work History",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
                Text(
                  boyName,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            backgroundColor: primaryBlue,
          ),
          body: state.isLoadingWrkHistory
              ? const Center(child: CircularProgressIndicator())
              : state.workHistory.isEmpty
              ? _buildEmptyState()
              : _buildWorkList(context),

        );
      },
    );
  }

  /// 📭 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No Work History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This boy has no confirmed works yet",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// 📋 Work List
  Widget _buildWorkList(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, mnPro, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await mnPro.fetchBoyWorkHistory(boyId);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mnPro.workHistory.length,
            itemBuilder: (context, index) {
              final work = mnPro.workHistory[index];
              return _buildWorkCard(work);
            },
          ),
        );
      },
    );
  }

  /// 🎴 Work Card
  Widget _buildWorkCard(Map<String, dynamic> work) {
    final eventStatus = work['EVENT_STATUS'] ?? 'UPCOMING';
    final attendanceStatus =
        work['ATTENDANCE_STATUS'] ?? 'PENDING';

    Color statusColor = Colors.orange;

    if (eventStatus == 'COMPLETED') {
      statusColor = Colors.green;
    } else if (eventStatus == 'CANCELLED') {
      statusColor = Colors.red;
    } else if (eventStatus == 'ONGOING') {
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event,
                    color: primaryBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    work['EVENT_NAME'] ?? 'Event',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    eventStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _detailRow(Icons.calendar_today, 'Event Date',
                    work['EVENT_DATE'] ?? '-'),
                _detailRow(Icons.location_on, 'Location',
                    work['LOCATION_NAME'] ?? '-'),
                _detailRow(Icons.restaurant, 'Meal Type',
                    work['MEAL_TYPE'] ?? '-'),
                _detailRow(Icons.people, 'Boys Required',
                    '${work['BOYS_REQUIRED'] ?? 0}'),
                _detailRow(Icons.check_circle_outline, 'Work Status',
                    work['STATUS'] ?? '-'),
                _detailRow(Icons.accessibility, 'Attendance',
                    attendanceStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Detail Row
  Widget _detailRow(
      IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(
                    color: Colors.black87, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
