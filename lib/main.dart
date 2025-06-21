import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CountryProvider(),
      child: const JidoApp(),
    ),
  );
}

class JidoApp extends StatelessWidget {
  const JidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JidoApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}