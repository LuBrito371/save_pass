import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:save_pass/src/controller/sqlite_password_controller.dart';
import 'package:save_pass/src/controller/sqlite_profile_controller.dart';
import 'package:save_pass/src/model/password_model.dart';
import 'package:save_pass/src/model/profile_model.dart';
import 'package:save_pass/src/model/repository/interface/i_password_repository.dart';
import 'package:save_pass/src/model/repository/interface/i_profile_repository.dart';
import 'package:save_pass/src/view/home/home_page.dart';
import 'package:save_pass/src/view/profile/profile_page.dart';
import 'package:save_pass/ui/theme.dart';

class FakePasswordRepository implements IPasswordRepository {
  final List<PasswordModel> _items = [];

  @override
  Future<void> deletePassword(String serviceName) async {
    _items.removeWhere((p) => p.serviceName == serviceName);
  }

  @override
  Future<List<PasswordModel>> getAllPasswords() async => List.from(_items);

  @override
  Future<PasswordModel> getPassword(String serviceName) async {
    return _items.firstWhere((p) => p.serviceName == serviceName);
  }

  @override
  Future<void> savePassword(PasswordModel password) async {
    _items.add(password);
  }

  @override
  Future<void> updatePassword(PasswordModel password) async {
    _items.removeWhere((p) => p.serviceName == password.serviceName);
    _items.add(password);
  }
}

class FakeProfileRepository implements IProfileRepository {
  ProfileModel? savedProfile;
  int saveCalls = 0;

  @override
  Future<ProfileModel?> getProfile() async => savedProfile;

  @override
  Future<void> saveProfile(ProfileModel profile) async {
    saveCalls++;
    savedProfile = profile;
  }
}

Widget buildTestApp({
  required FakeProfileRepository profileRepo,
  FakePasswordRepository? passwordRepo,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => SQlitePasswordController(
          repository: passwordRepo ?? FakePasswordRepository(),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => SQliteProfileController(repository: profileRepo),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const HomePage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (_) => const ProfilePage());
        }
        return MaterialPageRoute(builder: (_) => const HomePage());
      },
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProfileModel', () {
    test('serializes and deserializes correctly', () {
      final model = ProfileModel(
        name: 'Lucas Brito',
        email: 'lucas@ufape.edu.br',
        password: 'secret123',
      );
      final json = model.toJson();
      final restored = ProfileModel.fromJson(json);

      expect(restored.id, 1);
      expect(restored.name, 'Lucas Brito');
      expect(restored.email, 'lucas@ufape.edu.br');
      expect(restored.password, 'secret123');
    });
  });

  group('ProfilePage navigation, validation, and persistence', () {
    testWidgets('navigates from HomePage to ProfilePage and back',
        (tester) async {
      final profileRepo = FakeProfileRepository();
      await tester.pumpWidget(buildTestApp(profileRepo: profileRepo));
      await tester.pumpAndSettle();

      expect(find.textContaining('Usuário'), findsOneWidget);
      expect(find.text('US'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile_header_button')));
      await tester.pumpAndSettle();

      expect(find.text('Perfil do Usuário'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.text('Suas senhas'), findsOneWidget);
    });

    testWidgets('validates required fields and blocks saving', (tester) async {
      final profileRepo = FakeProfileRepository();
      await tester.pumpWidget(buildTestApp(profileRepo: profileRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_header_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('O nome de usuário é obrigatório'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(profileRepo.saveCalls, 0);
      expect(find.text('Perfil do Usuário'), findsOneWidget);
    });

    testWidgets('validates min lengths and email format before saving',
        (tester) async {
      final profileRepo = FakeProfileRepository();
      await tester.pumpWidget(buildTestApp(profileRepo: profileRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_header_button')));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Lu');
      await tester.enterText(fields.at(1), 'email-invalido');
      await tester.enterText(fields.at(2), '12345');

      await tester.tap(find.text('Salvar Perfil'));
      await tester.pumpAndSettle();

      expect(
        find.text('O nome deve ter pelo menos 3 caracteres'),
        findsOneWidget,
      );
      expect(find.text('Informe um e-mail válido'), findsOneWidget);
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
      expect(profileRepo.saveCalls, 0);
    });

    testWidgets(
        'saves valid profile, updates HomePage, and reloads saved fields on restart',
        (tester) async {
      final profileRepo = FakeProfileRepository();
      await tester.pumpWidget(buildTestApp(profileRepo: profileRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('profile_header_button')));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Lucas Brito');
      await tester.enterText(fields.at(1), 'lucas.brito@ufape.edu.br');
      await tester.enterText(fields.at(2), 'senhaSegura123');

      await tester.tap(find.text('Salvar Perfil'));
      await tester.pumpAndSettle();

      expect(profileRepo.saveCalls, 1);
      expect(find.text('Suas senhas'), findsOneWidget);
      expect(find.text('LB'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.textSpan?.toPlainText() == 'Olá, Lucas Brito',
        ),
        findsOneWidget,
      );

      // Simulate closing and reopening the app with a fresh widget tree & controllers
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await tester.pumpWidget(buildTestApp(profileRepo: profileRepo));
      await tester.pumpAndSettle();

      expect(find.text('LB'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && w.textSpan?.toPlainText() == 'Olá, Lucas Brito',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('profile_header_button')));
      await tester.pumpAndSettle();

      final reloadedFields = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      ).toList();
      expect(reloadedFields[0].controller?.text, 'Lucas Brito');
      expect(reloadedFields[1].controller?.text, 'lucas.brito@ufape.edu.br');
      expect(reloadedFields[2].controller?.text, 'senhaSegura123');
    });
  });
}
