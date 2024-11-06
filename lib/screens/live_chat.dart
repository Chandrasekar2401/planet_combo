import 'dart:async';
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../controllers/appLoad_controller.dart';

class LiveChat extends StatefulWidget {
  const LiveChat({Key? key}) : super(key: key);
  @override
  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = appLoadController.loggedUserData.value.userid!;
    _createUserChatCollection();
  }

  Future<void> _createUserChatCollection() async {
    try {
      // Create a document for the user if it doesn't exist
      final userChatRef = _firestore.collection('userChats').doc(currentUserId);
      final doc = await userChatRef.get();

      if (!doc.exists) {
        await userChatRef.set({
          'userId': currentUserId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error creating user chat collection: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create message data
      final messageData = {
        'senderId': currentUserId,
        'senderType': 'user', // To differentiate between user and admin messages
        'message': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'sent',
        'isRead': false
      };

      // Add message to user-specific subcollection
      await _firestore
          .collection('userChats')
          .doc(currentUserId)
          .collection('messages')
          .add(messageData)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Connection timeout. Please check your internet.');
        },
      );

      // Update last active timestamp
      await _firestore
          .collection('userChats')
          .doc(currentUserId)
          .update({
        'lastActive': FieldValue.serverTimestamp(),
        'lastMessage': _messageController.text.trim(),
      });

      if (mounted) {
        _messageController.clear();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Message sent successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      print('Error sending message: $e');
      String errorMessage = 'Failed to send message';

      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            errorMessage = 'Permission denied. Please check your authentication.';
            break;
          case 'unavailable':
            errorMessage = 'Service is currently unavailable. Please try again later.';
            break;
          default:
            errorMessage = 'Error: ${e.message}';
        }
      } else if (e is TimeoutException) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      }

      if (mounted) {
        setState(() {
          _error = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _sendMessage,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            image: AssetImage('assets/images/bg_profile.png'),
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
              child: StreamBuilder<QuerySnapshot>(
                // Updated stream to use user-specific messages
                stream: _firestore
                    .collection('userChats')
                    .doc(currentUserId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet\nStart a conversation!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final isUserMessage = data['senderType'] == 'user';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            IntrinsicWidth(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isUserMessage ? Colors.blue[100] : Colors.white,
                                      borderRadius: BorderRadius.circular(7)
                                  ),
                                  child: ClipPath(
                                    clipper: ChatMessageClipper(),
                                    child: ListTile(
                                      title: commonText(
                                          text: isUserMessage ? 'You' : 'Admin',
                                          fontSize: 14,
                                          color: Colors.blue
                                      ),
                                      subtitle: commonText(
                                          text: data['message']
                                      ),
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(height: 7)
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Message input section remains the same
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_isLoading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(
                          Icons.send,
                          size: 27,
                          color: Colors.green,
                        ),
                        onPressed: _sendMessage,
                      ),
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
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(16, 0);
    path.lineTo(size.width - 16, 0);
    path.lineTo(size.width - 16, size.height - 16);
    path.quadraticBezierTo(size.width - 16, size.height, size.width, size.height);
    path.lineTo(16, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 16);
    path.lineTo(0, 16);
    path.quadraticBezierTo(0, 0, 16, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
