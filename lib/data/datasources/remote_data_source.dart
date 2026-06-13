import 'package:cloud_firestore/cloud_firestore.dart';

class RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveReportToCloud(double risk, double age, double bp) async {
    await _firestore.collection('health_reports').add({
      'riskScore': risk,
      'age': age,
      'bloodPressure': bp,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}