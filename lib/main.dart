import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.data}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications',description:
      'This channel is used for important notifications.');

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      Constants.DEF_NOTIF_CHANNEL,
      Constants.DEF_NOTIF_CHANNEL,
      );

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  var platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  if (true) {
    var notifTitle = message.data["title"];
    var notifBody = message.data["message"];
     flutterLocalNotificationsPlugin.show(
      0,
     "fIREBASE fUNCTION",
      "EXaMpLe",
      platformChannelSpecifics,
    );
    // flutterLocalNotificationsPlugin.show(
    //   notification.hashCode,
    //   notification.title,
    //   notification.body,
    //   NotificationDetails(
    //     android: androidPlatformChannelSpecifics
    //   ),
    // );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String token='';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.instance
        .getToken()
        .then((token1) {
          print("Fcm Token: $token1");
          token=token1!;
    });
  }



  void _incrementCounter() {
     users.doc() // <-- Document ID
        .set({
      'name': "sathya",
      'fcmToken': token,

    }).then((value) {
      print("+++++++++++++++++++++++++++++++++");
      print("Success Adding Data");
    } )
        .catchError((error) {
          print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    });
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  _onFCMMessage(RemoteMessage message) {
    print("FCM: onMessage: ${message.data}");
    _sendLocalNotification(message);
  }

  _initialiseLocalNotification() async {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        );
  }

  Future _sendLocalNotification(RemoteMessage message) async {
    print("_sendLocalNotification");
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        Constants.DEF_NOTIF_CHANNEL,
        Constants.DEF_NOTIF_CHANNEL,
       );
    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    var notifTitle = message.data["title"];
    var notifBody = message.data["message"];
    await flutterLocalNotificationsPlugin.show(
      0,
      notifTitle,
      notifBody,
      platformChannelSpecifics,
    );
  }



  @override
  Widget build(BuildContext context) {

    _initialiseLocalNotification();
    FirebaseMessaging.onMessage.listen((message) {
      _onFCMMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("FCM: onMessageOpenedApp: $message");
    });

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


abstract class Constants {
  static const PATH_START = "/startSession/7737486223";
  static const PATH_STOP = "/stopSession/7737486223/";

  static const DIALOG_ROUTE_OK_ALERT = "okalert";
  static const DIALOG_ROUTE_LOADER = "loader";

  static const String PREF_IS_WELCOMED = "PREF_IS_WELCOMED";

  static const APP_BAR_HEIGHT = 56.0;
  static const CHARGING_REFRESH_INTERVAL = 5;
  static const ADMIN = "admin";
  static const ACTIVITY_TIME_FORMAT = "dd-MM-yyyy HH:mm";

  static const DEF_NOTIF_CHANNEL = "example";
}