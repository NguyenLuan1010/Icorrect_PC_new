import 'package:icorrect_pc/src/data_source/dependency_injection.dart';
import 'package:icorrect_pc/src/data_source/repositories/auth_repository.dart';

abstract class RegisterConstract {}

class RegisterPresenter {
  final RegisterConstract? _view;
  AuthRepository? _authRepository;

  RegisterPresenter(this._view) {
    _authRepository = Injector().getAuthRepository();
  }

  
}
