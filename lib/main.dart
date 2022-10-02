import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:visco/view/homepage.dart';

import 'firebase_options.dart';
import 'model/post.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/homepage',
      routes: {
        '/homepage': (context) => HomePage(),
        '/postpage': (context) => PostPage(),
      },
    );
  }
}
