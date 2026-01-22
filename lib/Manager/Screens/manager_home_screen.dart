
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Boys/Providers/boys_provider.dart';
import '../../Boys/Screens/boy_registration.dart';
import '../../Constants/my_functions.dart';
import '../Providers/EventDetailProvider.dart';
import '../Providers/ManagerProvider.dart';
import 'create_new_event.dart';
import 'event_details_screen.dart';

class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ManagerProvider managerProvider = Provider.of<ManagerProvider>(context);
    BoysProvider boysProvider = Provider.of<BoysProvider>(context);
    EventDetailsProvider eventDetailsProvider = Provider.of<EventDetailsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/Logo.png',
          height: 40,
        ),
      ),
      body: Column(
        children: [

          /// 🔹 ACTION BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      boysProvider.clearBoyForm();
                      callNext(
                         RegisterBoyScreen(registeredBy: 'MANAGER'),
                        context,
                      );
                    },
                    icon: const Icon(Icons.add, color: Color(0xffE65100)),
                    label: const Text(
                      "Add Boys",
                      style: TextStyle(color: Color(0xffE65100)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xffE65100)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      managerProvider.clearEventRegScreens();
                      callNext( CreateEventScreen(), context);
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Create Event",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffE65100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 TAB BAR (RUNNING FIRST)
          _buildTabBar(context),

          /// 🔹 EVENT LIST
          Expanded(
            child: Consumer<ManagerProvider>(
              builder: (context, provider, _) {
                final events = provider.selectedTabIndex == 0
                    ? provider.runningEventsList
                    : provider.upcomingEventsList;

                if (events.isEmpty) {
                  return const Center(
                    child: Text(
                      "No events found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return InkWell(
                      onTap: () {
                        eventDetailsProvider.fetchConfirmedBoys(event.eventId);
                        eventDetailsProvider.setEventModelData(event);
                        eventDetailsProvider.fetchSiteCaptain(event.eventId);
                        callNext(
                          EventDetailedScreen(eventID: event.eventId,),
                          context,
                        );
                      },
                      child: _buildEventCard(
                        date: event.eventDate,
                        title: event.eventName,
                        boys: event.boysRequired.toString(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 CUSTOM TAB BAR
  Widget _buildTabBar(BuildContext context) {
    final provider = Provider.of<ManagerProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          /// RUNNING EVENTS (INDEX 0)
          _tabItem(
            title: "Confirmed Events",
            isSelected: provider.selectedTabIndex == 0,
            onTap: () {
              provider.fetchRunningEvents();
              provider.setTabIndex(0);
            },
          ),

          /// UPCOMING EVENTS (INDEX 1)
          _tabItem(
            title: "Upcoming Events",
            isSelected: provider.selectedTabIndex == 1,
            onTap: () {
              provider.fetchUpcomingEvents();
              provider.setTabIndex(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xff1A237E) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 140 : 0,
            color: const Color(0xff1A237E),
          ),
        ],
      ),
    );
  }

  /// 🔹 EVENT CARD
  Widget _buildEventCard({
    required String date,
    required String title,
    required String boys,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                boys,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Boys",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
