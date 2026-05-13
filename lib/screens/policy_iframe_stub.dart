// Mobile/desktop stub for the terms-and-conditions iframe registration.
// The real implementation lives in policy_iframe_web.dart and is selected
// via a conditional import on web builds. This file exists only so that
// non-web builds can compile without pulling in dart:ui_web.
void registerTermsIframeViewFactory(String viewType, String url) {
  // Intentionally empty — never called outside web.
}

void setTermsIframePointerEvents(String viewType, bool enabled) {
  // Intentionally empty — never called outside web.
}
