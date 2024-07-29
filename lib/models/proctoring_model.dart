class Proctoring {
  String id;
  String examId;
  String studentId;
  bool isCheating;

  Proctoring({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.isCheating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'isCheating': isCheating,
    };
  }

  factory Proctoring.fromMap(Map<String, dynamic> map, String id) {
    return Proctoring(
      id: id,
      examId: map['examId'],
      studentId: map['studentId'],
      isCheating: map['isCheating'],
    );
  }
}
