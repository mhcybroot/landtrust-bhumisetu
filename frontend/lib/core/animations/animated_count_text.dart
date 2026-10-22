import 'package:flutter/material.dart';

/// Smoothly counts up from 0 to target number inside a string.
/// Preserves prefix (e.g. '৳ '), suffix (e.g. ' টি', ' জন'), and comma formatting.
class AnimatedCountText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration duration;
  final Curve curve;
  final TextOverflow? overflow;
  final int? maxLines;

  const AnimatedCountText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.easeOutCubic,
    this.overflow,
    this.maxLines,
  });

  static final _regex = RegExp(r'^([^\d০-৯]*)([\d০-৯,.]+)(.*)$');

  @override
  Widget build(BuildContext context) {
    final match = _regex.firstMatch(text.trim());
    if (match == null) return _buildText(text);

    final prefix = match.group(1) ?? '';
    final rawNumber = match.group(2) ?? '';
    final suffix = match.group(3) ?? '';
    final hasBn = RegExp(r'[০-৯]').hasMatch(rawNumber);

    final normalized = hasBn
        ? rawNumber.split('').map((c) => (c.codeUnitAt(0) >= 0x09E6 && c.codeUnitAt(0) <= 0x09EF)
            ? String.fromCharCode(48 + (c.codeUnitAt(0) - 0x09E6))
            : c).join()
        : rawNumber;

    final cleanStr = normalized.replaceAll(',', '');
    final target = double.tryParse(cleanStr);
    if (target == null) return _buildText(text);

    final hasCommas = rawNumber.contains(',');
    final isSa = RegExp(r',\d{2},').hasMatch(rawNumber) || prefix.contains('৳');
    final decPlaces = cleanStr.contains('.') ? cleanStr.split('.')[1].length : 0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: target),
      duration: duration,
      curve: curve,
      builder: (context, val, child) => _buildText(
        '$prefix${_format(val, decPlaces, hasCommas, isSa, hasBn)}$suffix',
      ),
    );
  }

  Widget _buildText(String val) =>
      Text(val, style: style, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  String _format(double val, int places, bool commas, bool isSa, bool isBn) {
    if (places == 0) return _formatInt(val.round(), commas, isSa, isBn);
    final intPart = val.toInt();
    final frac = (val - intPart).toStringAsFixed(places).substring(2);
    return '${_formatInt(intPart, commas, isSa, isBn)}.${isBn ? _toBn(frac) : frac}';
  }

  String _formatInt(int n, bool commas, bool isSa, bool isBn) {
    var s = n.toString();
    if (commas && s.length > 3) {
      if (isSa) {
        final last3 = s.substring(s.length - 3);
        var rest = s.substring(0, s.length - 3);
        final chunks = <String>[];
        while (rest.length > 2) {
          chunks.insert(0, rest.substring(rest.length - 2));
          rest = rest.substring(0, rest.length - 2);
        }
        if (rest.isNotEmpty) chunks.insert(0, rest);
        chunks.add(last3);
        s = chunks.join(',');
      } else {
        s = s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
      }
    }
    return isBn ? _toBn(s) : s;
  }

  String _toBn(String s) => s.split('').map((c) =>
      (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) ? String.fromCharCode(0x09E6 + (c.codeUnitAt(0) - 48)) : c).join();
}
