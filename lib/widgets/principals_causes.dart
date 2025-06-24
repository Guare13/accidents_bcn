import 'package:flutter/material.dart';

class PrincipalsCauses extends StatelessWidget {
  final List<dynamic> accidents;

  const PrincipalsCauses({super.key, required this.accidents});

  @override
  Widget build(BuildContext context) {
    Map<String, int> causaFreq = {};

    for (var acc in accidents) {
      String? causa = acc['Descripcio_causa_vianant'];
      if (causa != null && causa.isNotEmpty) {
        causaFreq[causa] = (causaFreq[causa] ?? 0) + 1;
      }
    }

    var topCauses = causaFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    topCauses = topCauses.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Principals causes d'accident",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...topCauses.map((e) => ListTile(
              title: Text(e.key),
              trailing: Text('${e.value} casos'),
            )),
      ],
    );
  }
}
