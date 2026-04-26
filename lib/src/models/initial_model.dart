/**
 * Modify: 17/04/2026 ;
 * Ruan Gustavo Soares da Silva ;
 * Files database loading into initial screen ;
 */

/// Load base day word ;
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