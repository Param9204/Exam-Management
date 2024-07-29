import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/result_model.dart';

class StudentResultsScreen extends StatelessWidget {
  final int obtainedMarks;
  final int totalMarks;
  final List<Map<String, dynamic>> fullPaper;
  final String title;

  StudentResultsScreen({
    required this.obtainedMarks,
    required this.totalMarks,
    required this.fullPaper,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (obtainedMarks / totalMarks) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Results'),
        automaticallyImplyLeading: false,
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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Exam Results',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.blue.shade100,
                          offset: Offset(3.0, 3.0),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildResultRow('Title:', title),
                        _buildResultRow('Total Marks:', '$totalMarks'),
                        _buildResultRow('Obtained Marks:', '$obtainedMarks'),
                        _buildResultRow('Percentage:', '${percentage.toStringAsFixed(2)}%'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _saveResultToFirestore();

                        final pdfFile = await _generatePdf(obtainedMarks, totalMarks, percentage, fullPaper, title);
                        await Share.shareXFiles([XFile(pdfFile.path)], text: 'My Exam Results');
                      } catch (e) {
                        print('Error generating or sharing PDF: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Share Result',
                          style: TextStyle(color: Colors.white), // Change text color to white
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 22, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResultToFirestore() async {
    final result = Result(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      marks: obtainedMarks,
      feedback: "Well done",
      email: "student@example.com", // Replace with the actual student's email
      title: title,
    );

    try {
      await FirebaseFirestore.instance.collection('results').doc(result.id).set(result.toMap());
    } catch (e) {
      print('Error saving result to Firestore: $e');
    }
  }

  Future<File> _generatePdf(int obtainedMarks, int totalMarks, double percentage, List<Map<String, dynamic>> fullPaper, String title) async {
    final pdf = pw.Document();
    Directory? tempDir;

    try {
      tempDir = await getTemporaryDirectory();
    } catch (e) {
      print('Error getting temporary directory: $e');
    }

    if (tempDir == null) {
      throw Exception('Failed to get temporary directory');
    }

    final file = File('${tempDir.path}/result.pdf');

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Exam Results',
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              _buildPdfResultRow('Title:', title),
              pw.SizedBox(height: 10),
              _buildPdfResultRow('Total Marks:', '$totalMarks'),
              pw.SizedBox(height: 10),
              _buildPdfResultRow('Obtained Marks:', '$obtainedMarks'),
              pw.SizedBox(height: 10),
              _buildPdfResultRow('Percentage:', '${percentage.toStringAsFixed(2)}%'),
              pw.SizedBox(height: 30),
              pw.Text(
                'Full Paper:',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey),
              ),
              pw.SizedBox(height: 20),
              pw.ListView.builder(
                itemCount: fullPaper.length,
                itemBuilder: (context, index) {
                  final question = fullPaper[index];
                  return _buildPdfQuestionAnswer(question);
                },
              ),
            ],
          );
        },
      ),
    );

    try {
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print('Error saving PDF file: $e');
    }

    return file;
  }

  pw.Widget _buildPdfResultRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
        ),
      ],
    );
  }

  pw.Widget _buildPdfQuestionAnswer(Map<String, dynamic> question) {
    final questionText = question['question'];
    final type = question['type'];

    String displayedAnswer;
    if (type == 'MCQ') {
      displayedAnswer = question['selectedAnswer'] ?? 'Not answered';
    } else {
      displayedAnswer = question['answer'];
    }

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Q: $questionText',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey),
          ),
          pw.Text(
            'A: $displayedAnswer',
            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: PdfColors.blueGrey),
        ],
      ),
    );
  }
}
