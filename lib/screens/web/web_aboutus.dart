import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';
import 'package:planetcombo/screens/web/web_home.dart';

Widget buildWebAboutUs() {
  return const WebAboutUsPage();
}

class WebAboutUsPage extends StatefulWidget {
  const WebAboutUsPage({Key? key}) : super(key: key);

  @override
  State<WebAboutUsPage> createState() => _WebAboutUsPageState();
}

class _WebAboutUsPageState extends State<WebAboutUsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2; // About Us tab
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
      case 2: // About Us (current page)
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const SizedBox(height: 70), // Space for menu button
                    commonBoldText(text: 'About Planet Combo', color: Colors.white, fontSize: 42),
                    const SizedBox(height: 20),
                    commonText(text: "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance.", color: Colors.white),
                    const SizedBox(height: 20),
                    commonText(text: "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.", color: Colors.white),
                    const SizedBox(height: 20),
                    commonText(text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.", color: Colors.white),
                    const SizedBox(height: 100)
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

// Custom Drawer Widget
class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  final int selectedIndex;
  final bool isLoggedIn;

  final Constants constant = Constants();

  CustomDrawer({super.key, required this.onItemTap, required this.selectedIndex, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                boxShadow: const [],
              ),
              child: Image.asset('assets/images/headletters.png'),
            ),
            _createDrawerItem(
              icon: Icons.home_outlined,
              text: isLoggedIn ? 'Dashboard' : 'Home',
              onTap: () => onItemTap(0),
              isSelected: selectedIndex == 0,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/article.svg',
              text: 'Articles',
              onTap: () => onItemTap(1),
              isSelected: selectedIndex == 1,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/about1.svg',
              text: 'About us',
              onTap: () => onItemTap(2),
              isSelected: selectedIndex == 2,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/contact1.svg',
              text: 'Contact',
              onTap: () => onItemTap(3),
              isSelected: selectedIndex == 3,
            ),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.all(12),
                child: commonBoldText(text: '© 2024 Planet Combo - All Rights Reserved.', fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    String? svgIcon,
    IconData? icon,
    required String text,
    required GestureTapCallback onTap,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: ListTile(
        leading: svgIcon == null ? Icon(
          icon,
          size: 21,
          color: isSelected ? constant.appPrimaryColor : Colors.black,
        ) :
        SvgPicture.asset(
          svgIcon,
          colorFilter: ColorFilter.mode(
            isSelected ? constant.appPrimaryColor : Colors.black,
            BlendMode.srcIn,
          ),
          width: 21,
          height: 21,
        ),
        title: Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? constant.appPrimaryColor  : Colors.black,
          ),
        ),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}