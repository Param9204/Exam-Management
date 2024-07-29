import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam_model.dart';
import '../models/result_model.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createExam(Exam exam) async {
    DocumentReference docRef = await _firestore.collection('exams').add(exam.toMap());
    exam.id = docRef.id;
    await docRef.update(exam.toMap());
  }

  Future<void> updateExam(Exam exam) async {
    await _firestore.collection('exams').doc(exam.id).update(exam.toMap());
  }

  Future<String> getStudentEmail(String studentId) async {
    try {
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(studentId).get();

      if (studentDoc.exists) {
        Map<String, dynamic>? data = studentDoc.data() as Map<String, dynamic>?;
        return data != null && data.containsKey('email') ? data['email'] ?? 'No email found' : 'Email field not found in the document';
      } else {
        return 'Student not found';
      }
    } catch (e) {
      print('Error fetching student email for studentId $studentId: $e');
      throw e;
    }
  }

  Future<void> deleteExam(String examId) async {
    await _firestore.collection('exams').doc(examId).delete();
  }

  Future<List<Exam>> getExams() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('exams').get();
      return snapshot.docs.map((doc) => Exam.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      throw e;
    }
  }



  Future<List<Result>> getAllResults() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('results').get();
      print('Number of results fetched: ${snapshot.docs.length}');
      snapshot.docs.forEach((doc) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
      });
      return snapshot.docs.map((doc) => Result.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      print('Error fetching results: $e');
      throw e;
    }
  }


  Future<void> saveResult(Result result) async {
    try {
      DocumentReference resultRef = _firestore.collection('results').doc();
      await resultRef.set(result.toMap());
    } catch (e) {
      print("Error saving result: $e");
      throw e;
    }
  }

  // New method to get results by teacher ID
  Future<List<Result>> getResultsByTeacherId(String teacherId) async {
    try {
      print('Fetching results for teacherId: $teacherId');
      QuerySnapshot snapshot = await _firestore
          .collection('results')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      List<Result> results = snapshot.docs.map((doc) {
        return Result.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      print('Number of documents fetched: ${results.length}');
      return results;
    } catch (e) {
      print('Error fetching results: $e');
      return [];
    }
  }

}
