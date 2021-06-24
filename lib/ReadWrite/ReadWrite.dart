import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class ReadWrite{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<File> writeCounter(List<dynamic> counter) async {
    final file = await _localFile;

    // Write the file
    print("Writing to file $counter");
    return file.writeAsString('$counter');
  }

  Future<List<String>> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      print('Contents : $contents');
      final result = new List<String>.from(jsonDecode(contents));
      print('Result : $result');

      return result;
    } catch (e) {
      // If encountering an error, return 0
      print("error encountered: $e");
      return [];
    }
  }

}