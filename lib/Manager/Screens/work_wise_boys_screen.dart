import 'package:cateryyx/Constants/my_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/work_manage_boys_utils.dart';
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
    double height=MediaQuery.of(context).size.height;
    double width=MediaQuery.of(context).size.width;
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
        builder: (context555, provider, _) {
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
                  InkWell(
                    onTap: (){
                      showBoySearchDialog(context,eventId,eventDetailsProvider);
                    },
                    child: Container(
                      height: 40,width: width,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(child: Text('Add Boy',
                      style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _label("Site Captain"),
                  InkWell(
                    onTap: () {
                      if (provider.confirmedBoysList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No boys available to assign as captain"),
                          ),
                        );
                        return;
                      }

                      showSelectCaptainDialog(context, provider, eventId);
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Captain Name / Choose Captain
                          Text(
                            provider.siteCaptainName.isEmpty
                                ? "Choose Captain"
                                : "Captain: ${provider.siteCaptainName}",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          Row(
                            children: [
                              /// DELETE ICON only if captain exists
                              if (provider.siteCaptainId.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    showRemoveCaptainConfirmation(eventId,context, provider);
                                  },
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),

                              const SizedBox(width: 8),

                              const Icon(Icons.arrow_drop_down, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                itemBuilder: (contexted, index) {
                  final boy = provider.confirmedBoysList[index];

                  return InkWell(
                    onLongPress: (){
                      showDeleteBoyDialog(context,eventId,boy.boyId,boy.boyName,eventDetailsProvider);
                    },
                    child: Container(
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

void showBoySearchDialog(BuildContext context, String eventId,EventDetailsProvider eventDetailsProvider) {
  String searchText = "";
  List<Map<String, dynamic>> results = [];

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (contextlll, setState) {
          return AlertDialog(
            title: Text("Search Boy"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search by name or phone",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) async {
                    searchText = value;
                    if (searchText.length > 1) {
                      results = await eventDetailsProvider.searchBoys(searchText);
                    } else {
                      results = [];
                    }
                    setState(() {});
                  },
                ),

                SizedBox(height: 10),

                SizedBox(
                  height: 250,
                  width: double.maxFinite,
                  child: results.isEmpty
                      ? Center(child: Text("No results"))
                      : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (ctx, i) {
                      final boy = results[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(boy['NAME'][0]),
                        ),
                        title: Text(boy['NAME']),
                        subtitle: Text(boy['PHONE']),
                        onTap: () {
                          Navigator.pop(context);
                          showConfirmAddBoyDialog(
                            context,
                            eventId,
                            boy['BOY_ID'],
                            boy['NAME'],eventDetailsProvider,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showConfirmAddBoyDialog(
    BuildContext context, String eventId, String boyId, String boyName,EventDetailsProvider eventDetailsProvider) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Confirm Assign"),
      content: Text("Do you want to add $boyName to this work?"),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        Consumer<EventDetailsProvider>(
          builder: (contextll,val,chillld) {
            return val.addBoyBool
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              child: Text("Add Boy"),
              onPressed: () async {
                try {
                  await eventDetailsProvider.managerAssignBoyToEvent(eventId, boyId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$boyName added successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  finish(context);
                } catch (e) {
                  String msg = e.toString();

                  msg = msg.replaceAll("Exception:", "").trim();

                  if (msg.contains("Boy already added")) {
                    msg = "This boy is already added";
                  } else if (msg.contains("Already assigned")) {
                    msg = "This boy already has this work";
                  } else if (msg.contains("All slots filled")) {
                    msg = "All required slots are already filled";
                  } else if (msg.contains("Boy not found")) {
                    msg = "Boy not found";
                  } else {
                    msg = "Something went wrong";
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        )
,
      ],
    ),
  );
}
void showDeleteBoyDialog(
    BuildContext context,
    String eventId,
    String boyId,
    String boyName,
    EventDetailsProvider provider,
    ) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Remove Boy"),
      content: Text("Do you want to remove $boyName from this work?"),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        Consumer<EventDetailsProvider>(
          builder: (contextd,vaall,child) {
            return
            vaall.removeBoyLoader?
               const Center(child: CircularProgressIndicator()):

              ElevatedButton(
              child: Text("Remove"),
              onPressed: () async {
                await provider.removeBoyFromEvent(eventId, boyId,context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$boyName removed from work")),
                );
              },
            );
          }
        ),
      ],
    ),
  );
}

void showSelectCaptainDialog(
    BuildContext context,
    EventDetailsProvider provider,
    String eventId,
    ) {
  TextEditingController searchController = TextEditingController();

  List filteredList = provider.confirmedBoysList;
  String? selectedBoyId = provider.siteCaptainId; // preselect if exists

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Site Captain",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// 🔍 SEARCH BOX
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search boys...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (query) {
                      setState(() {
                        filteredList = provider.confirmedBoysList
                            .where((boy) =>
                        boy.boyName
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                            boy.boyPhone.contains(query))
                            .toList();
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// LIST OF BOYS (SCROLLABLE)
                  SizedBox(
                    height: 350,
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final boy = filteredList[index];

                        bool isSelected = selectedBoyId == boy.boyId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedBoyId = boy.boyId;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(boy.boyName),
                              subtitle: Text(boy.boyPhone),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (selectedBoyId == null ||
                            selectedBoyId!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text("Please select a captain first")),
                          );
                          return;
                        }

                        /// Confirm before saving
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Confirm Captain"),
                            content: Text(
                                "Assign ${filteredList.firstWhere((b) => b.boyId == selectedBoyId).boyName} as Site Captain?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context); // close confirm
                                  Navigator.pop(context); // close dialog

                                  final selectedBoy =
                                  filteredList.firstWhere(
                                          (b) => b.boyId == selectedBoyId);

                                  await provider.assignSiteCaptain(
                                    boyId: selectedBoy.boyId,
                                    boyName: selectedBoy.boyName,
                                    currentEventId: eventId,
                                  );
                                },
                                child: const Text(
                                  "Assign",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        "Save Captain",
                        style:
                        TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xff1A237E),
      ),
    ),
  );
}
void showRemoveCaptainConfirmation(String eventID,
    BuildContext context, EventDetailsProvider provider) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Remove Captain?"),
      content: Text(
        "Are you sure you want to remove ${provider.siteCaptainName} "
            "as the site captain?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await provider.removeSiteCaptain(eventID);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Site Captain removed")),
            );
          },
          child: const Text(
            "Remove",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
