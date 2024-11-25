import 'dart:js' as js;
import 'dart:html' as html;

class WebInterop {
  static bool checkScript(String id) {
    return html.document.getElementById(id) != null;
  }

  static void loadScript(String id, String src, Function onLoad) {
    final script = html.ScriptElement()
      ..id = id
      ..type = 'text/javascript'
      ..src = src;

    script.onLoad.listen((_) {
      onLoad();
    });

    html.document.head!.append(script);
  }

  static dynamic createAutocompleteService() {
    return js.JsObject(
        js.context['google']['maps']['places']['AutocompleteService']
    );
  }

  static dynamic createRequest(String input) {
    return js.JsObject.jsify({
      'input': input,
      'types': ['(cities)']
    });
  }

  static void getPredictions(dynamic service, dynamic request, Function callback) {
    service.callMethod('getPlacePredictions', [
      request,
      js.allowInterop(callback)
    ]);
  }
}