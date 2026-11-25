import 'package:save_pass/src/model/profile_model.dart';
import 'package:save_pass/src/model/repository/app_database.dart';
import 'package:save_pass/src/model/repository/interface/i_profile_repository.dart';
import 'package:sqflite/sqflite.dart';

class SQliteProfileRepository implements IProfileRepository {
  final Database database;

  SQliteProfileRepository(this.database);

  @override
  Future<ProfileModel?> getProfile() async {
    final result = await database.query(
      'profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (result.isEmpty) {
      return null;
    }
    return ProfileModel.fromJson(result.first);
  }

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    await database.insert(
      'profile',
      profile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Database> open() => AppDatabase.open();

  static Future<void> close(Database database) async {
    await database.close();
  }
}
