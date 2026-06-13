import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/datasources/ml_model_service.dart';
import '../data/datasources/history_service.dart';
import '../domain/entities/health_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final MLModelService _mlService = MLModelService();
  final HistoryService _historyService = HistoryService();
  
  double? _riskScore;
  bool _isLoading = false;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _preloadModel();
    _loadHistory();
  }

  void _preloadModel() {
    _mlService.loadModel().catchError((error) {
      debugPrint('Model preload failed: $error');
    });
  }

  void _loadHistory() async {
    try {
      final history = await _historyService.getHistory();
      setState(() => _history = history.reversed.toList());
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  void _predict() async {
    final age = double.tryParse(ageController.text) ?? 0;
    final bp = double.tryParse(bpController.text) ?? 0;

    if (age <= 0 || bp <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid age and blood pressure values.')),
      );
      return;
    }

    setState(() {
      _riskScore = null;
      _isLoading = true;
    });

    try {
      final result = await _mlService
          .predict(HealthData(age: age, trestbps: bp, chol: 0, thalach: 0))
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      setState(() {
        _riskScore = result;
        _isLoading = false;
      });

      await _historyService.savePrediction(result);

      FirebaseFirestore.instance.collection('history').add({
        'age': age,
        'bp': bp,
        'risk': result,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        _loadHistory();
      }).catchError((error) {
        debugPrint('Cloud save failed: $error');
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: const Icon(Icons.monitor_heart, color: Colors.blueAccent),
        title: const Text("Edge-AI Diagnostics"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              children: [
                Card(
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const Icon(Icons.monitor_heart, size: 50, color: Colors.blueAccent),
                        TextField(controller: ageController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Age")),
                        TextField(controller: bpController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Blood Pressure")),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _predict,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("PREDICT RISK"),
                        ),
                        if (_riskScore != null) 
                          Padding(padding: const EdgeInsets.only(top: 20), child: Text("Score: ${_riskScore!.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, color: Colors.blueAccent))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Recent History", style: TextStyle(color: Colors.grey)),
                ..._history.map((h) => ListTile(title: Text(h, style: const TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
