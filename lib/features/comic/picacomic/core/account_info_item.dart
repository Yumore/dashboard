/// Ports PicaComic's `AccountInfoItem`.
class AccountInfoItem {
  final String title;
  final String Function()? data;
  final void Function()? onTap;

  AccountInfoItem({required this.title, this.data, this.onTap});
}
