import 'package:flutter/material.dart';
import 'package:kd_utils/methods/get_week_day.dart';

void main() {
  // timeStamp(timeStamp: "1694160861");
  // final DateTime date = getDateTimeFromTimeStamp(timeStamp: "1694160861");
  // print(date);

  print(getWeekDay(8, short: true));

  // runApp(const MyApp());
  // test('adds one to input values', () {
  //   final calculator = Calculator();
  //   expect(calculator.addOne(2), 3);
  //   expect(calculator.addOne(-7), -6);
  //   expect(calculator.addOne(0), 1);
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}
