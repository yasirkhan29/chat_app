import 'dart:io';

import 'package:chat1_practice/Model/UIHelper.dart';
import 'package:chat1_practice/Model/UserModel.dart';
import 'package:chat1_practice/pages/HomePage.dart';
import 'package:chat1_practice/Background/completeProfileBackgroun.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firbaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firbaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  //step 1
  TextEditingController fullNameController = TextEditingController();
// step 2
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

// step 3
  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

// step 4
  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Select profile pictuer"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo),
                  title: Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Select from Photo"),
                ),
              ],
            ),
          );
        });
  }

// step 5
  void checkValue() {
    String fullname = fullNameController.text.trim();

    if (fullname == "" || imageFile == null) {
      UIHelper.showAlertDialog(
          context, "Incomplete data", "please fill all the field ");
    } else {
      uploadData();
    }
  }

// step 6
  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image...");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictuer")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.tomap())
        .then((value) {
      showDialog(
          context: context,
          builder: (context) {
            return Container(
              child: const AlertDialog(
                title: Text(
                  "Data uploaded",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            );
          });
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firbaseUser)));
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 202, 132, 214),
        shadowColor: Colors.purpleAccent,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
        centerTitle: true,
      ),
      body: CompliteBackground(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(children: [
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
              onPressed: () {
                showPhotoOption();
              },
              child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 202, 132, 214),
                  radius: 60,
                  child: imageFile == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        )
                      : Image.file(
                          imageFile!,
                        )),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: "Full Name",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                color: Color.fromARGB(255, 202, 132, 214),
                child: Text("Submit"),
                onPressed: () {
                  checkValue();
                })
          ]),
        ),
      ),
    ));
  }
}
