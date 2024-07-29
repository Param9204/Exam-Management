import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/result_model.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Result>> getResultsByStudentId(String studentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('results')
          .where('studentId', isEqualTo: studentId)
          .get();

      return snapshot.docs.map((doc) => Result.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print("Error fetching results by student ID: $e");
      return [];
    }
  }
}
