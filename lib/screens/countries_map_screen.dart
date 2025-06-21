import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jidoapp/models/country_model.dart';
import 'package:jidoapp/providers/country_provider.dart';
import 'package:jidoapp/screens/country_selection_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

List<Country> _parseCountries(String jsonStr) {
  final data = json.decode(jsonStr);
  final List<dynamic> features = data['features'];
  List<Country> countries = features.map((feature) => Country.fromJson(feature)).toList();
  countries.removeWhere((country) => country.name.toLowerCase() == 'indian ocean ter.');
  return countries;
}

enum GroupBy { continent, subregion }

class CountriesMapScreen extends StatefulWidget {
  final String? region;
  const CountriesMapScreen({super.key, this.region});

  @override
  State<CountriesMapScreen> createState() => _CountriesMapScreenState();
}

class _CountriesMapScreenState extends State<CountriesMapScreen> {
  // MapController는 이제 fitCamera에 사용되지 않지만, 다른 기능 확장을 위해 남겨둘 수 있습니다.
  final MapController _mapController = MapController();
  List<Country> _allCountries = [];
  bool _isLoading = true;

  static final Map<String, Map<String, dynamic>> _continentData = {
    'Europe': {'bounds': LatLngBounds(const LatLng(34, -35), const LatLng(72, 50))},
    'Asia': {'bounds': LatLngBounds(const LatLng(-12, 15), const LatLng(82, 190))},
    'Africa': {'bounds': LatLngBounds(const LatLng(-40, -28), const LatLng(40, 75))},
    'North America': {'bounds': LatLngBounds(const LatLng(5, -175), const LatLng(85, -10))},
    'South America': {'bounds': LatLngBounds(const LatLng(-60, -105), const LatLng(15, -25))},
    'Oceania': {'bounds': LatLngBounds(const LatLng(-55, 95), const LatLng(30, -130))},
  };

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/custom.geo.json');
      final List<Country> countries = await compute(_parseCountries, jsonStr);
      if (mounted) {
        setState(() { _allCountries = countries; _isLoading = false; });
      }
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('지도 데이터를 불러오는 데 실패했습니다: $e')),);
      }
    }
  }

  Color _getColorByContinent(String? continent) {
    switch (continent) { case 'North America': return Colors.blue.shade400; case 'South America': return Colors.green.shade400; case 'Africa': return Colors.brown.shade400; case 'Europe': return Colors.yellow.shade700; case 'Asia': return Colors.pink.shade300; case 'Oceania': return Colors.purple.shade400; default: return Colors.grey.shade500; }
  }

  Color _getColorBySubregion(String? subregion) {
    switch (subregion) { case null: return Colors.grey.shade400; case 'Western Asia': return Colors.red.shade400; case 'Central Asia': return Colors.orange.shade600; case 'Southern Asia': return Colors.amber.shade600; case 'Eastern Asia': return Colors.yellow.shade600; case 'South-Eastern Asia': return Colors.lime.shade600; case 'Northern Europe': return Colors.green.shade400; case 'Western Europe': return Colors.teal.shade400; case 'Eastern Europe': return Colors.cyan.shade500; case 'Southern Europe': return Colors.lightBlue.shade400; case 'Central Europe': return Colors.blue.shade800; case 'Northern Africa': return Colors.indigo.shade300; case 'Western Africa': return Colors.purple.shade300; case 'Middle Africa': return Colors.pink.shade300; case 'Eastern Africa': return Colors.red.shade300; case 'Southern Africa': return Colors.orange.shade300; case 'North America': return Colors.cyan.shade700; case 'Central America': return Colors.teal.shade700; case 'Caribbean': return Colors.lightGreen.shade700; case 'South America': return Colors.green.shade800; case 'Australia and New Zealand': return Colors.deepPurple.shade400; case 'Melanesia': return Colors.indigo.shade400; case 'Micronesia': return Colors.blue.shade800; case 'Polynesia': return Colors.cyan.shade800; default: debugPrint("Warning: Unhandled subregion '$subregion'."); return Colors.grey.shade500; }
  }

  @override
  Widget build(BuildContext context) {
    final seamlessBackgroundColor = const Color(0xfff2f4f6);

    return Scaffold(
      backgroundColor: seamlessBackgroundColor,
      appBar: AppBar(title: Text(widget.region ?? 'World Map')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<CountryProvider>(
        builder: (context, provider, child) {
          final visitedSet = provider.visitedCountries;
          final isWorldView = widget.region == null;
          final List<Country> countriesForThisView = isWorldView ? _allCountries : _allCountries.where((c) => c.continent == widget.region).toList();

          final List<Polygon> polygonsToDraw = [];
          for (var country in countriesForThisView) {
            final bool isVisited = visitedSet.contains(country.name);
            final subregionForColoring = (country.name == 'Iran') ? 'Western Asia' : country.subregion;
            final color = isWorldView ? _getColorByContinent(country.continent) : _getColorBySubregion(subregionForColoring);

            for (var polygonData in country.polygonsData) {
              polygonsToDraw.add(Polygon(
                points: polygonData.first, holePointsList: polygonData.length > 1 ? polygonData.sublist(1) : null,
                color: isVisited ? color : Colors.grey.withOpacity(0.35),
                borderColor: isVisited ? Colors.black45 : Colors.white70,
                borderStrokeWidth: 0.5, isFilled: true,
              ));
            }
          }

          final worldBounds = LatLngBounds(const LatLng(-60, -180), const LatLng(85, 180));
          final LatLngBounds boundsToFit = isWorldView ? worldBounds : _continentData[widget.region]!['bounds'] as LatLngBounds;

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // *** 수정 1: onMapReady 대신 initialCameraFit 사용 ***
              // 지도가 처음부터 이 경계에 맞춰서 로드됩니다.
              initialCameraFit: CameraFit.bounds(
                bounds: boundsToFit,
                padding: const EdgeInsets.all(25.0),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom,
              ),
              cameraConstraint: CameraConstraint.contain(
                bounds: boundsToFit,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                backgroundColor: seamlessBackgroundColor,
              ),
              if (polygonsToDraw.isNotEmpty) PolygonLayer(polygons: polygonsToDraw),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<CountryProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton(
            onPressed: _isLoading ? null : () {
              final isWorldView = widget.region == null;
              final countriesForThisView = isWorldView ? _allCountries : _allCountries.where((c) => c.continent == widget.region).toList();
              showModalBottomSheet(
                context: context, isScrollControlled: true,
                builder: (_) => DraggableScrollableSheet(
                  expand: false, initialChildSize: 0.8, maxChildSize: 0.9, minChildSize: 0.5,
                  builder: (BuildContext context, ScrollController scrollController) {
                    return CountrySelectionScreen(
                      allCountries: countriesForThisView,
                      groupBy: isWorldView ? GroupBy.continent : GroupBy.subregion,
                      scrollController: scrollController,
                    );
                  },
                ),
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}