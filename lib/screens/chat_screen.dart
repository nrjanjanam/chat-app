import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app_prac/notification.dart';
import 'package:chat_app_prac/widgets/chat/messages.dart';
import 'package:chat_app_prac/widgets/chat/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseMessaging fbm = FirebaseMessaging.instance;

  Future<void> permissionCheck() async {
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
    });
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
          if (!isAllowed)
            {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Allow notifications",
                  ),
                  content: const Text(
                    "Our app would like to send you notifications",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Don't allow",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AwesomeNotifications()
                            .requestPermissionToSendNotifications()
                            .then((isAccepted) {
                          if (isAccepted) {
                            Navigator.of(context).pop();
                          } else {}
                        });
                      },
                      child: const Text(
                        "Allow",
                        style: TextStyle(
                            color: Colors.pink,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
            }
        });
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    //check for firebase as well as awesome notification settings
    permissionCheck();

    createScheduledNotification();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        await createMarketingNotification(
          context: context,
          message: message.notification?.body,
          title: message.notification?.title,
        );
      }
    });

    //runs when Firebase notification is tapped when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint(
            'A new onMessageOpenedApp event was published! ${message.notification?.title} ${message.notification?.body}');
      },
      onDone: () {},
    );

    AwesomeNotifications().actionStream.listen((recievedAction) {
      if (recievedAction.channelKey == 'high_importance_channel') {
        if (Platform.isIOS) {
          AwesomeNotifications().getGlobalBadgeCounter().then((badgeCount) =>
              AwesomeNotifications().setGlobalBadgeCounter(badgeCount - 1));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
            content: Text(
                "Action taken on Notification from ${recievedAction.channelKey ?? ""} channel"),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    });

    AwesomeNotifications().createdStream.listen((recievedNotif) {
      if (recievedNotif.channelKey == 'high_importance_channel') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
            content:
                Text('Chat Notification sent on ${recievedNotif.createdDate}'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
            content: Text(
                'Marketing Notification sent on ${recievedNotif.createdDate}'),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
    AwesomeNotifications().dismissedSink.close();
    AwesomeNotifications().displayedSink.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        permissionCheck();
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
            elevation: 1,
            dropdownColor: Colors.pink,
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
      body: WillPopScope(
        onWillPop: () => Future.value(true),
        child: Column(
          children: const [
            Expanded(child: Messages()),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}
