import 'dart:io';

import 'package:chat_app_prac/widgets/auth/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:image_picker/image_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(
      {Key? key, @required this.submitAuthFunction, @required this.isLoading})
      : super(key: key);

  final void Function(
      {@required String? email,
      @required String? password,
      @required String? username,
      @required bool? isLogin,
      @required File? image})? submitAuthFunction;

  final bool? isLoading;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  String? _userEmail = '';
  String? _userName = '';
  String? _userPassword = '';
  File? _userImageFile;

  void _pickedImg(XFile image) {
    _userImageFile = File(image.path);
  }

  void _trySubmit() {
    final bool? _isValid = _formKey.currentState?.validate();

    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8.0),
          content: const Text('Please pick an image'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }
    if (_isValid != null && _isValid) {
      _formKey.currentState?.save();
      debugPrint('$_userEmail $_userName $_userPassword');
      if (widget.submitAuthFunction != null) {
        widget.submitAuthFunction!(
          email: _userEmail,
          isLogin: _isLogin,
          password: _userPassword,
          username: _userName,
          image: _userImageFile,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!_isLogin)
                    UserImagePicker(
                      imagePickFn: _pickedImg,
                    ),
                  //email
                  TextFormField(
                    key: const ValueKey('email'),
                    onSaved: (email) {
                      _userEmail = email?.trim();
                    },
                    validator: (email) {
                      email = email?.trim();
                      if ((email != null &&
                              (!(email.isEmail) || (email.isEmpty))) ||
                          email == null) {
                        return 'Kindly enter a valid email address';
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                    ),
                  ),
                  //username
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey('username'),
                      onSaved: (name) {
                        _userName = name;
                      },
                      validator: (username) {
                        if ((username != null &&
                                (username.length < 4 || (username.isEmpty))) ||
                            username == null) {
                          return 'Kindly enter a valid username of atleast 4 charectars';
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'User Name',
                      ),
                    ),
                  //password
                  TextFormField(
                    key: const ValueKey('password'),
                    onSaved: (pwd) {
                      _userPassword = pwd;
                    },
                    validator: (pwd) {
                      if ((pwd != null &&
                              ((pwd.length < 7) || (pwd.isEmpty))) ||
                          pwd == null) {
                        return 'Password must be at least 7 charectars long';
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  if (widget.isLoading!)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _trySubmit,
                      child: Text(_isLogin ? 'Login' : 'Sign Up'),
                    ),
                  if (!widget.isLoading!)
                    TextButton(
                        onPressed: () {
                          setState(() {
                            FocusManager().primaryFocus?.unfocus();
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(_isLogin
                            ? 'Create New Account'
                            : 'I already have an account'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
