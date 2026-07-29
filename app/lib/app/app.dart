import 'package:flutter/material.dart';
import 'package:jizhangben/app/app_shell.dart';
import 'package:jizhangben/core/app_metadata.dart';

class JizhangbenApp extends StatelessWidget {
  const JizhangbenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppMetadata.displayName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D6B57)),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
