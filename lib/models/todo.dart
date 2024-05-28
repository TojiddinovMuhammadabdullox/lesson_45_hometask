class Todo {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  bool isCompleted;
  final List<Note> notes;

  Todo(
      {required this.id,
      required this.title,
      required this.description,
      required this.date,
      this.isCompleted = false,
      this.notes = const []});
}

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createDate;

  Note(
      {required this.id,
      required this.title,
      required this.content,
      required this.createDate});
}
