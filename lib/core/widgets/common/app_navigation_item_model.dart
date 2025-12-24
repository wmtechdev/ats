import 'package:flutter/material.dart';

class AppNavigationItemModel {
  final String title;
  final IconData icon;
  final String route;
  final bool enabled;

  const AppNavigationItemModel({
    required this.title,
    required this.icon,
    required this.route,
    this.enabled = true,
  });
}

