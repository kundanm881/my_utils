import 'package:kd_utils/kd_utils.dart';

class MyApi extends  AppApiService{
  ApiState apiState = ApiState.loading;
  @override
  Future get(String url) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future post(String url, {required Map<String, dynamic> body}) {
    // TODO: implement post
    throw UnimplementedError();
  }
}