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

  @override
  void initState() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('onMessage');
        try {
          var data = message['data'];
          String name = data['name'];
          String age = data['age'];
          debugPrint('name: $name & age: $age');
        } catch (error) {
          debugPrint("error: $error");
        }
        return true;
      },
    );
    _firebaseMessaging.getToken().then((String token) {
      setState(() {
        this.token = token;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    debugPrint('token: $token');

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
