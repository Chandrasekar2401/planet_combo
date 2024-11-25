import 'dart:async';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';

class LiveChat extends StatefulWidget {
  const LiveChat({Key? key}) : super(key: key);
  @override
  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  late final DatabaseReference _database;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  String? _error;
  String? userKey;
  String? userEmail;
  String? userProfile;
  int messageCount = 0;
  List<Map<String, dynamic>> messagesList = [];
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Initialize Firebase for web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCXAw8BQBx4OPMOWyNaI4bv7gh5GUXa0lQ",
          authDomain: "flutterplanetcombo-ff367.firebaseapp.com",
          databaseURL: "https://flutterplanetcombo-ff367-default-rtdb.firebaseio.com",
          projectId: "flutterplanetcombo-ff367",
          storageBucket: "flutterplanetcombo-ff367.appspot.com",
          messagingSenderId: "488939796804",
          appId: "1:488939796804:web:5c94e0a3b5f03ca2abbf11",
        ),
      );

      _database = FirebaseDatabase.instance.ref();
      await _initializeUser();
    } catch (e) {
      print('Firebase initialization error: $e');
      setState(() {
        _error = 'Failed to initialize Firebase. Please try again.';
      });
    }
  }

  Future<void> _initializeUser() async {
    try {
      userEmail = appLoadController.loggedUserData.value.userid;
      userProfile = appLoadController.loggedUserData.value.userphoto;
      await _findOrCreateUser(userEmail!);
    } catch (e) {
      print('Error initializing user: $e');
      setState(() {
        _error = 'Failed to initialize chat. Please try again.';
      });
    }
  }

  Future<void> _findOrCreateUser(String email) async {
    try {
      DatabaseReference usersRef = _database.child('UsersList');

      // Instead of using query, we'll listen to the value event once
      DatabaseEvent event = await usersRef.once();

      if (event.snapshot.value != null) {
        final usersData = event.snapshot.value as Map;
        bool userFound = false;

        usersData.forEach((key, value) {
          if (value['userEmail'] == email) {
            userKey = key;
            messageCount = value['message'] ?? 0;
            userFound = true;
          }
        });

        if (!userFound) {
          await _createNewUser(email);
        }
      } else {
        await _createNewUser(email);
      }

      // Start listening to messages
      _listenToMessages();

    } catch (e) {
      print('Error in findOrCreateUser: $e');
      setState(() {
        _error = 'Failed to initialize user data';
      });
    }
  }

  Future<void> _createNewUser(String email) async {
    final newUserRef = _database.child('UsersList').push();
    userKey = newUserRef.key;
    await newUserRef.set({
      'adminMessage': 0,
      'message': 0,
      'userActive': 'y',
      'userEmail': email,
      'userProfileUrl': userProfile,
    });
  }

  void _listenToMessages() {
    if (userKey == null) return;

    _messagesSubscription?.cancel();

    _messagesSubscription = _database
        .child('message/$userKey')
        .onValue
        .listen((DatabaseEvent event) {
      if (!mounted) return;

      if (event.snapshot.value != null) {
        final messagesData = event.snapshot.value as Map;
        final List<Map<String, dynamic>> newMessages = [];

        messagesData.forEach((key, value) {
          newMessages.add({
            'key': key,
            'time': value['TimeStamp'],
            'message': value['message'],
            'from': value['from'].toString(),
          });
        });

        setState(() {
          messagesList = newMessages;
        });

        _scrollToBottom();
      }
    }, onError: (error) {
      print('Error listening to messages: $error');
      setState(() {
        _error = 'Failed to load messages. Please refresh the page.';
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || userKey == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      messageCount++;
      await _database.child('UsersList').child(userKey!).update({
        'message': messageCount,
        'userActive': 'y',
      });

      final newMessageRef = _database.child('message').child(userKey!).push();
      await newMessageRef.set({
        'message': _messageController.text.trim(),
        'from': 2,
        'TimeStamp': ServerValue.timestamp,
      });

      if (mounted) {
        _messageController.clear();
        _scrollToBottom();
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _error = 'Failed to send message. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue("Chat"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chatbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() => _error = null),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: messagesList.length,
                itemBuilder: (context, index) {
                  final message = messagesList[index];
                  final isUserMessage = message['from'] == '2';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Colors.blue[100]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isUserMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isUserMessage)
                              Text(
                                'admin',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(message['message']),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type here...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (userKey != null) {
      _database.child('UsersList').child(userKey!).update({
        'userActive': '',
      });
    }
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}