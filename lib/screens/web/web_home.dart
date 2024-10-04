import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/common/theme_widgets.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:planetcombo/screens/web/webLogin.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';

class WebHomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  final List<String> imgList = [
    'assets/images/web/bg1.jpg',
    'assets/images/web/bg2.jpg',
    'assets/images/web/bg3.jpg',
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

  int _selectedIndex = 0;

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close the drawer after selecting an item
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 2.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
       return appLoadController.userValue.value == true ? const Dashboard() : const WebLogin();
      case 2:
        return buildWebArticle();
      case 3:
        return buildWebAboutUs();
      case 4:
        return buildWebContactUs();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: imgList.length,
          itemBuilder: (context, index, realIndex) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double scale = _animation.value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imgList[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(children: [
                    commonBoldText(text: 'PLANET COMBO', color: Colors.white, fontSize: 62),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],),
                  SizedBox(height: 20),
                  commonBoldText(text: 'ASTROLOGY LIFE PREDICTIONS', fontSize: 32, color: Colors.white),
                  SizedBox(height: 20),
                  commonBoldText(text: '(CHANDRASEKAR PATHATHI - CP ASTROLOGY)', fontSize: 22, color: Colors.white),
                  SizedBox(height: 25),
                  commonColorButton(
                      textPadding: 18,
                      fontSize: 22,
                      title: 'Book Services',
                      textColor: Colors.white,
                      buttonColor: Colors.deepOrange,
                      onPressed: (){
                        appLoadController.userValue.value == true ?
                        Navigator.pushNamed(context, '/dashboard') :
                        Navigator.pushNamed(context, '/webLogin');
                      }),
                ],
              )
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        onItemTap: _handleItemTap,
        selectedIndex: _selectedIndex,
      ),
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }
}