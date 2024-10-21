import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './components/ClientInfoForm.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './components/LoadingScreen.dart';
import './components/ClientListPage.dart'; // Import ClientListPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Client Information App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with the splash screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () async {
      bool isConnected = await initializeFirebase();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(isConnected: isConnected)),
      );
    });
  }

  Future<bool> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      return true; // Firebase connected successfully
    } catch (e) {
      print('Error initializing Firebase: $e');
      return false; // Failed to connect
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(); // Show the loading screen
  }
}

class HomePage extends StatelessWidget {
  final bool isConnected;

  HomePage({required this.isConnected}); // Receive Firebase connection status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Information'),
        actions: [
          // Add Client button
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Client',
            onPressed: () {
              // Show ClientInfoForm as a popup dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add Client'),
                    content: Container(
                      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                      child: ClientInfoForm(), // Your form inside the dialog
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Icon(FontAwesomeIcons.close),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isConnected
          ? ClientListPage() // Show ClientListPage if Firebase is connected
          : Center(
              child: Text(
                'Failed to Connect to Firebase',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
