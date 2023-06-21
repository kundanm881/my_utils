import 'package:flutter/material.dart';

import 'date_picker_view.dart';
// part 'date_picker_view.dart';

abstract class DatePickerState extends State<DatePickerView> {
  late ScrollController dateScrollController;
  late DateTime currentDate, startDate, endDate;
  final double boxSize = 80;

  List<DateTime> dates = [];

  _verInit() {
    dateScrollController = ScrollController();
    currentDate = DateTime(
      widget.currentDate.year,
      widget.currentDate.month,
      widget.currentDate.day,
    );
    startDate = DateTime(
      widget.startDate.year,
      widget.startDate.month,
      widget.startDate.day,
    );
    endDate = DateTime(
      widget.endDate.year,
      widget.endDate.month,
      widget.endDate.day,
    );
  }

  _setListDates() {
    for (int i = 0; i < getDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    print(dates);
  }

  int get getDays => endDate.difference(startDate).inDays;

  @override
  void initState() {
    _verInit();
    _setListDates();
    // int _currentDateIndex;
    print(dates.indexOf(currentDate));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      dateScrollController.animateTo(
          (dates.indexOf(currentDate) * (boxSize + widget.dateSpacing)),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn);
    });

    super.initState();
  }

  @override
  void dispose() {
    dateScrollController.dispose();
    super.dispose();
  }

  // style
  TextStyle get monthTextStyle =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  String getWeekDay(DateTime dateTime) {
    int weekday = dateTime.weekday;
    switch (weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "day not found";
    }
  }
}
