import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/screens/payments/payment_dashboard.dart';
import 'package:planetcombo/screens/payments/pricing.dart';
import 'package:planetcombo/screens/profile/profile.dart';
import 'package:planetcombo/screens/services/horoscope_services.dart';
import 'package:planetcombo/screens/static/facts_myths.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';
import 'package:planetcombo/screens/web/web_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:planetcombo/screens/live_chat.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:planetcombo/youtube_listing.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/screens/common/drawer.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Constants
  static const bool enableVideoBackground = true;
  static const double videoPlaybackSpeed = 0.8;
  static const double videoVolume = 0.3;
  static const double profileImageSize = 32;
  static const String defaultAvatarAsset = 'assets/imgs/profile_avatar.png';

  // Keys and Controllers
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalAuthentication auth = LocalAuthentication();
  final LocalizationController localizationController =
  Get.put(LocalizationController.getInstance(), permanent: true);
  final AppLoadController appLoadController =
  Get.put(AppLoadController.getInstance(), permanent: true);
  final AddHoroscopeController addHoroscopeController =
  Get.put(AddHoroscopeController.getInstance(), permanent: true);
  final Constants constants = Constants();

  // State Variables
  int _selectedDrawerIndex = 0;
  bool _isMuted = true; // Start muted by default for web, will be false for mobile
  Orientation? _currentOrientation;

  // Video Variables
  List<String> videoAssets = [];
  final List<VideoPlayerController> _videoControllers = [];
  int _currentVideoIndex = 0;
  bool _isVideoInitialized = false;

  bool get _isWeb => kIsWeb;
  bool get _isMobile => !_isWeb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _debugVideoSetup();

    // For mobile, start with audio enabled (unmuted)
    if (!_isWeb) {
      _isMuted = false;
    }

    if (enableVideoBackground) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          _determineVideoAssets();
          _initializeVideos();
        }
      });
    }
  }

  void _determineVideoAssets() {
    if (_isWeb) {
      // Web always uses landscape video
      videoAssets = ['assets/videos/vid.mp4'];
    } else {
      // Mobile: determine based on screen orientation
      final size = MediaQuery.of(context).size;
      final isPortrait = size.height > size.width;

      if (isPortrait) {
        // Portrait mode - use portrait video
        videoAssets = ['assets/videos/pot.mp4'];
        print('Mobile Portrait mode detected - using pot.mp4');
      } else {
        // Landscape mode (including tablets) - use landscape video
        videoAssets = ['assets/videos/vid.mp4'];
        print('Mobile Landscape mode detected - using vid.mp4');
      }
    }

    print('Video assets determined: $videoAssets');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _syncVideoState();
    } else if (state == AppLifecycleState.paused) {
      _pauseAllVideos();
    }
  }

  void _syncVideoState() {
    if (_videoControllers.isNotEmpty &&
        _currentVideoIndex < _videoControllers.length &&
        _videoControllers[_currentVideoIndex].value.isInitialized) {
      final controller = _videoControllers[_currentVideoIndex];

      controller.setVolume(_isMuted ? 0.0 : videoVolume);

      if (!controller.value.isPlaying) {
        _playCurrentVideo();
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _pauseAllVideos() {
    for (var controller in _videoControllers) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
  }

  void _debugVideoSetup() {
    print('=== VIDEO SETUP DEBUG ===');
    print('enableVideoBackground: $enableVideoBackground');
    print('Platform: ${_isWeb ? "Web" : "Mobile"}');
    print('Initial mute state: $_isMuted');
    print('========================');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeVideoControllers();
    super.dispose();
  }

  Future<void> _initializeVideos() async {
    if (!mounted) return;

    print('Initializing ${videoAssets.length} videos...');
    _disposeVideoControllers();

    for (int i = 0; i < videoAssets.length; i++) {
      final controller = VideoPlayerController.asset(videoAssets[i]);

      try {
        await controller.initialize();

        if (!mounted) {
          controller.dispose();
          return;
        }

        if (controller.value.isInitialized &&
            controller.value.size.width > 0 &&
            controller.value.size.height > 0 &&
            controller.value.duration > Duration.zero) {
          controller.setLooping(false);
          controller.setVolume(_isMuted ? 0.0 : videoVolume);
          controller.setPlaybackSpeed(videoPlaybackSpeed);

          _videoControllers.add(controller);
          print('Video $i initialized successfully');
        } else {
          controller.dispose();
        }
      } catch (e) {
        print('Error initializing video $i: $e');
        controller.dispose();
      }
    }

    if (_videoControllers.isNotEmpty && mounted) {
      setState(() => _isVideoInitialized = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startVideoLoop();
      });
    }
  }

  void _startVideoLoop() {
    if (_videoControllers.isEmpty || !mounted) return;

    print('Starting video loop with ${_videoControllers.length} videos');
    _currentVideoIndex = 0;
    _playCurrentVideo();
  }

  void _playCurrentVideo() {
    if (_currentVideoIndex >= _videoControllers.length || !mounted) return;
    final controller = _videoControllers[_currentVideoIndex];

    if (!controller.value.isInitialized) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _playCurrentVideo();
      });
      return;
    }

    try {
      controller.seekTo(Duration.zero);
      controller.setPlaybackSpeed(videoPlaybackSpeed);
      controller.setVolume(_isMuted ? 0.0 : videoVolume);

      controller.removeListener(_videoListener);
      controller.addListener(_videoListener);

      controller.play();
      print(
          'Playing video $_currentVideoIndex with ${_isMuted ? "muted" : "unmuted"} audio');
    } catch (e) {
      print('Error playing video: $e');
      _switchToNextVideo();
    }
  }

  void _videoListener() {
    if (!mounted || _currentVideoIndex >= _videoControllers.length) return;

    final controller = _videoControllers[_currentVideoIndex];

    if (!controller.value.isInitialized) {
      print('Controller became uninitialized during playback');
      return;
    }

    try {
      if (controller.value.hasError) {
        print('Video playback error: ${controller.value.errorDescription}');
        _switchToNextVideo();
        return;
      }

      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        print('Video finished, switching to next');
        _switchToNextVideo();
      }
    } catch (e) {
      print('Error in video listener: $e');
      _switchToNextVideo();
    }
  }

  void _switchToNextVideo() {
    if (!mounted || _videoControllers.isEmpty) return;
    try {
      if (_currentVideoIndex < _videoControllers.length) {
        _videoControllers[_currentVideoIndex].removeListener(_videoListener);
        _videoControllers[_currentVideoIndex].pause();
      }

      _currentVideoIndex = (_currentVideoIndex + 1) % _videoControllers.length;
      print('Switching to video $_currentVideoIndex');

      if (mounted) {
        setState(() {});
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _playCurrentVideo();
        });
      }
    } catch (e) {
      print('Error switching video: $e');
    }
  }

  void _disposeVideoControllers() {
    print('Disposing ${_videoControllers.length} video controllers');
    for (var controller in _videoControllers) {
      try {
        controller.removeListener(_videoListener);
        controller.pause();
        controller.dispose();
      } catch (e) {
        print('Error disposing controller: $e');
      }
    }
    _videoControllers.clear();
  }

  void _toggleMute() {
    if (_isWeb) {
      setState(() {
        _isMuted = !_isMuted;
      });

      if (_videoControllers.isNotEmpty &&
          _currentVideoIndex < _videoControllers.length &&
          _videoControllers[_currentVideoIndex].value.isInitialized) {
        _videoControllers[_currentVideoIndex]
            .setVolume(_isMuted ? 0.0 : videoVolume);

        if (!_isMuted &&
            !_videoControllers[_currentVideoIndex].value.isPlaying) {
          _playCurrentVideo();
        }
      }

      print('Audio ${_isMuted ? "muted" : "unmuted"}');
    }
  }

  void _handleOrientationChange() {
    if (!_isWeb && mounted) {
      final size = MediaQuery.of(context).size;
      final newOrientation =
      size.height > size.width ? Orientation.portrait : Orientation.landscape;

      if (_currentOrientation != newOrientation) {
        _currentOrientation = newOrientation;
        print('Orientation changed to: $newOrientation');

        _determineVideoAssets();
        if (enableVideoBackground) {
          _initializeVideos();
        }
      }
    }
  }

  void _onPageResumed() {
    _handleOrientationChange();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncVideoState();
      }
    });
  }

  // Navigation Methods
  void _handleDrawerItemTap(int index) {
    appLoadController.userValue.value = true;
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        break; // Dashboard
      case 1:
        _navigateToArticles();
        break;
      case 2:
        _navigateToAboutUs();
        break;
      case 3:
        _navigateToContact();
        break;
    }
  }

  void _navigateToArticles() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => buildWebArticle()));
  }

  void _navigateToAboutUs() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => buildWebAboutUs()));
  }

  void _navigateToContact() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => buildWebContactUs()));
  }

  Future<void> _showLogoutDialog() async {
    return yesOrNoDialog(
      context: context,
      dialogMessage: LocalizationController.getInstance()
          .getTranslatedValue('Are you sure you want to logout?'),
      cancelText:
      LocalizationController.getInstance().getTranslatedValue('No'),
      okText: LocalizationController.getInstance().getTranslatedValue('Yes'),
      cancelAction: () => Navigator.pop(context),
      okAction: _performLogout,
    );
  }

  Future<void> _performLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    appLoadController.userValue.value = false;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WebHomePage()),
          (route) => false,
    );
  }

  // PROFILE IMAGE

  Widget _buildProfileImage(String imageUrl) {
    if (_isWeb) {
      return _buildWebProfileImage(imageUrl);
    }
    return _buildMobileProfileImage(imageUrl);
  }

  Widget _buildWebProfileImage(String imageUrl) {
    return ClipOval(
      child: Container(
        width: profileImageSize,
        height: profileImageSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl, headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET',
            }),
            fit: BoxFit.cover,
            onError: (error, stackTrace) =>
                print('Error loading image: $error'),
          ),
        ),
        child: Image.network(
          imageUrl,
          width: profileImageSize,
          height: profileImageSize,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: profileImageSize,
            height: profileImageSize,
            color: Colors.grey[300],
            child: const Icon(Icons.person, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileProfileImage(String imageUrl) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => Container(
          width: 40,
          height: 40,
          color: Colors.grey[300],
          child: const Icon(Icons.person, size: 22),
        ),
      ),
    );
  }

  // BACKGROUND VIDEO LAYER

  Widget _buildVideoBackground() {
    if (!enableVideoBackground ||
        !_isVideoInitialized ||
        _videoControllers.isEmpty ||
        _currentVideoIndex >= _videoControllers.length) {
      return const SizedBox.shrink();
    }

    final controller = _videoControllers[_currentVideoIndex];

    if (controller.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // OLD MENU GRID (WEB ONLY)

  Widget _buildMenuItem({
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    bool showBorder = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 125,
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
            bottom: BorderSide(
              color: enableVideoBackground
                  ? Colors.white.withOpacity(0.3)
                  : appLoadController.appPrimaryColor,
              width: 0.3,
            ),
          )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 52,
              height: 52,
              color: enableVideoBackground
                  ? Colors.white
                  : appLoadController.appPrimaryColor,
            ),
            const SizedBox(height: 12),
            commonBoldText(
              text: LocalizationController.getInstance()
                  .getTranslatedValue(text),
              fontSize: 13,
              color: enableVideoBackground
                  ? Colors.white
                  : appLoadController.appPrimaryColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/Headletters_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            commonBoldText(
              fontSize: 21,
              color: Colors.white,
              text: LocalizationController.getInstance()
                  .getTranslatedValue("Welcome to Planet Combo"),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: commonText(
                fontSize: 14,
                color: Colors.white,
                textAlign: TextAlign.center,
                text: LocalizationController.getInstance().getTranslatedValue(
                  "Planetary calculation on horoscopes, Dasas and transists powered by True Astrology software",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Positioned.fill(
      top: 15,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final menuWidth =
          kIsWeb ? (screenWidth * 0.85).clamp(800.0, 1600.0) : screenWidth;

          return Center(
            child: SizedBox(
              width: menuWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: enableVideoBackground ? Colors.transparent : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      _buildVideoBackground(),
                      if (enableVideoBackground)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ),
                      _buildMenuContent(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLeftMenuColumn(),
        _buildMenuDivider(),
        _buildRightMenuColumn(),
      ],
    );
  }

  Widget _buildLeftMenuColumn() {
    return Column(
      children: [
        _buildMenuItem(
          iconPath: 'assets/svg/horoscope.svg',
          text: "Horoscope Services",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HoroscopeServices())),
        ),
        _buildMenuItem(
          iconPath: 'assets/svg/app.svg',
          text: "About Planetcombo",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FactsMyths())),
        ),
        _buildMenuItem(
          iconPath: 'assets/svg/Profile_Update.svg',
          text: "Profile",
          onTap: () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Profile())),
        ),
        _buildMenuItem(
          iconPath: 'assets/svg/support.svg',
          text: "Tech Support",
          onTap: () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LiveChat())),
          showBorder: false,
        ),
      ],
    );
  }

  Widget _buildRightMenuColumn() {
    return Column(
      children: [
        _buildMenuItem(
          iconPath: 'assets/svg/payment.svg',
          text: "Payment",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PaymentDashboard())),
        ),
        _buildMenuItem(
          iconPath: 'assets/svg/wallet.svg',
          text: "Pricing Plans",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PricingPage())),
        ),
        _buildMenuItem(
          iconPath: 'assets/svg/youtube.svg',
          text: "How to Use",
          onTap: () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const YouTubeVideosPage())),
        ),
        // Terms & Conditions removed from dashboard in both views
      ],
    );
  }

  Widget _buildMenuDivider() {
    return Container(
      width: 0.5,
      height: 390,
      color: enableVideoBackground
          ? Colors.white.withOpacity(0.5)
          : appLoadController.appPrimaryColor,
    );
  }

  void _handleTermsAndConditions() {
    final link =
        ApplicationBaseController.getInstance().termsAndConditionsLink.value;
    if (link.isEmpty) {
      showFailedToast('Error : Link Not found');
    } else {
      launchUrl(Uri.parse(link));
    }
  }

  Widget _buildLogoutButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final logoutWidth =
        kIsWeb ? (screenWidth * 0.85).clamp(800.0, 1600.0) : screenWidth;

        return Center(
          child: SizedBox(
            width: logoutWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: GestureDetector(
                onTap: _showLogoutDialog,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/logout.svg',
                                width: 16,
                                height: 16,
                                color: appLoadController.appPrimaryColor,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  LocalizationController.getInstance()
                                      .getTranslatedValue(
                                      "Logout - (${appLoadController.loggedUserData.value.userid})"),
                                  style: TextStyle(
                                    color: appLoadController.appPrimaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        return isWideScreen ? _buildWideScreenFooter() : _buildMobileFooter();
      },
    );
  }

  Widget _buildWideScreenFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildContactSection()),
          Expanded(child: _buildCopyrightSection()),
        ],
      ),
    );
  }

  Widget _buildMobileFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          _buildCopyrightSection(),
          const Divider(color: Colors.black12, height: 24),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonBoldText(
          text: "NAME : VENKATARAMAN CHANDRASEKAR",
          color: Colors.black,
          fontSize: 11,
        ),
        const SizedBox(height: 4),
        commonText(
          text:
          "ADDRESS: 7, KANNADASAN SALAI, T NAGAR THIYAGARAYA NAGAR CHENNAI",
          color: Colors.black,
          fontSize: 10,
        ),
        const SizedBox(height: 4),
        commonText(
          text: "STATE : TAMIL NADU , POSTAL CODE : 600017",
          color: Colors.black,
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildCopyrightSection() {
    final isINR =
        appLoadController.loggedUserData.value.ucurrency!.toLowerCase() == 'inr';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        commonBoldText(
          textAlign: TextAlign.right,
          text: isINR
              ? LocalizationController.getInstance()
              .getTranslatedValue("Domain Name : PlanetCombo.com")
              : LocalizationController.getInstance()
              .getTranslatedValue("© Planet Combo... All rights reserved"),
          fontSize: 11,
          color: Colors.black,
        ),
        const SizedBox(height: 4),
        commonText(
          textAlign: TextAlign.right,
          text: isINR
              ? LocalizationController.getInstance().getTranslatedValue(
              "Planetary calculations on horoscopes, Dasas and transits powered by True Astrology software")
              : LocalizationController.getInstance()
              .getTranslatedValue("Developed by Planetcombo Team"),
          fontSize: 10,
          color: Colors.black,
        ),
        const SizedBox(height: 4),
        commonText(
          fontSize: 11,
          color: Colors.black,
          textAlign: TextAlign.right,
          text: isINR
              ? '© ${LocalizationController.getInstance().getTranslatedValue("V.Chandrasekar... All rights reserved")}'
              : LocalizationController.getInstance()
              .getTranslatedValue("Version : 1.0.0"),
        ),
      ],
    );
  }

  // ---------- NEW MOBILE DASHBOARD LAYOUT ----------

  Widget _buildMobileDashboardBody() {
    final size = MediaQuery.of(context).size;
    final primary = appLoadController.appPrimaryColor;
    final username = appLoadController.loggedUserData.value.username ?? '';

    // ~70% video, ~30% bottom panel
    final double panelHeight = size.height * 0.35;

    return Stack(
      children: [
        // Background video
        Positioned.fill(
          child: enableVideoBackground && _isVideoInitialized
              ? _buildVideoBackground()
              : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFf2b20a), Color(0xFFf34509)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Dark overlay for readability
        if (enableVideoBackground)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

        // Center welcome text (no button)
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                commonText(
                  text: LocalizationController.getInstance()
                      .getTranslatedValue("Hi, $username"),
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 4),
                commonBoldText(
                  text: LocalizationController.getInstance()
                      .getTranslatedValue("Welcome to Planet Combo"),
                  fontSize: 22,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),

        // Bottom white panel
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height:panelHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Horoscope Services full-width card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HoroscopeServices(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primary.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/horoscope.svg',
                              width: 28,
                              height: 28,
                              color: primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: commonBoldText(
                                text:
                                LocalizationController.getInstance()
                                    .getTranslatedValue("Horoscope Services"),
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: commonBoldText(text:
                                'NEW',
                                color: Colors.white,
                                fontSize: 9
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8), // small gap between card and grid

                  // Grid – now starts right under the card
                  Flexible(
                    fit: FlexFit.loose,
                    child: GridView.count(
                      padding: EdgeInsets.zero,              // <-- no extra padding
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.3,
                      shrinkWrap: true,                      // <-- use only required height
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildMobileMenuTile(
                          title: "Payment",
                          iconPath: 'assets/svg/payment.svg',
                          isNew: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentDashboard(),
                              ),
                            );
                          },
                        ),
                        _buildMobileMenuTile(
                          title: "Pricing Plans",
                          iconPath: 'assets/svg/wallet.svg',
                          isNew: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PricingPage(),
                              ),
                            );
                          },
                        ),
                        _buildMobileMenuTile(
                          title: "How to Use",
                          iconPath: 'assets/svg/youtube.svg',
                          isNew: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const YouTubeVideosPage(),
                              ),
                            );
                          },
                        ),
                        _buildMobileMenuTile(
                          title: "Profile",
                          iconPath: 'assets/svg/Profile_Update.svg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Profile(),
                              ),
                            );
                          },
                        ),
                        _buildMobileMenuTile(
                          title: "Tech Support",
                          iconPath: 'assets/svg/support.svg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LiveChat(),
                              ),
                            );
                          },
                        ),
                        _buildMobileMenuTile(
                          title: "About Us",
                          iconPath: 'assets/svg/app.svg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FactsMyths(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenuTile({
    required String title,
    required String iconPath,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    final primary = appLoadController.appPrimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 26,
                    height: 26,
                    color: primary,
                  ),
                  const Spacer(),
                  Text(
                    LocalizationController.getInstance()
                        .getTranslatedValue(title),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            if (isNew)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- WEB BODY (UNCHANGED LAYOUT) ----------

  Widget _buildWebDashboardBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 620,
            child: Stack(
              children: [
                _buildMenuGrid(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildLogoutButton(),
          _buildFooter(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onPageResumed();
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: _isMobile,
        drawer: DashboardDrawer(
          onItemTap: _handleDrawerItemTap,
          selectedIndex: _selectedDrawerIndex,
          isLoggedIn: true,
          context: context,
        ),
        appBar: _isWeb
            ? GradientAppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          actions: [
            if (enableVideoBackground && _isWeb)
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleMute,
                tooltip: _isMuted ? 'Unmute' : 'Mute',
              ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Profile())),
              child: SizedBox(
                height: 40,
                width: 40,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ClipOval(
                    child: _buildProfileImage(
                        appLoadController.loggedUserData.value.userphoto!),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  const Icon(Icons.payment_outlined,
                      color: Colors.white, size: 16),
                  commonBoldText(
                    text:
                    ' - ${appLoadController.loggedUserData.value.ucurrency ?? ""}',
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
          ],
          title: LocalizationController.getInstance().getTranslatedValue(
              "Welcome !  ${appLoadController.loggedUserData.value.username}"),
          colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
          centerTitle: true,
        )
            : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const Profile())),
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildProfileImage(
                    appLoadController.loggedUserData.value.userphoto!),
              ),
            ),
          ],
        ),
        body:
        _isWeb ? _buildWebDashboardBody() : _buildMobileDashboardBody(),
      ),
    );
  }
}