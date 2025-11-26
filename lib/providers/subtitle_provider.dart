import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SubtitleItem {
  final Duration start;
  final Duration end;
  final String text;
  final String? rawText;

  SubtitleItem({
    required this.start,
    required this.end,
    required this.text,
    this.rawText,
  });

  @override
  String toString() =>
      'SubtitleItem(start: $start, end: $end, text: $text)';
}

enum SubtitleFormat { srt, vtt, ssa, ass, unknown }

abstract class SubtitleParser {
  List<SubtitleItem> parse(String content);

  static SubtitleFormat detectFormat(String content) {
    final trimmed = content.trim();

    if (trimmed.startsWith('WEBVTT')) {
      return SubtitleFormat.vtt;
    } else if (trimmed.contains('[Script Info]') ||
        trimmed.contains('[V4+ Styles]')) {
      return trimmed.contains('Format: ') && trimmed.contains('Dialogue: ')
          ? SubtitleFormat.ass
          : SubtitleFormat.ssa;
    } else if (RegExp(r'^\d+\s*\n\d{2}:\d{2}:\d{2}').hasMatch(trimmed)) {
      return SubtitleFormat.srt;
    }

    return SubtitleFormat.unknown;
  }

  static SubtitleParser? createParser(SubtitleFormat format) {
    switch (format) {
      case SubtitleFormat.srt:
        return SRTParser();
      case SubtitleFormat.vtt:
        return VTTParser();
      case SubtitleFormat.ssa:
      case SubtitleFormat.ass:
        return SSAParser();
      case SubtitleFormat.unknown:
        return null;
    }
  }

  static String cleanText(String text) {
    String cleaned = text;

    cleaned = cleaned.replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*i\s*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*/\s*i\s*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*b\s*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*/\s*b\s*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*u\s*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*/\s*u\s*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*font[^>]*>', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'<\s*/\s*font\s*>', caseSensitive: false), '');

    cleaned = cleaned.replaceAll(RegExp(r'<[^>]+>'), '');

    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'), '');

    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]+'), ' ');

    cleaned = cleaned.trim();

    return cleaned;
  }

  static Duration parseTime(String timeString) {
    try {
      timeString = timeString.replaceAll(',', '.').trim();

      final match = RegExp(r'(\d{1,2}):(\d{2}):(\d{2})[\.,]?(\d{1,3})?')
          .firstMatch(timeString);

      if (match == null) return Duration.zero;

      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final seconds = int.parse(match.group(3)!);
      final milliseconds = match.group(4) != null
          ? int.parse(match.group(4)!.padRight(3, '0').substring(0, 3))
          : 0;

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } catch (e) {
      debugPrint('Error parsing time "$timeString": $e');
      return Duration.zero;
    }
  }
}

class SRTParser extends SubtitleParser {
  @override
  List<SubtitleItem> parse(String content) {
    final List<SubtitleItem> subtitles = [];

    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final blocks = content.split(RegExp(r'\n\s*\n'));

    for (var block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 3) continue;

      try {
        int startLine = 0;
        if (RegExp(r'^\d+$').hasMatch(lines[0].trim())) {
          startLine = 1;
        }

        if (lines.length < startLine + 2) continue;

        final timeCode = lines[startLine];
        final times = timeCode.split('-->');
        if (times.length != 2) continue;

        final start = SubtitleParser.parseTime(times[0].trim());
        final end = SubtitleParser.parseTime(times[1].trim());

        final rawText = lines.sublist(startLine + 1).join('\n');
        final cleanedText = SubtitleParser.cleanText(rawText);

        if (cleanedText.isEmpty) continue;

        subtitles.add(SubtitleItem(
          start: start,
          end: end,
          text: cleanedText,
          rawText: rawText,
        ));
      } catch (e) {
        debugPrint('Error parsing SRT block: $e\n$block');
      }
    }

    subtitles.sort((a, b) => a.start.compareTo(b.start));

    return subtitles;
  }
}

/// WebVTT
class VTTParser extends SubtitleParser {
  @override
  List<SubtitleItem> parse(String content) {
    final List<SubtitleItem> subtitles = [];

    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    content = content.replaceFirst(RegExp(r'^WEBVTT[^\n]*\n'), '');

    final blocks = content.split(RegExp(r'\n\s*\n'));

    for (var block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      try {
        int timeLineIndex = 0;

        for (int i = 0; i < lines.length && i < 2; i++) {
          if (lines[i].contains('-->')) {
            timeLineIndex = i;
            break;
          }
        }

        if (timeLineIndex >= lines.length) continue;

        final timeCode = lines[timeLineIndex];
        final times = timeCode.split('-->');
        if (times.length != 2) continue;

        String startTime = times[0].trim().split(' ')[0];
        String endTime = times[1].trim().split(' ')[0];

        final start = SubtitleParser.parseTime(startTime);
        final end = SubtitleParser.parseTime(endTime);

        if (timeLineIndex + 1 >= lines.length) continue;

        final rawText = lines.sublist(timeLineIndex + 1).join('\n');
        final cleanedText = SubtitleParser.cleanText(rawText);

        if (cleanedText.isEmpty) continue;

        subtitles.add(SubtitleItem(
          start: start,
          end: end,
          text: cleanedText,
          rawText: rawText,
        ));
      } catch (e) {
        debugPrint('Error parsing VTT block: $e\n$block');
      }
    }

    subtitles.sort((a, b) => a.start.compareTo(b.start));
    return subtitles;
  }
}

class SSAParser extends SubtitleParser {
  @override
  List<SubtitleItem> parse(String content) {
    final List<SubtitleItem> subtitles = [];

    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = content.split('\n');

    int formatIndex = -1;
    List<String> formatFields = [];

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('Format:')) {
        formatFields = lines[i]
            .substring(7)
            .split(',')
            .map((e) => e.trim())
            .toList();
        formatIndex = i;
        break;
      }
    }

    if (formatIndex == -1) return subtitles;

    final startIdx = formatFields.indexOf('Start');
    final endIdx = formatFields.indexOf('End');
    final textIdx = formatFields.indexOf('Text');

    if (startIdx == -1 || endIdx == -1 || textIdx == -1) {
      return subtitles;
    }

    for (int i = formatIndex + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('Dialogue:')) continue;

      try {
        final parts = line.substring(9).split(',');
        if (parts.length <= textIdx) continue;

        final start = _parseSSATime(parts[startIdx].trim());
        final end = _parseSSATime(parts[endIdx].trim());

        final rawText = parts.sublist(textIdx).join(',');
        final cleanedText = _cleanSSAText(rawText);

        if (cleanedText.isEmpty) continue;

        subtitles.add(SubtitleItem(
          start: start,
          end: end,
          text: cleanedText,
          rawText: rawText,
        ));
      } catch (e) {
        debugPrint('Error parsing SSA dialogue: $e\n$line');
      }
    }

    subtitles.sort((a, b) => a.start.compareTo(b.start));
    return subtitles;
  }

  Duration _parseSSATime(String timeString) {

    final match = RegExp(r'(\d+):(\d{2}):(\d{2})\.(\d{2})')
        .firstMatch(timeString);

    if (match == null) return Duration.zero;

    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    final seconds = int.parse(match.group(3)!);
    final centiseconds = int.parse(match.group(4)!);

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: centiseconds * 10,
    );
  }

  String _cleanSSAText(String text) {
    String cleaned = text.replaceAll(RegExp(r'\{[^}]*\}'), '');

    cleaned = cleaned.replaceAll(r'\N', '\n');
    cleaned = cleaned.replaceAll(r'\n', '\n');

    cleaned = SubtitleParser.cleanText(cleaned);

    return cleaned;
  }
}

class SubtitleProvider extends ChangeNotifier {
  File? _subtitle1File;
  File? _subtitle2File;

  List<SubtitleItem>? _subtitle1Data;
  List<SubtitleItem>? _subtitle2Data;

  SubtitleFormat _subtitle1Format = SubtitleFormat.unknown;
  SubtitleFormat _subtitle2Format = SubtitleFormat.unknown;

  String _currentSubtitle1 = '';
  String _currentSubtitle2 = '';

  double _subtitle1Size = 18.0;
  double _subtitle2Size = 16.0;

  Color _subtitle1Color = Colors.white;
  Color _subtitle2Color = Colors.yellowAccent;

  double _subtitleGap = 10.0;

  bool _showSubtitle1 = true;
  bool _showSubtitle2 = true;

  // Cache
  int _lastSubtitle1Index = 0;
  int _lastSubtitle2Index = 0;

  // Getters
  File? get subtitle1File => _subtitle1File;
  File? get subtitle2File => _subtitle2File;
  String get currentSubtitle1 => _currentSubtitle1;
  String get currentSubtitle2 => _currentSubtitle2;
  double get subtitle1Size => _subtitle1Size;
  double get subtitle2Size => _subtitle2Size;
  Color get subtitle1Color => _subtitle1Color;
  Color get subtitle2Color => _subtitle2Color;
  double get subtitleGap => _subtitleGap;
  bool get showSubtitle1 => _showSubtitle1;
  bool get showSubtitle2 => _showSubtitle2;
  SubtitleFormat get subtitle1Format => _subtitle1Format;
  SubtitleFormat get subtitle2Format => _subtitle2Format;
  int? get subtitle1Count => _subtitle1Data?.length;
  int? get subtitle2Count => _subtitle2Data?.length;

  Future<void> pickSubtitle1() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt', 'vtt', 'ssa', 'ass'],
      );

      if (result != null && result.files.single.path != null) {
        _subtitle1File = File(result.files.single.path!);
        await _parseSubtitle1();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking subtitle 1: $e');
      rethrow;
    }
  }

  Future<void> pickSubtitle2() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt', 'vtt', 'ssa', 'ass'],
      );

      if (result != null && result.files.single.path != null) {
        _subtitle2File = File(result.files.single.path!);
        await _parseSubtitle2();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking subtitle 2: $e');
      rethrow;
    }
  }

  Future<void> _parseSubtitle1() async {
    if (_subtitle1File == null) return;

    try {
      final content = await _subtitle1File!.readAsString();

      _subtitle1Format = SubtitleParser.detectFormat(content);
      debugPrint('Detected subtitle 1 format: $_subtitle1Format');

      final parser = SubtitleParser.createParser(_subtitle1Format);

      if (parser == null) {
        throw Exception('Unsupported subtitle format: $_subtitle1Format');
      }

      _subtitle1Data = parser.parse(content);
      _lastSubtitle1Index = 0;

      debugPrint('Parsed ${_subtitle1Data!.length} subtitle 1 items');
    } catch (e) {
      debugPrint('Error parsing subtitle 1: $e');
      _subtitle1Data = null;
      _subtitle1Format = SubtitleFormat.unknown;
      rethrow;
    }
  }

  Future<void> _parseSubtitle2() async {
    if (_subtitle2File == null) return;

    try {
      final content = await _subtitle2File!.readAsString();

      _subtitle2Format = SubtitleParser.detectFormat(content);
      debugPrint('Detected subtitle 2 format: $_subtitle2Format');

      final parser = SubtitleParser.createParser(_subtitle2Format);

      if (parser == null) {
        throw Exception('Unsupported subtitle format: $_subtitle2Format');
      }

      _subtitle2Data = parser.parse(content);
      _lastSubtitle2Index = 0;

      debugPrint('Parsed ${_subtitle2Data!.length} subtitle 2 items');
    } catch (e) {
      debugPrint('Error parsing subtitle 2: $e');
      _subtitle2Data = null;
      _subtitle2Format = SubtitleFormat.unknown;
      rethrow;
    }
  }

  void updateSubtitles(Duration position) {
    bool changed = false;

    if (_subtitle1Data != null) {
      final newText = _getSubtitleText(
        _subtitle1Data!,
        position,
        _lastSubtitle1Index,
            (index) => _lastSubtitle1Index = index,
      );

      if (newText != _currentSubtitle1) {
        _currentSubtitle1 = newText;
        changed = true;
      }
    }

    if (_subtitle2Data != null) {
      final newText = _getSubtitleText(
        _subtitle2Data!,
        position,
        _lastSubtitle2Index,
            (index) => _lastSubtitle2Index = index,
      );

      if (newText != _currentSubtitle2) {
        _currentSubtitle2 = newText;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// (Binary Search + Cache)
  String _getSubtitleText(
      List<SubtitleItem> subtitles,
      Duration position,
      int lastIndex,
      Function(int) updateLastIndex,
      ) {
    if (subtitles.isEmpty) return '';

    if (lastIndex < subtitles.length) {
      final current = subtitles[lastIndex];
      if (position >= current.start && position <= current.end) {
        return current.text;
      }
    }

    for (int i = lastIndex; i < subtitles.length; i++) {
      final subtitle = subtitles[i];

      if (position >= subtitle.start && position <= subtitle.end) {
        updateLastIndex(i);
        return subtitle.text;
      }

      if (position < subtitle.start) {
        break;
      }
    }

    for (int i = 0; i < lastIndex; i++) {
      final subtitle = subtitles[i];

      if (position >= subtitle.start && position <= subtitle.end) {
        updateLastIndex(i);
        return subtitle.text;
      }
    }

    return '';
  }

  void setSubtitle1Size(double size) {
    _subtitle1Size = size.clamp(8.0, 72.0);
    notifyListeners();
  }

  void setSubtitle2Size(double size) {
    _subtitle2Size = size.clamp(8.0, 72.0);
    notifyListeners();
  }

  void setSubtitle1Color(Color color) {
    _subtitle1Color = color;
    notifyListeners();
  }

  void setSubtitle2Color(Color color) {
    _subtitle2Color = color;
    notifyListeners();
  }

  void setSubtitleGap(double gap) {
    _subtitleGap = gap.clamp(0.0, 100.0);
    notifyListeners();
  }

  void toggleSubtitle1() {
    _showSubtitle1 = !_showSubtitle1;
    notifyListeners();
  }

  void toggleSubtitle2() {
    _showSubtitle2 = !_showSubtitle2;
    notifyListeners();
  }

  void clearSubtitle1() {
    _subtitle1File = null;
    _subtitle1Data = null;
    _currentSubtitle1 = '';
    _subtitle1Format = SubtitleFormat.unknown;
    _lastSubtitle1Index = 0;
    notifyListeners();
  }

  void clearSubtitle2() {
    _subtitle2File = null;
    _subtitle2Data = null;
    _currentSubtitle2 = '';
    _subtitle2Format = SubtitleFormat.unknown;
    _lastSubtitle2Index = 0;
    notifyListeners();
  }

  void clearAllSubtitles() {
    clearSubtitle1();
    clearSubtitle2();
  }

  @override
  void dispose() {
    _subtitle1Data = null;
    _subtitle2Data = null;
    super.dispose();
  }
}