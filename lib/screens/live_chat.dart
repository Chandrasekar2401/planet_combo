import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';

class LiveChat extends StatefulWidget {
  const LiveChat({Key? key}) : super(key: key);

  @override
  _LiveChatState createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  // Realtime Database URL. The Android entry in firebase_options.dart
  // doesn't carry a databaseURL, so we pass it explicitly when grabbing
  // the database instance. Same URL works for every platform since the
  // RTDB lives in one project.
  static const _databaseUrl =
      'https://flutterplanetcombo-ff367-default-rtdb.firebaseio.com';

  static const _tag = '[LiveChat]';

  // Controllers
  final _appLoadController = Get.find<AppLoadController>();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  // State variables
  late DatabaseReference _database;
  StreamSubscription? _messagesSubscription;
  final List<Map<String, dynamic>> _messagesList = [];

  String? _userKey;
  String? _error;
  int _messageCount = 0;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _initFailed = false;
  bool _showResponseNotification = false;

  // Cached user data
  late final String _userEmail;
  late final String _userProfile;

  @override
  void initState() {
    super.initState();
    _userEmail = _appLoadController.loggedUserData.value.userid ?? '';
    _userProfile = _appLoadController.loggedUserData.value.userphoto ?? '';
    debugPrint('$_tag initState userEmail="$_userEmail"');
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      debugPrint('$_tag _initializeFirebase: start');

      // Firebase is already initialized in main.dart for every platform.
      // Calling Firebase.initializeApp again with a different option set
      // throws [core/duplicate-app] and used to leave the page stuck on
      // an infinite loader. Just use the already-initialized default app.
      if (Firebase.apps.isEmpty) {
        debugPrint('$_tag _initializeFirebase: no apps, initializing default');
        await Firebase.initializeApp();
      } else {
        debugPrint(
            '$_tag _initializeFirebase: reusing existing app "${Firebase.apps.first.name}"');
      }

      // Grab the RTDB by URL so platforms whose FirebaseOptions don't
      // include a databaseURL (e.g. Android in firebase_options.dart)
      // still know where to read/write.
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: _databaseUrl,
      ).ref();
      debugPrint('$_tag _initializeFirebase: database ref acquired');

      await _initializeUser();

      if (!mounted) return;
      setState(() => _isInitialized = true);
      debugPrint('$_tag _initializeFirebase: done');
    } catch (e, st) {
      debugPrint('$_tag _initializeFirebase FAILED: $e\n$st');
      _handleInitFailure('Firebase initialization error', e);
    }
  }

  Future<void> _initializeUser() async {
    try {
      debugPrint('$_tag _initializeUser: start');
      if (_userEmail.isEmpty) throw Exception('User email not found');
      await _findOrCreateUser(_userEmail);
      debugPrint('$_tag _initializeUser: done (userKey=$_userKey)');
    } catch (e, st) {
      debugPrint('$_tag _initializeUser FAILED: $e\n$st');
      rethrow; // let _initializeFirebase surface the error
    }
  }

  Future<void> _findOrCreateUser(String email) async {
    debugPrint('$_tag _findOrCreateUser: looking up "$email"');
    final usersRef = _database.child('UsersList');

    // Timeout so a misconfigured DB / dead network shows an error
    // instead of spinning forever.
    final event = await usersRef
        .once()
        .timeout(const Duration(seconds: 15), onTimeout: () {
      throw TimeoutException(
          'Timed out reading UsersList from $_databaseUrl after 15s');
    });
    debugPrint(
        '$_tag _findOrCreateUser: snapshot received (exists=${event.snapshot.value != null})');

    if (event.snapshot.value != null) {
      final usersData = event.snapshot.value as Map;
      final existingUser = usersData.entries.firstWhere(
            (entry) => (entry.value as Map)['userEmail'] == email,
        orElse: () => MapEntry('', {}),
      );

      if (existingUser.key.isNotEmpty) {
        _userKey = existingUser.key;
        _messageCount = (existingUser.value as Map)['message'] ?? 0;
        debugPrint(
            '$_tag _findOrCreateUser: found existing user key=$_userKey count=$_messageCount');
      } else {
        await _createNewUser(email);
      }
    } else {
      await _createNewUser(email);
    }

    _startMessageListener();
  }

  Future<void> _createNewUser(String email) async {
    try {
      final newUserRef = _database.child('UsersList').push();
      _userKey = newUserRef.key;
      await newUserRef.set({
        'adminMessage': 0,
        'message': 0,
        'userActive': 'y',
        'userEmail': email,
        'userProfileUrl': _userProfile,
      });
    } catch (e) {
      _handleError('Error creating new user', e);
    }
  }

  void _startMessageListener() {
    if (_userKey == null) return;

    _messagesSubscription?.cancel();
    _messagesSubscription = _database
        .child('message/$_userKey')
        .onValue
        .listen(_handleMessageUpdate, onError: (error) {
      _handleError('Message listening error', error);
    });
  }

  void _handleMessageUpdate(DatabaseEvent event) {
    if (!mounted) return;

    try {
      if (event.snapshot.value != null) {
        final messagesData = event.snapshot.value as Map;
        final newMessages = messagesData.entries.map((entry) => {
          'key': entry.key,
          'time': entry.value['TimeStamp'],
          'message': entry.value['message'],
          'from': entry.value['from'].toString(),
        }).toList();

        // Sort messages by timestamp
        newMessages.sort((a, b) => (a['time'] ?? 0).compareTo(b['time'] ?? 0));

        // Check if last message is from user
        bool lastMessageFromUser = false;
        if (newMessages.isNotEmpty) {
          lastMessageFromUser = newMessages.last['from'] == '2';
        }

        setState(() {
          _messagesList
            ..clear()
            ..addAll(newMessages);

          // Show notification if last message is from user
          _showResponseNotification = lastMessageFromUser;
        });
        _scrollToBottom();
      }
    } catch (e) {
      _handleError('Message update error', e);
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _userKey == null) return;

    setState(() => _isLoading = true);

    try {
      _messageCount++;
      await Future.wait([
        _database.child('UsersList').child(_userKey!).update({
          'message': _messageCount,
          'userActive': 'y',
        }),
        _database.child('message').child(_userKey!).push().set({
          'message': message,
          'from': 2,
          'TimeStamp': ServerValue.timestamp,
        }),
      ]);

      if (mounted) {
        _messageController.clear();
        setState(() {
          _showResponseNotification = true;
        });
      }
    } catch (e) {
      _handleError('Error sending message', e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Removed the _showNotification() method as we no longer need timer-based hiding

  void _handleError(String context, dynamic error) {
    debugPrint('$_tag $context: $error');
    if (mounted) {
      setState(() => _error = 'An error occurred. Please try again.');
    }
  }

  // Used for failures during the initial load. Unblocks the build so the
  // user sees an error + retry instead of an unending CircularProgressIndicator.
  void _handleInitFailure(String context, dynamic error) {
    debugPrint('$_tag $context: $error');
    if (!mounted) return;
    setState(() {
      _initFailed = true;
      _isInitialized = true; // unblock the build
      _error = 'Could not connect to chat. ${error.toString()}';
    });
  }

  void _retryInit() {
    debugPrint('$_tag _retryInit');
    setState(() {
      _initFailed = false;
      _isInitialized = false;
      _error = null;
    });
    _initializeFirebase();
  }

  void _scrollToBottom() {
    if (!mounted) return;
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUserMessage = message['from'] == '2';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.blue[100] : Colors.white,
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
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
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
                  hintText: 'Please here...',
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
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.send),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseNotification() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showResponseNotification ? 40 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showResponseNotification ? 1.0 : 0.0,
        child: Container(
          width: double.infinity,
          color: Colors.blue.withOpacity(0.8),
          child: const Center(
            child: Text(
              'You reached the technical support. feel free to leave your questions here, our team will reply within 24 hours',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          title: LocalizationController.getInstance()
              .getTranslatedValue("Chat"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_initFailed) {
      return Scaffold(
        appBar: GradientAppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          title: LocalizationController.getInstance()
              .getTranslatedValue("Chat"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  _error ?? 'Could not load chat.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retryInit,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance()
            .getTranslatedValue("Chat"),
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
            _buildResponseNotification(),
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
                itemCount: _messagesList.length,
                itemBuilder: (_, index) => _buildMessageBubble(_messagesList[index]),
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_userKey != null) {
      _database.child('UsersList').child(_userKey!).update({
        'userActive': '',
      });
    }
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}