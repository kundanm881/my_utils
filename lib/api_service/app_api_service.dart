abstract class AppApiService {
  Future get(String url);
  Future post(String url, {required Map<String, dynamic> body});

  urlToUri(String url) {
    return Uri.parse(url);
  }

  exception(String exceptionMessage) {
    return Exception(exceptionMessage);
  }
}