import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; // Import for generating unique IDs
import '../models/exam_model.dart';
import '../models/result_model.dart';
import '../services/exam_service.dart';
import '../widgets/custom_button.dart';
import 'student_result_screens.dart';

class StudentExamScreen extends StatefulWidget {
  final Exam exam;
  final String studentId;

  StudentExamScreen({required this.exam, required this.studentId});

  @override
  _StudentExamScreenState createState() => _StudentExamScreenState();
}

class _StudentExamScreenState extends State<StudentExamScreen> with WidgetsBindingObserver {
  final Map<String, List<String>> _studentAnswers = {};
  final ExamService _examService = ExamService();
  final TextEditingController _feedbackController = TextEditingController();
  User? _currentUser;
  String? _studentEmail;
  bool _isLoading = true;
  Timer? _timer;
  late int _remainingTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _studentAnswers.addAll({
      for (var q in widget.exam.questions) q.id: [],
    });
    _initializeCurrentUser();
    _startTimer();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_isSubmitting) {
      _submitExam();
    }
  }

  Future<void> _initializeCurrentUser() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser == null) {
        throw FirebaseAuthException(
          code: 'NO_USER',
          message: 'No user is currently signed in.',
        );
      }
      setState(() {
        _studentEmail = _currentUser!.email;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }

  void _updateAnswer(String questionId, String option, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!_studentAnswers.containsKey(questionId)) {
          _studentAnswers[questionId] = [];
        }
        _studentAnswers[questionId]!.add(option);
      } else {
        _studentAnswers[questionId]?.remove(option);
      }
    });
  }

  Future<void> _submitExam() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      int totalMarks = 0;
      int obtainedMarks = 0;
      final Map<String, String> studentAnswers = {};
      final Map<String, String> writtenAnswers = {};

      for (var question in widget.exam.questions) {
        String studentAnswer = '';
        String correctAnswer = question.answer ?? '';

        if (question.type == 'mcq') {
          List<String> answers = _studentAnswers[question.id] ?? [];
          studentAnswer = answers.isNotEmpty ? answers.join(', ') : 'No answer';
          studentAnswers[question.id] = studentAnswer;
        } else if (question.type == 'written') {
          List<String> answers = _studentAnswers[question.id] ?? [];
          studentAnswer = answers.isNotEmpty ? answers.first : 'No answer';
          writtenAnswers[question.id] = studentAnswer;
        }

        studentAnswer = studentAnswer.trim().toLowerCase();
        correctAnswer = correctAnswer.trim().toLowerCase();

        if (question.type == 'mcq') {
          List<String> correctOptions = correctAnswer.split(',').map((e) => e.trim()).toList();
          if (correctOptions.any((opt) => studentAnswer.contains(opt))) {
            obtainedMarks += question.marks;
          }
        } else if (question.type == 'written') {
          if (studentAnswer == question.writtenAnswer?.trim().toLowerCase()) {
            obtainedMarks += question.marks;
          }
        }
        totalMarks += question.marks;
      }

      Result result = Result(
        id: Uuid().v4(), // Generate unique ID
        marks: obtainedMarks,
        feedback: _feedbackController.text,
        email: _studentEmail ?? '',
        title: widget.exam.title,
      );

      await _examService.saveResult(result);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentResultsScreen(
            obtainedMarks: obtainedMarks,
            totalMarks: totalMarks,
            title: widget.exam.title,
            fullPaper: widget.exam.questions.map((question) {
              return {
                'question': question.questionText,
                'answer': question.type == 'mcq'
                    ? _studentAnswers[question.id]?.join(', ') ?? 'No answer'
                    : _studentAnswers[question.id]?.isNotEmpty == true
                    ? _studentAnswers[question.id]!.first
                    : 'No answer',
              };
            }).toList(),
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exam submitted successfully")),
      );
    } catch (e) {
      print("Error submitting exam: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting exam: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _startTimer() {
    _remainingTime = widget.exam.duration * 60; // Convert minutes to seconds

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          if (!_isSubmitting) {
            _submitExam();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Student Email: ${_studentEmail ?? 'Loading...'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Feedback',
                    labelStyle: TextStyle(color: Colors.blue.shade900),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Time remaining: ${_remainingTime ~/ 60}:${_remainingTime % 60 < 10 ? '0' : ''}${_remainingTime % 60}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              SizedBox(height: 16),
              ...widget.exam.questions.map((question) {
                if (question.type == 'mcq') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.questionText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            ...question.options!.map((option) {
                              return CheckboxListTile(
                                title: Text(option),
                                value: _studentAnswers[question.id]?.contains(option) ?? false,
                                onChanged: (bool? value) {
                                  if (value != null) {
                                    _updateAnswer(question.id, option, value);
                                  }
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (question.type == 'written') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.questionText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  _studentAnswers[question.id] = [value];
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              }).toList(),
              SizedBox(height: 20),
              CustomButton(
                onPressed: () {
                  if (!_isSubmitting) {
                    _submitExam();
                  }
                },
                text: 'Submit Exam',
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
