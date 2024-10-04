import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
                          Expanded(child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: MapSection(),
                          )),
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

  ContactInfoItem({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 40),
        SizedBox(height: 10),
        Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
        SizedBox(height: 5),
        Text(content, style: TextStyle(color: Colors.white, fontSize: 14)),
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
          target: LatLng(45.5231, -122.6765),  // Portland, OR coordinates
          zoom: 6,
        ),
      ),
    );
  }
}

class MessageForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave a Message',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Name',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Email',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Phone',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Subject',
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Message',
            ),
            maxLines: 4,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            ),
            onPressed: () {
              // Handle form submission
            },
          ),
        ],
      ),
    );
  }
}