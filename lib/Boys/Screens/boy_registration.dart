import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/boys_provider.dart';

class RegisterBoyScreen extends StatelessWidget {
  String registeredBy;
  RegisterBoyScreen({Key? key,required this.registeredBy}) : super(key: key);

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xff1A237E);
    const primaryOrange = Color(0xffE65100);

    return Consumer<BoysProvider>(
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
              "Register New Boy",
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

                  _label("Boy Name"),
                  _textField(
                    provider.boyNameController,
                    "Enter full name",
                    Icons.person,
                  ),

                  const SizedBox(height: 15),

                  _label("Phone Number"),
                  _textField(
                    provider.phoneController,
                    "10 digit mobile number",
                    Icons.phone,
                    keyboard: TextInputType.phone,
                    maxLength: 10,
                  ),

                  const SizedBox(height: 15),

                  _label("Guardian Contact"),
                  _textField(
                    provider.guardianController,
                    "Guardian phone number",
                    Icons.call,
                    keyboard: TextInputType.phone,
                    maxLength: 10,
                  ),

                  const SizedBox(height: 15),

                  _label("Date of Birth"),
                  TextFormField(
                    controller: provider.dobController,
                    readOnly: true,
                    onTap: () => provider.selectDob(context),
                    decoration: _decoration(
                      "Select DOB",
                      Icons.calendar_today,
                    ),
                    validator: (v) => v!.isEmpty ? "Required field" : null,
                  ),

                  const SizedBox(height: 15),

                  _label("Blood Group"),
                  DropdownButtonFormField<String>(
                    value: provider.selectedBloodGroup,
                    decoration: _decoration("", Icons.bloodtype),
                    items: [
                      "A+","A-","B+","B-","O+","O-","AB+","AB-"
                    ].map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    )).toList(),
                    onChanged: (v) => provider.changeBloodGroup(v!),
                    validator: (v) => v == null ? "Select blood group" : null,
                  ),

                  const SizedBox(height: 15),

                  _label("Place"),
                  _textField(
                    provider.placeController,
                    "Enter place",
                    Icons.location_city,
                  ),

                  const SizedBox(height: 15),

                  _label("District"),
                  _textField(
                    provider.districtController,
                    "Enter district",
                    Icons.map,
                  ),

                  const SizedBox(height: 15),

                  _label("Pin Code"),
                  _textField(
                    provider.pinController,
                    "6 digit pin code",
                    Icons.pin,
                    keyboard: TextInputType.number,
                    maxLength: 6,
                  ),

                  const SizedBox(height: 15),

                  _label("Address"),
                  _textField(
                    provider.addressController,
                    "Full address",
                    Icons.home,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        provider.registerNewBoyFun(context,registeredBy);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 17,
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
        int? maxLength,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: _decoration(hint, icon),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}
