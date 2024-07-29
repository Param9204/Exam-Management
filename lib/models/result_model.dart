class Result {
  late final String id;
  final int marks;
  final String feedback;
  final String email; // Add this field
  String title;



  Result({
    required this.id,
    required this.marks,
    required this.feedback,
    required this.email, // Add this parameter
    required this.title,

  });

  // Add 'totalMarks' in toMap and fromMap methods
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marks': marks,
      'feedback': feedback,
      'Email' : email,
      'title' : title,
    };
  }


  factory Result.fromMap(Map<String, dynamic> map, String id) {
    print('Mapping Result from Firestore: $map'); // Add this line
    return Result(
      id: id,
      marks: map['marks'] ?? 0,
      feedback: map['feedback'] ?? '',
      email: map['Email'] ?? 'No Email',
      title: map['title'] ?? 'No Title',
    );
  }
}
