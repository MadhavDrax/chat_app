import 'package:chat_app/widgets/avatar_pick.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = false;
  var _enteredEmail = '';
  var _enteredPass = '';
  var _selectedAvatar = '';
  var _userName = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedAvatar.isEmpty) {
      return;
    }
    _form.currentState!.save();
    print(_enteredEmail);
    print(_enteredPass);

    try {
      if (_isLogin) {
        final UserCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPass,
        );
        print(UserCredential);
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPass,
        );

        // we have to store data in firebase database (collections)
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'userName': _userName,
              'email': _enteredEmail,
              'profileImage': _selectedAvatar,
            });
        print(userCredential);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //.....
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AvatarPick();
                    },
                  );
                },
                child: Container(
                  width: 200,
                  margin: EdgeInsets.all(20),
                  child: Image.asset('assets/images/chat.png'),
                ),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          //if login screen then show nothing or else show avatar selection
                          _isLogin
                              ? SizedBox(height: 5)
                              : _selectedAvatar.isEmpty
                              //show a demo image with image selection option
                              ? GestureDetector(
                                  onTap: () async {
                                    final selectedAvatar =
                                        await showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            return AvatarPick();
                                          },
                                        );
                                    if (selectedAvatar!.isNotEmpty) {
                                      setState(() {
                                        _selectedAvatar = selectedAvatar;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person_2_outlined,
                                      size: 50,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                )
                              //if image is selected then show it
                              : Stack(
                                  alignment: AlignmentGeometry.xy(1, -1),
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: AssetImage(
                                        _selectedAvatar,
                                      ),
                                      radius: 50,
                                    ),
                                    IconButton.filled(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      onPressed: () {
                                        setState(() {
                                          _selectedAvatar = '';
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                label: Text('User Name'),
                              ),
                              keyboardType: TextInputType.name,
                              enableSuggestions: false,
                              autocorrect: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter atleast 4 letters';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _userName = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Email Address'),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return 'Please enter valid email address!';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text('Password'),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 6) {
                                return 'Password must be greater than 6 characters!';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPass = newValue!;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            onPressed: _submit,
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Craete an account'
                                  : 'I already have an account',
                            ),
                          ),
                        ],
                      ),
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
}
