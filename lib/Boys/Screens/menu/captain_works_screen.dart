import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:cateryyx/Manager/Providers/EventDetailProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Constants/my_functions.dart';
import '../../../Manager/Screens/event_details_screen.dart';


class CaptainEventsScreen extends StatelessWidget {
  final String captainId;
  final String captainName;

  const CaptainEventsScreen({
    Key? key,
    required this.captainId,
    required this.captainName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EventDetailsProvider provider = Provider.of<EventDetailsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Captain: $captainName"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Consumer<EventDetailsProvider>(
        builder: (context, p, _) {

          if (p.isCaptainLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (p.captainEventsList.isEmpty) {
            return const Center(
              child: Text("No assigned works found"),
            );
          }

          return ListView.builder(
            itemCount: p.captainEventsList.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final event = p.captainEventsList[index];

              return InkWell(
                onTap: () {
                  provider.setEventModelData(event);
                  callNext(
                    EventDetailedScreen(eventID: event.eventId),
                    context,
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 40, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.eventName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              event.eventDate,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${event.boysRequired}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
