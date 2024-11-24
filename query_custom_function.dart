import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/flutter_flow/custom_functions.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/auth/firebase_auth/auth_util.dart';

String buildAlgoliaFilterQuery(
  List<String> tags,
  DateTime? startDate,
  DateTime? endDate,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  final List<String> queryParts = [];

  void addQueryPart(String part) {
    if (part.isNotEmpty) {
      queryParts.add(part);
    }
  }

  if (startDate != null) {
    addQueryPart("timePosted > ${startDate.millisecondsSinceEpoch}");
  }
  if (endDate != null) {
    addQueryPart("timePosted < ${endDate.millisecondsSinceEpoch}");
  }
  if (tags.isNotEmpty) {
    final String tagsQuery = tags.map((tag) => "tags:$tag").join(" OR ");
    addQueryPart("($tagsQuery)");
  }

  return queryParts.join(" AND ");
  

  /// MODIFY CODE ONLY ABOVE THIS LINE
}
