import 'package:flutter/material.dart';
import 'package:jidoapp/screens/countries_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JidoApp', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1564419429381-98dbcf916478?q=80&w=2574&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(context, 'Countries', Icons.public, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CountriesMenuScreen()));
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'Cities', Icons.location_city, () {}),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'Landmarks', Icons.camera_alt, () {}),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'Settings', Icons.settings, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        minimumSize: const Size(250, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white70)),
      ),
    );
  }
}