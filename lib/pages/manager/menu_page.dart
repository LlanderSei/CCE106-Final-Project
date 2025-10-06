// menu_page.dart
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:flutter/rendering.dart';
import 'package:gradient_icon/gradient_icon.dart';
import '../../controllers/manager/menu_controller.dart';
import '../../models/dish.dart';
import 'modify_dish_page.dart';

class MenuPage extends StatefulWidget {
  final Function(bool)? onFabVisibilityChanged;

  const MenuPage({super.key, this.onFabVisibilityChanged});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final ScrollController _scrollController = ScrollController();
  final MenuController _controller = MenuController.instance;

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

  void _showDeleteDialog(Dish dish) {
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Text('Are you sure you want to delete ${dish.name}?'),
              actions: <Widget>[
                if (!isDeleting)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orangeAccent),
                      foregroundColor: Colors.orangeAccent,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.orange),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                if (!isDeleting)
                  GradientButton(
                    colors: GradientColorSets.set2,
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      setState(() => isDeleting = true);
                      try {
                        await _controller.deleteDish(dish.id!);
                      } catch (e) {
                        if (context.mounted) {
                          Toast.show('Error deleting: $e');
                        }
                        setState(() => isDeleting = false);
                        return;
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                if (isDeleting) const GradientCircularProgressIndicator(),
              ],
            );
          },
        );
      },
    );
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
                  'Dish Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Dish>>(
            stream: _controller.getAllDishesForStaff(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: GradientCircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No menu items found.'));
              }
              final dishes = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                itemCount: dishes.length,
                itemBuilder: (context, index) {
                  final dish = dishes[index];
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
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: dish.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      dish.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                                size: 60,
                                              ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    size: 60,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dish.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₱${dish.price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Visible: ${dish.isVisible ? 'True' : 'False'}',
                                ),
                                Text(
                                  'Available: ${dish.isAvailable ? 'True' : 'False'}',
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                      builder: (context) => ModifyDishPage(
                                        dishId: dish.id,
                                        dish: dish,
                                      ),
                                    ),
                                  );
                                },
                                tooltip: "Edit Menu",
                              ),
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.delete,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set2,
                                  ),
                                  offset: Offset.zero,
                                ),
                                onPressed: () => _showDeleteDialog(dish),
                                tooltip: "Delete Menu",
                              ),
                            ],
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
