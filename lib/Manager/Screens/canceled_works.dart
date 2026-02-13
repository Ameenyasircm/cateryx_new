import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/event_model.dart';


class CanceledWorksScreen extends StatelessWidget {
  const CanceledWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventDetailsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Canceled Works"),
        backgroundColor: Colors.red,
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.canceledList.isEmpty
          ? const Center(
        child: Text(
          "No Canceled Works Available",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.canceledList.length,
        itemBuilder: (context, index) {
          EventModel event = provider.canceledList[index];

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                event.eventName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("ID: ${event.eventId}"),
                  Text("Date: ${event.eventDate}"),
                  Text("Client: ${event.clientName}"),
                ],
              ),
              trailing: const Icon(Icons.block, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
