// lib/views/admin/dish_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/controllers/admin/dish_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/admin/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/models/admin/dish.dart';
import 'package:bbqlagao_and_beefpares/models/admin/ingredient.dart';

class DishManagementScreen extends ConsumerWidget {
  const DishManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(dishProvider);
    final ingredientsAsync = ref.watch(inventoryProvider);

    // Start modification: Wrapped the body content in SingleChildScrollView for vertical scrolling
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: dishesAsync.when(
          data: (dishes) => ingredientsAsync.when(
            data: (ingredients) {
              final ingMap = {for (var ing in ingredients) ing.id: ing};
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Available')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: dishes.map((dish) {
                    final isAvailable = dish.ingredients.every(
                      (req) =>
                          (ingMap[req.ingredientId]?.stockQuantity ?? 0) >=
                          req.quantity,
                    );
                    return DataRow(
                      onSelectChanged: (_) => showDialog(
                        context: context,
                        builder: (_) => EditDishDialog(initialDish: dish),
                      ),
                      cells: [
                        DataCell(Text(dish.name)),
                        DataCell(Text(dish.description)),
                        DataCell(Text('\$${dish.price}')),
                        DataCell(Text(isAvailable ? 'Yes' : 'No')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) =>
                                      EditDishDialog(initialDish: dish),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text('Delete ${dish.name}?'),
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
                                        .read(dishControllerProvider)
                                        .deleteDish(dish.id);
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
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showDialog(context: context, builder: (_) => EditDishDialog()),
        child: Icon(Icons.add),
      ),
    );
    // End modification
  }
}

class EditDishDialog extends ConsumerStatefulWidget {
  final Dish? initialDish;

  const EditDishDialog({super.key, this.initialDish});

  @override
  _EditDishDialogState createState() => _EditDishDialogState();
}

class _EditDishDialogState extends ConsumerState<EditDishDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late List<IngredientRequirement> _ingredients;
  String? _selectedIngId;
  TextEditingController _qtyController = TextEditingController(text: '1');
  final Map<IngredientRequirement, TextEditingController> _qtyControllers = {};
  final Map<IngredientRequirement, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialDish?.name ?? '',
    );
    _descController = TextEditingController(
      text: widget.initialDish?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.initialDish?.price.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.initialDish?.imageUrl ?? '',
    );
    _ingredients = List.from(widget.initialDish?.ingredients ?? []);
    for (var req in _ingredients) {
      _qtyControllers[req] = TextEditingController(
        text: req.quantity.toString(),
      );
      _focusNodes[req] = FocusNode();
    }
  }

  @override
  void dispose() {
    for (var controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _qtyController.dispose();
    super.dispose();
  }

  void _updateQuantity(IngredientRequirement req, String value) {
    final newQty = int.tryParse(value) ?? 0;
    final index = _ingredients.indexOf(req);
    setState(() {
      _ingredients[index] = IngredientRequirement(
        ingredientId: req.ingredientId,
        quantity: newQty,
      );
      _qtyControllers[req]?.text = newQty.toString();
    });
    // Request focus back to the same field
    FocusScope.of(context).requestFocus(_focusNodes[req]);
  }

  void _handleQtyChange(IngredientRequirement req, String value) {
    final currentText = _qtyControllers[req]?.text ?? '';
    if (currentText.isNotEmpty &&
        currentText[currentText.length - 1] == '0' &&
        value.isNotEmpty &&
        value != '0') {
      // Replace the last zero with the new non-zero digit
      final newValue = currentText.substring(0, currentText.length - 1) + value;
      _updateQuantity(req, newValue);
    } else {
      _updateQuantity(req, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(inventoryProvider);
    return Dialog(
      child: SizedBox(
        width: 500,
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
                      widget.initialDish == null ? 'Add Dish' : 'Edit Dish',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Image URL (optional)',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Ingredients:'),
                    SizedBox(
                      height: 72, // Height for 3 ListTiles (24px each + padding)
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _ingredients.length,
                        itemBuilder: (context, index) {
                          final req = _ingredients[index];
                          final ing = ingredientsAsync.when(
                            data: (ings) => ings.firstWhere(
                              (i) => i.id == req.ingredientId,
                              orElse: () => Ingredient(
                                id: '',
                                name: 'Unknown',
                                stockQuantity: 0,
                              ),
                            ),
                            loading: () => Ingredient(
                              id: '',
                              name: 'Loading...',
                              stockQuantity: 0,
                            ),
                            error: (err, stack) => Ingredient(
                              id: '',
                              name: 'Error',
                              stockQuantity: 0,
                            ),
                          );
                          return ListTile(
                            title: Text(ing.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _qtyControllers[req],
                                    focusNode: _focusNodes[req],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        _handleQtyChange(req, value),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _ingredients.remove(req);
                                      _qtyControllers.remove(req);
                                      _focusNodes.remove(req);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Add Ingredient:'),
                    ingredientsAsync.when(
                      data: (ings) {
                        final availableIngs = ings.where(
                          (ing) => !_ingredients.any(
                            (req) => req.ingredientId == ing.id,
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedIngId,
                                    hint: Text('Select Ingredient'),
                                    items: availableIngs.map((ing) {
                                      return DropdownMenuItem(
                                        value: ing.id,
                                        child: Text(ing.name),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedIngId = val;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _qtyController,
                                    decoration: InputDecoration(
                                      labelText: 'Qty',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final qty =
                                      int.tryParse(_qtyController.text) ?? 0;
                                  if (_selectedIngId != null && qty > 0) {
                                    setState(() {
                                      final newReq = IngredientRequirement(
                                        ingredientId: _selectedIngId!,
                                        quantity: qty,
                                      );
                                      _ingredients.add(newReq);
                                      _qtyControllers[newReq] =
                                          TextEditingController(
                                            text: qty.toString(),
                                          );
                                      _focusNodes[newReq] = FocusNode();
                                      _selectedIngId = null;
                                      _qtyController.text = '1';
                                    });
                                  }
                                },
                                child: Text('Add Ingredient'),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
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
                      final name = _nameController.text;
                      final desc = _descController.text;
                      final price =
                          double.tryParse(_priceController.text) ?? 0.0;
                      final imageUrl = _imageUrlController.text.isEmpty
                          ? null
                          : _imageUrlController.text;
                      final dish = Dish(
                        id: widget.initialDish?.id ?? '',
                        name: name,
                        description: desc,
                        price: price,
                        imageUrl: imageUrl,
                        ingredients: _ingredients,
                      );
                      if (widget.initialDish == null) {
                        ref.read(dishControllerProvider).addDish(dish);
                      } else {
                        ref.read(dishControllerProvider).updateDish(dish);
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