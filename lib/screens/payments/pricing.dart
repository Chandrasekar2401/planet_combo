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
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

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

  // Currency and pricing helper methods
  String currencyType() {
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr') {
      return '₹ ';
    } else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed') {
      return 'AED ';
    } else {
      return '\$ ';
    }
  }

  String kundliAmount() {
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr') {
      return '499';
    } else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed') {
      return '50';
    } else {
      return '30';
    }
  }

  String lifeGuidanceAmount() {
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr') {
      return '399';
    } else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed') {
      return '50';
    } else {
      return '20';
    }
  }

  String dailyRequestAmount() {
    if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr') {
      return '699';
    } else if(appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'aed') {
      return '45';
    } else {
      return '20';
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double horizontalPadding = isMobile ? 16.0 : 80.0;
    final double titleFontSize = isMobile ? 28.0 : 40.0;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      autofocus: true,
      child: Scaffold(
        appBar: isMobile ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(0,17, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          // Remove default back button label
          automaticallyImplyLeading: false,
        ) : null,
        // Make the body fill the screen minus the status bar
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2D1B69),
                Color(0xFF6A1B9A),
                Color(0xFF4A148C),
                Color(0xFF1A1035),
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
                    _buildTopSection(isMobile, horizontalPadding, titleFontSize),
                    _buildPricingSection(isMobile, horizontalPadding),
                    _buildBottomSection(isMobile, horizontalPadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  Widget _buildTopSection(bool isMobile, double horizontalPadding, double titleFontSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
              fontSize: isMobile ? 24 : titleFontSize,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 80),
            child: isMobile
                ? Column(
              children: [
                _buildRotatingLogo(small: true),
                const SizedBox(height: 24),
                _buildMobileDescriptionText(),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildDescriptionText(),
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

  Widget _buildMobileDescriptionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyledText(
          'The PlanetCombo tool, harnesses the power of ',
          highlightText: 'CP Astrology',
          remainingText: ', a prediction system built after years of research.',
        ),
        const SizedBox(height: 16),
        _buildStyledText(
          'Our tools are based on scientific calculations for accuracy.',
        ),
        const SizedBox(height: 16),
        _buildStyledText(
          'Predicts events like ',
          highlightText: 'Marriage, Career, Finance, Health',
          remainingText: ' and more.',
        ),
      ],
    );
  }

  Widget _buildDescriptionText() {
    return Column(
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

  Widget _buildPricingSection(bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          _buildSectionTitle('Our Pricing Plans', isMobile),
          if (isMobile)
            Column(
              children: [
                _buildPricingCard(
                  'Introductory offer',
                  kundliAmount(),
                  ['Personalized Chart Generation', '30 Days Free Daily Prediction', 'Two life guidance questions'],
                  Colors.purple,
                  isMobile: true,
                ),
                const SizedBox(height: 20),
                _buildPricingCard(
                  'Daily Predictions',
                  dailyRequestAmount(),
                  ['90 days Daily predictions'],
                  Colors.amber,
                  isPopular: true,
                  isMobile: true,
                ),
                const SizedBox(height: 20),
                _buildPricingCard(
                  'Life Guidance',
                  lifeGuidanceAmount(),
                  ['Two Life Guidance Questions'],
                  Colors.purple,
                  isMobile: true,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPricingCard(
                    'Introductory offer',
                    kundliAmount(),
                    ['Personalized Chart Generation', '30 Days Free Daily Prediction', 'Two life guidance questions'],
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildPricingCard(
                    'Daily Predictions',
                    dailyRequestAmount(),
                    ['90 days Daily predictions'],
                    Colors.amber,
                    isPopular: true,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildPricingCard(
                    'Life Guidance',
                    lifeGuidanceAmount(),
                    ['Two Life Guidance Questions'],
                    Colors.purple,
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
        bool isMobile = false,
      }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          commonBoldText(
            text: title,
            fontSize: isMobile ? 20 : 24,
            color: color,
          ),
          const SizedBox(height: 16),
          commonBoldText(
            text: currencyType() + price,
            fontSize: isMobile ? 32 : 40,
            color: color,
          ),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: color, size: isMobile ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: commonText(
                    text: feature,
                    textAlign: TextAlign.left,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
          )).toList(),
          const SizedBox(height: 16),
          const Divider(height: 0.01, color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'
                    ? 'assets/svg/upi-icon.svg'
                    : 'assets/svg/stripe.svg',
                height: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr' ? 24 : 39,
              ),
              const SizedBox(width: 8),
              commonBoldText(
                text: appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr'
                    ? ' - Pay securely with UPI'
                    : ' - Pay securely with Stripe',
                color: Colors.purple,
                fontSize: isMobile ? 12 : 14,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    final double lineWidth = isMobile ? 50 : 100;
    final double fontSize = isMobile ? 24 : 32;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 2,
            width: lineWidth,
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
              fontSize: fontSize,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Container(
            height: 2,
            width: lineWidth,
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

  Widget _buildBottomSection(bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 80),
      child: Column(
        children: [
          _buildSectionTitle('Our Services', isMobile),
          if (isMobile)
            Column(
              children: [
                _buildInfoCard(
                  'Unique',
                  'PlanetCombo offers personalised and accurate predictions.',
                  Icons.auto_awesome,
                  "",
                  isMobile: true,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  'Horoscope/Kundli',
                  'North Indian and South Indian Formats available.',
                  Icons.psychology,
                  "",
                  isMobile: true,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  'Daily Forecasts',
                  "Get accurate daily predictions.",
                  Icons.precision_manufacturing,
                  "",
                  isMobile: true,
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  'Life Guidance',
                  'Get answers to specific life questions.',
                  Icons.light,
                  "",
                  isMobile: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoCard(
                        'Unique',
                        'PlanetCombo offers personalised and accurate predictions.',
                        Icons.auto_awesome,
                        "",
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        'Horoscope/Kundli',
                        'North Indian and South Indian Formats available.',
                        Icons.psychology,
                        "",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoCard(
                        'Daily Forecasts',
                        "Get accurate daily predictions.",
                        Icons.precision_manufacturing,
                        "",
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        'Life Guidance',
                        'Get answers to specific life questions.',
                        Icons.light,
                        "",
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

  Widget _buildInfoCard(
      String title,
      String subtitle,
      IconData? icon,
      String? imagePath, {
        bool isMobile = false,
      }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          imagePath == ""
              ? Icon(icon, color: Colors.amber, size: isMobile ? 28 : 32)
              : SizedBox(height: 40, child: SvgPicture.asset(imagePath!)),
          SizedBox(height: isMobile ? 12 : 16),
          commonBoldText(
            text: title,
            fontSize: isMobile ? 16 : 18,
            color: Colors.white,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          commonBoldText(
            text: subtitle,
            fontSize: isMobile ? 12 : 14,
            color: Colors.white.withOpacity(0.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}