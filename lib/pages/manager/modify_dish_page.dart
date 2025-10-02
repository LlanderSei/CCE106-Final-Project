import 'package:bbqlagao_and_beefpares/controllers/manager/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/menu_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:bbqlagao_and_beefpares/customtoast.dart';
import '../../models/dish.dart';
import '../../models/item.dart';

class ModifyDishPage extends StatefulWidget {
  final String? dishId;
  final Dish? dish;

  const ModifyDishPage({super.key, this.dishId, this.dish});

  @override
  State<ModifyDishPage> createState() => _ModifyDishPageState();
}

class _ModifyDishPageState extends State<ModifyDishPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imageUrlCtrl;
  late bool _isVisible;
  final MenuController _menuController = MenuController();
  final InventoryController _inventoryController = InventoryController();
  List<Map<String, dynamic>> _selectedIngredients = [];
  double _price = 0.0;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.dish?.name ?? '');
    _descCtrl = TextEditingController(text: widget.dish?.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.dish?.price.toStringAsFixed(2) ?? '0.00',
    );
    _imageUrlCtrl = TextEditingController(text: widget.dish?.imageUrl ?? '');
    _isVisible = widget.dish?.isVisible ?? true;
    _price = widget.dish?.price ?? 0.0;
    if (widget.dish != null) {
      _selectedIngredients = List<Map<String, dynamic>>.from(
        widget.dish!.ingredients
            .where((ing) => ing['itemId'] != null)
            .map((ing) => {'id': ing['itemId'], 'quantity': ing['quantity']}),
      );
      _loadIngredientNames();
    }
  }

  Future<void> _loadIngredientNames() async {
    final List<Map<String, dynamic>> updated = [];
    for (final ing in _selectedIngredients) {
      if (ing['id'] == null) continue;
      final doc = await FirebaseFirestore.instance
          .collection('inventory')
          .doc(ing['id'])
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        updated.add({
          'id': ing['id'],
          'name': data['name'] ?? 'Unknown',
          'quantity': ing['quantity'],
        });
      } else {
        if (mounted) {
          Toast.show(context, 'Item Unavailable/Deleted');
        }
      }
    }
    if (mounted) {
      setState(() {
        _selectedIngredients = updated;
      });
    }
  }

  void _incrementPrice() {
    setState(() {
      _price += 0.01;
      _priceCtrl.text = _price.toStringAsFixed(2);
    });
  }

  void _decrementPrice() {
    if (_price > 0) {
      setState(() {
        _price -= 0.01;
        _priceCtrl.text = _price.toStringAsFixed(2);
      });
    }
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) => _IngredientSelectionDialog(
        inventoryController: _inventoryController,
        selectedIngredients: _selectedIngredients,
        onSelected: (id, name, quantity) {
          setState(() {
            _selectedIngredients.add({
              'id': id,
              'name': name,
              'quantity': quantity,
            });
          });
        },
      ),
    );
  }

  void _updateIngredientQuantity(String id, int newQuantity) {
    setState(() {
      final index = _selectedIngredients.indexWhere((ing) => ing['id'] == id);
      if (index != -1 && newQuantity >= 0) {
        _selectedIngredients[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeIngredient(String id) {
    setState(() {
      _selectedIngredients.removeWhere((ing) => ing['id'] == id);
    });
  }

  Future<bool> _computeAvailability() async {
    for (final ing in _selectedIngredients) {
      if (ing['id'] == null) return false;
      final doc = await FirebaseFirestore.instance
          .collection('inventory')
          .doc(ing['id'])
          .get();
      if (!doc.exists || (doc.data()?['quantity'] ?? 0) < ing['quantity']) {
        return false;
      }
    }
    return true;
  }

  Widget _buildImagePreview() {
    if (_imageUrlCtrl.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrlCtrl.text,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedIngredients.length,
          itemBuilder: (context, index) {
            final ing = _selectedIngredients[index];
            return Card(
              child: ListTile(
                title: Text(ing['name'] ?? 'Unknown'),
                subtitle: Text('Quantity: ${ing['quantity']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateIngredientQuantity(
                        ing['id'],
                        (ing['quantity'] as int) - 1,
                      ),
                    ),
                    Text('${ing['quantity']}'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateIngredientQuantity(
                        ing['id'],
                        (ing['quantity'] as int) + 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeIngredient(ing['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.dishId != null ? 'Edit Dish' : 'New Dish';
    final buttonText = widget.dishId != null ? 'Update Dish' : 'Add Dish';
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
                    const Text('Dish Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Dish name is required';
                        }
                        return null;
                      },
                    ),
                    const Divider(),
                    const Text('Description'),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(),
                      maxLines: 3,
                    ),
                    const Divider(),
                    const Text('Price'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decrementPrice,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            decoration: const InputDecoration(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  double.tryParse(value) == null) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _incrementPrice,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Text('Publish Dish'),
                        const Spacer(),
                        Switch(
                          value: _isVisible,
                          onChanged: (value) =>
                              setState(() => _isVisible = value),
                          activeThumbColor: Colors.amber,
                        ),
                      ],
                    ),
                    const Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addIngredient,
                        child: Text(
                          'Add Ingredient',
                          style: TextStyle(color: Colors.amber[300]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Selected Ingredients:'),
                    _buildIngredientsList(),
                    const Divider(),
                    const Text('Image URL'),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(),
                    ),
                    _buildImagePreview(),
                    const SizedBox(height: 20),
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
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final bool available = await _computeAvailability();
                        final ingredientsForSave = _selectedIngredients
                            .where((ing) => ing['id'] != null)
                            .map(
                              (ing) => {
                                'itemId': ing['id'],
                                'quantity': ing['quantity'],
                              },
                            )
                            .toList();
                        final newDish = Dish(
                          id: widget.dishId,
                          name: _nameCtrl.text,
                          description: _descCtrl.text.isEmpty
                              ? null
                              : _descCtrl.text,
                          price: double.parse(_priceCtrl.text),
                          isVisible: _isVisible,
                          isAvailable: available,
                          ingredients: ingredientsForSave,
                          imageUrl: _imageUrlCtrl.text.isEmpty
                              ? null
                              : _imageUrlCtrl.text,
                        );
                        if (widget.dishId == null) {
                          await _menuController.addDish(newDish);
                        } else {
                          await _menuController.updateDish(
                            widget.dishId!,
                            newDish,
                          );
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white),
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
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }
}

class _IngredientSelectionDialog extends StatefulWidget {
  final InventoryController inventoryController;
  final List<Map<String, dynamic>>? selectedIngredients;
  final Function(String, String, int) onSelected;

  const _IngredientSelectionDialog({
    required this.inventoryController,
    this.selectedIngredients,
    required this.onSelected,
  });

  @override
  State<_IngredientSelectionDialog> createState() =>
      _IngredientSelectionDialogState();
}

class _IngredientSelectionDialogState
    extends State<_IngredientSelectionDialog> {
  final _quantityController = TextEditingController(text: '1');
  final _searchController = TextEditingController();
  Item? _selectedItem;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Ingredient'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Ingredients',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Item>>(
                stream: widget.inventoryController.getItems,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data!
                        .where(
                          (item) =>
                              item.name.toLowerCase().contains(_searchText),
                        )
                        .toList();
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final alreadyAdded =
                            widget.selectedIngredients?.any(
                              (ing) => ing['id'] == item.id,
                            ) ??
                            false;
                        return ListTile(
                          title: Text(item.name),
                          enabled: !alreadyAdded,
                          onTap: alreadyAdded
                              ? null
                              : () => setState(() => _selectedItem = item),
                          selected: _selectedItem?.id == item.id,
                          selectedColor: Colors.orange,
                        );
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.orange)),
        ),
        ElevatedButton(
          onPressed: _selectedItem != null
              ? () {
                  final qty = int.tryParse(_quantityController.text) ?? 1;
                  widget.onSelected(
                    _selectedItem!.id!,
                    _selectedItem!.name,
                    qty,
                  );
                  Navigator.pop(context);
                }
              : null,
          child: Text('Add', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
