import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jidoapp/models/country_model.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/screens/countries_map_screen.dart';

class HeaderItem {
  final String title;
  final String stats;
  HeaderItem(this.title, this.stats);
}

class CountrySelectionScreen extends StatefulWidget {
  final List<Country> allCountries;
  final ScrollController scrollController;
  final GroupBy groupBy;

  const CountrySelectionScreen({
    super.key, required this.allCountries, required this.scrollController, required this.groupBy,
  });

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  String _searchQuery = '';
  late Set<String> _tempSelectedCountries;
  late List<dynamic> _displayList;

  @override
  void initState() {
    super.initState();
    _tempSelectedCountries = Provider.of<CountryProvider>(context, listen: false).visitedCountries.toSet();
    _buildDisplayList();
  }

  void _buildDisplayList() {
    final Map<String, List<Country>> groupedCountries = {};

    final relevantCountries = _searchQuery.isEmpty
        ? widget.allCountries
        : widget.allCountries.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    for (var country in relevantCountries) {
      final key = (widget.groupBy == GroupBy.continent ? country.continent : country.subregion) ?? 'Unclassified';
      groupedCountries.putIfAbsent(key, () => []).add(country);
    }

    groupedCountries.forEach((key, value) => value.sort((a, b) => a.name.compareTo(b.name)));
    final sortedGroupKeys = groupedCountries.keys.toList()..sort();

    _displayList = [];
    for (var key in sortedGroupKeys) {
      final countriesInGroup = groupedCountries[key]!;
      final visitedCount = countriesInGroup.where((c) => _tempSelectedCountries.contains(c.name)).length;
      final totalCount = countriesInGroup.length;
      final percent = totalCount > 0 ? (visitedCount / totalCount * 100).round() : 0;
      final stats = '$visitedCount/$totalCount ($percent%)';

      _displayList.add(HeaderItem(key, stats));
      _displayList.addAll(countriesInGroup);
    }
  }

  void _onSearchChanged(String query) {
    setState(() { _searchQuery = query; _buildDisplayList(); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextField(onChanged: _onSearchChanged, decoration: InputDecoration(labelText: 'Search Country', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _displayList.length,
              itemBuilder: (context, index) {
                final item = _displayList[index];
                if (item is HeaderItem) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                        Text(item.stats, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                      ],
                    ),
                  );
                }
                if (item is Country) {
                  final country = item;
                  final isSelected = _tempSelectedCountries.contains(country.name);
                  return CheckboxListTile(
                    title: Text(country.name),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _tempSelectedCountries.add(country.name);
                        } else {
                          _tempSelectedCountries.remove(country.name);
                        }
                        _buildDisplayList();
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Cancel'))),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(onPressed: () {
                Provider.of<CountryProvider>(context, listen: false).updateVisitedCountries(_tempSelectedCountries);
                Navigator.pop(context);
              }, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('OK'))),
            ],
          ),
        ],
      ),
    );
  }
}