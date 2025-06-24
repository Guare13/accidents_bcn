import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/year_provider.dart';
import '../services/data_service.dart';

const bool kUseLimit = true; // posa-ho a false en producció

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> accidents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAccidentData();
    
  }

Future<void> fetchAccidentData() async {
  setState(() => isLoading = true);
  final year = Provider.of<YearProvider>(context, listen: false).selectedYear;

  try {
    final records = await DataService.fetchAccidents(year);

    List<Map<String, dynamic>> list = [];

    for (var record in records) {
      final lat = tryParseCoordinate(record, ['Latitud_WGS84', 'Latitud', 'CoordY']);
      final lon = tryParseCoordinate(record, ['Longitud_WGS84', 'Longitud', 'CoordX']);
      if (lat != null && lon != null) {
        list.add({
          'latlng': LatLng(lat, lon),
          'dia': record['Dia_mes']?.toString() ?? '—',
          'hora': record['Hora_dia']?.toString() ?? '—',
          'mes': record['Nom_mes'],
          'victimes': record['Numero_victimes'],
          'morts': int.tryParse(record['Numero_morts']?.toString() ?? '') ?? 0,
        });
      }
    }

    setState(() {
      accidents = list;
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error carregant dades: ${e.toString()}')),
    );
  }
}
  void _mostrarDetall(BuildContext context, Map<String, dynamic> acc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detall de l\'accident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🕒 Hora: ${acc['hora']}:00'),
            Text('📅 Dia: ${acc['dia']} de ${acc['mes']}'),
            Text('  Víctimes: ${acc['victimes']}'),
            Text('  Morts: ${acc['morts']}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Tancar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  final bool esMobil = MediaQuery.of(context).size.width < 600;

  return isLoading
      ? const Center(child: CircularProgressIndicator())
      : Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: esMobil ? 8.0 : 20.0,
                  horizontal: esMobil ? 8.0 : 40.0,
                ),
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(41.38879, 2.15899),
                    zoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: accidents.map((acc) {
                        return Marker(
                          width: 10,
                          height: 10,
                          point: acc['latlng'],
                          child: GestureDetector(
                            onTap: () => _mostrarDetall(context, acc),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color:  Color(0xFF1565C0), // Blau fosc
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
}
}
