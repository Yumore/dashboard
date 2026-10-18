/// Bubble content kind of the FlutterSocialAppUIKit chat thread
/// (source `lib/util/data.dart:86`, `List types = ["text", "image"]`).
///
/// The source keeps the kind as a string and compares it with `"text"` in
/// `lib/views/widgets/chat_bubble.dart:155`. The port uses an enum with the
/// same two values.
enum FlutterSocialAppUIKitMessageType { text, image }
