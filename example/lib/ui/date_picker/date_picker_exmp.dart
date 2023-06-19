import 'package:flutter/material.dart';
import 'package:kd_utils/kd_utils.dart';

class DatePickerDemo extends StatelessWidget {
  const DatePickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("DateTime demo"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            20.height,
            DatePicker(
              currentDate: DateTime.now(),
              startDate: DateTime.now().subtract(Duration( days: 100)),
              endDate: DateTime.now().add(Duration(days: 100)),
            ),
          ],
        ),
      ),
    );
  }
}

