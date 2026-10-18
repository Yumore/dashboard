/// Ports PicaComic's `CategoryButtonData`.
class CategoryButtonData {
  final String label;
  final void Function() onTap;

  const CategoryButtonData({required this.label, required this.onTap});
}
