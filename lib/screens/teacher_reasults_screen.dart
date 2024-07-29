import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/result_model.dart';

class TeacherResultsScreen extends StatefulWidget {
  @override
  _TeacherResultsScreenState createState() => _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends State<TeacherResultsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, List<Result>> _resultsByTitle = {};
  String? _selectedTitle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      QuerySnapshot resultSnapshot = await _firestore.collection('results').get();
      final results = resultSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final result = Result.fromMap(data, doc.id);
        return result;
      }).toList();

      final Map<String, List<Result>> resultsMap = {};

      for (var result in results) {
        if (!resultsMap.containsKey(result.title)) {
          resultsMap[result.title] = [];
        }
        resultsMap[result.title]!.add(result);
      }

      setState(() {
        _resultsByTitle = resultsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> titles = _resultsByTitle.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Results',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10.0,
        shadowColor: Colors.black54,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (titles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedTitle,
                  decoration: InputDecoration(
                    labelText: 'Select Paper Title',
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                  ),
                  dropdownColor: Colors.blueGrey[50],
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                  items: titles.map((title) {
                    return DropdownMenuItem<String>(
                      value: title,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedTitle = newValue;
                    });
                  },
                ),
              ),
            Expanded(
              child: _selectedTitle != null
                  ? ListView(
                children: _resultsByTitle[_selectedTitle!]!.map((result) {
                  return Card(
                    elevation: 10.0,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListTile(
                      title: Text(
                        result.email,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      subtitle: Text('Marks: ${result.marks}',
                          style: TextStyle(color: Colors.black87)),
                    ),
                  );
                }).toList(),
              )
                  : Center(child: Text('No results available')),
            ),
          ],
        ),
      ),
    );
  }
}
