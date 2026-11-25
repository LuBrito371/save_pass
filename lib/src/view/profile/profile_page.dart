import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:save_pass/src/controller/sqlite_profile_controller.dart';
import 'package:save_pass/src/model/profile_model.dart';
import 'package:save_pass/ui/colors.dart';
import 'package:save_pass/ui/components/app_button.dart';
import 'package:save_pass/ui/components/custom_text_field.dart';
import 'package:save_pass/ui/text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\+\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _hasPopulatedInitialData = false;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final controller = context.read<SQliteProfileController>();
    final existing = controller.profile;
    if (existing != null) {
      _populateFields(existing);
      return;
    }

    final loaded = await controller.ensureLoaded();
    if (!mounted || loaded == null || _hasPopulatedInitialData) return;

    final isFormUntouched = _nameController.text.isEmpty &&
        _emailController.text.isEmpty &&
        _passwordController.text.isEmpty;
    if (isFormUntouched) {
      _populateFields(loaded);
    }
  }

  void _populateFields(ProfileModel profile) {
    _hasPopulatedInitialData = true;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _passwordController.text = profile.password;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'O nome de usuário é obrigatório';
    }
    if (trimmed.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final raw = value ?? '';
    if (raw.trim().isEmpty) {
      return 'A senha é obrigatória';
    }
    if (raw.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleSave() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final profile = ProfileModel(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await context.read<SQliteProfileController>().saveProfile(profile);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil salvo com sucesso!'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Perfil do Usuário'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Nome de usuário',
                  style: AppTextStyle.bodyText1,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Insira seu nome de usuário',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                Text(
                  'E-mail de recuperação',
                  style: AppTextStyle.bodyText1,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'usuario@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                Text(
                  'Senha secreta',
                  style: AppTextStyle.bodyText1,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  hintText: 'Sua senha mestra',
                  obscureText: _isObscure,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.gray200,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: _handleSave,
                  text: 'Salvar Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
