import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:major_project/data/User.dart';
import 'package:major_project/helper/dialogs.dart';
import 'package:major_project/nav_anim/userprofile_nav_anim.dart';
import '../api/apis.dart';
import '../data/Collections.dart';
import 'home_screen.dart';


class RegistrationProfileScreen extends StatefulWidget {
  @override
  _RegistrationProfileScreenState createState() => _RegistrationProfileScreenState();
}

class _RegistrationProfileScreenState extends State<RegistrationProfileScreen> {
  File? _image;
  String? savedImage;
  String? imageUrl ;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      String filename = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique filename
      Reference ref = FirebaseStorage.instance.ref().child('profile_images').child(filename);
      UploadTask uploadTask = ref.putFile(_image!);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await storageSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection(CollectionsConst.userCollection)
          .doc(APIs.auth.currentUser!.uid)
          .update({'profileImageUrl': imageUrl});

      Fluttertoast.showToast(
        msg: "Image uploaded successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var email = APIs.auth.currentUser!.email;

    _emailController.text = email!;
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top:15.0),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Camera'),
                                onTap: () {
                                  _getImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Gallery'),
                                onTap: () {
                                  _getImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.black87,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignOutside,
                              style: BorderStyle.solid
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          image: DecorationImage(
                            image: _image != null
                                ? FileImage(_image!)
                                : imageUrl != null
                                ? NetworkImage(savedImage!) as ImageProvider<Object>
                                : const AssetImage('assets/images/profile.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  maxLines: 1,
                  enabled: false,
                  controller: _emailController,
                  style: GoogleFonts.robotoSerif(color: Colors.white),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined,color: Colors.white70,),
                    labelStyle: GoogleFonts.robotoSerif(color: Colors.white),
                    border:  const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  maxLines: 1,
                  controller: _nameController,
                  style: GoogleFonts.robotoSerif(color: Colors.white),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person,color: Colors.white70,),
                    labelStyle: GoogleFonts.robotoSerif(color: Colors.white),
                    border:  const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: TextField(
                  maxLines: 3,
                  minLines: 1,
                  controller: _aboutController,
                  style: GoogleFonts.robotoSerif(color: Colors.white),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    _validateAndSubmit();
                  },
                  decoration: InputDecoration(
                    labelText: 'About',
                    prefixIcon: const Icon(CupertinoIcons.info_circle,color: Colors.white70,),
                    labelStyle: GoogleFonts.robotoSerif(color: Colors.white),
                    border:  const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                   _validateAndSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.robotoSerif(
                      fontStyle: FontStyle.normal,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 5),
                child: ElevatedButton(
                  onPressed: (){
                    _removeImage();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      backgroundColor:Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                  child:  Text(
                    'Remove Image',
                    style: GoogleFonts.robotoSerif(
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _validateAndSubmit() async {

    if(_image != null && _nameController.text.isNotEmpty) {
      Dialogs.showProgressBar(context, Colors.green, "Uploading Please wait...");
      await APIs.auth.currentUser!.updateDisplayName(
          _nameController.text);
      await APIs.auth.currentUser!.updatePhotoURL(imageUrl);

      setState(() {
        imageUrl = imageUrl;
      });
      try {
       await  APIs.createUser();

        if(mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              UserprofileNavAnim(
                  builder: (context) => const HomeScreen()));
        }
      } catch (e) {
        log('Error: $e');
        Fluttertoast.showToast(
          msg: "Something went wrong!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }else if(_image == null){

      Dialogs.showSnackbar(
          context,''
          'Please select your profile pic!',
          Colors.red,
          SnackBarBehavior.fixed,
          Colors.white
      );
    }
    else if(_nameController.text.trim().isEmpty){
      Dialogs.showSnackbar(
          context,
          'Please enter your name!',
          Colors.red,
          SnackBarBehavior.fixed,
          Colors.white
      );
    }
  }

}
