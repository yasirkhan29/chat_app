import 'package:chat1_practice/Model/UserModel.dart';
import 'package:chat1_practice/Model/firebaseHelper.dart';
import 'package:chat1_practice/pages/HomePage.dart';
import 'package:chat1_practice/pages/SiginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
// logged
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyApploggedIn(
        userModel: thisUserModel,
        firebaseUser: currentUser,
      ));
    } else {
      runApp(MyApp());
    }
  } else {
    // not logged in
    runApp(MyApp());
  }
}

// loged not
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// loged in already
class MyApploggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyApploggedIn(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
