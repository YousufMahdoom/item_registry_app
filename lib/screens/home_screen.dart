import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Item>('items');

    return Scaffold(
      appBar: AppBar(title: const Text("Item Registry")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Item> items, _) {
          if (items.isEmpty) {
            return const Center(child: Text("No items added yet."));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("SKU: ${item.sku} | ${item.category}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddItemScreen(editItem: item, index: index),
                          ),
                        );
                      } else if (value == 'delete') {
                        final box = Hive.box<Item>('items');
                        await box.deleteAt(index);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item.name} deleted")),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
