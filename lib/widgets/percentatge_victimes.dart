import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PercentatgeVictimesMortals extends StatelessWidget {
  final List<dynamic> accidents;

  const PercentatgeVictimesMortals({super.key, required this.accidents});

  @override
  Widget build(BuildContext context) {
    int morts = 0;
    int greus = 0;
    int lleus = 0;

    for (var acc in accidents) {
      morts += int.tryParse(acc['Numero_morts']?.toString() ?? '0') ?? 0;
      greus += int.tryParse(acc['Numero_lesionats_greus']?.toString() ?? '0') ?? 0;
      lleus += int.tryParse(acc['Numero_lesionats_lleus']?.toString() ?? '0') ?? 0;
    }

    final total = morts + greus + lleus;
    if (total == 0) {
      return const Text('No hi ha dades per mostrar el gràfic de víctimes.');
    }

    final mortsPercent = (morts / total) * 100;
    final greusPercent = (greus / total) * 100;
    final lleusPercent = (lleus / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Distribució de víctimes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: mortsPercent,
                    color: Colors.red,
                    radius: 60,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: greusPercent,
                    color: Colors.orange,
                    radius: 60,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: lleusPercent,
                    color: Colors.blue,
                    radius: 60,
                    showTitle: false,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildLegendRow(Colors.red, 'Morts', morts, mortsPercent),
        _buildLegendRow(Colors.orange, 'Ferits greus', greus, greusPercent),
        _buildLegendRow(Colors.blue, 'Ferits lleus', lleus, lleusPercent),
      ],
    );
  }

  Widget _buildLegendRow(Color color, String label, int count, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count (${percent.toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
