import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:save_pass/src/controller/sqlite_password_controller.dart';
import 'package:save_pass/src/controller/sqlite_profile_controller.dart';
import 'package:save_pass/src/view/home/password_list_tile.dart';
import 'package:save_pass/src/view/home/search_text_field.dart';
import 'package:save_pass/ui/colors.dart';
import 'package:save_pass/ui/text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'US';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  Widget background() {
    return Column(
      children: [
        Container(
          color: AppColors.primary,
          height: 155,
        ),
        Expanded(
          child: Container(
            color: AppColors.black900,
          ),
        ),
      ],
    );
  }

  Widget header(BuildContext context) {
    final profileName = context.watch<SQliteProfileController>().profile?.name;
    final displayName =
        (profileName != null && profileName.trim().isNotEmpty)
            ? profileName.trim()
            : 'Usuário';
    final initials = _getInitials(displayName);

    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('profile_header_button'),
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.black900,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Text(
                            initials,
                            style: AppTextStyle.headline6
                                .copyWith(color: AppColors.accent),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              TextSpan(
                                text: 'Olá, ',
                                style: AppTextStyle.headline5,
                                children: [
                                  TextSpan(
                                    text: displayName,
                                    style: AppTextStyle.headline4,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Sinta-se seguro aqui',
                              style: AppTextStyle.subtitle2
                                  .copyWith(color: AppColors.gray200),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 48,
            height: 48,
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/new_password');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          background(),
          Consumer<SQlitePasswordController>(
              builder: (context, SQlitePasswordController controller, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  header(context),
                  const SizedBox(height: 24),
                  SearchTextField(
                    hintText: 'Qual senha você procura?',
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        controller.search(value);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suas senhas',
                        style: AppTextStyle.headline5,
                      ),
                      Text('${controller.passwords.length} senhas',
                          style: AppTextStyle.bodyText2.copyWith(
                            color: AppColors.gray500,
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _searchController.text.isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: controller.filteredPasswords.length,
                            itemBuilder: (context, index) {
                              return PasswordListTile(
                                passwordService:
                                    controller.filteredPasswords[index],
                              );
                            },
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: controller.passwords.length,
                            itemBuilder: (context, index) {
                              return PasswordListTile(
                                passwordService: controller.passwords[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}
