import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMsg() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    //using this to close keybaord
    FocusScope.of(context).unfocus();
    _messageController.clear();

    //logic to send message

    //get current user
    final user = await FirebaseAuth.instance.currentUser;

    //get current user data
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    //creating new document and collection to store data
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': DateTime.now(),
      'userId': user.uid,
      'userName': userData.data()!['userName'],
      'userImage': userData.data()!['profileImage']
    });

    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(18, 1, 10, 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(label: Text('send message...')),
            ),
          ),
          IconButton(
            onPressed: _submitMsg,
            icon: Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
