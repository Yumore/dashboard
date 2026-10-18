import 'dart:convert';
import 'dart:typed_data';

/// Pure-Dart port of the native `aespack` plugin the source app used for the
/// gogoplay handshake.
///
/// `aespack` is a method-channel plugin; both of its implementations perform
/// the same primitive:
/// * Android `AespackPlugin.encrypt/decrypt`: `AES/CBC/PKCS5Padding`, key and
///   IV are the raw bytes of the 16 character strings, input/output Base64.
/// * iOS `NSData+AES`: `CCCrypt(kCCAlgorithmAES128, kCCOptionPKCS7Padding)`
///   with the key/IV copied through `getCString:maxLength:17`, which truncates
///   them to 16 characters.
///
/// The plugin is not a host dependency and cannot run in a unit test, so the
/// identical algorithm is reimplemented here (AES-128, CBC, PKCS#7, Base64).
class TakoAes {
  TakoAes({required this.key, required this.iv})
    : _core = _Aes128(_keyBytes(key, 'key')),
      _iv = _keyBytes(iv, 'iv');

  final String key;
  final String iv;
  final _Aes128 _core;
  final Uint8List _iv;

  /// AES-CBC encrypts [plainText] and returns the Base64 ciphertext.
  String encrypt(String plainText) {
    return base64.encode(_core.encodeCbc(utf8.encode(plainText), _iv));
  }

  /// AES-CBC decrypts Base64 [cipherText] and returns the UTF-8 plaintext.
  ///
  /// Both plugins wrap their Base64 output (Java at 76 columns, iOS at 64), so
  /// embedded line breaks are stripped before decoding, and URL-safe or
  /// unpadded input is normalised.
  String decrypt(String cipherText) {
    final cleaned = cipherText.replaceAll(RegExp(r'\s'), '');
    final bytes = base64.decode(base64.normalize(cleaned));
    return utf8.decode(_core.decodeCbc(bytes, _iv));
  }

  static Uint8List _keyBytes(String value, String name) {
    final bytes = utf8.encode(value);
    if (bytes.length != 16) {
      throw FormatException(
        'AES-128 $name must be 16 bytes, got ${bytes.length}',
      );
    }
    return Uint8List.fromList(bytes);
  }
}

/// AES-128 block cipher in CBC mode with PKCS#7 padding (FIPS-197).
class _Aes128 {
  _Aes128(List<int> key) : _roundKeys = _expand(key);

  static const int _blockSize = 16;
  static const int _rounds = 10;

  final Uint8List _roundKeys;

  Uint8List encodeCbc(List<int> plain, Uint8List iv) {
    final padded = _pad(plain);
    final out = Uint8List(padded.length);
    var previous = iv;
    for (var offset = 0; offset < padded.length; offset += _blockSize) {
      final block = Uint8List(_blockSize);
      for (var i = 0; i < _blockSize; i++) {
        block[i] = padded[offset + i] ^ previous[i];
      }
      final encrypted = _encryptBlock(block);
      out.setRange(offset, offset + _blockSize, encrypted);
      previous = encrypted;
    }
    return out;
  }

  Uint8List decodeCbc(List<int> cipher, Uint8List iv) {
    if (cipher.isEmpty || cipher.length % _blockSize != 0) {
      throw const FormatException(
        'AES ciphertext must be a non-empty multiple of 16 bytes',
      );
    }
    final out = Uint8List(cipher.length);
    var previous = iv;
    for (var offset = 0; offset < cipher.length; offset += _blockSize) {
      final block = Uint8List.fromList(
        cipher.sublist(offset, offset + _blockSize),
      );
      final decrypted = _decryptBlock(block);
      for (var i = 0; i < _blockSize; i++) {
        out[offset + i] = decrypted[i] ^ previous[i];
      }
      previous = block;
    }
    return _unpad(out);
  }

  Uint8List _encryptBlock(Uint8List input) {
    var state = Uint8List.fromList(input);
    _addRoundKey(state, 0);
    for (var round = 1; round < _rounds; round++) {
      state = _subBytes(state, _sbox);
      state = _shiftRows(state);
      state = _mixColumns(state);
      _addRoundKey(state, round);
    }
    state = _subBytes(state, _sbox);
    state = _shiftRows(state);
    _addRoundKey(state, _rounds);
    return state;
  }

  Uint8List _decryptBlock(Uint8List input) {
    var state = Uint8List.fromList(input);
    _addRoundKey(state, _rounds);
    for (var round = _rounds - 1; round > 0; round--) {
      state = _invShiftRows(state);
      state = _subBytes(state, _invSbox);
      _addRoundKey(state, round);
      state = _invMixColumns(state);
    }
    state = _invShiftRows(state);
    state = _subBytes(state, _invSbox);
    _addRoundKey(state, 0);
    return state;
  }

  void _addRoundKey(Uint8List state, int round) {
    for (var i = 0; i < _blockSize; i++) {
      state[i] ^= _roundKeys[round * _blockSize + i];
    }
  }

  static Uint8List _subBytes(Uint8List state, Uint8List box) {
    final out = Uint8List(_blockSize);
    for (var i = 0; i < _blockSize; i++) {
      out[i] = box[state[i]];
    }
    return out;
  }

  /// State is column-major: `state[row + 4 * column]`.
  static Uint8List _shiftRows(Uint8List state) {
    final out = Uint8List(_blockSize);
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 4; column++) {
        out[row + 4 * column] = state[row + 4 * ((column + row) % 4)];
      }
    }
    return out;
  }

  static Uint8List _invShiftRows(Uint8List state) {
    final out = Uint8List(_blockSize);
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 4; column++) {
        out[row + 4 * column] = state[row + 4 * ((column - row) % 4)];
      }
    }
    return out;
  }

  static Uint8List _mixColumns(Uint8List state) {
    final out = Uint8List(_blockSize);
    for (var column = 0; column < 4; column++) {
      final a0 = state[4 * column];
      final a1 = state[4 * column + 1];
      final a2 = state[4 * column + 2];
      final a3 = state[4 * column + 3];
      out[4 * column] = _gmul(a0, 2) ^ _gmul(a1, 3) ^ a2 ^ a3;
      out[4 * column + 1] = a0 ^ _gmul(a1, 2) ^ _gmul(a2, 3) ^ a3;
      out[4 * column + 2] = a0 ^ a1 ^ _gmul(a2, 2) ^ _gmul(a3, 3);
      out[4 * column + 3] = _gmul(a0, 3) ^ a1 ^ a2 ^ _gmul(a3, 2);
    }
    return out;
  }

  static Uint8List _invMixColumns(Uint8List state) {
    final out = Uint8List(_blockSize);
    for (var column = 0; column < 4; column++) {
      final a0 = state[4 * column];
      final a1 = state[4 * column + 1];
      final a2 = state[4 * column + 2];
      final a3 = state[4 * column + 3];
      out[4 * column] =
          _gmul(a0, 14) ^ _gmul(a1, 11) ^ _gmul(a2, 13) ^ _gmul(a3, 9);
      out[4 * column + 1] =
          _gmul(a0, 9) ^ _gmul(a1, 14) ^ _gmul(a2, 11) ^ _gmul(a3, 13);
      out[4 * column + 2] =
          _gmul(a0, 13) ^ _gmul(a1, 9) ^ _gmul(a2, 14) ^ _gmul(a3, 11);
      out[4 * column + 3] =
          _gmul(a0, 11) ^ _gmul(a1, 13) ^ _gmul(a2, 9) ^ _gmul(a3, 14);
    }
    return out;
  }

  static int _gmul(int a, int b) {
    var left = a;
    var right = b;
    var result = 0;
    while (right > 0) {
      if (right & 1 != 0) result ^= left;
      left = _xtime(left);
      right >>= 1;
    }
    return result & 0xFF;
  }

  static int _xtime(int value) {
    final shifted = (value << 1) & 0xFF;
    return value & 0x80 == 0 ? shifted : shifted ^ 0x1B;
  }

  static Uint8List _pad(List<int> plain) {
    final remainder = plain.length % _blockSize;
    final padding = _blockSize - remainder;
    final out = Uint8List(plain.length + padding);
    out.setRange(0, plain.length, plain);
    for (var i = plain.length; i < out.length; i++) {
      out[i] = padding;
    }
    return out;
  }

  static Uint8List _unpad(Uint8List padded) {
    final padding = padded.last;
    if (padding < 1 || padding > _blockSize || padding > padded.length) {
      throw const FormatException('Invalid PKCS#7 padding');
    }
    for (var i = padded.length - padding; i < padded.length; i++) {
      if (padded[i] != padding) {
        throw const FormatException('Invalid PKCS#7 padding');
      }
    }
    return Uint8List.sublistView(padded, 0, padded.length - padding);
  }

  static Uint8List _expand(List<int> key) {
    final words = Uint8List(176);
    words.setRange(0, 16, key);
    var index = 16;
    var rcon = 1;
    while (index < 176) {
      var t0 = words[index - 4];
      var t1 = words[index - 3];
      var t2 = words[index - 2];
      var t3 = words[index - 1];
      if (index % 16 == 0) {
        final first = t0;
        t0 = _sbox[t1] ^ rcon;
        t1 = _sbox[t2];
        t2 = _sbox[t3];
        t3 = _sbox[first];
        rcon = _xtime(rcon);
      }
      words[index] = words[index - 16] ^ t0;
      words[index + 1] = words[index - 15] ^ t1;
      words[index + 2] = words[index - 14] ^ t2;
      words[index + 3] = words[index - 13] ^ t3;
      index += 4;
    }
    return words;
  }

  /// AES S-box (FIPS-197 figure 7).
  static final Uint8List _sbox = Uint8List.fromList(const <int>[
    0x63,
    0x7c,
    0x77,
    0x7b,
    0xf2,
    0x6b,
    0x6f,
    0xc5,
    0x30,
    0x01,
    0x67,
    0x2b,
    0xfe,
    0xd7,
    0xab,
    0x76,
    0xca,
    0x82,
    0xc9,
    0x7d,
    0xfa,
    0x59,
    0x47,
    0xf0,
    0xad,
    0xd4,
    0xa2,
    0xaf,
    0x9c,
    0xa4,
    0x72,
    0xc0,
    0xb7,
    0xfd,
    0x93,
    0x26,
    0x36,
    0x3f,
    0xf7,
    0xcc,
    0x34,
    0xa5,
    0xe5,
    0xf1,
    0x71,
    0xd8,
    0x31,
    0x15,
    0x04,
    0xc7,
    0x23,
    0xc3,
    0x18,
    0x96,
    0x05,
    0x9a,
    0x07,
    0x12,
    0x80,
    0xe2,
    0xeb,
    0x27,
    0xb2,
    0x75,
    0x09,
    0x83,
    0x2c,
    0x1a,
    0x1b,
    0x6e,
    0x5a,
    0xa0,
    0x52,
    0x3b,
    0xd6,
    0xb3,
    0x29,
    0xe3,
    0x2f,
    0x84,
    0x53,
    0xd1,
    0x00,
    0xed,
    0x20,
    0xfc,
    0xb1,
    0x5b,
    0x6a,
    0xcb,
    0xbe,
    0x39,
    0x4a,
    0x4c,
    0x58,
    0xcf,
    0xd0,
    0xef,
    0xaa,
    0xfb,
    0x43,
    0x4d,
    0x33,
    0x85,
    0x45,
    0xf9,
    0x02,
    0x7f,
    0x50,
    0x3c,
    0x9f,
    0xa8,
    0x51,
    0xa3,
    0x40,
    0x8f,
    0x92,
    0x9d,
    0x38,
    0xf5,
    0xbc,
    0xb6,
    0xda,
    0x21,
    0x10,
    0xff,
    0xf3,
    0xd2,
    0xcd,
    0x0c,
    0x13,
    0xec,
    0x5f,
    0x97,
    0x44,
    0x17,
    0xc4,
    0xa7,
    0x7e,
    0x3d,
    0x64,
    0x5d,
    0x19,
    0x73,
    0x60,
    0x81,
    0x4f,
    0xdc,
    0x22,
    0x2a,
    0x90,
    0x88,
    0x46,
    0xee,
    0xb8,
    0x14,
    0xde,
    0x5e,
    0x0b,
    0xdb,
    0xe0,
    0x32,
    0x3a,
    0x0a,
    0x49,
    0x06,
    0x24,
    0x5c,
    0xc2,
    0xd3,
    0xac,
    0x62,
    0x91,
    0x95,
    0xe4,
    0x79,
    0xe7,
    0xc8,
    0x37,
    0x6d,
    0x8d,
    0xd5,
    0x4e,
    0xa9,
    0x6c,
    0x56,
    0xf4,
    0xea,
    0x65,
    0x7a,
    0xae,
    0x08,
    0xba,
    0x78,
    0x25,
    0x2e,
    0x1c,
    0xa6,
    0xb4,
    0xc6,
    0xe8,
    0xdd,
    0x74,
    0x1f,
    0x4b,
    0xbd,
    0x8b,
    0x8a,
    0x70,
    0x3e,
    0xb5,
    0x66,
    0x48,
    0x03,
    0xf6,
    0x0e,
    0x61,
    0x35,
    0x57,
    0xb9,
    0x86,
    0xc1,
    0x1d,
    0x9e,
    0xe1,
    0xf8,
    0x98,
    0x11,
    0x69,
    0xd9,
    0x8e,
    0x94,
    0x9b,
    0x1e,
    0x87,
    0xe9,
    0xce,
    0x55,
    0x28,
    0xdf,
    0x8c,
    0xa1,
    0x89,
    0x0d,
    0xbf,
    0xe6,
    0x42,
    0x68,
    0x41,
    0x99,
    0x2d,
    0x0f,
    0xb0,
    0x54,
    0xbb,
    0x16,
  ]);

  /// Inverse AES S-box (FIPS-197 figure 14).
  static final Uint8List _invSbox = Uint8List.fromList(const <int>[
    0x52,
    0x09,
    0x6a,
    0xd5,
    0x30,
    0x36,
    0xa5,
    0x38,
    0xbf,
    0x40,
    0xa3,
    0x9e,
    0x81,
    0xf3,
    0xd7,
    0xfb,
    0x7c,
    0xe3,
    0x39,
    0x82,
    0x9b,
    0x2f,
    0xff,
    0x87,
    0x34,
    0x8e,
    0x43,
    0x44,
    0xc4,
    0xde,
    0xe9,
    0xcb,
    0x54,
    0x7b,
    0x94,
    0x32,
    0xa6,
    0xc2,
    0x23,
    0x3d,
    0xee,
    0x4c,
    0x95,
    0x0b,
    0x42,
    0xfa,
    0xc3,
    0x4e,
    0x08,
    0x2e,
    0xa1,
    0x66,
    0x28,
    0xd9,
    0x24,
    0xb2,
    0x76,
    0x5b,
    0xa2,
    0x49,
    0x6d,
    0x8b,
    0xd1,
    0x25,
    0x72,
    0xf8,
    0xf6,
    0x64,
    0x86,
    0x68,
    0x98,
    0x16,
    0xd4,
    0xa4,
    0x5c,
    0xcc,
    0x5d,
    0x65,
    0xb6,
    0x92,
    0x6c,
    0x70,
    0x48,
    0x50,
    0xfd,
    0xed,
    0xb9,
    0xda,
    0x5e,
    0x15,
    0x46,
    0x57,
    0xa7,
    0x8d,
    0x9d,
    0x84,
    0x90,
    0xd8,
    0xab,
    0x00,
    0x8c,
    0xbc,
    0xd3,
    0x0a,
    0xf7,
    0xe4,
    0x58,
    0x05,
    0xb8,
    0xb3,
    0x45,
    0x06,
    0xd0,
    0x2c,
    0x1e,
    0x8f,
    0xca,
    0x3f,
    0x0f,
    0x02,
    0xc1,
    0xaf,
    0xbd,
    0x03,
    0x01,
    0x13,
    0x8a,
    0x6b,
    0x3a,
    0x91,
    0x11,
    0x41,
    0x4f,
    0x67,
    0xdc,
    0xea,
    0x97,
    0xf2,
    0xcf,
    0xce,
    0xf0,
    0xb4,
    0xe6,
    0x73,
    0x96,
    0xac,
    0x74,
    0x22,
    0xe7,
    0xad,
    0x35,
    0x85,
    0xe2,
    0xf9,
    0x37,
    0xe8,
    0x1c,
    0x75,
    0xdf,
    0x6e,
    0x47,
    0xf1,
    0x1a,
    0x71,
    0x1d,
    0x29,
    0xc5,
    0x89,
    0x6f,
    0xb7,
    0x62,
    0x0e,
    0xaa,
    0x18,
    0xbe,
    0x1b,
    0xfc,
    0x56,
    0x3e,
    0x4b,
    0xc6,
    0xd2,
    0x79,
    0x20,
    0x9a,
    0xdb,
    0xc0,
    0xfe,
    0x78,
    0xcd,
    0x5a,
    0xf4,
    0x1f,
    0xdd,
    0xa8,
    0x33,
    0x88,
    0x07,
    0xc7,
    0x31,
    0xb1,
    0x12,
    0x10,
    0x59,
    0x27,
    0x80,
    0xec,
    0x5f,
    0x60,
    0x51,
    0x7f,
    0xa9,
    0x19,
    0xb5,
    0x4a,
    0x0d,
    0x2d,
    0xe5,
    0x7a,
    0x9f,
    0x93,
    0xc9,
    0x9c,
    0xef,
    0xa0,
    0xe0,
    0x3b,
    0x4d,
    0xae,
    0x2a,
    0xf5,
    0xb0,
    0xc8,
    0xeb,
    0xbb,
    0x3c,
    0x83,
    0x53,
    0x99,
    0x61,
    0x17,
    0x2b,
    0x04,
    0x7e,
    0xba,
    0x77,
    0xd6,
    0x26,
    0xe1,
    0x69,
    0x14,
    0x63,
    0x55,
    0x21,
    0x0c,
    0x7d,
  ]);
}
