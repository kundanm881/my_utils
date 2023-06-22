import 'package:flutter/material.dart';
import 'package:kd_utils/kd_utils.dart';

class DatePickerDemo extends StatelessWidget {
  const DatePickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff1f1f1),
      appBar: AppBar(
        title: Text("DateTime demo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            20.height,
            DatePickerView(
              currentDate: DateTime.now(),
              startDate: DateTime.now().subtract(Duration(days: 50)),
              endDate: DateTime.now().add(Duration(days: 50)),
              weekday: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              onDateClick: (selectedDate) {
                print(selectedDate);
              },
            ),
          ],
        ),
      ),
    );
  }
}
