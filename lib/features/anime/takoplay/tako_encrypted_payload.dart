/// The `encrypt-ajax.php` envelope: `{"data": "<base64 ciphertext>"}`.
class TakoEncryptedPayload {
  const TakoEncryptedPayload({required this.data});

  factory TakoEncryptedPayload.fromJson(Map<String, dynamic> json) {
    final data = json['data']?.toString() ?? '';
    if (data.isEmpty) {
      throw const FormatException('encrypt-ajax response has no data field');
    }
    return TakoEncryptedPayload(data: data);
  }

  /// Base64 AES-CBC ciphertext that decrypts to `{"source":[...]}`.
  final String data;
}
