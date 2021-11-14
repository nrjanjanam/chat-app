import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController? _enteredMessageController =
      TextEditingController(text: '');

  String? _enteredMessage;

  void _sendMessage() async {
    FocusScope.of(context).unfocus();

    final DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get();

    FirebaseFirestore.instance.collection('chat').add({
      "text": _enteredMessageController?.text,
      "createdAt": Timestamp.now(),
      "userId": FirebaseAuth.instance.currentUser?.uid,
      "userName": userData['userName'],
      "userImage": userData['imageUrl'],
    });

    setState(() {
      _enteredMessage = '';
      _enteredMessageController?.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textDirection: TextDirection.ltr,
        controller: _enteredMessageController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: const Text('Send message...'),
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary,
          suffixIcon: IconButton(
            onPressed:
                _enteredMessage != null && _enteredMessage!.trim().isEmpty
                    ? null
                    : _sendMessage,
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),
        onChanged: (value) {
          setState(
            () {
              _enteredMessage = value;
            },
          );
        },
      ),
    );
  }
}
