import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:planetcombo/screens/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

class FactsMyths extends StatefulWidget {
  const FactsMyths({super.key});

  @override
  State<FactsMyths> createState() => _FactsMythsState();
}

class _FactsMythsState extends State<FactsMyths> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

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
    _fadeController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double horizontalPadding = isMobile ? 16.0 : 80.0;

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
                Color(0xFFE6A43F), // Light orange/amber (top)
                Color(0xFFE67E22), // Medium orange
                Color(0xFFDD6B20), // Dark orange
                Color(0xFFC05621), // Deep orange/brown (bottom)
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
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
                      _buildHeader(isMobile),
                      _buildFactsSection(isMobile, horizontalPadding),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 16 : 40,
        isMobile ? 16 : 24,
        isMobile ? 16 : 20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFFFF9C4),
                      Colors.white,
                    ],
                  ).createShader(bounds),
                  child: commonBoldText(
                    text: LocalizationController.getInstance()
                        .getTranslatedValue("Myths & Facts"),
                    fontSize: isMobile ? 24 : 32,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox()
              // IconButton(
              //   icon: const Icon(Icons.home_outlined,
              //       color: Colors.white, size: 28),
              //   onPressed: () {
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => Dashboard()),
              //           (Route<dynamic> route) => false,
              //     );
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactsSection(bool isMobile, double horizontalPadding) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 24 : 40,
      ),
      child: Column(
        children: [
          _buildFactCard(
            'Fact#1.',
            "Scientifically, it is not possible to determine from a horoscope whether the horoscope owner is deceased or alive. The app assumes that the horoscope owner is alive and seeks guidance.",
            isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFactCard(
            'Fact#2.',
            "According to experts, astrology is a predictive science that isn't purely scientific. This app demonstrates that its predictions rely on two key factors: a) planetary calculations based on the Ephemeris supplied by NASA, and b) a prediction engine developed using horoscope and transitory positions following event rules. Notably, there is no manual intervention, aligning with the universality of methods across horoscopes.",
            isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFactCard(
            'Fact#3.',
            "Planet Combo has developed a birth time adjustment methodology that aligns effectively with the predictive approach. Accurate data is crucial for horoscope generation; otherwise, predictions may be inaccurate. Planet Combo offers a 30-day free service to verify predictions. Once validated, the horoscope is certified for full use.",
            isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFactCard(
            'Fact#4.',
            "Traditional Vedic astrology draws upon concepts such as Doshams, Yogams, Uttcham, and Neecham of houses and planets to make life predictions. CP Astrology, which builds upon the extended and expanded rules of KP Astrology, is actively researching Vedic principles further. Planet Combo remains committed to this research.",
            isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFactCard(
            'Fact#5.',
            "Can the Planet Combo app be used without birth details? The answer is NO. However, Planet Combo will try to create a horoscope based on past life events and explore options for generating the horoscope. Even in such cases, having the place and date is critical, and efforts will be made to determine the exact time.",
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(String title, String content, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE67E22).withOpacity(0.2),
            blurRadius: isMobile ? 15 : 20,
            spreadRadius: isMobile ? 3 : 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonBoldText(
            text: title,
            fontSize: isMobile ? 20 : 24,
            color: const Color(0xFF6A1B9A),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: isMobile ? 14 : 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}