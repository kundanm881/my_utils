abstract class KException {
  final int errorCode;
  final String errorMessage;

  KException({required this.errorCode, required this.errorMessage});

  @override
  String toString() {
    return "errorCode $errorCode, errorMessage $errorMessage";
  }
}

class TextException extends KException {
  TextException({required super.errorCode, required super.errorMessage});
}
