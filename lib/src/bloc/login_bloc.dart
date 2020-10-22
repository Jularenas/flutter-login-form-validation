import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:formvalidation/src/bloc/validators.dart';

class LoginBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passWordController = BehaviorSubject<String>();

  //recuperar datos de stream
  Stream<String> get emailStream =>
      _emailController.stream.transform(validarEmail);
  Stream<String> get passwordStream =>
      _passWordController.stream.transform(validarPassword);
  Stream<bool> get formValidStream =>
      Rx.combineLatest2(emailStream, passwordStream, (e, p) => true);

  //insertar stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passWordController.sink.add;

  //get latest stream value
  String get email => _emailController.value;
  String get password => _passWordController.value;

  dispose() {
    _emailController?.close();
    _passWordController?.close();
  }
}
