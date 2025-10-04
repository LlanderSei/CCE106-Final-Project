import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
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
  late String _result;
  int _quantity = 0;
  final InventoryController _controller = InventoryController();
  bool _isLoading = false;

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
                    const Text('Item Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Item name is required';
                        }
                        return null;
                      },
                    ),
                    const Divider(),
                    const Text('Description'),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(),
                      maxLines: 5,
                    ),
                    const Divider(),
                    const Text('Quantity'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decrementQty,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _qtyCtrl,
                            decoration: const InputDecoration(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  int.tryParse(value) == null) {
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
                    const Divider(),
                    const Text('Image URL'),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(),
                    ),
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
                            side: const BorderSide(color: Colors.orangeAccent),
                            foregroundColor: Colors.orangeAccent,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const GradientCircularProgressIndicator()
                      : GradientButton(
                          onPressed: () async {
                            if (_isLoading) return;
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              try {
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
                                  await _controller.updateItem(
                                    widget.itemId!,
                                    newItem,
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
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }
}
