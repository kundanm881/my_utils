import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kd_utils/kd_utils.dart';

class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});

  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  int? kDate;
  FocusNode focusNode = FocusNode();

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
                // print(selectedDate);
                setState(() {
                  int poch = (selectedDate.microsecondsSinceEpoch);
                  kDate = (poch / 1000000).round();
                });
              },
            ),
            20.height,
            if (kDate != null)
              Text(timeStampToDateTime(kDate!).toString())
            else
              Text("No Data $kDate"),
            20.height,
            OTPView(
              otpCount: 5,
              style: OTPStyle(
                  cursorColor: Colors.green,
                  maxHeight: 60,
                  inputBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 3,
                    ),
                  ),
                  isDense: true,
                  // maxWidth: 10,
                  space: 20),
              onSubmit: (otp) {
                log(otp.toString());
              },
              controller: TextEditingController(),
            ),
            20.height,
            ElevatedButton(
              onPressed: () {
                kSnackBar(context, message: "das das");
              },
              child: Text("snack"),
            )
          ],
        ),
      ),
    );
  }
}
