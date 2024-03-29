DateTime timeStampToDateTime(dynamic timeStamp) {
  // convert timeStamp to string
  final String stringTime = timeStamp.toString();

  // convert to int Time
  final int intTime = int.parse(stringTime);

  late int tempEpoch = 0;

  switch (stringTime.length) {
    case 10:
      tempEpoch = (intTime * 1000000);
      break;
    case 13:
      tempEpoch = (intTime * 1000);
      break;
    default:
      tempEpoch = intTime;
      break;
  }

  //* convert int date time to DateTime
  final finalTime = DateTime.fromMicrosecondsSinceEpoch(tempEpoch);

  return finalTime;
}

@Deprecated('use TimeStampToDateTime')
DateTime getDateTimeFromTimeStamp({dynamic timeStamp}) {
  // convert timeStamp to string
  final String stringTime = timeStamp.toString();

  // convert string time to int
  final int intTime = int.parse(stringTime);

  late int tempEpoch = 0;

  switch (stringTime.length) {
    case 10:
      tempEpoch = (intTime * 1000000);
      break;
    case 13:
      tempEpoch = (intTime * 1000);
      break;
    default:
      tempEpoch = intTime;
      break;
  }

  //* convert int date time to DateTime
  final finalTime = DateTime.fromMicrosecondsSinceEpoch(tempEpoch);

  return finalTime;
}
