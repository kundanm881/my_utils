# Kd Utils package

A package to make smooth and fast devlepment

## Get Started

```dart
import 'package:kd_utils/kd_utils.dart';
```

### Dot Line painter

```dart
CustomPaint(
 painter: DotLinePainter(
  dotheight: 4,
  space: 16,
  strokeWdith: 5,
  strokeCap: StrokeCap.round,
  axis: Axis.vertical,
 ),
),
```

#### User of extension

Sizebox Extension

```dart
200.height,
10.width,
```

#### Base api class

```dart
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
