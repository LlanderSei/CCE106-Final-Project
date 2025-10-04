import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/users_controller.dart';
import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'modify_user_page.dart';

class StaffListPage extends StatefulWidget {
  final void Function(bool)? onFabVisibilityChanged;
  const StaffListPage({super.key, this.onFabVisibilityChanged});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final ScrollController _scrollController = ScrollController();
  final UsersController _controller = UsersController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final visible =
        _scrollController.position.userScrollDirection !=
        ScrollDirection.reverse;
    if (widget.onFabVisibilityChanged != null) {
      widget.onFabVisibilityChanged!(visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Staffs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<User>>(
            stream: _controller.getUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: GradientCircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No staff found.'));
              }
              final users = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.orange[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(user.email),
                                Text("Role: ${user.role}"),
                                Text("Provider: ${user.provider ?? 'Unknown'}"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: GradientIcon(
                              icon: Icons.edit,
                              gradient: LinearGradient(
                                colors: GradientColorSets.set2,
                              ),
                              offset: Offset.zero,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifyUserPage(
                                    userId: user.id,
                                    user: user,
                                  ),
                                ),
                              );
                            },
                            tooltip: "Edit Staff",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
