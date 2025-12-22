import 'package:flutter/material.dart';
import 'package:ats/core/app/candidate_initializer.dart';
import 'package:ats/core/app/candidate_app.dart';

void main() async {
  await CandidateInitializer.initialize();
  runApp(const CandidateApp());
}

