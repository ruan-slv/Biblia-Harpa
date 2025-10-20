import 'package:biblia_e_harpa/src/models/avisoModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AvisoServiceAPI {
  static const String baseURL = "https://bible-server-api.vercel.app/api/canal";
  static Future<List<AvisoModel>> fetchAvisos() async {
    final response = await http.get(Uri.parse(baseURL));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      final List avisos = [...data["avisos"]];
      return avisos.map((item) => AvisoModel.fromJson(item)).toList();
    } else {
      throw Exception("Erro ao carregar os avisos");
    }
  }
}