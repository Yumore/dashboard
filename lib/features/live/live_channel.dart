class LiveChannel {
  const LiveChannel({
    required this.name,
    required this.group,
    required this.urls,
    this.logo,
    this.id,
  });

  final String name;
  final String group;
  final List<Uri> urls;
  final Uri? logo;
  final String? id;
}
