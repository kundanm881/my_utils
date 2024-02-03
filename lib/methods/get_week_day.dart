String getWeekDay(int day, {bool short = false}) {
  String din = "";

  // Check week as per int day value
  switch (day) {
    case DateTime.monday:
      din = "Monday";
      break;
    case DateTime.tuesday:
      din = "Tuesday";
      break;
    case DateTime.wednesday:
      din = "Wednesday";
      break;
    case DateTime.thursday:
      din = "Thursday";
      break;
    case DateTime.friday:
      din = "Friday";
      break;
    case DateTime.saturday:
      din = "Saturday";
      break;
    case DateTime.sunday:
      din = "Sunday";
      break;
    default:
      din = "Day Not Found";
      break;
  }

  if (short) {
    String st = din.substring(0, 3);
    if (day < 0 || day > 7) {
      return din;
    } else {
      return st;
    }
  } else {
    return din;
  }
}
