import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/entities/health_data.dart';

class MLModelService {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('heart_model.tflite');
  }

  Future<double> predict(HealthData data) async {
    if (_interpreter == null) await loadModel();

    var input = [
      [data.age, data.trestbps, data.chol, data.thalach]
    ];

    var output = List.filled(1, 0.0).reshape([1, 1]);
    _interpreter!.run(input, output);

    return output[0][0];
  }
}
