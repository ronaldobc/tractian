import 'package:flutter/material.dart';

import 'package:tractian/pages/assets_page.dart';
import 'package:tractian/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tractian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: false,
      ),
      routes: {
        HomePage.ROUTE: (context) => const HomePage(),
        AssetsPage.ROUTE: (context) => const AssetsPage(),
      },
    );
  }
}
