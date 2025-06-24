import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../providers/year_provider.dart';

class YearSelector extends StatelessWidget {
  const YearSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Selecciona l\'any:'),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: yearProvider.selectedYear,
          items: DataService.availableYears
              .map((year) => DropdownMenuItem(value: year, child: Text(year)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              yearProvider.setYear(value);
            }
          },
        ),
      ],
    );
  }
}