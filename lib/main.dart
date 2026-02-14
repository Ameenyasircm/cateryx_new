
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Boys/Providers/boys_provider.dart';
import 'Boys/Screens/navbar/boy_bottomNav.dart';
import 'Manager/Providers/EventDetailProvider.dart';
import 'Manager/Providers/LoginProvider.dart';
import 'Manager/Providers/ManagerProvider.dart';
import 'Manager/Screens/event_details_screen.dart';
import 'Manager/Screens/sample.dart';
import 'Manager/Screens/splashScreen.dart';
import 'core/utils/snackBarNotifications/snackBar_notifications.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://awtcvvdjhoxinfjfaqsb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3dGN2dmRqaG94aW5mamZhcXNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzODc5OTAsImV4cCI6MjA4NTk2Mzk5MH0.sy4F-UIb1IsIyqXaJkIjzy6rASX8_Evwp4a4em7bXjs',
  );
  // Wrap everything in try-catch for debugging
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Firebase
    await Firebase.initializeApp();

    // Run the app
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // If there's an error, show it on screen
    debugPrint('❌ Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(error: e.toString()),
      ),
    );
  }
}

// Error screen to display initialization errors
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check:\n• Firebase configuration\n• Internet connection\n• App permissions',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: false,
      designSize: const Size(360, 813),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => ManagerProvider()),
            ChangeNotifierProvider(create: (_) => BoysProvider()),
            ChangeNotifierProvider(create: (_) => EventDetailsProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey:NotificationSnack.scaffoldMessengerKey,
            title: 'Evento',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
              // home: EventDetailedScreen()
          ),
        );
      },
    );
  }
}