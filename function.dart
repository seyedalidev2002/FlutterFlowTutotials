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

String? multiLanguageText(
  String? languageCode,
  String key,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  Map<String, Map<String, String>> notifications = {
    "noitf1": {
      "en": "Hello",
      "pt": "Olla",
    },
    "notif2": {
      "en": "English",
      "pt": "Not English",
    }
  };
  final map = notifications[key];
  if (map == null) return '';
  if (map[languageCode] == null) return map['en'] ?? '';

  return map[languageCode] ?? '';

  /// MODIFY CODE ONLY ABOVE THIS LINE
}
