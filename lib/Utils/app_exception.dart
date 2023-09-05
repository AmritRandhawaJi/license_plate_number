
class AppException implements Exception{

  final String _message;

  AppException({required String message}) : _message = message;

 String toError(){
return "Status : $_message";
 }
}

class InvalidResponse extends AppException{
  InvalidResponse([String? message]) :super(message: "Invalid Response");
}

class InternetError extends AppException{
  InternetError([String? message]) :super(message: "Internet Error");
}