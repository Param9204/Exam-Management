class Exam {
  String id;
  String title;
  String type; // easy, medium, hard
  DateTime date;
  int duration; // in minutes
  String venue;
  List<Question> questions;

  Exam({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.duration,
    required this.venue,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
      'duration': duration,
      'venue': venue,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map, String id) {
    return Exam(
      id: id,
      title: map['title'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      venue: map['venue'],
      questions: (map['questions'] as List<dynamic>)
          .map((q) => Question.fromMap(q as Map<String, dynamic>, ''))
          .toList(),
    );
  }
}

class Question {
  String id;
  String type; // mcq or written
  String questionText;
  List<String>? options; // for MCQ
  String? answer; // for MCQ
  String? writtenAnswer; // for written questions
  int marks;

  Question({
    required this.id,
    required this.type,
    required this.questionText,
    this.options,
    this.answer,
    this.writtenAnswer,
    required this.marks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'questionText': questionText,
      'options': options,
      'answer': answer,
      'writtenAnswer': writtenAnswer,
      'marks': marks,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map, String id) {
    return Question(
      id: id,
      type: map['type'],
      questionText: map['questionText'],
      options: List<String>.from(map['options'] ?? []),
      answer: map['answer'],
      writtenAnswer: map['writtenAnswer'],
      marks: map['marks'],
    );
  }
}
