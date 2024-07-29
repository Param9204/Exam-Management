import 'package:flutter/material.dart';

class WrittenQuestionWidget extends StatelessWidget {
  final TextEditingController questionController;
  final TextEditingController answerController;
  final TextEditingController marksController;
  final VoidCallback onDelete;

  WrittenQuestionWidget({
    required this.questionController,
    required this.answerController,
    required this.marksController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: questionController,
          decoration: InputDecoration(labelText: 'Written Question'),
        ),
        TextField(
          controller: answerController,
          decoration: InputDecoration(labelText: 'Answer'),
        ),
        TextField(
          controller: marksController,
          decoration: InputDecoration(labelText: 'Marks'),
          keyboardType: TextInputType.number,
        ),
        ElevatedButton(
          onPressed: onDelete,
          child: Text('Delete Question'),
        ),
      ],
    );
  }
}
