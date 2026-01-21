import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';

import '../../Constants/appConfig.dart';
import '../Providers/ManagerProvider.dart';
import 'map_pick_screen.dart';

class CreateEventScreen extends StatelessWidget {
   CreateEventScreen({Key? key}) : super(key: key);
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xff1A237E);
    const primaryOrange = Color(0xffE65100);

    return Consumer<ManagerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: primaryBlue),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Create Event",
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _label("Event Name"),
                  _textField(
                    provider.nameController,
                    "Enter event name",
                    Icons.event,
                  ),

                  const SizedBox(height: 15),

                  _label("Event Date"),
                  TextFormField(
                    controller: provider.dateController,
                    readOnly: true,
                    onTap: () => provider.selectDate(context),
                    decoration: _decoration(
                      "Select Date",
                      Icons.calendar_today,
                    ),
                    validator: (v) => v!.isEmpty ? "Required field" : null,
                  ),

                  const SizedBox(height: 15),

                  _label("Select Meal Type"),
                  DropdownButtonFormField<String>(
                    value: provider.selectedMeal,
                    decoration: _decoration("", Icons.restaurant_menu),
                    items: ['Breakfast', 'Lunch', 'Dinner']
                        .map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => provider.changeMeal(v!),
                  ),

                  const SizedBox(height: 15),

                  _label("Location"),
                  TextFormField(
                    controller: provider.locationController,
                    readOnly: true,
                    decoration: _decoration(
                      "Add location from map",
                      Icons.map_outlined,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xffE65100)),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                          );

                          if (result != null) {
                            provider.setLocation(
                              address: result['address'],
                              lat: result['lat'],
                              lng: result['lng'],
                            );
                          }
                        },
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? "Required field" : null,
                  ),

                  const SizedBox(height: 15),
                  _label("Publish Event"),

                Wrap(
                  spacing: 12,
                  children: [
                    ChoiceChip(
                      label: const Text("Publish Now"),
                      selected: provider.publishType == PublishType.now,
                      selectedColor: const Color(0xffE65100),
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: provider.publishType == PublishType.now
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          provider.changePublishType(PublishType.now),
                    ),
                    ChoiceChip(
                      label: const Text("Publish Later"),
                      selected: provider.publishType == PublishType.later,
                      selectedColor: const Color(0xffE65100),
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: provider.publishType == PublishType.later
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) =>
                          provider.changePublishType(PublishType.later),
                    ),
                  ],
                ),
                  const SizedBox(height: 15),

                  _label("Number of Boys Required"),
                  _textField(
                    provider.boysController,
                    "e.g. 20",
                    Icons.people,
                    keyboard: TextInputType.number,
                  ),

                  const SizedBox(height: 15),

                  _label("Description"),
                  _textField(
                    provider.descController,
                    "Enter details...",
                    Icons.description,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (){
                        if (!formKey.currentState!.validate()) return;
                        provider.createEventFun(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Create Event",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ---------- UI Helpers ----------

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

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xff1A237E), size: 20),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
    );
  }

  Widget _textField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType keyboard = TextInputType.text,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: _decoration(hint, icon),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}
