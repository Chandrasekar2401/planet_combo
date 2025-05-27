import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_home.dart';

Widget buildWebContactUs() {
  return const ContactPage();
}

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 3; // Contact tab
  final AppLoadController appLoadController = Get.put(AppLoadController.getInstance(), permanent: true);
  final Constants constants = Constants();

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pop(); // Close drawer

    switch (index) {
      case 0: // Home/Dashboard
        if (appLoadController.userValue.value) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WebHomePage()));
        }
        break;
      case 1: // Articles
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => buildWebArticle()));
        break;
      case 2: // About Us
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => buildWebAboutUs()));
        break;
      case 3: // Contact (current page)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = appLoadController.userValue.value;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        context: context,
        onItemTap: _handleItemTap,
        selectedIndex: _selectedIndex,
        isLoggedIn: isLoggedIn,
      ),
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/web/article_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(60, 70, 60, 0), // Updated padding for menu
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContactInfoSection(),
                    const SizedBox(height: 20),
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
                              const SizedBox(width: 20),
                              Expanded(child: MessageForm()),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              MapSection(),
                              const SizedBox(height: 20),
                              MessageForm(),
                              const SizedBox(height: 50), // Add space at bottom for mobile
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16.0,
              left: 16.0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 650;

    if (isSmallScreen) {
      // Vertical layout for small screens
      return Column(
        children: [
          ContactInfoItem(
            icon: Icons.location_on,
            title: 'Address',
            content: '123 Street Name, City, 32008',
          ),
          const SizedBox(height: 20),
          ContactInfoItem(
            icon: Icons.phone,
            title: 'Phone',
            content: '+974 4430 0437',
          ),
          const SizedBox(height: 20),
          ContactInfoItem(
            icon: Icons.email,
            title: 'Email Address',
            content: 'headlettersapi@gmail.com',
          ),
        ],
      );
    } else {
      // Horizontal layout for wider screens
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
            content: 'headlettersapi@gmail.com',
          ),
        ],
      );
    }
  }
}

class ContactInfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const ContactInfoItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 40),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(45.5231, -122.6765), // Portland, OR coordinates
            zoom: 6,
          ),
          zoomControlsEnabled: false,
          markers: <Marker>{
            Marker(
              markerId: MarkerId('office_location'),
              position: LatLng(45.5231, -122.6765),
              infoWindow: InfoWindow(title: 'Our Office'),
            ),
          },
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
      // Send email logic would go here

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
          const SnackBar(
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leave a Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              validator: _validateRequired,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Email',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Phone',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectController,
              validator: _validateRequired,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Subject',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              validator: _validateRequired,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Message',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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