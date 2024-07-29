import 'package:exam/screens/admin_dashboard.dart';
import 'package:exam/screens/student_dashboard.dart';
import 'package:exam/screens/teacher_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/role_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoleService _roleService = RoleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: FutureBuilder<String>(
        future: _roleService.getUserRole(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final role = snapshot.data!;
          if (role == 'admin') {
            return AdminDashboard();
          } else if (role == 'teacher') {
            return TeacherDashboard();
          } else {
            return StudentDashboard();
          }
        },
      ),
    );
  }
}
