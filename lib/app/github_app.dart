import 'package:flutter/material.dart';
import 'package:moblers_github_trends/screens/home_screen.dart';

class GithubApp extends StatelessWidget {
  const GithubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Trends',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: HomeScreen(),
    );
  }
}
