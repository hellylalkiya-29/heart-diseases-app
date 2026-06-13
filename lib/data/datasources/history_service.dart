import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'prediction_history';

  Future<void> savePrediction(double risk) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    history.add("${DateTime.now().toString().substring(5, 16)} | Risk: ${risk.toStringAsFixed(2)}");
    await prefs.setStringList(_key, history);
  }

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}