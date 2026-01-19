import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Providers/EventDetailProvider.dart';

class EventAllBoys extends StatelessWidget {
  final String eventId,eventLocation,eventDate;

  const EventAllBoys({super.key
    ,required this.eventId
    ,required this.eventLocation
    ,required this.eventDate
  });

  void _callNumber(String phone) async {
    final Uri url = Uri(scheme: "tel", path: phone);
    await launchUrl(url);
  }

  void _openWhatsApp(String phone) async {
    final Uri url = Uri.parse("https://wa.me/$phone");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    EventDetailsProvider eventDetailsProvider = Provider.of<EventDetailsProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title:  Text('Event Details'),
        actions: [
          InkWell(
              onTap: (){
                eventDetailsProvider.copyEventDetails(eventLocation,eventDate,context);
              },
              child: Icon(Icons.copy))
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body: Consumer<EventDetailsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // EVENT INFORMATION TOP SECTION
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("SITE :", eventLocation),
                  _infoRow("WORK DATE :", eventDate),

                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),

                  const Text(
                    "Confirmed Boys",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

              // 🔽 BOYS LIST
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.confirmedBoysList.length,
                itemBuilder: (context, index) {
                  final boy = provider.confirmedBoysList[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          child: Icon(Icons.person, size: 28),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            "${index + 1}. ${boy.boyName} - ${boy.boyPhone}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => _callNumber(boy.boyPhone),
                          icon: const Icon(Icons.call, color: Colors.green),
                        ),
                        IconButton(
                          onPressed: () => _openWhatsApp(boy.boyPhone),
                          icon: Image.asset('assets/whsp.png',
                              color: Colors.teal, scale: 8),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
      ],
    ),
  );
}
