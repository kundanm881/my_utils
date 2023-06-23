import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kd_utils/extensions/extensions.dart';
import 'package:kd_utils/widgets/date_picker/date_picker_state.dart';

class DatePickerView extends StatefulWidget {
  final DateTime currentDate;
  final DateTime startDate;
  final DateTime endDate;
  final TextStyle? yearMonth, day, weekday;
  final double dateSpacing;
  final Function(DateTime selectedDate) onDateClick;
  final Color? color, dayColor, weekdayColor;
  final Color? activeColor, activeDay, activeWeekday;
  final double dayWeekHeight;
  final BoxDecoration decoration;

  const DatePickerView({
    super.key,
    required this.currentDate,
    required this.startDate,
    required this.endDate,
    this.yearMonth,
    this.dateSpacing = 10,
    required this.onDateClick,
    this.color,
    this.activeColor,
    this.day = const TextStyle(fontSize: 20),
    this.weekday = const TextStyle(),
    this.activeDay,
    this.activeWeekday,
    this.dayColor,
    this.weekdayColor,
    this.dayWeekHeight = 4,
    this.decoration = const BoxDecoration(),
  });

  @override
  State<DatePickerView> createState() => _DatePickerViewState();
}

class _DatePickerViewState extends DatePickerState {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: dateScrollController,
          builder: (context, child) {
            DateTime scrollerDate = widget.startDate.add(Duration(
                days: (dateScrollController.hasClients)
                    ? (dateScrollController.offset / 90).round()
                    : 0));
            return Text("${DateFormat("yyy - MMM").format(scrollerDate)}",
                style: widget.yearMonth ?? monthTextStyle);
          },
        ),
        8.height,
        Container(
          height: boxSize,
          child: ListView.separated(
            controller: dateScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  widget.onDateClick(dates[index]);
                  setState(() {
                    currentDate = dates[index];
                  });
                },
                child: Container(
                  width: boxSize,
                  decoration: widget.decoration.copyWith(
                    color: (currentDate == dates[index])
                        ? widget.activeColor ??
                            context.appTheme.colorScheme.primary
                        : widget.color ??
                            context.appTheme.colorScheme.onSecondaryContainer,
                    // borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${getWeekDay(dates[index])}",
                          style: widget.weekday!.copyWith(
                              color: (dates[index] == currentDate)
                                  ? widget.activeWeekday ?? Colors.white
                                  : widget.weekdayColor ?? Colors.black)),
                      widget.dayWeekHeight.height,
                      Text(
                        "${DateFormat("dd").format(dates[index])}",
                        style: widget.day!.copyWith(
                            color: (dates[index] == currentDate)
                                ? widget.activeWeekday ?? Colors.white
                                : widget.weekdayColor ?? Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => widget.dateSpacing.width,
          ),
        ),
      ],
    );
  }
}
