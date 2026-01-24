import 'package:cateryyx/Manager/Providers/ManagerProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/colors.dart';
import '../../Constants/my_functions.dart';
import '../../core/theme/app_typography.dart';
import '../Models/closed_event_model.dart';
import '../Providers/EventDetailProvider.dart';
import 'closed_event_details_screen.dart';

class ClosedEventsScreen extends StatelessWidget {
  const ClosedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventDetailsProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor:blue7E,
        title:  Text('Closed Events',style: AppTypography.body1.copyWith(
            color: Colors.white
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today,color: Colors.white,),
            onPressed: (){
              provider.pickDate(context);
            },
          ),
          if (provider.selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear,color: Colors.white,),
              onPressed: () {
                provider.selectedDate = null;
                provider.fetchClosedEvents();
              },
            ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(EventDetailsProvider provider) {
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
        return InkWell(
            onTap: (){
              provider.setClosedEventModelData(event);
              callNext(ClosedEventDetailsScreen(), context);
            },
            child: _ClosedEventCard(event: event));
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
