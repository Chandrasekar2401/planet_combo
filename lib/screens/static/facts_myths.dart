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
                    _buildHeader(),
                    _buildFactsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFC107),
                    Color(0xFFFFD700),
                  ],
                ).createShader(bounds),
                child: commonBoldText(
                  text: LocalizationController.getInstance()
                      .getTranslatedValue("Myths & Facts"),
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.home_outlined, color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Dashboard()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFactsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Column(
        children: [
          _buildFactCard(
            'Fact#1.',
            "Scientifically, it is not possible to determine from a horoscope whether the chart owner is deceased or alive. The app assumes that the chart owner is alive and seeks guidance.",
          ),
          const SizedBox(height: 20),
          _buildFactCard(
            'Fact#2.',
            "According to experts, astrology is a predictive science that isn't purely scientific. This app demonstrates that its predictions rely on two key factors: a) planetary calculations based on the Ephemeris supplied by NASA, and b) a prediction engine developed using chart and transitory positions following event rules. Notably, there is no manual intervention, aligning with the universality of methods across charts.",
          ),
          const SizedBox(height: 20),
          _buildFactCard(
            'Fact#3.',
            "Planet Combo has developed a birth time adjustment methodology that aligns effectively with the predictive approach. Accurate data is crucial for chart generation; otherwise, predictions may be inaccurate. PLANETCOMBO offers a 30-day free service to verify predictions. Once validated, the chart is certified for full use.",
          ),
          const SizedBox(height: 20),
          _buildFactCard(
            'Fact#4.',
            "Traditional Vedic astrology draws upon concepts such as Doshams, Yogams, Uttcham, and Neecham of houses and planets to make life predictions. CP Astrology, which builds upon the extended and expanded rules of KP Astrology, is actively researching Vedic principles further. PLANETCOMBO remains committed to this research.",
          ),
          const SizedBox(height: 20),
          _buildFactCard(
            'Fact#5.',
            "Can the PLANETCOMBO app be used without birth details? The answer is NO. However, PLANETCOMBO will try to create a chart based on past life events and explore options for generating the chart. Even in such cases, having the place and date is critical, and efforts will be made to determine the exact time.",
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}