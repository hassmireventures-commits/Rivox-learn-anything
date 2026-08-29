import 'package:html/parser.dart' show parse;
import 'package:dio/dio.dart';

import '../../core/error/app_exception.dart';
import '../../core/network/dio_client.dart';

class WebsiteIndexer {
  const WebsiteIndexer();

  Future<String> fetchAndExtract(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      throw const LibraryException('httpsOnly');
    }
    final dio = DioClient.create();
    final response = await dio.get<String>(
      url,
      options: Options(responseType: ResponseType.plain, headers: {'User-Agent': 'LearnAnything/1.0'}),
    );
    final html = response.data ?? '';
    if (html.isEmpty) throw const LibraryException('emptyPage');

    final doc = parse(html);
    doc.querySelectorAll('script, style, nav, footer, header, aside').forEach((e) => e.remove());
    final main = doc.querySelector('main, article, [role=main]');
    final text = (main ?? doc.body)?.text ?? doc.text ?? '';
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length < 100) {
      throw const LibraryException('notEnoughText');
    }
    return cleaned;
  }
}
