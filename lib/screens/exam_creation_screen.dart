import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import '../services/exam_service.dart';
import '../widgets/mcq_widget.dart';
import '../widgets/written_question_widget.dart';

class ExamCreationScreen extends StatefulWidget {
  final Exam? exam;

  ExamCreationScreen({this.exam});

  @override
  _ExamCreationScreenState createState() => _ExamCreationScreenState();
}

class _ExamCreationScreenState extends State<ExamCreationScreen> {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _venueController = TextEditingController();
  final _examService = ExamService();

  final List<MCQWidget> _mcqWidgets = [];
  final List<WrittenQuestionWidget> _writtenQuestionWidgets = [];

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      _populateFields(widget.exam!);
    }
  }

  void _populateFields(Exam exam) {
    _titleController.text = exam.title;
    _typeController.text = exam.type;
    _dateController.text = exam.date.toLocal().toString().split(' ')[0];
    _timeController.text = "${exam.date.hour}h ${exam.date.minute}m";
    _durationController.text = "${exam.duration ~/ 60}h ${exam.duration % 60}m";
    _venueController.text = exam.venue;

    setState(() {
      _mcqWidgets.clear();
      _writtenQuestionWidgets.clear();
      for (var question in exam.questions) {
        if (question.type == 'mcq') {
          _mcqWidgets.add(
            MCQWidget(
              questionController: TextEditingController(text: question.questionText),
              optionControllers: List.generate(
                question.options?.length ?? 0,
                    (index) => TextEditingController(text: question.options![index]),
              ),
              answerController: TextEditingController(text: question.answer),
              marksController: TextEditingController(text: question.marks.toString()),
              onDelete: () {
                setState(() {
                  _mcqWidgets.removeAt(_mcqWidgets.indexOf(
                      _mcqWidgets.firstWhere(
                              (widget) => widget.questionController.text == question.questionText
                      )));
                });
              },
            ),
          );
        } else if (question.type == 'written') {
          _writtenQuestionWidgets.add(
            WrittenQuestionWidget(
              questionController: TextEditingController(text: question.questionText),
              answerController: TextEditingController(text: question.writtenAnswer),
              marksController: TextEditingController(text: question.marks.toString()),
              onDelete: () {
                setState(() {
                  _writtenQuestionWidgets.removeAt(_writtenQuestionWidgets.indexOf(
                      _writtenQuestionWidgets.firstWhere(
                              (widget) => widget.questionController.text == question.questionText
                      )));
                });
              },
            ),
          );
        }
      }
    });
  }

  void _addMCQ() {
    setState(() {
      _mcqWidgets.add(
        MCQWidget(
          questionController: TextEditingController(),
          optionControllers: List.generate(4, (_) => TextEditingController()),
          answerController: TextEditingController(),
          marksController: TextEditingController(),
          onDelete: () {
            setState(() {
              _mcqWidgets.removeLast();
            });
          },
        ),
      );
    });
  }

  void _addWrittenQuestion() {
    setState(() {
      _writtenQuestionWidgets.add(
        WrittenQuestionWidget(
          questionController: TextEditingController(),
          answerController: TextEditingController(),
          marksController: TextEditingController(),
          onDelete: () {
            setState(() {
              _writtenQuestionWidgets.removeLast();
            });
          },
        ),
      );
    });
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _selectDuration() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = "${pickedTime.hour}h ${pickedTime.minute}m";
      });
    }
  }

  DateTime _parseDateTime() {
    final dateParts = _dateController.text.split('-');
    final timeParts = _timeController.text.split('h');

    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].replaceAll('m', ''));

    return DateTime(year, month, day, hour, minute);
  }

  int _parseDuration(String durationText) {
    final durationParts = durationText.split(' ');
    int hours = 0;
    int minutes = 0;

    for (var part in durationParts) {
      if (part.endsWith('h')) {
        hours = int.tryParse(part.replaceAll('h', '')) ?? 0;
      } else if (part.endsWith('m')) {
        minutes = int.tryParse(part.replaceAll('m', '')) ?? 0;
      }
    }

    if (hours == 0 && minutes == 0) {
      throw FormatException('Invalid duration format. Expected format: "Xh Ym".');
    }

    return hours * 60 + minutes;
  }

  void _createOrUpdateExam() {
    try {
      // Set a predefined duration value (for example, 1 hour and 30 minutes)
      final int predefinedDurationInMinutes = 90; // 1 hour 30 minutes

      final exam = Exam(
        id: widget.exam?.id ?? '', // Use existing ID if updating
        title: _titleController.text,
        type: _typeController.text,
        date: _parseDateTime(),
        duration: predefinedDurationInMinutes,
        venue: _venueController.text,
        questions: [
          ..._mcqWidgets.map((widget) {
            return Question(
              id: '', // ID will be generated by the backend if needed
              type: 'mcq',
              questionText: widget.questionController.text,
              options: widget.optionControllers.map((controller) => controller.text).toList(),
              answer: widget.answerController.text,
              marks: int.tryParse(widget.marksController.text) ?? 0,
            );
          }),
          ..._writtenQuestionWidgets.map((widget) {
            return Question(
              id: '', // ID will be generated by the backend if needed
              type: 'written',
              questionText: widget.questionController.text,
              writtenAnswer: widget.answerController.text,
              marks: int.tryParse(widget.marksController.text) ?? 0,
            );
          }),
        ],
      );

      if (widget.exam != null) {
        _examService.updateExam(exam).then((_) {
          Navigator.pop(context, true); // Return true to indicate success
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating exam: $error')),
          );
        });
      } else {
        _examService.createExam(exam).then((_) {
          Navigator.pop(context, true); // Return true to indicate success
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating exam: $error')),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating or updating exam: $e')),
      );
      print('Error creating or updating exam: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam == null ? 'Create Exam' : 'Edit Exam'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Title'),
              _buildTextField(_typeController, 'Type'),
              _buildDatePickerField(_dateController, 'Date', _selectDate),
              _buildDatePickerField(_timeController, 'Time', _selectDuration),
              _buildTextField(_venueController, 'Venue'),
              SizedBox(height: 20),
              _buildSectionTitle('Questions'),
              ElevatedButton.icon(
                onPressed: _addMCQ,
                icon: Icon(Icons.add),
                label: Text('Add MCQ'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addWrittenQuestion,
                icon: Icon(Icons.add),
                label: Text('Add Written Question'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildQuestionList(),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _createOrUpdateExam,
                  child: Text(widget.exam == null ? 'Create Exam' : 'Update Exam'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
      TextEditingController controller, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onTap: onTap,
        readOnly: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuestionList() {
    return Column(
      children: [
        ..._mcqWidgets.map((widget) => Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget,
          ),
        )),
        ..._writtenQuestionWidgets.map((widget) => Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget,
          ),
        )),
      ],
    );
  }
}
