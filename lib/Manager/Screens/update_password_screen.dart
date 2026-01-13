import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../Providers/ManagerProvider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String managerID,fromWhere; // Passed as /BOYS/BOY1767283893322

  const ChangePasswordScreen({super.key, required this.managerID,required this.fromWhere});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _isLoading = false;

// Inside _ChangePasswordScreenState
  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Access your provider (Replace 'YourProviderName' with your actual class name)
        ManagerProvider provider = Provider.of<ManagerProvider>(context, listen: false);

        await provider.updateBoyPassword(
            context,
            widget.managerID,
            _passController.text.trim(),widget.fromWhere
        );


        if (mounted) Navigator.pop(context);
      } catch (e) {
        // Error is handled in provider, stop loading here
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FD),
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Secure Your Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff1A237E)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please enter a new 6-digit numeric password.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _buildPasswordField(
                controller: _passController,
                label: "New Password",
                hint: "Enter 6 digits",
              ),

              const SizedBox(height: 20),

              _buildPasswordField(
                controller: _confirmPassController,
                label: "Confirm Password",
                hint: "Re-enter 6 digits",
                isConfirm: true,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1A237E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isConfirm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only numbers
          decoration: InputDecoration(
            hintText: hint,
            counterText: "", // Hides the 0/6 counter for a cleaner look
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xff1A237E)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff1A237E), width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Field required";
            if (value.length != 6) return "Must be exactly 6 digits";
            if (isConfirm && value != _passController.text) return "Passwords do not match";
            return null;
          },
        ),
      ],
    );
  }
}