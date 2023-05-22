// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  final _shoppingBox = Hive.box('shopping_box');

  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {
        "key": key,
        'name': item['name'],
        'quantity': item['quantity'],
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print(_items);
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("An item has been deleted"),
      ),
    );
  }

  void _showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _qtyController.text = existingItem['quantity'];
    }
    await showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "product name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _qtyController,
                decoration: InputDecoration(hintText: "product quantity"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (itemKey == null) {
                    _createItem({
                      "name": _nameController.text,
                      "quantity": _qtyController.text,
                    });
                  }
                  if (itemKey != null) {
                    _updateItem(itemKey, {
                      "name": _nameController.text.trim(),
                      "quantity": _qtyController.text.trim(),
                    });
                  }
                  _nameController.text = "";
                  _qtyController.text = "";
                  Navigator.of(context).pop();
                },
                child: Text(itemKey == null ? "Create New" : "Update"),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hive"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final currentData = _items[index];
          return Card(
            color: Colors.orange.shade100,
            elevation: 3,
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(currentData['name']),
              subtitle: Text(currentData['quantity']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showForm(context, currentData['key']),
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => _deleteItem(currentData['key']),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
    );
  }
}
