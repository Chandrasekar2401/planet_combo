import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';
import 'package:planetcombo/screens/web/web_home.dart';

Widget buildWebArticle() {
  return const WebArticlePage();
}

class WebArticlePage extends StatefulWidget {
  const WebArticlePage({Key? key}) : super(key: key);

  @override
  State<WebArticlePage> createState() => _WebArticlePageState();
}

class _WebArticlePageState extends State<WebArticlePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 1; // Articles tab
  final Constants constants = Constants();

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).pop(); // Close drawer

    switch (index) {
      case 0: // Home/Dashboard
      print('the value of logged user ${appLoadController.userValue.value}');
        if (appLoadController.userValue.value) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WebHomePage()));
        }
        break;
      case 1: // Articles (current page)
        break;
      case 2: // About Us
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => buildWebAboutUs()));
        break;
      case 3: // Contact
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => buildWebContactUs()));
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
              child: Column(
                children: [
                  const SizedBox(height: 70), // Space for app bar
                  commonBoldText(text: 'Articles', color: Colors.white, fontSize: 32),
                  const SizedBox(height: 20), // Bottom padding for the title
                  ResponsiveAstrologyCards(),
                  const SizedBox(height: 100),
                ],
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

class ResponsiveAstrologyCards extends StatelessWidget {
  final List<Map<String, String>> cardData = [
    {
      'image': 'assets/images/web/article1.jpg',
      'title': 'Neque Porro Quisquam Est Qui Dolorem Ipsum Neque Porro Quisquam Est Qui Dolorem Ipsum',
      'description': 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit. Nulla Sit Amet Libero Sed Erat Lacinia Vestibulum Sed Molestie Urna. Nunc Sagittis Ipsum Sit Amet Finibus Finibus.',
    },
    {
      'image': 'assets/images/web/article2.jpg',
      'title': 'Neque Porro Quisquam Est Qui Dolorem Ipsum Neque Porro Quisquam Est Qui Dolorem Ipsum',
      'description': 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit. Nulla Sit Amet Libero Sed Erat Lacinia Vestibulum Sed Molestie Urna. Nunc Sagittis Ipsum Sit Amet Finibus Finibus.',
    },
    {
      'image': 'assets/images/web/article3.jpg',
      'title': 'Neque Porro Quisquam Est Qui Dolorem Ipsum Neque Porro Quisquam Est Qui Dolorem Ipsum',
      'description': 'Lorem Ipsum Dolor Sit Amet, Consectetur Adipiscing Elit. Nulla Sit Amet Libero Sed Erat Lacinia Vestibulum Sed Molestie Urna. Nunc Sagittis Ipsum Sit Amet Finibus Finibus.',
    },
  ];

  ResponsiveAstrologyCards({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return _buildWideLayout();
        } else if (constraints.maxWidth > 800) {
          return _buildMediumLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cardData.map((data) => Expanded(child: _buildCard(data))).toList(),
      ),
    );
  }

  Widget _buildMediumLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildCard(cardData[0])),
              const SizedBox(width: 16),
              Expanded(child: _buildCard(cardData[1])),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(cardData[2]),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: cardData.map((data) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCard(data),
        )).toList(),
      ),
    );
  }

  Widget _buildCard(Map<String, String> data) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              data['image']!,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  data['description']!,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text('READ MORE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}