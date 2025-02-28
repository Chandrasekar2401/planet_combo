import 'package:flutter/material.dart';
import 'package:planetcombo/common/widgets.dart';
import 'package:planetcombo/controllers/localization_controller.dart';
import 'package:get/get.dart';
import 'package:planetcombo/controllers/applicationbase_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({Key? key}) : super(key: key);

  @override
  _TermsConditionsState createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  final ApplicationBaseController applicationBaseController =
  Get.put(ApplicationBaseController.getInstance(), permanent: true);

  late WebViewController webViewController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    print('the terms and conditions link url ${ApplicationBaseController.getInstance().termsAndConditionsLink.value}');
    if(ApplicationBaseController.getInstance().termsAndConditionsLink.value == ''){
      setState(() {
        _hasError = true;
      });
    }else{
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar.
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onWebResourceError: (WebResourceError error) {
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith(ApplicationBaseController.getInstance().termsAndConditionsLink.value)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(ApplicationBaseController.getInstance().termsAndConditionsLink.value));
    }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: LocalizationController.getInstance().getTranslatedValue("Terms and Conditions"),
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
          : WebViewWidget(controller: webViewController),
    );
  }
}