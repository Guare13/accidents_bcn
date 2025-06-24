import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/year_provider.dart';

class MortsAcumulatsPerMes extends StatelessWidget {
  final List<dynamic> accidents;

  const MortsAcumulatsPerMes({super.key, required this.accidents});

  static const List<String> mesos = [
    'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny',
    'Juliol', 'Agost', 'Set.', 'Oct.', 'Nov.', 'Des.'
  ];

  @override
  Widget build(BuildContext context) {
    final selectedYear = Provider.of<YearProvider>(context).selectedYear;

    final mortsPerMes = List.filled(12, 0);

    for (final acc in accidents) {
      final any = acc['Any']?.toString();
      final mesStr = acc['Mes_any']?.toString();
      final morts = int.tryParse(acc['Numero_morts']?.toString() ?? '') ?? 0;

      if (any == selectedYear && mesStr != null) {
        final mesIndex = int.tryParse(mesStr);
        if (mesIndex != null && mesIndex >= 1 && mesIndex <= 12) {
          mortsPerMes[mesIndex - 1] += morts;
        }
      }
    }

    // Càlcul de suma acumulada
    final acumulats = <double>[];
    int suma = 0;
    for (final m in mortsPerMes) {
      suma += m;
      acumulats.add(suma.toDouble());
    }

    final maxY = acumulats.reduce((a, b) => a > b ? a : b) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolució acumulada de víctimes mortals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(12, (i) => FlSpot(i.toDouble(), acumulats[i])),
                  isCurved: true,
                  color: Colors.red,
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                )
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < mesos.length) {
                        return Text(mesos[index], style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 5).ceilToDouble(),
                    getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}
