import 'package:cloud_firestore/cloud_firestore.dart';
import '../Manager/Models/event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all events
  Future<List<EventModel>> fetchAllEvents() async {
    try {
      final snapshot = await _db
          .collection('EVENTS')
          .where('EVENT_STATUS',isEqualTo: 'UPCOMING')
          .orderBy('EVENT_DATE_TS', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch upcoming events
  Future<List<EventModel>> fetchUpcomingEvents(String userId) async {
    try {
      // 1️⃣ Get today's UTC start
      final nowUtc = DateTime.now().toUtc();
      final startOfTodayUtc =
      DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

      // 2️⃣ Fetch upcoming events
      final eventsSnapshot = await _db
          .collection('EVENTS')
          .where(
        'EVENT_DATE_TS',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(startOfTodayUtc),).where('WORK_ACTIVE_STATUS',isEqualTo: 'ACTIVE')
          .orderBy('EVENT_DATE_TS')
          .get();

      final events = eventsSnapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();

      // 3️⃣ Fetch confirmed works of this boy
      final confirmedSnapshot = await _db
          .collection('BOYS')
          .doc(userId)
          .collection('CONFIRMED_WORKS')
          .get();

      final confirmedEventIds =
      confirmedSnapshot.docs.map((d) => d.id).toSet();

      // 4️⃣ Remove already confirmed events
      events.removeWhere(
            (event) => confirmedEventIds.contains(event.eventId),
      );

      return events;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    }
  }


  /// Take a work
  Future<void> takeWork(String eventId, String boyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String boyName = prefs.getString('boyName') ?? '';
      final String boyPhone = prefs.getString('boyPhone') ?? '';
      print("sssssssssssssss $boyId  $eventId");
      
      if (boyId.isEmpty) throw Exception('Boy not logged in');

      final eventRef = _db.collection('EVENTS').doc(eventId);
      final confirmedBoyRef = eventRef.collection('CONFIRMED_BOYS').doc(boyId);
      final boyWorkRef = _db
          .collection('BOYS')
          .doc(boyId)
          .collection('CONFIRMED_WORKS')
          .doc(eventId);

      await _db.runTransaction((transaction) async {
        // Read event document
        final eventSnap = await transaction.get(eventRef);
        if (!eventSnap.exists) throw Exception('Event not found');

        final data = eventSnap.data()!;
        final int required = data['BOYS_REQUIRED'] ?? 0;
        final int taken = data['BOYS_TAKEN'] ?? 0;

        if (taken >= required) throw Exception('All slots filled');

        // Check duplicates (sequentially, to keep the transaction simple)
        final confirmedBoySnap = await transaction.get(confirmedBoyRef);
        final boyWorkSnap = await transaction.get(boyWorkRef);

        if (confirmedBoySnap.exists) throw Exception('Already took this work');
        if (boyWorkSnap.exists) throw Exception('Work already exists');

        final updatedTaken = taken + 1;

        // Update event TAKEN COUNT
        final updateData = <String, dynamic>{
          'BOYS_TAKEN': updatedTaken,
        };
        if (updatedTaken == required) {
          updateData['BOYS_STATUS'] = 'FULL';
        }
        transaction.update(eventRef, updateData);

        /// -----------------------------------------------------------------
        /// 🚀 STORE ONLY MINIMUM, IMPORTANT EVENT DATA
        /// -----------------------------------------------------------------
        final minimalEventData = {
          'EVENT_ID': eventId,
          'BOY_ID': boyId,

          // Boy details
          'BOY_NAME': boyName,
          'BOY_PHONE': boyPhone,

          // Status
          'STATUS': 'CONFIRMED',
          'ATTENDANCE_STATUS': 'PENDING',
          'CONFIRMED_AT': FieldValue.serverTimestamp(),

          // ⬇️ Only these four event fields will be saved
          'EVENT_NAME': data['EVENT_NAME'],
          'EVENT_DATE': data['EVENT_DATE'],
          'EVENT_DATE_TS': data['EVENT_DATE_TS'],
          'LOCATION_NAME': data['LOCATION_NAME'],
          'LATITUDE': data['LATITUDE'],
          'LONGITUDE': data['LONGITUDE'],
          'MEAL_TYPE': data['MEAL_TYPE'],
          'CLIENT_NAME': data['CLIENT_NAME'],
        };

        // EVENTS → CONFIRMED_BOYS
        transaction.set(confirmedBoyRef, minimalEventData);

        // BOYS → CONFIRMED_WORKS
        transaction.set(boyWorkRef, minimalEventData);
        await fetchUpcomingEvents(boyId);
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Error taking work: $e');
    }
  }

  Future<List<EventModel>> fetchConfirmedWorks(String userId) async {
    try {
      final snapshot = await _db
          .collection('BOYS')
          .doc(userId)
          .collection('CONFIRMED_WORKS')
          .orderBy('CONFIRMED_AT', descending: true)
          .get();

      final results = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();

        final eventId = data['EVENT_ID'];
        if (eventId == null || eventId.toString().isEmpty) return null;

        final eventDoc = await _db.collection('EVENTS').doc(eventId).get();
        if (!eventDoc.exists) return null;

        final eventData = eventDoc.data() as Map<String, dynamic>?;
        if (eventData == null) return null;

        final status = eventData['STATUS'];
        if (status == 'CLOSED') return null;

        // ✅ return Event data
        return EventModel.fromMap(eventData);
      }));

      return results.whereType<EventModel>().toList();
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }







}
