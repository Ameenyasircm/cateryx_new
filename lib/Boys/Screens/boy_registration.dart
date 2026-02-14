import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/utils/snackBarNotifications/snackBar_notifications.dart';
import '../Providers/boys_provider.dart';

class RegisterBoyScreen extends StatelessWidget {
  final String registeredBy;
  RegisterBoyScreen({super.key,required this.registeredBy});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xff1A237E);
    const primaryOrange = Color(0xffE65100);

    return Consumer<BoysProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
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
                  Center(child: _boyPhotoUpload()),
                  const SizedBox(height: 15),
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

                  if (registeredBy == "MANAGER") ...[
                    const SizedBox(height: 15),
                    _label("Wage (Manager Entry)"),
                    _textField(
                      provider.wageController,
                      "Enter wage amount",
                      Icons.currency_rupee,
                      keyboard: TextInputType.number,
                    ),
                  ],

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
                  GestureDetector(
                    onTap: () async {
                      // Show Cupertino Date Picker here
                      DateTime? pickedDate = await showCupertinoModalPopup<DateTime>(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: Text("Select DOB"),
                            actions: <Widget>[
                              SizedBox(
                                height: 300, // or any fixed height you want
                                child: CupertinoDatePicker(

                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: DateTime(2007, 1, 1), // you can adjust this
                                  minimumDate: DateTime(1985, 1, 1),
                                  maximumDate:  DateTime(2007, 1, 1),
                                  onDateTimeChanged: (DateTime newDate) {

                                    provider.dateSetting(newDate);

                                  },
                                ),
                              ),
                              CupertinoDialogAction(
                                child: Text("Done"),
                                onPressed: () {
                                  Navigator.pop(context); // Close the date picker
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFF9F9F9),
                            width: 3),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                provider.dobController.text.isEmpty ? 'Select your DOB' : provider.dobController.text,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.black87),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // const SizedBox(height: 15),
                  //
                  // _label("Blood Group"),
                  // DropdownButtonFormField<String>(
                  //   value: provider.selectedBloodGroup,
                  //   decoration: _decoration("", Icons.bloodtype),
                  //   items: [
                  //     "A+","A-","B+","B-","O+","O-","AB+","AB-"
                  //   ].map((e) => DropdownMenuItem(
                  //     value: e,
                  //     child: Text(e),
                  //   )).toList(),
                  //   onChanged: (v) => provider.changeBloodGroup(v!),
                  //   validator: (v) => v == null ? "Select blood group" : null,
                  // ),


                  const SizedBox(height: 15),

                  _label("District"),
                  _districtDropdown(context),


                  const SizedBox(height: 15),

                  _label("Place"),
                  _textField(
                    provider.placeController,
                    "Enter place",
                    Icons.location_city,
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

                  const SizedBox(height: 15),
                  _label("Aadhaar Proof Photo"),
                  _aadhaarPhotoUpload(),

                  const SizedBox(height: 15),
                  _label("Create Password"),
                  TextFormField(
                    controller: provider.passwordController,
                    obscureText: provider.obscurePassword,
                    decoration: _decoration("Enter password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          provider.obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xff1A237E),
                        ),
                        onPressed: provider.togglePasswordVisibility,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password required";
                      if (v.length < 6) return "Minimum 6 characters required";
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),
                  _label("Confirm Password"),
                  TextFormField(
                    controller: provider.confirmPasswordController,
                    obscureText: provider.obscureConfirmPassword,
                    decoration: _decoration("Confirm password", Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          provider.obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xff1A237E),
                        ),
                        onPressed: provider.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Confirm your password";
                      if (v != provider.passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isRegisteringBoy
                          ? null
                          : () {
                        if (!formKey.currentState!.validate()) return;
                        final error = provider.validateRegistration();
                        if (error != null) {
                          NotificationSnack.showError(error);
                          return;
                        }
                        provider.registerNewBoyFun(context, registeredBy);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: provider.isRegisteringBoy
                            ? Row(
                          key: const ValueKey("loading"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Processing...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                            : const Text(
                          "Submit",
                          key: ValueKey("submit"),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  Widget _aadhaarPhotoUpload() {
    return Consumer<BoysProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => provider.pickAadhaarPhoto(context),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.aadhaarPhoto != null
                    ? const Color(0xff1A237E)
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: provider.aadhaarPhoto != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          provider.aadhaarPhoto!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            provider.aadhaarPhoto = null;
                            provider.notifyListeners();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Tap to upload Aadhaar photo",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _boyPhotoUpload() {
    return Consumer<BoysProvider>(  // Replace with your provider name
      builder: (context, provider, _) {
        return Center(
          child: GestureDetector(
            onTap: () => provider.pickBoyPhoto(context),
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    border: Border.all(
                      color: provider.boyPhoto != null
                          ? const Color(0xff1A237E)
                          : Colors.grey[300]!,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: provider.boyPhoto != null
                        ? Image.file(
                      provider.boyPhoto!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 30,
                          color: Colors.grey[400],
                        ),

                        Text(
                          "Add Photo",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Camera/Edit Icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xff1A237E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      provider.boyPhoto != null
                          ? Icons.edit
                          : Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                // Remove button (only shown when photo exists)
                if (provider.boyPhoto != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        provider.clearBoyPhoto();
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _districtDropdown(BuildContext context) {
    final districts = [
      "Ernakulam",
      "Alappuzha",
      "Idukki",
      "Kannur",
      "Kasaragod",
      "Kollam",
      "Kottayam",
      "Kozhikode",
      "Malappuram",
      "Palakkad",
      "Pathanamthitta",
      "Thiruvananthapuram",
      "Thrissur",
      "Wayanad",
    ];

    return Consumer<BoysProvider>(
      builder: (contextss,provider,cho) {
        return DropdownButtonFormField<String>(
          value: provider.districtController.text.isEmpty
              ? null
              : provider.districtController.text,
          decoration: _decoration("Select district", Icons.map),
          items: districts.map((d) {
            return DropdownMenuItem<String>(
              value: d,
              child: Text(d),
            );
          }).toList(),
          onChanged: (value) {
            provider.districtController.text = value ?? "";
            print('${provider.districtController.text} KFNEJRERKF ');
          },
          validator: (v) => (v == null || v.isEmpty) ? "Required field" : null,
        );
      }
    );
  }

}
