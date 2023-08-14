import 'package:chat1_practice/Model/UIHelper.dart';
import 'package:chat1_practice/Model/UserModel.dart';
import 'package:chat1_practice/pages/HomePage.dart';
import 'package:chat1_practice/pages/SignUpPage.dart';
import 'package:chat1_practice/Background/loginBackfround.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //step 1
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
// setep 2
  void checkvalues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == '' || password == '') {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the field");
    } else {
      login(email, password);
    }
  }

// step 3
  void login(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Logging In");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      // show alert dialog
      UIHelper.showAlertDialog(
          context, "An error occuerd", ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                  userModel: userModel, firebaseUser: credential!.user!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: LoginBackground(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        fontSize: 40,
                        color: Color.fromARGB(255, 202, 132, 214),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email Address"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                      color: Color.fromARGB(255, 202, 132, 214),
                      child: Text("Log In"),
                      onPressed: () {
                        checkvalues();
                      })
                ],
              ),
            ),
          ),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have account?",
              style: TextStyle(fontSize: 16),
            ),
            CupertinoButton(
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 184, 91, 201),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                })
          ],
        ),
      ),
    );
  }
}
