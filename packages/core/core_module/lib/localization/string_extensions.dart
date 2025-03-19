import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Extension on String for easy translation access
extension StringExtension on String {
  /// Translate the string key
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
} 