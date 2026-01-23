import 'package:cateryyx/Manager/Providers/ManagerProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/closed_event_model.dart';

class ClosedEventsScreen extends StatefulWidget {
  const ClosedEventsScreen({super.key});

  @override
  State<ClosedEventsScreen> createState() => _ClosedEventsScreenState();
}

class _ClosedEventsScreenState extends State<ClosedEventsScreen> {
  DateTime? selectedDate;


  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate = picked;
      context.read<ManagerProvider>().fetchClosedEvents(date: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ManagerProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Closed Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                selectedDate = null;
                provider.fetchClosedEvents();
              },
            ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ManagerProvider provider) {
    if (provider.isLoadingClosedEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.closedEventsList.isEmpty) {
      return const Center(
        child: Text(
          'No closed events found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.closedEventsList.length,
      itemBuilder: (context, index) {
        final event = provider.closedEventsList[index];
        return _ClosedEventCard(event: event);
      },
    );
  }
}
class _ClosedEventCard extends StatelessWidget {
  final ClosedEventModel event;

  const _ClosedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.eventName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            _infoRow(Icons.location_on, event.location),
            _infoRow(Icons.calendar_today, event.eventDate),
            _infoRow(Icons.lock_clock, 'Closed'),

          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
