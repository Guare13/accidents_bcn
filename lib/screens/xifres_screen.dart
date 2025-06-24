import 'package:flutter/material.dart';
import '../widgets/percentatge_victimes.dart';
import '../widgets/morts_per_mes.dart';
import '../widgets/principals_causes.dart';
import 'package:provider/provider.dart';
import '../providers/year_provider.dart';
import '../services/data_service.dart';

class XifresScreen extends StatefulWidget {
  const XifresScreen({super.key});

  @override
  State<XifresScreen> createState() => _XifresScreenState();
}

class _XifresScreenState extends State<XifresScreen> {
  List<dynamic> accidents = [];
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
    setState(() {
      accidents = records;
      isLoading = false;
    });
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error carregant dades: ${e.toString()}')),
    );
  }
}

@override
Widget build(BuildContext context) {
  return isLoading
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PercentatgeVictimesMortals(accidents: accidents),
              const SizedBox(height: 20),
              MortsPerMes(accidents: accidents),
              const SizedBox(height: 20),
              PrincipalsCauses(accidents: accidents),
            ],
          ),
        );
}
}
