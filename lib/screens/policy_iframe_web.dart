// Web implementation of the terms-and-conditions iframe registration.
// Selected via conditional import in policy.dart for web builds.
import 'dart:ui_web' as ui_web;
import 'package:universal_html/html.dart' as html;

final Set<String> _registered = <String>{};

// We keep a reference to each iframe so we can toggle pointer events on
// it from Flutter (e.g. disable iframe interactions while the Scaffold
// drawer is open — otherwise taps fall through to the PDF instead of
// the drawer items).
final Map<String, html.IFrameElement> _iframes = <String, html.IFrameElement>{};

void registerTermsIframeViewFactory(String viewType, String url) {
  // platformViewRegistry rejects duplicate registrations, so guard against
  // it (hot reload / re-entry into the Terms screen would otherwise crash).
  if (_registered.contains(viewType)) return;
  _registered.add(viewType);
  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      _iframes[viewType] = iframe;
      return iframe;
    },
  );
}

void setTermsIframePointerEvents(String viewType, bool enabled) {
  final iframe = _iframes[viewType];
  if (iframe == null) return;
  iframe.style.pointerEvents = enabled ? 'auto' : 'none';
}
