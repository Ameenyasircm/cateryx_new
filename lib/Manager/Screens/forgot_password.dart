
import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'LoginScreen.dart';

class ForgotPassword extends StatelessWidget {
   ForgotPassword({super.key});
  final TextEditingController _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ensure 'assets/Logo.png' is in your pubspec.yaml
                    Image.asset('assets/Logo.png', width: 160),
                    const SizedBox(height: 10),
                    const Text(
                      "Cateryx",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              Text(
                "Forgot Password",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              AppSpacing.h24,
              buildInputField(
                controller: _phoneController,
                hint: "Phone Number",
                icon: Icons.phone_android,
                type: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
             AppSpacing.h45,
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                onPressed: () async {
                  if(_phoneController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Please enter phone number")),
                    );
                    return;
                  }
                  final supabase = Supabase.instance.client;
                  await supabase.auth.signInWithOtp(
                    phone: '+91${_phoneController.text}',  // India format
                  );
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE64A19),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child:const Text(
                    "Send OTP",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

          ],),
        ),
      ),
    );
  }
}
