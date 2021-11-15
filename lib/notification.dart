import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> createChatNotification(
    {String? message, String? senderName, BuildContext? context}) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      channelKey: 'high_importance_channel',
      title: Emojis.icon_speech_balloon,
      body: '$senderName says $message',
      icon: 'resource://mipmap/ic_launcher',
      backgroundColor: Theme.of(context!).colorScheme.primary,
      notificationLayout: NotificationLayout.BigText,
    ),
  );
}

Future<void> createMarketingNotification(
    {String? message, String? title, BuildContext? context}) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      channelKey: 'marketing_channel',
      title: '$title',
      body: '$message',
      icon: 'resource://mipmap/ic_launcher',
      backgroundColor: Theme.of(context!).colorScheme.secondary,
    ),
  );
}

Future<void> createScheduledNotification(
    {String? message, String? title}) async {
  await AwesomeNotifications().createNotification(
    schedule: NotificationAndroidCrontab(
      repeats: true,
      allowWhileIdle: true,
      crontabExpression: '0 9,16,21 * * ?',
      initialDateTime: DateTime.now(),
      timeZone: DateTime.now().timeZoneName,
    ),
    actionButtons: [
      NotificationActionButton(key: 'MARK_DONE', label: 'Mark Done'),
    ],
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      channelKey: 'scheduled_channel',
      title: 'Scheduled channel ${Emojis.wheater_droplet}',
      body: 'Water your plant regularly to keep it healthy',
      icon: 'resource://mipmap/ic_launcher',
      backgroundColor: Colors.blue,
      notificationLayout: NotificationLayout.Default,
    ),
  );
}
