
abstract class AppApiService {
  Future get(String url);
  Future post(String url, {required Map<String, dynamic> body});

  @deprecated
  urlToUri(String url) {
    return Uri.parse(url);
  }

  @deprecated
  exception(String exceptionMessage) {
    return Exception(exceptionMessage);
  }
}


