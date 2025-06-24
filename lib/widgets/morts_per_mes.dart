import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MortsPerMes extends StatelessWidget {
  final List<dynamic> accidents;

  const MortsPerMes({super.key, required this.accidents});

  static const List<String> mesosCatalans = [
    'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny',
    'Juliol', 'Agost', 'Setembre', 'Octubre', 'Novembre', 'Desembre'
  ];

  @override
  Widget build(BuildContext context) {
    // Inicialitzem llista amb 0 morts per mes
    final mortsPerMes = List<int>.filled(12, 0);

    for (final acc in accidents) {
      final mes = acc['Nom_mes']?.toString();
      final morts = int.tryParse(acc['Numero_morts']?.toString() ?? '') ?? 0;

      final index = mesosCatalans.indexOf(mes ?? '');
      if (index != -1) {
        mortsPerMes[index] += morts;
      }
    }

    final double maxY = mortsPerMes.isEmpty
        ? 10
        : mortsPerMes.reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Víctimes mortals per mes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: List.generate(12, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: mortsPerMes[i].toDouble(),
                      color: Colors.red,
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < mesosCatalans.length) {
                        return Text(mesosCatalans[index], style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY / 5).ceilToDouble() == 0 ? 1 : (maxY / 5).ceilToDouble(),
                    getTitlesWidget: (value, _) {
                      return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                    },
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
