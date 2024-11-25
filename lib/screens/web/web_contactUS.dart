import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;

Widget buildWebContactUs() {
  return ContactPage();
}

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/web/article_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(60, 20, 60, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContactInfoSection(),
                SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: MapSection(),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(child: MessageForm()),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          MapSection(),
                          SizedBox(height: 20),
                          MessageForm(),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ContactInfoItem(
          icon: Icons.location_on,
          title: 'Address',
          content: '123 Street Name, City, 32008',
        ),
        ContactInfoItem(
          icon: Icons.phone,
          title: 'Phone',
          content: '+974 4430 0437',
        ),
        ContactInfoItem(
          icon: Icons.email,
          title: 'Email Address',
          content: 'headletterscapi@gmail.com',
        ),
      ],
    );
  }
}

class ContactInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  ContactInfoItem({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 40),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

class MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(45.5231, -122.6765), // Portland, OR coordinates
          zoom: 6,
        ),
      ),
    );
  }
}

class MessageForm extends StatefulWidget {
  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
  }


  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState?.reset();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error sending email: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave a Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              validator: _validateRequired,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _subjectController,
              validator: _validateRequired,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _messageController,
              validator: _validateRequired,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: _isSending
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
                    : Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}