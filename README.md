
# Kd Utils package

A package to make smooth and fast devlepment

## Getting Started

import package

```dart
import 'package:kd_utils/kd_utils.dart';
```

use .height, .width insted sizebox

```dart
200.height,
10.width,
```

## Use base api abstract class
```dart
import 'package:kd_utils/api_service/app_api_service.dart';

class MyApi extends  AppApiService{
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
```
