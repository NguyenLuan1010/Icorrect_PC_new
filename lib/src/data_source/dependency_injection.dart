import 'package:icorrect_pc/src/data_source/repositories/auth_repository.dart';
import 'package:icorrect_pc/src/data_source/repositories/homework_repository.dart';
import 'package:icorrect_pc/src/data_source/repositories/my_test_repository.dart';
import 'package:icorrect_pc/src/data_source/repositories/simulator_test_repository.dart';

class Injector {
  static final Injector _singleton = Injector._internal();
  factory Injector() {
    return _singleton;
  }
  Injector._internal();
  HomeWorkRepository getHomeWorkRepository() => HomeWorkRepositoryImpl();
  AuthRepository getAuthRepository() => AuthRepositoryImpl();
  SimulatorTestRepository getTestRepository() => SimulatorTestRepositoryImpl();
  MyTestRepository getMyTestRepository() => MyTestImpl();
}
