import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';

class AddItemScreen extends StatefulWidget {
  final Item? editItem; // For editing an existing item
  final int? index; // Index of the item being edited

  const AddItemScreen({super.key, this.editItem, this.index});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _retailPriceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();

  DateTime? _expiryDate;

  // Dropdown values
  String? _selectedCategory;
  String? _selectedUnit;

  // Dropdown options
  final List<String> _categories = ["Grocery", "Beverages", "Household"];
  final List<String> _units = ["pcs", "kg", "ltr"];

  @override
  void initState() {
    super.initState();

    // If editing, pre-fill data
    if (widget.editItem != null) {
      _nameController.text = widget.editItem!.name;
      _skuController.text = widget.editItem!.sku;
      _selectedCategory = widget.editItem!.category;
      _selectedUnit = widget.editItem!.unit;
      _basePriceController.text = widget.editItem!.basePrice.toString();
      _retailPriceController.text =
          widget.editItem!.retailPrice?.toString() ?? '';
      _supplierController.text = widget.editItem!.supplier ?? '';
      _expiryDate = widget.editItem!.expiryDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editItem == null ? "Add Item" : "Edit Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Item Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Item Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter item name" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: "SKU / Item Code",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter SKU" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Select a category" : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: const InputDecoration(
                    labelText: "Unit of Measurement",
                    border: OutlineInputBorder(),
                  ),
                  items: _units.map((unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Select a unit of measurement" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _basePriceController,
                  decoration: const InputDecoration(
                    labelText: "Base Price",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "Enter base price";
                    if (double.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _retailPriceController,
                  decoration: const InputDecoration(
                    labelText: "Retail Price (optional)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isNotEmpty && double.tryParse(value) == null) {
                      return "Enter a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _supplierController,
                  decoration: const InputDecoration(
                    labelText: "Supplier Name (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _expiryDate == null
                            ? "No expiry date selected"
                            : "Expiry: ${_expiryDate!.toLocal()}".split(" ")[0],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _expiryDate = picked;
                          });
                        }
                      },
                      child: const Text("Select Date"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ), // Full-width button
                    backgroundColor: Colors.blue, // Stronger color
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var newItem = Item(
                        id: widget.editItem?.id ?? const Uuid().v4(),
                        name: _nameController.text,
                        sku: _skuController.text,
                        category: _selectedCategory!,
                        unit: _selectedUnit!,
                        basePrice: double.parse(_basePriceController.text),
                        retailPrice: _retailPriceController.text.isNotEmpty
                            ? double.parse(_retailPriceController.text)
                            : null,
                        supplier: _supplierController.text.isNotEmpty
                            ? _supplierController.text
                            : null,
                        expiryDate: _expiryDate,
                      );

                      final box = Hive.box<Item>('items');
                      if (widget.editItem != null) {
                        await box.putAt(widget.index!, newItem);
                      } else {
                        await box.add(newItem);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.editItem == null
                                ? "Item added successfully!"
                                : "Item updated successfully!",
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.editItem == null ? "Save Item" : "Update Item",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
