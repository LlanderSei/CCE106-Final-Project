import 'package:bbqlagao_and_beefpares/controllers/manager/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/menu_controller.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_checkbox.dart';
import 'package:gradient_icon/gradient_icon.dart';
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
  bool _isLoading = false;

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
          Toast.show('Item Unavailable/Deleted');
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _IngredientSelectionBottomSheet(
        inventoryController: _inventoryController,
        selectedIngredientIds: _selectedIngredients
            .map((ing) => ing['id'] as String)
            .toSet(),
        onAdd: (newIngredients) {
          setState(() {
            _selectedIngredients.addAll(newIngredients);
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
              color: Colors.orange[50],
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
                      icon: GradientIcon(
                        icon: Icons.delete,
                        gradient: LinearGradient(
                          colors: GradientColorSets.set2,
                        ),
                        offset: Offset.zero,
                      ),
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
                      child: GradientButton(
                        onPressed: _addIngredient,
                        child: Text(
                          'Add Ingredient',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
                  !_isLoading
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orangeAccent),
                            foregroundColor: Colors.orangeAccent,
                            backgroundColor: Colors.white54,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const GradientCircularProgressIndicator()
                      : GradientButton(
                          colors: GradientColorSets.set3,
                          onPressed: () async {
                            if (_isLoading) return;
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
                                final bool available =
                                    await _computeAvailability();
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
                              } catch (e) {
                                Toast.show('Error: ${e.toString()}');
                              } finally {
                                if (context.mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                          child: Text(
                            buttonText,
                            style: TextStyle(
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
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }
}

class _IngredientSelectionBottomSheet extends StatefulWidget {
  final InventoryController inventoryController;
  final Set<String> selectedIngredientIds;
  final Function(List<Map<String, dynamic>>) onAdd;

  const _IngredientSelectionBottomSheet({
    required this.inventoryController,
    required this.selectedIngredientIds,
    required this.onAdd,
  });

  @override
  State<_IngredientSelectionBottomSheet> createState() =>
      _IngredientSelectionBottomSheetState();
}

class _IngredientSelectionBottomSheetState
    extends State<_IngredientSelectionBottomSheet> {
  String _searchText = '';
  final List<Map<String, dynamic>> _selectedIngredients = [];

  bool _isSelected(Item item) {
    return _selectedIngredients.any((m) => m['id'] == item.id);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchText = val.toLowerCase()),
              decoration: const InputDecoration(
                labelText: 'Search Ingredients',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: widget.inventoryController.getItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GradientCircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No ingredients available.'));
                }
                final availableIngredients = snapshot.data!
                    .where(
                      (item) =>
                          !widget.selectedIngredientIds.contains(item.id) &&
                          item.name.toLowerCase().contains(_searchText),
                    )
                    .toList();
                return ListView.builder(
                  controller: scrollController,
                  itemCount: availableIngredients.length,
                  itemBuilder: (context, index) {
                    final item = availableIngredients[index];
                    final isSelected = _isSelected(item);
                    return ListTile(
                      leading: GradientCheckbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val!) {
                              _selectedIngredients.add({
                                'id': item.id,
                                'name': item.name,
                              });
                            } else {
                              _selectedIngredients.removeWhere(
                                (m) => m['id'] == item.id,
                              );
                            }
                          });
                        },
                      ),
                      title: Text(item.name),
                      subtitle: Text('Stock: ${item.quantity}'),
                      trailing: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image_not_supported),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  onPressed: () {
                    final newIngredients = _selectedIngredients
                        .map(
                          (m) => {
                            'id': m['id'],
                            'name': m['name'],
                            'quantity': 1,
                          },
                        )
                        .toList();
                    widget.onAdd(newIngredients);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add Ingredient',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
