import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exam_model.dart';
import '../services/exam_service.dart';
import '../services/auth_service.dart';
import 'student_exam_screen.dart';
import 'student_result_screens.dart';
import 'student_edit_profile.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  final ExamService _examService = ExamService();
  final AuthService _authService = AuthService();
  List<Exam> _exams = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _fetchExams();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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

  void _logout() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out")),
      );
    }
  }

  void _navigateToExam(Exam exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentExamScreen(exam: exam, studentId: ''),
      ),
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        final int obtainedMarks = result['obtainedMarks'];
        final int totalMarks = result['totalMarks'];
        final List<Map<String, dynamic>> fullPaper = result['fullPaper'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentResultsScreen(
              obtainedMarks: obtainedMarks,
              totalMarks: totalMarks,
              fullPaper: fullPaper,
              title: exam.title,
            ),
          ),
        );
      }
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25.0,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.school,
                              color: Colors.blue.shade900,
                              size: 30.0,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Student Dashboard',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: _navigateToEditProfile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          elevation: 10.0,
          shadowColor: Colors.black54,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _fetchExams,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadowColor: Colors.grey,
                  elevation: 8,
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Refresh Exams',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _exams.length,
                itemBuilder: (context, index) {
                  final exam = _exams[index];
                  _animationController.forward();
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    ),
                    child: Card(
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      shadowColor: Colors.black54,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.assignment, color: Colors.blue.shade900),
                        ),
                        title: Text(
                          exam.title,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              'Time: ${exam.duration} mins',
                              style: GoogleFonts.roboto(
                                fontSize: 14.0,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _navigateToExam(exam),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Colors.grey,
                            elevation: 8,
                            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                          ),
                          child: Text(
                            'Take Exam',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
