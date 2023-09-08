DateTime getDateTimeFromTimeStamp({dynamic timeStamp}){
  final String stringTime = timeStamp.toString();
  final int intTime = int.parse(stringTime);

  late int tempEpoch = 0;

  switch(stringTime.length){
    case 10: ;
    tempEpoch =  (intTime* 1000000);
    break;
    case 13:
      tempEpoch =  (intTime* 1000);
    break;
    default:
      tempEpoch = intTime;
      break;
  }

  final finalTime = DateTime.fromMicrosecondsSinceEpoch(tempEpoch);
  return finalTime;
}