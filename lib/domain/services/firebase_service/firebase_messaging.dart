import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleB6(RemoteMessage message) async {
  print(message);
  // You can handle on message received Here
}


class FirebaseCM {
  final firebaseMessaging = FirebaseMessaging.instance;
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'notification',
    'notification',
    importance: Importance.max,
    playSound: true,
    showBadge: true,
  );

  final localNotification  = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("Permission denied");
    }

    if(FirebaseAuth.instance.currentUser != null) {
      final fcmToken = await firebaseMessaging.getToken();

      //Here your can update token id in DB

    }

    //This is for background notification
    FirebaseMessaging.onBackgroundMessage(handleB6);
    initPushNotification();
    initLocalNotification();
  }

  Future<void> initPushNotification() async {
    const android = AndroidInitializationSettings('@drawable/logo_home.png');
    const settings  =InitializationSettings(android: android);

    await localNotification.initialize(settings);
  }

  Future<void> initLocalNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void handleMessage(RemoteMessage? message) {
    if (message != null) {
      print("onMessage: $message");
    }
  }

  void suscribeToTopic() {
    FirebaseMessaging.instance.subscribeToTopic('notification');
  }
}