import 'package:flutter/foundation.dart';
import 'package:save_pass/src/model/profile_model.dart';
import 'package:save_pass/src/model/repository/interface/i_profile_repository.dart';
import 'package:save_pass/src/model/repository/sqlite_profile_repository.dart';

class SQliteProfileController extends ChangeNotifier {
  IProfileRepository? _profileRepository;
  SQliteProfileRepository? _sqliteRepository;
  ProfileModel? _profile;
  bool _isLoaded = false;
  late final Future<void> _initFuture;

  SQliteProfileController({IProfileRepository? repository}) {
    _profileRepository = repository;
    _initFuture = _initialize();
  }

  ProfileModel? get profile => _profile;
  bool get isLoaded => _isLoaded;

  Future<void> _initialize() async {
    if (_profileRepository == null) {
      final database = await SQliteProfileRepository.open();
      _sqliteRepository = SQliteProfileRepository(database);
      _profileRepository = _sqliteRepository;
    }
    _profile = await _profileRepository!.getProfile();
    _isLoaded = true;
    notifyListeners();
  }

  Future<ProfileModel?> ensureLoaded() async {
    await _initFuture;
    return _profile;
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await _initFuture;
    await _profileRepository!.saveProfile(profile);
    _profile = profile;
    notifyListeners();
  }

  @override
  void dispose() {
    final repo = _sqliteRepository;
    if (repo != null) {
      SQliteProfileRepository.close(repo.database);
    }
    super.dispose();
  }
}
