import 'package:gymtrak/home.dart';
import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/misc/notification_service.dart' as localNotificationService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localNotificationService.setup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      home: const HomePage(),
    );
  }
}
