abstract class KExcaption {
  final int errorCode;
  final String errorMessage;

  KExcaption({required this.errorCode, required this.errorMessage});

  @override
  String toString() {
    return "errorCode $errorCode, errorMessage $errorMessage";
  }
}

class Exception extends KExcaption {
  Exception({required super.errorCode, required super.errorMessage});
}
