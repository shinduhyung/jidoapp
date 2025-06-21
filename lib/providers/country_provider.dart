import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:jidoapp/models/country_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Country> _parseAndFilterCountries(String jsonStr) {
  final data = json.decode(jsonStr);
  final List<dynamic> features = data['features'];
  List<Country> countries = features.map((feature) => Country.fromJson(feature)).toList();
  countries.removeWhere((country) => country.name.toLowerCase() == 'indian ocean ter.');
  return countries;
}

class CountryProvider with ChangeNotifier {
  bool _isLoading = true;
  List<Country> _allCountries = [];
  Set<String> _visitedCountries = {};

  bool get isLoading => _isLoading;
  List<Country> get allCountries => _allCountries;
  Set<String> get visitedCountries => _visitedCountries;

  CountryProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    final String jsonStr = await rootBundle.loadString('assets/custom.geo.json');
    _allCountries = await compute(_parseAndFilterCountries, jsonStr);

    final prefs = await SharedPreferences.getInstance();
    _visitedCountries = prefs.getStringList('visited_countries')?.toSet() ?? {};

    _isLoading = false;
    notifyListeners();
  }

  void updateVisitedCountries(Set<String> newCountries) {
    _visitedCountries = newCountries;
    _saveVisitedCountries();
    notifyListeners();
  }

  Future<void> _saveVisitedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('visited_countries', _visitedCountries.toList());
  }
}