import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() {
    return _ChatMessagesState();
  }
}

class _ChatMessagesState extends State<ChatMessages> {
  final authUserData = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return Center(child: Text('No messages available!'));
        }
        if (chatSnapshot.hasError) {
          return Center(child: Text('Something went wrong...'));
        }

        //get all messages in accessable list
        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextchatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index].data()
                : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextChatMessageUserId = nextchatMessage != null
                ? nextchatMessage['userId']
                : null;
            final nextUserIsSame =
                currentMessageUserId == nextChatMessageUserId;

            return nextUserIsSame
                ? MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authUserData!.uid == chatMessage['userId'],
                  )
                : MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['userName'],
                    message: chatMessage['text'],
                    isMe: authUserData!.uid == chatMessage['userId'],
                  );
          },
        );
      },
    );
  }
}
