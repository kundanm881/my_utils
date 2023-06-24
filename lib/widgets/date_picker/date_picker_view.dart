import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kd_utils/extensions/extensions.dart';
import 'package:kd_utils/widgets/date_picker/date_picker_state.dart';

class DatePickerView extends StatefulWidget {
  /// [currentDate] is user to show current index of date picker
  final DateTime currentDate;

  /// [startDate] is first date to start [arrey]
  final DateTime startDate;

  /// [endDate] is the last date of date picker
  final DateTime endDate;

  /// [yearMonth], [day], [weekday] is [textStyle]
  final TextStyle? yearMonth, day, weekday;

  /// [dateSpacing] is user to add space bitwen dates
  final double dateSpacing;

  /// [onDateClick] return clicked date
  final Function(DateTime selectedDate) onDateClick;

  /// [color] user used to apply colors
  final Color? color,
      dayColor,
      weekdayColor,
      activeColor,
      activeDay,
      activeWeekday;

  /// [dayWeekHeight] is used to add space bitween [day] and [weekday]
  final double dayWeekHeight;

  /// [decoration] is user to decorate container
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
            /// method is for chacking [dateScrollController] has client or not
            /// if the [dateScrollController] has client then devide [offset] / widgets with
            ///
            DateTime scrollerDate = widget.startDate.add(
              Duration(
                  days: (dateScrollController.hasClients)
                      ? (dateScrollController.offset /
                              ((widget.dateSpacing+boxSize)))
                          .round()
                      : 0),
            );
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
