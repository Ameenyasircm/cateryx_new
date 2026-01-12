import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailsProvider extends ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool isLoading = false;
  Map<String, dynamic>? eventData;
  List<Map<String, dynamic>> confirmedBoys = [];

  Future<void> fetchEventDetails(String eventId) async {
    try {
      isLoading = true;
      notifyListeners();

      final eventDoc = await db.collection('EVENTS').doc(eventId).get();

      if (!eventDoc.exists) {
        eventData = null;
        confirmedBoys = [];
        return;
      }

      final data = eventDoc.data() ?? {};

      // 🔐 Normalize data (VERY IMPORTANT)
      eventData = {
        'EVENT_NAME': data['EVENT_NAME'] ?? '',
        'LOCATION_NAME': data['LOCATION_NAME'] ?? '',
        'DESCRIPTION': data['DESCRIPTION'] ?? '',
        'EVENT_DATE': data['EVENT_DATE'] ?? '',
        'BOYS_TAKEN': data['BOYS_TAKEN'] ?? 0,
        'BOYS_REQUIRED': data['BOYS_REQUIRED'] ?? 0,
        'NOTES': List<String>.from(data['NOTES'] ?? []),
      };

      final boysSnap = await db
          .collection('EVENTS')
          .doc(eventId)
          .collection('CONFIRMED_BOYS')
          .orderBy('CONFIRMED_AT', descending: false)
          .get();

      confirmedBoys =
          boysSnap.docs.map((e) => e.data()).toList();
    } catch (e) {
      debugPrint('Error fetching event details: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String eventId, String note) async {
    try {
      await db.collection('EVENTS').doc(eventId).update({
        'NOTES': FieldValue.arrayUnion([note]),
      });

      // ✅ Update local state safely
      final List<String> notes =
      List<String>.from(eventData?['NOTES'] ?? []);
      notes.add(note);

      eventData?['NOTES'] = notes;

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note: $e');
    }
  }
}
