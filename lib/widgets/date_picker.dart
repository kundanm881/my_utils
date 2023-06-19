import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kd_utils/extensions/extensions.dart';

class DatePicker extends StatefulWidget {
  final DateTime currentDate;
  final DateTime startDate;
  final DateTime endDate;
  final TextStyle? monthStyle;

  const DatePicker({
    super.key,
    required this.currentDate,
    required this.startDate,
    required this.endDate,
    this.monthStyle,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  ScrollController dateScrollController = ScrollController();

  @override
  void initState() {
    _scrollerInit();

    super.initState();
  }

  // add liserner to controller
  _scrollerInit() {
    dateScrollController.addListener(() {
      print(dateScrollController.offset);
    });
  }

  @override
  void dispose() {
    dateScrollController.dispose();
    super.dispose();
  }

  int get _getDayes => widget.endDate.difference(widget.startDate).inDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Month", style: widget.monthStyle ?? monthTextStyle),
        8.height,
        Container(
          height: 80,
          child: ListView.separated(
            controller: dateScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _getDayes,
            itemBuilder: (context, index) => Container(
              width: 80,
              decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(
                  "${DateFormat().format(widget.currentDate)} ${widget.startDate.add(Duration(days: index))}"),
            ),
            separatorBuilder: (context, index) => 10.width,
          ),
        ),
      ],
    );
  }

  // style
  TextStyle get monthTextStyle =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
}
