import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/screens/countries_map_screen.dart';

class ContinentsListScreen extends StatelessWidget {
  const ContinentsListScreen({super.key});

  static const List<Map<String, dynamic>> continents = [
    {'name': 'Asia', 'icon': Icons.language}, {'name': 'Europe', 'icon': Icons.euro}, {'name': 'Africa', 'icon': Icons.public},
    {'name': 'North America', 'icon': Icons.public}, {'name': 'South America', 'icon': Icons.south_america}, {'name': 'Oceania', 'icon': Icons.public},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CountryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Continents')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: continents.length,
        itemBuilder: (context, index) {
          final continentName = continents[index]['name'];

          final countriesInContinent = provider.allCountries.where((c) => c.continent == continentName).toList();
          final visitedInContinent = countriesInContinent.where((c) => provider.visitedCountries.contains(c.name)).length;
          final totalInContinent = countriesInContinent.length;
          final percent = totalInContinent > 0 ? (visitedInContinent / totalInContinent * 100).round() : 0;
          final stats = '$visitedInContinent/$totalInContinent ($percent%)';

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              leading: Icon(continents[index]['icon'], size: 30, color: Theme.of(context).primaryColor),
              title: Text(continentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              trailing: Text(stats, style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CountriesMapScreen(region: continentName))),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }
}