import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/users_controller.dart';
import 'package:bbqlagao_and_beefpares/models/user.dart';

class ModifyUserPage extends StatefulWidget {
  final String? userId;
  final User? user;

  const ModifyUserPage({super.key, this.userId, this.user});

  @override
  State<ModifyUserPage> createState() => _ModifyUserPageState();
}

class _ModifyUserPageState extends State<ModifyUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late TextEditingController _confirmPasswordCtrl;
  String _role = 'Cashier';
  final UsersController _controller = UsersController();
  bool get isEdit => widget.userId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _passwordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();
    _role = widget.user?.role ?? 'Cashier';
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Edit Staff' : 'New Staff';
    final buttonText = isEdit ? 'Update Staff' : 'Add Staff';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 80.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                    const Divider(),
                    if (!isEdit) ...[
                      const Text('Email'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Email is required' : null,
                      ),
                      const Divider(),
                    ],
                    const Text('Role'),
                    DropdownButtonFormField<String>(
                      value: _role,
                      items: ['Admin', 'Manager', 'Cashier']
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _role = value!),
                      validator: (value) =>
                          value == null ? 'Role is required' : null,
                    ),
                    if (!isEdit) ...[
                      const Divider(),
                      const Text('Password'),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Password is required' : null,
                      ),
                      const Divider(),
                      const Text('Confirm Password'),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Confirm Password is required';
                          if (value != _passwordCtrl.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const Divider(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  !_isLoading
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orangeAccent),
                            foregroundColor: Colors.orange,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const GradientCircularProgressIndicator()
                      : GradientButton(
                          colors: GradientColorSets.set2,
                          onPressed: () async {
                            if (_isLoading) return;
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                final newUser = User(
                                  id: widget.userId,
                                  name: _nameCtrl.text,
                                  email: _emailCtrl.text,
                                  role: _role,
                                  provider: isEdit
                                      ? widget.user?.provider
                                      : null,
                                );
                                if (isEdit) {
                                  await _controller.updateUser(
                                    widget.userId!,
                                    newUser,
                                  );
                                } else {
                                  await _controller.addUser(
                                    newUser,
                                    _passwordCtrl.text,
                                  );
                                }
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                if (context.mounted) {
                                  Toast.show('Error: ${e.toString()}');
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }
}
