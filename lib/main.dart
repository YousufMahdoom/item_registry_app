import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/item.dart';
import 'screens/view_items_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter()); // Register your Item adapter
  await Hive.openBox<Item>('items'); // Open your items box
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Registry',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ViewItemsScreen(),
    );
  }
}
