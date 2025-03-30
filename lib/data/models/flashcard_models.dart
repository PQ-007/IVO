class Flashcard {
  final int? id;
  final String front;
  final String back;

  Flashcard({this.id, required this.front, required this.back, requiredthis});

  // Convert a Flashcard to a Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'front': {
        'question': front,
      },
      'back': back,
    };
  }

  // Create a Flashcard from a Map (for SQLite)
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      front: map['front'],
      back: map['back'],
    );
  }
}
