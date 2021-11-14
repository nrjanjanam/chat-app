import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String? message;
  final bool? isCurrentUser;
  final String? messageUserName;
  final String? messageUserImage;

  const MessageBubble({
    Key? key,
    @required this.message,
    @required this.isCurrentUser,
    @required this.messageUserName,
    @required this.messageUserImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisAlignment: isCurrentUser != null && isCurrentUser!
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isCurrentUser!
                    ? Colors.grey
                    : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12.0),
                    topRight: const Radius.circular(12.0),
                    bottomLeft: isCurrentUser!
                        ? const Radius.circular(12.0)
                        : Radius.zero,
                    bottomRight: !isCurrentUser!
                        ? const Radius.circular(12.0)
                        : Radius.zero),
              ),
              width: 140.0,
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              margin:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageUserName ?? "UserName",
                    style: const TextStyle(
                        color: Colors.pink, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    message ?? "",
                    style: TextStyle(
                        color: isCurrentUser! ? Colors.black : Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          child: CircleAvatar(
            key: ValueKey(messageUserImage),
            backgroundImage: NetworkImage(messageUserImage!),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          top: -5,
          right: isCurrentUser! ? 125 : null,
          left: !isCurrentUser! ? 125 : null,
        )
      ],
    );
  }
}
