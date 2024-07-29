import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/proctoring_model.dart';

class ProctoringService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> monitorExam(Proctoring proctoring) async {
    DocumentReference docRef = await _firestore.collection('proctoring').add(proctoring.toMap());
    proctoring.id = docRef.id;
    await docRef.update(proctoring.toMap());
  }

  Future<void> updateProctoring(Proctoring proctoring) async {
    await _firestore.collection('proctoring').doc(proctoring.id).update(proctoring.toMap());
  }
}
