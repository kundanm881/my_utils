# Kd Utils package

A package to make smooth and fast devlepment

## Get Started

```dart
import 'package:kd_utils/kd_utils.dart';
```

<h1>Date Picker </h1>

<img src="assets\demo_date_time.png" width=300/>

<h2>Usage.</h2>

```dart
DatePickerView(
  currentDate: DateTime.now(),
  startDate: DateTime.now().subtract(Duration(days: 50)),
  endDate: DateTime.now().add(Duration(days: 50)),
  weekday: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
  onDateClick: (selectedDate) {
    print(selectedDate);
  },
),
```

# Dot Line painter

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

# Extension methos

Widgets Extension 

```dart
200.height,

10.width,
```
Context Extension

```dart
ThemeData themeData = context.theme;

EdgeInsets padding = context.viewPadding;
    
Size screenSize = context.screenSize;
    
double screenWidth = context.screenWidth;
    
double screenHeight = context.screenHeight;
```


# Base Api class

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
