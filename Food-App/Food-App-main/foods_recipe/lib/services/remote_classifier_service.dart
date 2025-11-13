import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RemoteClassifierService {
  final String baseUrl; 
  RemoteClassifierService({required this.baseUrl});

  Future<List<MapEntry<String, double>>> classifyImage(File file, {int topK = 5}) async {
    final uri = Uri.parse('$baseUrl/classify');
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', file.path));

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      throw Exception('API ${resp.statusCode}: ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final List<dynamic> top = (data['top_k'] as List<dynamic>? ?? []);
    if (top.isEmpty && data.containsKey('label') && data.containsKey('score')) {
      return [MapEntry<String, double>(data['label'].toString(), (data['score'] as num).toDouble())];
    }
    final results = top.map((e) {
      final m = e as Map<String, dynamic>;
      return MapEntry<String, double>(m['label'].toString(), (m['score'] as num).toDouble());
    }).toList();
    results.sort((a, b) => b.value.compareTo(a.value));
    return results.take(topK).toList();
  }
}
