class DailyWord {
  final int id;
  final String text;
  final String reference;

  DailyWord({
    required this.id,
    required this.text,
    required this.reference,
  });

  factory DailyWord.fromJson(Map<String, dynamic> json) {
    return DailyWord(
      id: json["id"],
      text: json["text"],
      reference: json["reference"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "text": text,
      "reference": reference,
    };
  }
}
