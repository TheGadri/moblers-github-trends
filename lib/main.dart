import 'package:flutter/material.dart';
import 'package:moblers_github_trends/app/github_app.dart';
import 'package:moblers_github_trends/utils/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  runApp(const GithubApp());
}
