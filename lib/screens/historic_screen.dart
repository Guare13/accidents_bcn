import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/year_provider.dart';
import '../services/data_service.dart';

class HistoricScreen extends StatefulWidget {
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistoricScreenState();
}

class _HistoricScreenState extends State<HistoricScreen> {
  Map<String, int> dades = {};
  bool isLoading = true;
  double maxY = 100;
  String selectedOption = 'Dia de la setmana';

  final List<String> diesSetmana = [
    'Dilluns', 'Dimarts', 'Dimecres', 'Dijous', 'Divendres', 'Dissabte', 'Diumenge'
  ];

  final List<String> mesosCatalans = [
    'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny',
    'Juliol', 'Agost', 'Setembre', 'Octubre', 'Novembre', 'Desembre'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final year = Provider.of<YearProvider>(context, listen: false).selectedYear;

    try {
      final records = await DataService.fetchAccidents(year);

      Map<String, int> counts = {};

      if (selectedOption == 'Dia de la setmana') {
        counts = {for (var d in diesSetmana) d: 0};
        for (var r in records) {
          final d = r['Descripcio_dia_setmana'];
          if (counts.containsKey(d)) counts[d] = counts[d]! + 1;
        }
      } else if (selectedOption == 'Hora del dia') {
        counts = {};
        for (var r in records) {
          final h = r['Hora_dia']?.toString() ?? '';
          if (h.isEmpty) continue;
          counts[h] = (counts[h] ?? 0) + 1;
        }
      } else if (selectedOption == 'Mes de l\'any') {
  counts = {for (var m in mesosCatalans) m: 0};
  for (var r in records) {
    final m = r['Nom_mes'];
    if (counts.containsKey(m)) counts[m] = counts[m]! + 1;
  }

}
      setState(() {
        dades = counts;
        maxY = counts.isEmpty ? 10 : counts.values.reduce((a, b) => a > b ? a : b).toDouble();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  List<String> get currentLabels {
    if (selectedOption == 'Dia de la setmana') return diesSetmana;
    if (selectedOption == 'Mes de l\'any') return mesosCatalans;
    return dades.keys.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: selectedOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedOption = value);
                      fetchData();
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'Dia de la setmana', child: Text('Dia de la setmana')),
                    DropdownMenuItem(value: 'Hora del dia', child: Text('Hora del dia')),
                    DropdownMenuItem(value: 'Mes de l\'any', child: Text('Mes de l\'any')),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    final width = isDesktop ? 700.0 : double.infinity;

                    return Center(
                      child: SizedBox(
                        width: width,
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            maxY: maxY,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    final labels = currentLabels;
                                    if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        labels[index],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: ((maxY / 5).ceilToDouble() == 0) ? 1 : (maxY / 5).ceilToDouble(),
                                  getTitlesWidget: (value, meta) => SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(currentLabels.length, (index) {
                                  final label = currentLabels[index];
                                  final valor = dades[label] ?? 0;
                                  return FlSpot(index.toDouble(), valor.toDouble());
                                }),
                                isCurved: true,
                                color: Colors.blue,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(show: false),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Nombre d\'accidents per ${selectedOption.toLowerCase()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
  }
}
