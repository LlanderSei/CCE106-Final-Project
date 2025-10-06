//pages/manager/category_page.dart
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/models/category.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/category_controller.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:gradient_icon/gradient_icon.dart';

class CategoryPage extends StatefulWidget {
  final Function(bool)? onFabVisibilityChanged;

  const CategoryPage({super.key, this.onFabVisibilityChanged});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryController _controller = CategoryController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showFabNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    widget.onFabVisibilityChanged?.call(true);
  }

  void _scrollListener() {
    if (_scrollController.offset > 0) {
      _showFabNotifier.value = false;
      widget.onFabVisibilityChanged?.call(false);
    } else {
      _showFabNotifier.value = true;
      widget.onFabVisibilityChanged?.call(true);
    }
  }

  Future<void> _showCategoryDialog({String? id, String? initialName}) async {
    final isEdit = id != null;
    final nameCtrl = TextEditingController(text: initialName ?? '');
    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Category' : 'New Category'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Category Name'),
            enabled: !isSaving, // Disable input while saving
          ),
          actions: [
            if (!isSaving) // Only show buttons when not saving
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orangeAccent),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  nameCtrl.dispose(); // Dispose before popping
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            if (!isSaving)
              GradientButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    Toast.show('Name is required');
                    return;
                  }

                  // Update UI to show loading state
                  setState(() => isSaving = true);

                  try {
                    final cat = Category(name: name);
                    if (isEdit) {
                      await _controller.updateCategory(id, cat);
                    } else {
                      await _controller.addCategory(cat);
                    }

                    if (!context.mounted) return;
                    nameCtrl.dispose(); // Dispose before popping
                    Navigator.pop(dialogContext);
                  } catch (e) {
                    if (!context.mounted) return;
                    Toast.show('Error: ${e.toString()}');
                    // Re-enable buttons on error
                    setState(() => isSaving = false);
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isSaving)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: GradientCircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orangeAccent),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
          GradientButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.deleteCategory(id);
      } catch (e) {
        Toast.show('Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showFabNotifier,
        builder: (context, isVisible, child) {
          return Visibility(
            visible: isVisible,
            child: FloatingActionButton(
              backgroundColor: Colors.redAccent[100],
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => _showCategoryDialog(),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Category Name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text('Actions', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _controller.getCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GradientCircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }
                final categories = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Container(
                      margin: EdgeInsetsGeometry.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: LightGradientColorSets.set1,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 0),

                        child: ListTile(
                          title: Text(cat.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.edit,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set3,
                                  ),
                                  offset: Offset.zero,
                                ),
                                onPressed: () => _showCategoryDialog(
                                  id: cat.id,
                                  initialName: cat.name,
                                ),
                                tooltip: "Edit Category",
                              ),
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.delete,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set2,
                                  ),
                                  offset: Offset.zero,
                                ),
                                onPressed: () => _confirmDelete(cat.id!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _showFabNotifier.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}
