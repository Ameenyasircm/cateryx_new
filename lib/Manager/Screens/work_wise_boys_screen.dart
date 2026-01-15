import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/EventDetailProvider.dart';

class EventAllBoys extends StatelessWidget {
  final String eventId;

  const EventAllBoys({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Boys'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {

          /// 🔹 Loading
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// 🔹 Empty state
          if (provider.confirmedBoysList.isEmpty) {
            return const Center(
              child: Text(
                'No boys assigned to this event',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          /// 🔹 List
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.confirmedBoysList.length,
            itemBuilder: (context, index) {
              final boy = provider.confirmedBoysList[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [

                    /// Avatar
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),

                    const SizedBox(width: 12),

                    /// Name & Phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boy.boyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            boy.boyPhone,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        boy.status,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
