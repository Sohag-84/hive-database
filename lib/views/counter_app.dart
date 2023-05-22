// ignore_for_file: prefer_const_constructors, unused_element

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({Key? key}) : super(key: key);

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int counter = 0;
  String counterKey = "";
  final box = Hive.box("counter_box");

  @override
  void initState() {
    super.initState();

    final value = box.get(counterKey) ?? 0;
    counter = value;
  }

  void _increament() {
    setState(() {
      counter++;
    });
    box.put(counterKey, counter);
  }

  void _decreament() {
    setState(() {
      if (counter > 1) {
        counter--;
      }
      box.put(counterKey, counter);
    });
    box.put(counterKey, counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter App"),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _decreament,
              icon: Icon(Icons.minimize_outlined),
            ),
            SizedBox(width: 10),
            Text("Counter value: $counter"),
            SizedBox(width: 10),
            IconButton(
              onPressed: _increament,
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
