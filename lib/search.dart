import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Thread'),
      ),
      body: const Center(
        child: Text('This is the Make libary Page'),
      ),
    );
  }
}
