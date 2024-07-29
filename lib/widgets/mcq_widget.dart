import 'package:flutter/material.dart';

class MCQWidget extends StatelessWidget {
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  final TextEditingController answerController;
  final TextEditingController marksController;
  final VoidCallback onDelete;

  MCQWidget({
    required this.questionController,
    required this.optionControllers,
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
          decoration: InputDecoration(labelText: 'MCQ Question'),
        ),
        ...optionControllers.map((controller) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Option'),
          );
        }).toList(),
        TextField(
          controller: answerController,
          decoration: InputDecoration(labelText: 'Correct Answer'),
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
