import 'package:flutter/cupertino.dart';

/// DataModel to explain the unit of word in detection system
class Detection extends Comparable<Detection> {
  Detection({required this.range, this.style, this.emojiStartPoint});

  final TextRange range;
  final TextStyle? style;
  final int? emojiStartPoint;

  @override
  int compareTo(Detection other) {
    return range.start.compareTo(other.range.start);
  }
}

/// Hold functions to decorate tagged text
///
/// Return the list of [Detection] in [getDetections]
class Detector {
  final TextStyle? textStyle;
  final TextStyle? decoratedStyle;
  final bool? decorateAtSign;

  Detector({this.textStyle, this.decoratedStyle, this.decorateAtSign = false});

  List<Detection> _getSourceDetections(
      List<RegExpMatch> tags, String copiedText) {
    TextRange? previousItem;
    final result = <Detection>[];
    for (var tag in tags) {
      ///Add untagged content
      if (previousItem == null) {
        if (tag.start > 0) {
          result.add(Detection(
              range: TextRange(start: 0, end: tag.start), style: textStyle));
        }
      } else {
        result.add(Detection(
            range: TextRange(start: previousItem.end, end: tag.start),
            style: textStyle));
      }

      ///Add tagged content
      result.add(Detection(
          range: TextRange(start: tag.start, end: tag.end),
          style: decoratedStyle));
      previousItem = TextRange(start: tag.start, end: tag.end);
    }

    ///Add remaining untagged content
    if (result.last.range.end < copiedText.length) {
      result.add(Detection(
          range:
              TextRange(start: result.last.range.end, end: copiedText.length),
          style: textStyle));
    }
    return result;
  }

  /// Return the list of decorations with tagged and untagged text
  List<Detection> getDetections(String copiedText) {
    var regExp;
    if (this.decorateAtSign == true) {
      regExp = RegExp(
          r'''[@|#][^\s!@#$%^&*()=+،\/,\[{\]};:'"?><]+''',
          multiLine: true);
    }else{
      regExp = RegExp(
          r'''#[^\s!@#$%^&*()=+،\/,\[{\]};:'"?><]+''',
          multiLine: true);
    }
    
    final tags = regExp.allMatches(copiedText).toList();
    if (tags.isEmpty) {
      return [];
    }
    return _getSourceDetections(tags, copiedText);
  }
}
