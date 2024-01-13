import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:gymtrak/home.dart';
import 'package:flutter/material.dart';
import 'package:gymtrak/utilities/misc/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'medication_reminder',
          channelName: 'Medication Reminders',
          channelDescription: 'Notification channel for medication reminders',
          ledColor: Colors.white,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'medication_reminder',
            channelGroupName: 'Medication group')
      ],
      debug: true);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String name = 'Gymtrak';

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  @override
  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MainApp.navigatorKey,
      title: MainApp.name,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomePage());

          // case '/notification-page':
          //   return MaterialPageRoute(builder: (context) {
          //     final ReceivedAction receivedAction = settings.arguments as ReceivedAction;
          //     return MyNotificationPage(receivedAction: receivedAction);
          //   });

          default:
            assert(false, 'Page ${settings.name} not found');
            return null;
        }
      },
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
