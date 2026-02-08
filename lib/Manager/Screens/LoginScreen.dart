import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:provider/provider.dart';
import '../../Boys/Providers/boys_provider.dart';
import '../../Boys/Screens/boy_registration.dart';
import '../../Constants/my_functions.dart';
import '../Providers/LoginProvider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  // Controllers to capture user input
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? packageName;
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    getPackageName();
    // TODO: implement initState
    super.initState();
  }

  Future<void> getPackageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      packageName = packageInfo.packageName;
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Listening to the provider for the loading state
    final loginProvider = Provider.of<LoginProvider>(context);
    BoysProvider boysProvider = Provider.of<BoysProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Branded Header ---
            Container(
              height: size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB),
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

            // --- Login Form ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  packageName=='com.evento.manager'?
                  Text(
                    "Manager Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ):Text(
                    "Boys Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Secure access for event coordinators",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 35),

                  // Phone Input
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
                  const SizedBox(height: 20),

                  // Password Input
                  buildInputField(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isSecure: !_isPasswordVisible,
                    toggleVisibility: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loginProvider.otpLoader
                          ? null
                          : () {
                        if (_phoneController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                          loginProvider.userAuthorized(
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text.trim(),
                            context: context,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter phone and password")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE64A19),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: loginProvider.otpLoader
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                   Visibility(visible:  packageName=='com.evento.manager',
                     child: Center(
                      child: Text(
                        "Contact Admin for account issues",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                                       ),
                   ),
                  Visibility(
                    visible: packageName != 'com.evento.manager',
                    child: Center(
                      child: InkWell(
                        onTap: (){
                          boysProvider.clearBoyForm();
                          callNext(RegisterBoyScreen(registeredBy: 'BOY',), context);
                        },
                        child: Text(
                          "Register New Boy",
                          style: TextStyle(
                            color: Colors.blue,          // 🔵 blue color
                            fontSize: 15,                // ⬆️ little bigger
                            fontWeight: FontWeight.w500, // slightly bold
                            decoration: TextDecoration.underline, // ➖ underline
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable TextField Widget

}
Widget buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType type = TextInputType.text,
  final List<TextInputFormatter>? inputFormatters,
  bool isPassword = false,
  bool isSecure = false,
  VoidCallback? toggleVisibility,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(15),
    ),
    child: TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isSecure,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isSecure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );
}