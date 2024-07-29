import 'package:exam/screens/teacher_student-detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'teacher_student-detail_screen.dart';
import 'login_screen.dart';
import 'package:exam/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isAdmin = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _firestore.collection('users').doc(_currentUser!.uid).get().then((doc) {
        if (doc.exists) {
          setState(() {
            _isAdmin = doc['role'] == 'admin'; // Check if the user is an admin
          });
        } else {
          print('User document does not exist');
        }
      }).catchError((error) {
        print('Error fetching user document: $error');
      });
    }

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  Future<void> _deleteUser(String userId) async {
    if (_isAdmin) {
      try {
        await _firestore.collection('users').doc(userId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User deleted successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user: ${e.toString()}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You do not have permission to delete this user')));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      print('No user is logged in.');
    } else {
      print('Logged in user ID: ${user.uid}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,color: Colors.white,),
            onPressed: () async {
              try {
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to log out: ${e.toString()}')));
              }
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.7), Colors.blue.shade900.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No users found.'));
              }

              final users = snapshot.data!.docs;
              final teachers = users.where((user) => (user['role'] as String?)?.toLowerCase() == 'teacher').toList();
              final students = users.where((user) => (user['role'] as String?)?.toLowerCase() == 'student').toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Teachers',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildUserList(teachers),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Students',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildUserList(students),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<QueryDocumentSnapshot> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final userId = user.id;
        final userName = user['name'] as String?;
        final userRole = user['role'] as String?;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            elevation: 10,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: userRole?.toLowerCase() == 'teacher' ? Colors.blue : Colors.green,
                child: Icon(
                  userRole?.toLowerCase() == 'teacher' ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(
                userName ?? 'No name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                userRole ?? 'No role',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              trailing: _isAdmin
                  ? IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(userId),
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherStudentDetailScreen(userId: userId),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
