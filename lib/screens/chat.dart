import 'package:chat_app/widgets/chat_message.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
@override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
  
}

class _ChatScreenState extends State<ChatScreen>{
  StreamSubscription<String>? _tokenRefreshSubscription;

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  Future<void> _setupPushNotifications() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await messaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }

    _tokenRefreshSubscription = messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  Future<void> _saveFcmToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      // An array supports the same user being signed in on more than one device.
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}
