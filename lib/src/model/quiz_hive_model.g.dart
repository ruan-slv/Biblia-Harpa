part of 'quiz_hive_model.dart';

class QuizOptionHiveAdapter extends TypeAdapter<QuizOptionHive> {
  @override
  final int typeId = 1;

  @override
  QuizOptionHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizOptionHive(
      id: fields[0] as String,
      text: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuizOptionHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text);
  }
}

class QuizQuestionHiveAdapter extends TypeAdapter<QuizQuestionHive> {
  @override
  final int typeId = 2;

  @override
  QuizQuestionHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestionHive(
      question: fields[0] as String,
      options: (fields[1] as List).cast<QuizOptionHive>(),
      answer: fields[2] as String,
      reference: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestionHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.options)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.reference);
  }
}
