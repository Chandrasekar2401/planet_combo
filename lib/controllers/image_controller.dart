import 'package:http/http.dart' as http;

class CorsHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Access-Control-Allow-Origin'] = '*';
    return _inner.send(request);
  }
}