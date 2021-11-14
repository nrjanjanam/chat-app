import 'dart:io';

import 'package:chat_app_prac/widgets/auth/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  void _submitAuthForm(
      {@required String? email,
      @required String? password,
      @required String? username,
      @required bool? isLogin,
      @required File? image}) async {
    UserCredential _authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin != null && isLogin) {
        _authResult = await _auth.signInWithEmailAndPassword(
            email: email ?? "", password: password ?? "");
      } else {
        _authResult = await _auth.createUserWithEmailAndPassword(
            email: email ?? "", password: password ?? "");

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child((_authResult.user?.uid)! + '.jpg');

        await ref.putFile(image!).whenComplete(() async {
          String url = await ref.getDownloadURL();
          debugPrint("URL is" + url);

          //for adding extra data
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_authResult.user?.uid)
              .set({
            'userName': username,
            'email': email,
            'imageUrl': url,
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      String message;

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'An error occured, please check your credentials';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8.0),
          content: Text(e.message ?? message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      String message = 'An error occured, please check your credentials';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8.0),
          content: Text(e.message ?? message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8.0),
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body:
          AuthForm(submitAuthFunction: _submitAuthForm, isLoading: _isLoading),
    );
  }
}
