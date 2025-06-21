import 'package:latlong2/latlong.dart';

class Country {
  final String name;
  final String? continent;
  final String? subregion;
  final List<List<List<LatLng>>> polygonsData;

  Country({
    required this.name,
    this.continent,
    this.subregion,
    required this.polygonsData,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final geometry = json['geometry'];
    final coordinates = geometry['coordinates'];
    final type = geometry['type'];
    List<List<List<LatLng>>> allPolygonsData = [];

    List<LatLng> coordsToLatLng(List coords) {
      return coords.map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble())).toList();
    }

    if (type == 'Polygon') {
      List<List<LatLng>> polygonRings = [];
      for (var ring in coordinates) {
        polygonRings.add(coordsToLatLng(ring));
      }
      allPolygonsData.add(polygonRings);
    } else if (type == 'MultiPolygon') {
      for (var polygon in coordinates) {
        List<List<LatLng>> polygonRings = [];
        for (var ring in polygon) {
          polygonRings.add(coordsToLatLng(ring));
        }
        allPolygonsData.add(polygonRings);
      }
    }
    return Country(
      name: properties['admin'] ?? properties['name'] ?? 'Unknown',
      continent: properties['continent'],
      subregion: properties['subregion'],
      polygonsData: allPolygonsData,
    );
  }
}