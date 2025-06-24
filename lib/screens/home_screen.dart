import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/year_selector.dart';
import 'package:provider/provider.dart';
import '../providers/year_provider.dart';

const Color primaryStatColor = Color(0xFF1565C0); // Blau fosc

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedYear = '2024';
  int morts = 0;
  int ferits = 0;
  int accidents = 0;
  bool isLoading = true;
  

 String? currentYear;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final year = Provider.of<YearProvider>(context).selectedYear;
  if (currentYear != year) {
    currentYear = year;
    fetchData();
  }
}

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
  final year = Provider.of<YearProvider>(context, listen: false).selectedYear;
  final stats = await DataService.fetchMainStats(year);

  setState(() {
    morts = stats['morts']!;
    ferits = stats['ferits']!;
    accidents = stats['accidents']!;
    isLoading = false;
  });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const YearSelector(), // ⬅️ afegeix aquí
                const SizedBox(height: 20),
                const Text(
  'Cada dia, a Barcelona, es produeixen desenes d\'accidents de trànsit.',
  style: TextStyle(
    fontSize: 22, // ↗️ abans 18
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StatCard(
          title: 'Morts',
          value: morts,
          color: primaryStatColor,
        ),
      ),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StatCard(
          title: 'Ferits',
          value: ferits,
          color: primaryStatColor,
        ),
      ),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StatCard(
          title: 'Accidents',
          value: accidents,
          color: primaryStatColor,
        ),
      ),
    ),
  ],
),
                const SizedBox(height: 30),
                const Text(
  'Conèixer les dades és el primer pas per canviar-les.',
  style: TextStyle(
    fontSize: 18, // ↗️ abans no tenia estil
    fontStyle: FontStyle.italic,
  ),
  textAlign: TextAlign.center,
),
              ],
            ),
          );
  }
}


