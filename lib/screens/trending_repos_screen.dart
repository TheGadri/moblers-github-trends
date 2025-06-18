import 'package:flutter/material.dart';

class TrendingReposScreen extends StatelessWidget {
  const TrendingReposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending Repositories')),
      body: const Center(
        child: Text(
          'Trending repositories will be displayed here.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
