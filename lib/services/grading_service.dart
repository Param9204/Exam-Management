import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/result_model.dart';

class GradingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addResult(Result result) async {
    DocumentReference docRef = await _firestore.collection('results').add(result.toMap());
    result.id = docRef.id;
    await docRef.update(result.toMap());
  }

  Future<void> updateResult(Result result) async {
    await _firestore.collection('results').doc(result.id).update(result.toMap());
  }


}
