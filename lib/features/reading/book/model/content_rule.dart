
/// Legado-compatible book source (subset used by M1 engine).
class ContentRule {
  String content;
  String nextContentUrl;
  String sourceRegex;
  String replaceRegex;
  String imageStyle;

  ContentRule({
    this.content = '',
    this.nextContentUrl = '',
    this.sourceRegex = '',
    this.replaceRegex = '',
    this.imageStyle = '',
  });

  factory ContentRule.fromJson(Map<String, dynamic> json) => ContentRule(
        content: (json['content'] ?? '').toString(),
        nextContentUrl: (json['nextContentUrl'] ?? '').toString(),
        sourceRegex: (json['sourceRegex'] ?? '').toString(),
        replaceRegex: (json['replaceRegex'] ?? '').toString(),
        imageStyle: (json['imageStyle'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'nextContentUrl': nextContentUrl,
        'sourceRegex': sourceRegex,
        'replaceRegex': replaceRegex,
        'imageStyle': imageStyle,
      };
}
