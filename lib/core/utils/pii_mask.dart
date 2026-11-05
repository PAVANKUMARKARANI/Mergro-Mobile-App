/// Masks personal data in free text (transcripts, notes) before display.
abstract final class PiiMask {
  static final RegExp _email = RegExp(
    r'\b([A-Za-z0-9])[A-Za-z0-9._%+-]*@([A-Za-z0-9.-]+\.[A-Za-z]{2,})\b',
  );
  static final RegExp _phone = RegExp(r'\+?\d[\d\s()-]{6,}\d');

  /// [text] with emails shown as "a•••@gmail.com" and phone numbers as
  /// "•••• 10" (last two digits kept so agents can tell numbers apart).
  static String mask(String text) {
    final withoutEmails = text.replaceAllMapped(
      _email,
      (match) => '${match[1]}•••@${match[2]}',
    );
    return withoutEmails.replaceAllMapped(_phone, (match) {
      final digits = match[0]!.replaceAll(RegExp(r'\D'), '');
      return '•••• ${digits.substring(digits.length - 2)}';
    });
  }
}
