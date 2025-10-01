// lib/views/admin/admin_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/.old/controllers/staff/admin_controller.dart';
import 'package:bbqlagao_and_beefpares/.old/models/user.dart';

// Start modification: Updated to use User model, removed password field from edit dialog since not editable
class AdminManagementScreen extends ConsumerWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admins = ref.watch(adminControllerProvider);

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Actions')),
            ],
            rows: admins.isEmpty
                ? [
                    DataRow(
                      cells: [
                        DataCell(Text('No admins available')),
                        DataCell(Text('')),
                        DataCell(Text('')),
                      ],
                    ),
                  ]
                : admins.map((admin) {
                    return DataRow(
                      onSelectChanged: (_) => showDialog(
                        context: context,
                        builder: (_) => EditAdminDialog(initialAdmin: admin),
                      ),
                      cells: [
                        DataCell(Text(admin.fullName ?? '')),
                        DataCell(Text(admin.email)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) =>
                                      EditAdminDialog(initialAdmin: admin),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text(
                                        'Delete ${admin.fullName ?? admin.email}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    ref
                                        .read(adminControllerProvider.notifier)
                                        .deleteAdmin(admin.uid);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showDialog(context: context, builder: (_) => EditAdminDialog()),
        child: Icon(Icons.add),
      ),
    );
  }
}

class EditAdminDialog extends ConsumerStatefulWidget {
  final User? initialAdmin;

  const EditAdminDialog({super.key, this.initialAdmin});

  @override
  _EditAdminDialogState createState() => _EditAdminDialogState();
}

class _EditAdminDialogState extends ConsumerState<EditAdminDialog> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.initialAdmin?.fullName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialAdmin?.email ?? '',
    );
    _passwordController = TextEditingController(text: ''); // For add only
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.initialAdmin == null ? 'Add Admin' : 'Edit Admin',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (widget.initialAdmin == null)
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                  ],
                ),
              ),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final fullName = _fullNameController.text;
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      final adminController = ref.read(
                        adminControllerProvider.notifier,
                      );

                      if (widget.initialAdmin == null) {
                        adminController.addAdmin(fullName, email, password);
                      } else {
                        adminController.updateAdmin(
                          widget.initialAdmin!.uid,
                          fullName,
                          email,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// End modification