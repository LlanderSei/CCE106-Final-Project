import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/models/item.dart';

class ModifyItemPage extends StatefulWidget {
  final String? itemId;
  final Item? item;

  const ModifyItemPage({super.key, this.itemId, this.item});

  @override
  State<ModifyItemPage> createState() => _ModifyItemPageState();
}

class _ModifyItemPageState extends State<ModifyItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _imageUrlCtrl;
  int _quantity = 0;
  final InventoryController _controller = InventoryController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item?.name ?? '');
    _descCtrl = TextEditingController(text: widget.item?.description ?? '');
    _qtyCtrl = TextEditingController(text: '${widget.item?.quantity ?? 0}');
    _imageUrlCtrl = TextEditingController(text: widget.item?.imageUrl ?? '');
    _quantity = widget.item?.quantity ?? 0;
  }

  void _incrementQty() {
    setState(() {
      _quantity++;
      _qtyCtrl.text = _quantity.toString();
    });
  }

  void _decrementQty() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _qtyCtrl.text = _quantity.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemId != null ? 'Edit Item' : 'New Item';
    final buttonText = widget.itemId != null ? 'Update Item' : 'Add Item';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _decrementQty,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _incrementQty,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newItem = Item(
                          id: widget.itemId ?? '',
                          name: _nameCtrl.text,
                          description: _descCtrl.text.isEmpty
                              ? null
                              : _descCtrl.text,
                          quantity: int.parse(_qtyCtrl.text),
                          imageUrl: _imageUrlCtrl.text.isEmpty
                              ? null
                              : _imageUrlCtrl.text,
                        );
                        if (widget.itemId == null) {
                          await _controller.addItem(newItem);
                        } else {
                          await _controller.updateItem(widget.itemId!, newItem);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(
                      buttonText,
                      style: TextStyle(color: Colors.orangeAccent[200]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }
}
