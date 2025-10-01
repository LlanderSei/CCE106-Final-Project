// lib/views/admin/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/.old/controllers/staff/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/.old/models/admin/ingredient.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);
    // Start modification: Wrapped the body content in SingleChildScrollView for vertical scrolling
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: inventoryAsync.when(
          data: (items) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Actions')),
              ],
              rows: items.map((item) {
                return DataRow(
                  onSelectChanged: (_) => showDialog(
                    context: context,
                    builder: (_) =>
                        EditIngredientDialog(initialIngredient: item),
                  ),
                  cells: [
                    DataCell(Text(item.name)),
                    DataCell(Text(item.stockQuantity.toString())),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => ref
                                .read(inventoryControllerProvider)
                                .updateStock(item.id, item.stockQuantity - 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => ref
                                .read(inventoryControllerProvider)
                                .updateStock(item.id, item.stockQuantity + 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) =>
                                  EditIngredientDialog(initialIngredient: item),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text('Delete ${item.name}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                ref
                                    .read(inventoryControllerProvider)
                                    .deleteIngredient(item.id);
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
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => EditIngredientDialog(),
        ),
        child: Icon(Icons.add),
      ),
    );
    // End modification
  }
}

class EditIngredientDialog extends ConsumerStatefulWidget {
  final Ingredient? initialIngredient;

  EditIngredientDialog({this.initialIngredient});

  @override
  _EditIngredientDialogState createState() => _EditIngredientDialogState();
}

class _EditIngredientDialogState extends ConsumerState<EditIngredientDialog> {
  late TextEditingController _nameController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialIngredient?.name ?? '',
    );
    _stockController = TextEditingController(
      text: widget.initialIngredient?.stockQuantity.toString() ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500, // Set a wider width for the dialog
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
                      widget.initialIngredient == null
                          ? 'Add Ingredient'
                          : 'Edit Ingredient',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _stockController,
                      decoration: InputDecoration(labelText: 'Stock Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      final name = _nameController.text;
                      final stock = int.tryParse(_stockController.text) ?? 0;
                      final ingredient = Ingredient(
                        id: widget.initialIngredient?.id ?? '',
                        name: name,
                        stockQuantity: stock,
                      );
                      if (widget.initialIngredient == null) {
                        ref
                            .read(inventoryControllerProvider)
                            .addIngredient(ingredient);
                      } else {
                        ref
                            .read(inventoryControllerProvider)
                            .updateIngredient(ingredient);
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
