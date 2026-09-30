import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnnotationService {
  static const String _key = 'bible_annotations';

  static Future<Map<String, String>> getAnnotations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return {};
    return Map<String, String>.from(jsonDecode(data));
  }

  static Future<void> setAnnotation(String chapterId, String verseIndex, String color) async {
    final prefs = await SharedPreferences.getInstance();
    final annotations = await getAnnotations();
    final key = '$chapterId:$verseIndex';
    annotations[key] = color;
    await prefs.setString(_key, jsonEncode(annotations));
  }

  static Future<void> removeAnnotation(String chapterId, String verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final annotations = await getAnnotations();
    final key = '$chapterId:$verseIndex';
    annotations.remove(key);
    await prefs.setString(_key, jsonEncode(annotations));
  }

  static Future<String?> getAnnotationColor(String chapterId, String verseIndex) async {
    final annotations = await getAnnotations();
    final key = '$chapterId:$verseIndex';
    return annotations[key];
  }

  static Future<void> clearAllAnnotations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}