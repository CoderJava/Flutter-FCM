import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm/detail_page.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _controllerTopic = TextEditingController();
  String token = '';
  bool isSubscribed = false;

  static Future<dynamic> onBackgroundMessageHandler(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessageHandler');
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
      String name = data['name'];
      String age = data['age'];
      String page = data['page'];
      debugPrint('name: $name & age: $age & page: $page');
    }

    /*if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }*/

    // Or do other work.
    return Future.value(true);
  }

  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('onMessage');
        _getDataFcm(message, 'onMessage');
      },
      onBackgroundMessage: onBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async {
        debugPrint('onResume');
        _getDataFcm(message, 'onResume');
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('onLaunch');
        _getDataFcm(message, 'onLaunch');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      debugPrint("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      debugPrint('getToken: $token');
      setState(() {
        this.token = token;
      });
    });
    super.initState();
  }

  void _getDataFcm(Map<String, dynamic> message, String type) {
    try {
      /*debugPrint('message.length: ${message.keys.length}');
      debugPrint('message: $message');
      var aps = message['aps'];
      var name = message['name'];
      var age = message['age'];
      debugPrint('name: $name & age: $age');*/

      /*var data = message['data'];
      debugPrint('data: $data');
      String name = data['name'];
      String age = data['age'];
      String page = data['page'];
      debugPrint('name: $name & age: $age & page: $page');*/
      String page = '';
      String name = '';
      String age = '';
      if (Platform.isIOS) {
        name = message['name'];
        age = message['age'];
        page = message['page'];
      } else if (Platform.isAndroid) {
        var data = message['data'];
        name = data['name'];
        age = data['age'];
        page = data['page'];
      }
      debugPrint('name: $name & age: $age & page: $page');
      switch (type) {
        case 'onResume':
        case 'onLaunch':
          {
            if (page == 'detail_page') {
              _navigateToDetailPage();
            }
            break;
          }
        default:
          {
            debugPrint('unknown type in getDataFcm');
          }
      }
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('Flutter FCM'),
      ),
      body: SafeArea(
        child: Container(
          width: widthScreen,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Token',
                style: Theme.of(context).textTheme.title,
              ),
              SelectableText(
                token.isEmpty ? 'Getting value...' : token,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _controllerTopic,
                decoration: InputDecoration(hintText: 'Enter topic'),
                enabled: !isSubscribed,
              ),
              SizedBox(height: 8.0),
              Text('Subscribed: $isSubscribed'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Subscribe'),
                      onPressed: isSubscribed
                          ? null
                          : () {
                              String topic = _controllerTopic.text;
                              if (topic.isEmpty) {
                                _scaffoldState.currentState.showSnackBar(SnackBar(
                                  content: Text('Please enter topic'),
                                ));
                                return;
                              }
                              _firebaseMessaging.subscribeToTopic(topic);
                              setState(() {
                                isSubscribed = true;
                              });
                            },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Unsubscribe'),
                      onPressed: !isSubscribed
                          ? null
                          : () {
                              String topic = _controllerTopic.text;
                              _firebaseMessaging.unsubscribeFromTopic(topic);
                              setState(() {
                                isSubscribed = false;
                              });
                            },
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  child: Text('Move Page'),
                  onPressed: () {
                    _navigateToDetailPage();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetailPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage()),
    );
  }
}
