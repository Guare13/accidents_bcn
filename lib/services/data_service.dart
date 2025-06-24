import 'dart:convert';
import 'package:http/http.dart' as http;

const bool kUseLimit = true; // ↩️ posa a false quan vulguis dades completes

class DataService {
  static final Map<String, Map<String, int>> _mainStatsCache = {};
  // Map d’anys i resource_ids
  static Future<Map<String, int>> fetchMainStats(String year) async {
  if (_mainStatsCache.containsKey(year)) {
    return _mainStatsCache[year]!;
  }

  final records = await fetchAccidents(year);
  int morts = 0;
  int ferits = 0;
  int accidents = 0;

  for (var record in records) {
    accidents++;
    morts += int.tryParse(record['Numero_morts'].toString()) ?? 0;
    ferits += int.tryParse(record['Numero_victimes'].toString()) ?? 0;
  }

  final stats = {
    'morts': morts,
    'ferits': ferits,
    'accidents': accidents,
  };

  _mainStatsCache[year] = stats;
  return stats;
}
  static const Map<String, String> resourceIds = {
    '2024': '66f5e7e3-045b-4d19-b649-2eaea622ae93', // substitueix amb l’ID real
    '2023': 'd12c8a6f-feb0-4c3e-bcf1-46b8a8b3d651',
    '2022': '4d41914e-3121-40ee-9f8a-23c2ffe0d560',
    '2021': '2b689b1f-5653-4ee8-b378-76ad5a336423', // substitueix amb l’ID real
    '2020': 'bcfc0866-7e2a-4054-9a93-fb3f371fc5eb',
    '2019': '7a376881-0767-4ec2-bb41-12f4b645f1df',
    '2018': 'f94d9ac3-e46e-47cd-a3d0-a9b5b9639d86', // substitueix amb l’ID real
    '2017': 'acc9db4c-17b2-4862-8bcc-ed216f8e5839',
    '2016': 'be253540-d3ec-418f-9b72-386492fa5269',
    '2015': '962dcec4-f2a0-41e1-b6c2-c47c260f24b6', // substitueix amb l’ID real
    '2014': '9d8fb285-65d1-4380-8d98-137ca6c52f3e',
    '2013': 'f6e0b9b2-fd47-408f-8b36-ee09f7f4a336',
    '2012': 'c47bf51c-afd8-47e3-ab1b-51835465cd57', // substitueix amb l’ID real
    '2011': 'bd601249-a019-4798-aa3a-f112d4b6845b',
  };

  static Future<List<Map<String, dynamic>>> fetchAccidents(String year) async {
  final resourceId = resourceIds[year];
  if (resourceId == null) {
    throw Exception('No s\'ha trobat resource_id per a l\'any $year');
  }

  if (kUseLimit) {
    print('⚠️ Mode prova activat: només 100 registres carregats');

    final url = Uri.parse(
      'https://opendata-ajuntament.barcelona.cat/data/api/3/action/datastore_search'
      '?resource_id=$resourceId&limit=100',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final records = data['result']['records'];
      return List<Map<String, dynamic>>.from(records);
    } else {
      throw Exception('Error carregant dades per a l\'any $year');
    }
  } else {
    // 🔁 Mode complet amb paginació
    const int pageSize = 1000;
    int offset = 0;
    bool hasMore = true;
    List<Map<String, dynamic>> allRecords = [];

    while (hasMore) {
      final url = Uri.parse(
        'https://opendata-ajuntament.barcelona.cat/data/api/3/action/datastore_search'
        '?resource_id=$resourceId&limit=$pageSize&offset=$offset',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = List<Map<String, dynamic>>.from(data['result']['records']);
        allRecords.addAll(records);

        final total = data['result']['total'] ?? 0;
        offset += pageSize;
        hasMore = offset < total;
      } else {
        throw Exception('Error carregant dades per a l\'any $year');
      }
    }

    return allRecords;
  }
}


  static List<String> get availableYears => resourceIds.keys.toList();
}

// 🔚 Al final de data_service.dart
double? tryParseCoordinate(Map<String, dynamic> record, List<String> keys) {
  for (final key in keys) {
    final value = double.tryParse(record[key]?.toString() ?? '');
    if (value != null) return value;
  }
  return null;
}