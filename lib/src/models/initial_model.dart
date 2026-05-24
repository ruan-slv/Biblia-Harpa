class DayWord {
  final int id;
  final String text;
  final String reference;

  DayWord({required this.id, required this.text, required this.reference});

  factory DayWord.fromJson(Map<String, dynamic> json) {
    return DayWord(
        id: json["id"],
        text: json["text"],
        reference: json["reference"],
    );
  }
}