import 'package:flutter/material.dart';
import 'package:ats/core/app/admin_initializer.dart';
import 'package:ats/core/app/admin_app.dart';

void main() async {
  await AdminInitializer.initialize();
  runApp(const AdminApp());
}

