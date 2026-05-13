import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:planetcombo/screens/common/drawer.dart';
import 'package:planetcombo/screens/web/web_aboutus.dart';
import 'package:planetcombo/screens/web/web_article.dart';
import 'package:planetcombo/screens/web/web_contactUS.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:planetcombo/common/app_logger.dart';

// Conditional import: on web, pull in the real registerTermsIframeViewFactory
// that uses dart:ui_web + an IFrameElement. On mobile/desktop, pull in the
// stub so we don't reference dart:ui_web (which doesn't exist there).
import 'policy_iframe_stub.dart'
    if (dart.library.html) 'policy_iframe_web.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({Key? key}) : super(key: key);

  @override
  _TermsConditionsState createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  final ApplicationBaseController applicationBaseController =
      Get.put(ApplicationBaseController.getInstance(), permanent: true);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  WebViewController? webViewController;
  String? _webViewType;
  bool _hasError = false;
  // Mobile: tracks the WebView's loading state so we can overlay a
  // spinner while the (Google Docs viewer-wrapped) PDF is fetched.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final url =
        ApplicationBaseController.getInstance().termsAndConditionsLink.value;
    AppLogger.d('the terms and conditions link url $url');

    if (url.isEmpty) {
      _hasError = true;
      return;
    }

    if (kIsWeb) {
      // webview_flutter doesn't support web (setOnPageStarted etc. throw
      // UnimplementedError). Render the page in an <iframe> instead —
      // most browsers will use their built-in PDF viewer to display the
      // PDF inline, so we use the raw URL here.
      _webViewType =
          'terms-iframe-${url.hashCode.toRadixString(16)}';
      registerTermsIframeViewFactory(_webViewType!, url);
    } else {
      // Android's WebView has no PDF renderer; loading a .pdf URL
      // directly fails with net::ERR_CONNECTION_ABORTED. Wrap PDFs in
      // Google Docs Viewer so the WebView gets back rendered HTML.
      final loadUrl = _isPdfUrl(url)
          ? 'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(url)}'
          : url;

      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              // Stop the spinner so the user isn't stuck on a blank page
              // forever if the (Docs Viewer) load fails.
              if (mounted) setState(() => _isLoading = false);
            },
            // The previous implementation prevented navigation when the URL
            // started with the terms link — but the page we're loading IS
            // that link, so the initial load got blocked and the body
            // stayed blank. Allow navigation for everything.
            onNavigationRequest: (NavigationRequest request) =>
                NavigationDecision.navigate,
          ),
        )
        ..loadRequest(Uri.parse(loadUrl));
    }
  }

  bool _isPdfUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.pdf');
  }

  // Mirror Dashboard's drawer routing: the drawer is reachable from any
  // top-level screen, so each entry must navigate to the right place
  // from here. The Drawer is a Scaffold overlay (not a Navigator route),
  // so Navigator.pop won't close it — use the Scaffold's closeDrawer()
  // explicitly, which works on web too.
  void _handleDrawerItemTap(int index) {
    AppLogger.d('Terms drawer item tapped: index=$index', tag: 'TermsDrawer');
    _scaffoldKey.currentState?.closeDrawer();

    switch (index) {
      case 0:
        // Dashboard — walk all the way back to the root route. This
        // handles cases where there are more than one screen between
        // Terms and Dashboard (e.g. if the user reached Terms via
        // Articles → Terms).
        AppLogger.d('Terms drawer: popUntil first route (Dashboard)',
            tag: 'TermsDrawer');
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        AppLogger.d('Terms drawer: pushReplacement -> Articles',
            tag: 'TermsDrawer');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => buildWebArticle()),
        );
        break;
      case 2:
        AppLogger.d('Terms drawer: pushReplacement -> About Us',
            tag: 'TermsDrawer');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => buildWebAboutUs()),
        );
        break;
      case 3:
        AppLogger.d('Terms drawer: pushReplacement -> Contact',
            tag: 'TermsDrawer');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => buildWebContactUs()),
        );
        break;
      case 4:
        // Already on Terms & Conditions — closing the drawer is enough.
        AppLogger.d('Terms drawer: already on Terms, just closing drawer',
            tag: 'TermsDrawer');
        break;
    }
  }

  // On web the body is an <iframe> rendered as an HtmlElementView. The
  // iframe consumes all DOM pointer events, so taps on the Scaffold's
  // drawer overlay never reach Flutter — they get eaten by the PDF
  // viewer behind the drawer (this is why "Logout" felt like it was
  // scrolling the page). Toggle pointer-events: none on the iframe
  // while the drawer is open so the drawer items become tappable.
  void _onDrawerChanged(bool isOpen) {
    AppLogger.d('Terms Scaffold drawer changed: isOpen=$isOpen kIsWeb=$kIsWeb',
        tag: 'TermsDrawer');
    if (!kIsWeb || _webViewType == null) return;
    setTermsIframePointerEvents(_webViewType!, !isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: DashboardDrawer(
        onItemTap: _handleDrawerItemTap,
        selectedIndex: 4,
        isLoggedIn: true,
        context: context,
      ),
      onDrawerChanged: _onDrawerChanged,
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            AppLogger.d('Terms menu icon tapped -> openDrawer',
                tag: 'TermsDrawer');
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: LocalizationController.getInstance()
            .getTranslatedValue("Terms and Conditions"),
        colors: const [Color(0xFFf2b20a), Color(0xFFf34509)],
        centerTitle: true,
      ),
      body: _hasError
          ? Center(
              child: commonText(
                text: 'Policy will update soon',
                color: Colors.black12,
              ),
            )
          : kIsWeb
              ? HtmlElementView(viewType: _webViewType!)
              : Stack(
                  children: [
                    WebViewWidget(controller: webViewController!),
                    if (_isLoading)
                      Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFf34509)),
                            ),
                            const SizedBox(height: 16),
                            commonText(
                              text: 'Loading Terms and Conditions...',
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
