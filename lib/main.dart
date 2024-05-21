import 'package:dma/pages/dm_app.dart';
import 'package:dma/setup/firebase_setup.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFirebase();

  runApp(const DmApp());
}