import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import '../services/exam_service.dart';
import 'exam_creation_screen.dart';

class AllExamPapersScreen extends StatefulWidget {
  @override
  _AllExamPapersScreenState createState() => _AllExamPapersScreenState();
}

class _AllExamPapersScreenState extends State<AllExamPapersScreen> {
  final ExamService _examService = ExamService();
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    try {
      List<Exam> exams = await _examService.getExams();
      setState(() {
        _exams = exams;
      });
    } catch (e) {
      print("Error fetching exams: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching exams")),
      );
    }
  }

  void _editExam(Exam exam) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamCreationScreen(exam: exam),
      ),
    );
    if (result == true) { // Check if the result is true (indicating success)
      _fetchExams();
    }
  }

  void _deleteExam(String examId) async {
    try {
      await _examService.deleteExam(examId);
      _fetchExams();
    } catch (e) {
      print("Error deleting exam: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting exam")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Exam Papers'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _exams.isEmpty
              ? Center(
            child: Text(
              'No exams found.',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
          )
              : ListView.builder(
            itemCount: _exams.length,
            itemBuilder: (context, index) {
              final exam = _exams[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    exam.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${exam.date.toLocal()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editExam(exam),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteExam(exam.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
