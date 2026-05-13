import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:planetcombo/common/animated_image_carousel.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/add_horoscope_controller.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:planetcombo/controllers/appLoad_controller.dart';
import 'package:planetcombo/screens/payments/payment_dashboard.dart';
import 'package:planetcombo/screens/payments/pricing.dart';
import 'package:planetcombo/screens/policy.dart';
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
import 'package:planetcombo/main.dart' show appRouteObserver;
import 'package:planetcombo/screens/common/drawer.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:planetcombo/common/app_logger.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  // Constants
  static const bool enableVideoBackground = false;
  // Mobile-only: when true, show the animated image carousel instead of video.
  static const bool imageWallpaper = true;
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

    if (enableVideoBackground && !(_isMobile && imageWallpaper)) {
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

      // pot.mp4 was removed; mobile falls back to vid.mp4 for both
      // orientations. Unreachable while imageWallpaper is true.
      videoAssets = ['assets/videos/vid.mp4'];
      AppLogger.d('Mobile ${isPortrait ? "Portrait" : "Landscape"} - using vid.mp4');
    }

    AppLogger.d('Video assets determined: $videoAssets');
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
    AppLogger.d('=== VIDEO SETUP DEBUG ===');
    AppLogger.d('enableVideoBackground: $enableVideoBackground');
    AppLogger.d('Platform: ${_isWeb ? "Web" : "Mobile"}');
    AppLogger.d('Initial mute state: $_isMuted');
    AppLogger.d('========================');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _disposeVideoControllers();
    super.dispose();
  }

  // ---- RouteAware: pause/resume background video on navigation ----

  // Another route was pushed on top of the Dashboard — we're no longer
  // visible, so stop the video audio entirely.
  @override
  void didPushNext() {
    _pauseAllVideos();
  }

  // We came back to the Dashboard from another route — resume playback
  // (audio respects the current mute state) and reset the drawer's
  // selected highlight to "Dashboard" so the next open shows the right
  // active item (otherwise it'd still show whichever entry the user
  // tapped to leave — e.g. Terms & Conditions).
  @override
  void didPopNext() {
    _resumeCurrentVideo();
    if (_selectedDrawerIndex != 0) {
      setState(() => _selectedDrawerIndex = 0);
    }
  }

  void _resumeCurrentVideo() {
    if (_videoControllers.isEmpty ||
        _currentVideoIndex >= _videoControllers.length) {
      return;
    }
    final controller = _videoControllers[_currentVideoIndex];
    if (!controller.value.isInitialized) return;
    controller.setVolume(_isMuted ? 0.0 : videoVolume);
    if (!controller.value.isPlaying) {
      controller.play();
    }
  }

  Future<void> _initializeVideos() async {
    if (!mounted) return;

    AppLogger.d('Initializing ${videoAssets.length} videos...');
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
          AppLogger.d('Video $i initialized successfully');
        } else {
          controller.dispose();
        }
      } catch (e) {
        AppLogger.d('Error initializing video $i: $e');
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

    AppLogger.d('Starting video loop with ${_videoControllers.length} videos');
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
      AppLogger.d(
          'Playing video $_currentVideoIndex with ${_isMuted ? "muted" : "unmuted"} audio');
    } catch (e) {
      AppLogger.d('Error playing video: $e');
      _switchToNextVideo();
    }
  }

  void _videoListener() {
    if (!mounted || _currentVideoIndex >= _videoControllers.length) return;

    final controller = _videoControllers[_currentVideoIndex];

    if (!controller.value.isInitialized) {
      AppLogger.d('Controller became uninitialized during playback');
      return;
    }

    try {
      if (controller.value.hasError) {
        AppLogger.d('Video playback error: ${controller.value.errorDescription}');
        _switchToNextVideo();
        return;
      }

      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        AppLogger.d('Video finished, switching to next');
        _switchToNextVideo();
      }
    } catch (e) {
      AppLogger.d('Error in video listener: $e');
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
      AppLogger.d('Switching to video $_currentVideoIndex');

      if (mounted) {
        setState(() {});
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _playCurrentVideo();
        });
      }
    } catch (e) {
      AppLogger.d('Error switching video: $e');
    }
  }

  void _disposeVideoControllers() {
    AppLogger.d('Disposing ${_videoControllers.length} video controllers');
    for (var controller in _videoControllers) {
      try {
        controller.removeListener(_videoListener);
        controller.pause();
        controller.dispose();
      } catch (e) {
        AppLogger.d('Error disposing controller: $e');
      }
    }
    _videoControllers.clear();
  }

  void _toggleMute() {
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

    AppLogger.d('Audio ${_isMuted ? "muted" : "unmuted"}');
  }

  void _handleOrientationChange() {
    if (!_isWeb && mounted) {
      final size = MediaQuery.of(context).size;
      final newOrientation =
      size.height > size.width ? Orientation.portrait : Orientation.landscape;

      if (_currentOrientation != newOrientation) {
        _currentOrientation = newOrientation;
        AppLogger.d('Orientation changed to: $newOrientation');

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
      case 4:
        _navigateToTermsAndConditions();
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

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsConditions()),
    );
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
                AppLogger.d('Error loading image: $error'),
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
          iconPath: 'assets/svg/payment.svg',
          text: "Payment",
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PaymentDashboard())),
          showBorder: false,
        ),
      ],
    );
  }

  Widget _buildRightMenuColumn() {
    return Column(
      children: [
        _buildMenuItem(
          iconPath: 'assets/svg/today.svg',
          text: "Today Predictions",
          onTap: _showTodayPredictionsComingSoon,
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

  // Placeholder until the real Today Predictions screen is implemented.
  void _showTodayPredictionsComingSoon() {
    showFailedToast('Today Predictions - coming soon');
  }

  Widget _buildMenuDivider() {
    return Container(
      width: 0.5,
      height: 500,
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
    final primary = appLoadController.appPrimaryColor;
    final username = appLoadController.loggedUserData.value.username ?? '';

    return Stack(
      children: [
        Positioned.fill(
          child: enableVideoBackground && _isVideoInitialized
              ? _buildVideoBackground()
              : imageWallpaper
                  ? const AnimatedImageCarousel(
                      imagePaths: [
                        'assets/images/mobile/img1.png',
                        'assets/images/mobile/img2.png',
                        'assets/images/mobile/img3.jpg',
                        'assets/images/mobile/img4.png',
                        'assets/images/mobile/img5.png',
                      ],
                    )
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
        if (enableVideoBackground || imageWallpaper)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        // Welcome text sits directly above the bottom menu panel with a
        // 10px gap; both are anchored to the bottom edge.
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
              const SizedBox(height: 10),
              Container(
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
            child: SafeArea(
              top: false,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Horoscope Services + Today Predictions inside one
                  // full-width card, split 50/50 by a vertical centre
                  // divider (50% primary). Each half is independently
                  // tappable.
                  Container(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSplitCardHalf(
                              iconPath: 'assets/svg/horoscope.svg',
                              title: 'Horoscope Services',
                              primary: primary,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HoroscopeServices(),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 32,
                            color: primary.withOpacity(0.5),
                          ),
                          Expanded(
                            child: _buildSplitCardHalf(
                              iconPath: 'assets/svg/today.svg',
                              title: 'Today Predictions',
                              primary: primary,
                              onTap: _showTodayPredictionsComingSoon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8), // small gap between card and grid

                  // Grid – sizes itself to its content so the panel height
                  // matches the inner widgets rather than a fixed fraction
                  GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                          isNew: false,
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
                ],
              ),
            ),
            ),
          ),
            ],
          ),
        ),
      ],
    );
  }

  // One half of the full-width Horoscope / Today-Predictions card.
  Widget _buildSplitCardHalf({
    required String iconPath,
    required String title,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 26,
                height: 26,
                color: primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: commonBoldText(
                  text: LocalizationController.getInstance()
                      .getTranslatedValue(title),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
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
        width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: 26,
                    height: 26,
                    color: primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocalizationController.getInstance()
                        .getTranslatedValue(title),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
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
            height: 540,
            child: Stack(
              children: [
                _buildMenuGrid(),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _toggleMute,
                  tooltip: _isMuted ? 'Unmute' : 'Mute',
                ),
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
            if (enableVideoBackground && !imageWallpaper)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: _toggleMute,
                tooltip: _isMuted ? 'Unmute' : 'Mute',
              ),
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