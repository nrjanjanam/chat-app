import 'package:chat_app_prac/widgets/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.pink,
          ));
        } else if (chatSnapshot.hasData) {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>>? messages =
              chatSnapshot.data?.docs;
          try {
            return ListView.builder(
              reverse: true,
              itemBuilder: (ctx, i) => MessageBubble(
                messageUserName: messages![i].data()['userName'],
                messageUserImage: messages[i].data()['userImage'],
                message: messages[i].data()['text'],
                isCurrentUser: messages[i].data()['userId'] ==
                    FirebaseAuth.instance.currentUser!.uid,
                key: ValueKey(messages[i].id),
              ),
              itemCount: messages?.length,
            );
          } catch (e) {
            return Text(e.toString());
          }
        } else {
          return Text(chatSnapshot.error.toString());
        }
      },
    );
  }
}
