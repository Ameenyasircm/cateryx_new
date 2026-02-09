
import 'package:cateryyx/Constants/my_functions.dart';
import 'package:cateryyx/Manager/Screens/update_password_screen.dart';
import 'package:cateryyx/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Providers/ManagerProvider.dart';
import 'LoginScreen.dart';

class ForgotPassword extends StatefulWidget {
  final String managerID,fromWhere;
  const ForgotPassword({super.key,required this.managerID,required this.fromWhere});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isLoading = false;
  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      appBar: AppBar(
        title: const Text("Forgot Password", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Secure Your Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff1A237E)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please enter a new 6-digit numeric password.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                AppSpacing.h24,
                const SizedBox(height: 20),
                buildPasswordField(
                    controller: _passController,
                    label: "New Password",
                    hint: "Enter new password",
                    obscureValue: _hideNewPassword,
                    onToggle: () {
                      setState(() {
                        _hideNewPassword = !_hideNewPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Field required";
                      if (value.length != 6) return "Must be exactly 6 digits";
                      return null;
                    }
                ),

                const SizedBox(height: 20),

                buildPasswordField(
                    controller: _confirmPassController,
                    label: "Confirm Password",
                    hint: "Re-enter new password",
                    obscureValue: _hideConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _hideConfirmPassword = !_hideConfirmPassword;
                      });
                    },
                    isConfirm: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Field required";
                      if (value.length != 6) return "Must be exactly 6 digits";
                      if (true && value != _passController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    }
                ),
                const SizedBox(height: 40),
               AppSpacing.h45,
                Consumer<ManagerProvider>(
                  builder: (context2, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          provider.createNewPassword(context,widget.managerID,_passController.text.trim(),_confirmPassController.text.trim(),widget.fromWhere);
                          setState(() => _isLoading = false);
                          finish(context);
                        }

                      },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE64A19),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child:
                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.white):const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  }
                ),

            ],),
          ),
        ),
      ),
    );
  }
}
