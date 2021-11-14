import 'package:chat_app_prac/main.dart';
import 'package:chat_app_prac/widgets/chat/messages.dart';
import 'package:chat_app_prac/widgets/chat/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseMessaging fbm = FirebaseMessaging.instance;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    fbm.requestPermission().then((notificationSettings) {
      if (notificationSettings.authorizationStatus !=
          AuthorizationStatus.authorized) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(8.0),
              content: const Text('Permission not granted'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          );
        });
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null && !kIsWeb) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  icon: 'launch_background',
                ),
              ));
        }
      });

      //runs when notification is tapped when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            'A new onMessageOpenedApp event was published! ${message.notification?.title} ${message.notification?.body}');
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        actions: [
          DropdownButton<String>(
            items: [
              DropdownMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    const SizedBox(
                      width: 10.0,
                    )
                  ],
                ),
              )
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
      body: Column(
        children: const [
          Expanded(child: Messages()),
          NewMessage(),
        ],
      ),
    );
  }
}
