import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:planetcombo/common/widgets.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:planetcombo/controllers/appLoad_controller.dart';


class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _MysticalPricingPageState();
}

class _MysticalPricingPageState extends State<PricingPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);

  @override
  void initState() {
    super.initState();
    // Rotation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Fade and slide animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    const scrollAmount = 50.0;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _scroll(-scrollAmount);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _scroll(scrollAmount);
      }
    }
  }

  void _scroll(double amount) {
    if (_scrollController.hasClients) {
      double newOffset = _scrollController.offset + amount;
      newOffset = newOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildAnimatedContent(Widget child) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }

  String currencyType(){
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'){
      return '₹ ';
    }else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed'){
      return 'AED ';
    }else{
      return '\$ ';
    }
  }

  String kundliAmount(){
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'){
      return '499';
    }else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed'){
      return '50';
    }else{
      return '30';
    }
  }

  String lifeGuidanceAmount(){
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'){
      return '399';
    }else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed'){
      return '50';
    }else{
      return '20';
    }
  }

  String dailyRequestAmount(){
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'){
      return '699';
    }else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed'){
      return '45';
    }else{
      return '20';
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2D1B69), // Dark purple
                Color(0xFF6A1B9A), // Mid purple
                Color(0xFF4A148C), // Transition purple
                Color(0xFF1A1035), // Deep indigo
              ],
              stops: [0.0, 0.4, 0.7, 1.0],
            ),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 8,
            radius: const Radius.circular(4),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: _buildAnimatedContent(
                Column(
                  children: [
                    _buildTopSection(),
                    _buildPricingSection(),
                    _buildBottomSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 2,
            width: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0),
                  Colors.amber,
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFFC107),
                Color(0xFFFFD700),
              ],
            ).createShader(bounds),
            child: commonBoldText(
              text: title,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Container(
            height: 2,
            width: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber,
                  Colors.amber.withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFFC107),
                Color(0xFFFFD700),
              ],
            ).createShader(bounds),
            child: commonBoldText(
              text: 'KNOW YOUR FUTURE',
              fontSize: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStyledText(
                        'The PlanetCombo tool, harnesses the power of ',
                        highlightText: 'CP Astrology (Chandrasekar Pathathi)',
                        remainingText: ', a prediction system built after years of scientific research based on proven Indian astrology.',
                      ),
                      const SizedBox(height: 20),
                      _buildStyledText(
                        'Our tools are based on scientific calculations designed to improve prediction accuracy.',
                      ),
                      const SizedBox(height: 20),
                      _buildStyledText(
                        'The tool predicts significant life events like ',
                        highlightText: 'Marriage, Career, Finance, Health, Love Life, Education, Travel',
                        remainingText: ' and more.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: _buildRotatingLogo(small: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingLogo({bool small = false}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: small ? 190 : 380,
          height: small ? 190 : 380,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
              width: small ? 1 : 2,
            ),
          ),
        ),
        Container(
          width: small ? 180 : 360,
          height: small ? 180 : 360,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: small ? 170 : 440,
                height: small ? 170 : 440,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.transparent, Colors.transparent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.2),
                      blurRadius: small ? 15 : 30,
                      spreadRadius: small ? 1 : 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/headletters.png',
                    width: small ? 170 : 500,
                    height: small ? 170 : 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        children: [
          _buildSectionTitle('Our Pricing Plans'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 400, // Fixed height for all pricing cards
                  child: _buildPricingCard(
                    'Introductory offer',
                    kundliAmount(),
                    ['Personalized Chart Generation', '30 Days Free Daily Prediction from the date of chart generation', 'Two life guidance questions answered(within 30 days of registration)'],
                    Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 400, // Fixed height for all pricing cards
                  child: _buildPricingCard(
                    'Daily Predictions',
                    dailyRequestAmount(),
                    ['90 days Daily predictions from date of request'],
                    Colors.amber,
                    isPopular: true,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 400, // Fixed height for all pricing cards
                  child: _buildPricingCard(
                    'Life Guidance',
                    lifeGuidanceAmount(),
                    ['Two Life Guidance Questions'],
                    Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(80, 40, 80, 80),
      child: Column(
        children: [
          _buildSectionTitle('Our Services'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200, // Fixed height for info cards
                      child: _buildInfoCard(
                          'Unique',
                          'PlanetCombo is the only astrology service offering personalised and accurate predictions.',
                          Icons.auto_awesome,
                          ""
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200, // Fixed height for info cards
                      child: _buildInfoCard(
                          'Horoscope/Kundli',
                          'Provides North Indian and South Indian Formats with adjusted birth time.',
                          Icons.psychology,
                          ""
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200, // Fixed height for info cards
                      child: _buildInfoCard(
                          'Personalized Daily Forecasts',
                          "Get accurate daily predictions to give you the day's insight.",
                          Icons.precision_manufacturing,
                          ""
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200, // Fixed height for info cards
                      child: _buildInfoCard(
                          'Life Guidance',
                          'Get answers to specific life questions through our tools.',
                          Icons.light,
                          ""
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
      String title,
      String price,
      List<String> features,
      Color color, {
        bool isPopular = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonBoldText(
            text: title,
            fontSize: 24,
            color: color,
          ),
          const SizedBox(height: 16),
          commonBoldText(
            text: currencyType()+price,
            fontSize: 40,
            color: color,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView( // Add scrolling for overflow content
              child: Column(
                children: features.map((feature) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: commonText(
                          text: feature,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          const Divider(
            height: 0.01, // Reduced height
            color: Colors.black12, // Lighter opacity
          ),
          const SizedBox(height: 16), // Increased spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'?
                'assets/svg/upi-icon.svg' :  'assets/svg/stripe.svg',
                height: 24,
              ),
              const SizedBox(width: 8),
              commonBoldText(text: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'?
                'Pay securely with UPI' :  'Pay securely with Stripe',
                color: color,
                fontSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 8), // Added bottom padding
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData? icon, String? imagePath) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imagePath == "" ?
          Icon(icon, color: Colors.amber, size: 32):
          SizedBox(height:40, child: SvgPicture.asset(imagePath!)),
          const SizedBox(height: 16),
          commonBoldText(
            text: title,
            fontSize: 18,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          commonBoldText(
            text: subtitle,
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledText(String text, {String? highlightText, String? remainingText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 12),
          child: Icon(
            Icons.auto_awesome,
            color: Colors.amber,
            size: 20,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
              children: [
                TextSpan(text: text),
                if (highlightText != null)
                  TextSpan(
                    text: highlightText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                if (remainingText != null)
                  TextSpan(text: remainingText),
              ],
            ),
          ),
        ),
      ],
    );
  }

}