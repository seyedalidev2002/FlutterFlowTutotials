// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

Future shareFile(BuildContext context, String url) async {
  try {
    var fileType = getFileTypeFromUrl(url);
    var directory = await getTemporaryDirectory();
    var fileName = DateTime.now().millisecondsSinceEpoch;
    var filePath = '${directory.path}/$fileName.$fileType';
    Dio dio = Dio();

    await dio.download(url, (Headers headers) {
      filePath = '${directory.path}/$fileName.$fileType';
      return filePath;
    }).then((response) async {
      if (response.statusCode == 200) {
        await Share.shareXFiles([XFile(filePath)]);
      }
    });
  } catch (e) {
    print(e);
  }
}

String getFileTypeFromUrl(String url) {
  try {
    String fileName = url.split('?')[0];

    // Extract the file extension (everything after the last dot in the filename)
    String fileType = fileName.split('.').last;
    return fileType.toUpperCase();
  } catch (e) {
    return "";
  }
}
