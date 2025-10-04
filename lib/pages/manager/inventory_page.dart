// inventory_page.dart
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/models/item.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'modify_item_page.dart';

class InventoryPage extends StatefulWidget {
  final Function(bool)? onFabVisibilityChanged;

  const InventoryPage({super.key, this.onFabVisibilityChanged});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ScrollController _scrollController = ScrollController();
  final InventoryController _controller = InventoryController();

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

  void _showDeleteDialog(Item item) {
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Text('Are you sure you want to delete ${item.name}?'),
              actions: <Widget>[
                if (!isDeleting)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orangeAccent),
                      foregroundColor: Colors.orangeAccent,
                    ),
                    child: const Text('Cancel'),
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
                        await _controller.deleteItem(item.id!);
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
                  'Item Name',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Item>>(
            stream: _controller.getItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: GradientCircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No inventory items found.'));
              }
              final items = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
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
                            child: item.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.imageUrl!,
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
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Quantity: ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
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
                                      builder: (context) => ModifyItemPage(
                                        itemId: item.id,
                                        item: item,
                                      ),
                                    ),
                                  );
                                },
                                tooltip: "Edit Item",
                              ),
                              IconButton(
                                icon: GradientIcon(
                                  icon: Icons.delete,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set2,
                                  ),
                                  offset: Offset.zero,
                                ),
                                onPressed: () => _showDeleteDialog(item),
                                tooltip: "Delete Item",
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