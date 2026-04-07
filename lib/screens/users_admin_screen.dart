import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/local_api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final api = context.read<ApiService>();
    final strings = context.watch<LanguageProvider>().strings;
    const roles = ['admin', 'staff', 'viewer'];

    if (role != 'admin') {
      return Scaffold(
        body: Center(child: Text(strings.adminAccessRequired)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.userRoles)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: api.streamUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(child: Text(strings.noUsersFound));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              final id = user['id']?.toString() ?? '';
              final email = user['email']?.toString() ?? strings.unknown;
              final role = user['role']?.toString() ?? 'staff';

              return Card(
                child: ListTile(
                  title: Text(email),
                  subtitle: Text(id),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: roles.contains(role) ? role : 'staff',
                      items: roles
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(strings.roleValueLabel(r)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null || value == role) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(strings.changeRoleTitle),
                            content: Text(
                              '${strings.setRolePrompt} $email ${strings.roleValueLabel(value)}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(strings.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(strings.confirm),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await api.updateUserRole(id, value);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
