import 'package:flutter/material.dart';

class YearProvider extends ChangeNotifier {
  String _selectedYear = '2024';

  String get selectedYear => _selectedYear;

  void setYear(String year) {
    _selectedYear = year;
    notifyListeners();
  }
}