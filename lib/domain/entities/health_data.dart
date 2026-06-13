import 'package:equatable/equatable.dart';

class HealthData extends Equatable {
  final double age;
  final double trestbps; // Blood Pressure
  final double chol;     // Cholesterol
  final double thalach;  // Max Heart Rate

  const HealthData({
    required this.age,
    required this.trestbps,
    required this.chol,
    required this.thalach,
  });

  @override
  List<Object> get props => [age, trestbps, chol, thalach];
}
