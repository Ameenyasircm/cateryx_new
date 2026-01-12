import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/EventDetailProvider.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventDetailsProvider()..fetchEventDetails(eventId),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Light background for contrast
        appBar: AppBar(
          title: const Text("Event Details", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: Consumer<EventDetailsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }

            final event = provider.eventData;
            if (event == null || event.isEmpty) {
              return const Center(child: Text("Event data not found"));
            }

            final notes = (event['NOTES'] as List?) ?? [];

            return Column(
              children: [
                _eventHeader(event),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Confirmed Crew", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                _boysList(provider.confirmedBoys),
                _notesSection(context, provider, eventId, notes),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _eventHeader(Map<String, dynamic> event) {
    final boysTaken = event['BOYS_TAKEN'] ?? 0;
    final boysRequired = event['BOYS_REQUIRED'] ?? 1; // Avoid div by zero
    final progress = (boysTaken / boysRequired).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E), // Deep navy matching your logo feel
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  event['EVENT_NAME']?.toString().toUpperCase() ?? 'EVENT',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
            ],
          ),
          Text(event['LOCATION_NAME']?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            "Target: $boysTaken / $boysRequired Boys",
            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.orange,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _boysList(List<Map<String, dynamic>> boys) {
    return Expanded(
      child: boys.isEmpty
          ? const Center(child: Text("No crew assigned yet"))
          : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: boys.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final boy = boys[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE0B2),
              child: Icon(Icons.person, color: Colors.orange),
            ),
            title: Text(boy['BOY_NAME'] ?? 'Crew Member', style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(boy['BOY_PHONE'] ?? 'No Phone'),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green, size: 20),
              onPressed: () { /* Add URL Launcher logic */ },
            ),
          );
        },
      ),
    );
  }

// Update the _notesSection in your EventDetailScreen

  Widget _notesSection(BuildContext context, EventDetailsProvider provider,
      String eventId, List notes) {
    final TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Keeps it compact
        children: [
          // Header for Notes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Work Notes (${notes.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (notes.isNotEmpty)
                TextButton(
                  onPressed: () => _showAllNotes(context, notes),
                  child: const Text("View Full Notes"),
                ),
            ],
          ),

          // Preview of the latest note (if any)
          if (notes.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notes.last,
                maxLines: 3, // Show only first 3 lines in preview
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),

          // Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null, // Allows the input to grow as they type
                  decoration: InputDecoration(
                    hintText: "Write a note...",
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                backgroundColor: Colors.orange,
                elevation: 0,
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    provider.addNote(eventId, controller.text.trim());
                    controller.clear();
                  }
                },
                child: const Icon(Icons.send, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }

// Helper function to show very long notes in a scrollable bottom sheet
  void _showAllNotes(BuildContext context, List notes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Text("Event Instructions & Notes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const Divider(height: 30),
                    itemBuilder: (context, index) => SelectableText(
                      notes[index],
                      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }}