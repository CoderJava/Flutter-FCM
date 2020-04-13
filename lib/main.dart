import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    print('myBackgroundMessageHandler');
    if (message.containsKey('data')) {
      final dynamic data = message['data'];
      String name = data['name'];
      String age = data['age'];
      print('name: $name & age: $age');
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
        _getDataFcm(message);
        return true;
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async {
        print('onResume');
        _getDataFcm(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch');
        _getDataFcm(message);
      },
    );
    _firebaseMessaging.getToken().then((String token) {
      print('getToken: $token');
      setState(() {
        this.token = token;
      });
    });
    super.initState();
  }

  void _getDataFcm(Map<String, dynamic> message) {
    try {
      var data = message['data'];
      String name = data['name'];
      String age = data['age'];
      debugPrint('name: $name & age: $age');
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
            ],
          ),
        ),
      ),
    );
  }
}
