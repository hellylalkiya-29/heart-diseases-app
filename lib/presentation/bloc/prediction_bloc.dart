import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/ml_model_service.dart';
import '../../domain/entities/health_data.dart';

// Ye Bloc event aane par model service ko call karega
class PredictionBloc extends Bloc<HealthData, double?> {
  final MLModelService _mlService = MLModelService();

  PredictionBloc() : super(null) {
    on<HealthData>((event, emit) async {
      final result = await _mlService.predict(event);
      emit(result);
    });
  }
}
