import 'package:flutter/foundation.dart';
import 'package:save_pass/src/model/password_model.dart';
import 'package:save_pass/src/model/repository/interface/i_password_repository.dart';
import 'package:save_pass/src/model/repository/sqlite_password_respository.dart';

class SQlitePasswordController extends ChangeNotifier {
  IPasswordRepository? _passwordRepository;
  SQlitePasswordRepository? _sqliteRepository;
  final List<PasswordModel> _passwords = [];
  List<PasswordModel> filteredPasswords = [];

  SQlitePasswordController({IPasswordRepository? repository}) {
    _passwordRepository = repository;
    _initialize();
  }

  Future<void> _initialize() async {
    if (_passwordRepository == null) {
      final database = await SQlitePasswordRepository.open();
      _sqliteRepository = SQlitePasswordRepository(database);
      _passwordRepository = _sqliteRepository;
    }
    final passwords = await _passwordRepository!.getAllPasswords();
    _passwords.addAll(passwords);
    notifyListeners();
  }

  @override
  void dispose() {
    final repo = _sqliteRepository;
    if (repo != null) {
      SQlitePasswordRepository.close(repo.database);
    }
    _passwords.clear();
    super.dispose();
  }

  List<PasswordModel> get passwords => _passwords;

  Future<void> addPassword(PasswordModel password) async {
    final repo = _passwordRepository;
    if (repo == null) return;
    await repo.savePassword(password);
    _passwords.add(password);
    notifyListeners();
  }

  Future<void> deletePassword(PasswordModel password) async {
    final repo = _passwordRepository;
    if (repo == null) return;
    await repo.deletePassword(password.serviceName);
    _passwords.remove(password);
    notifyListeners();
  }

  Future<void> updatePassword(PasswordModel password) async {
    final repo = _passwordRepository;
    if (repo == null) return;
    await repo.updatePassword(password);
    _passwords.removeWhere((p) => p.serviceName == password.serviceName);
    _passwords.add(password);
    notifyListeners();
  }

  PasswordModel? getPassword(String serviceName) {
    final result = _passwords.firstWhere(
      (password) => password.serviceName == serviceName,
      orElse: () => PasswordModel(serviceName: '', username: '', password: ''),
    );
    if (result.serviceName.isNotEmpty) {
      return result;
    } else {
      return null;
    }
  }

  void search(String serviceName) {
    filteredPasswords = _passwords
        .where((password) => password.serviceName
            .toLowerCase()
            .contains(serviceName.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
