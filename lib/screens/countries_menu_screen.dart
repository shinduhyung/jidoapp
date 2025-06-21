import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/screens/countries_map_screen.dart';
import 'package:jidoapp/screens/continents_list_screen.dart';

class CountriesMenuScreen extends StatelessWidget {
  const CountriesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries'), elevation: 1),
      body: Consumer<CountryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalCountries = provider.allCountries.length;
          final visitedCountries = provider.visitedCountries.length;
          final worldPercent = totalCountries > 0 ? (visitedCountries / totalCountries * 100).round() : 0;
          final worldStats = '$visitedCountries/$totalCountries ($worldPercent%)';

          final allContinentsInDb = provider.allCountries.map((c) => c.continent ?? 'N/A').toSet();
          final visitedContinents = provider.allCountries
              .where((c) => provider.visitedCountries.contains(c.name))
              .map((c) => c.continent ?? 'N/A').toSet();
          final continentsPercent = allContinentsInDb.isNotEmpty ? (visitedContinents.length / allContinentsInDb.length * 100).round() : 0;
          final continentsStats = '${visitedContinents.length}/${allContinentsInDb.length} ($continentsPercent%)';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMenuItem(context: context, title: 'World Map', icon: Icons.map, stats: worldStats,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CountriesMapScreen()))),
                  const SizedBox(height: 20),
                  _buildMenuItem(context: context, title: 'Continents', icon: Icons.public, stats: continentsStats,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContinentsListScreen()))),
                  const SizedBox(height: 20),
                  _buildMenuItem(context: context, title: 'Flags', icon: Icons.flag, onPressed: () {}),
                  const SizedBox(height: 20),
                  _buildMenuItem(context: context, title: 'Statistics', icon: Icons.bar_chart, onPressed: () {}),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({required BuildContext context, required String title, required IconData icon, required VoidCallback onPressed, String? stats}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon), const SizedBox(width: 16), Text(title, style: const TextStyle(fontSize: 18))]),
          if (stats != null) Text(stats, style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}