/// Hand-written AES (128/192/256) ECB block cipher.
///
/// PicaComic used `package:pointycastle` for
/// `JmNetwork.convertData` (lib/network/jm_network/jm_network.dart:98). The host
/// root `pubspec.yaml` does not declare `pointycastle` (it is only a transitive
/// dependency) and may not be edited, so the ECB decrypt used by the 禁漫天堂 API
/// is reimplemented here. Verified against the FIPS-197 vectors in
/// test/picacomic_test.dart.
class JmAesEcb {
  JmAesEcb(List<int> key) : _rounds = (key.length ~/ 4) + 6 {
    if (key.length != 16 && key.length != 24 && key.length != 32) {
      throw ArgumentError('AES key must be 16, 24 or 32 bytes');
    }
    _roundKeys = _expandKey(key);
  }

  static const int blockSize = 16;

  final int _rounds;
  late final List<int> _roundKeys;

  /// Decrypts [input]; its length must be a multiple of [blockSize].
  List<int> decrypt(List<int> input) {
    if (input.length % blockSize != 0) {
      throw ArgumentError('AES input length must be a multiple of $blockSize');
    }
    final output = List<int>.filled(input.length, 0);
    for (var offset = 0; offset < input.length; offset += blockSize) {
      _decryptBlock(input, offset, output, offset);
    }
    return output;
  }

  /// Encrypts [input]; its length must be a multiple of [blockSize].
  List<int> encrypt(List<int> input) {
    if (input.length % blockSize != 0) {
      throw ArgumentError('AES input length must be a multiple of $blockSize');
    }
    final output = List<int>.filled(input.length, 0);
    for (var offset = 0; offset < input.length; offset += blockSize) {
      _encryptBlock(input, offset, output, offset);
    }
    return output;
  }

  void _encryptBlock(List<int> input, int inOffset, List<int> output, int outOffset) {
    final state = List<int>.generate(blockSize, (i) => input[inOffset + i]);
    _addRoundKey(state, 0);
    for (var round = 1; round < _rounds; round++) {
      _subBytes(state);
      _shiftRows(state);
      _mixColumns(state);
      _addRoundKey(state, round);
    }
    _subBytes(state);
    _shiftRows(state);
    _addRoundKey(state, _rounds);
    for (var i = 0; i < blockSize; i++) {
      output[outOffset + i] = state[i];
    }
  }

  void _decryptBlock(List<int> input, int inOffset, List<int> output, int outOffset) {
    final state = List<int>.generate(blockSize, (i) => input[inOffset + i]);
    _addRoundKey(state, _rounds);
    for (var round = _rounds - 1; round >= 1; round--) {
      _invShiftRows(state);
      _invSubBytes(state);
      _addRoundKey(state, round);
      _invMixColumns(state);
    }
    _invShiftRows(state);
    _invSubBytes(state);
    _addRoundKey(state, 0);
    for (var i = 0; i < blockSize; i++) {
      output[outOffset + i] = state[i];
    }
  }

  void _addRoundKey(List<int> state, int round) {
    final base = round * blockSize;
    for (var i = 0; i < blockSize; i++) {
      state[i] ^= _roundKeys[base + i];
    }
  }

  static void _subBytes(List<int> state) {
    for (var i = 0; i < blockSize; i++) {
      state[i] = _sbox[state[i]];
    }
  }

  static void _invSubBytes(List<int> state) {
    for (var i = 0; i < blockSize; i++) {
      state[i] = _invSbox[state[i]];
    }
  }

  /// Row `r` rotates left by `r`.
  static void _shiftRows(List<int> s) {
    for (var r = 1; r < 4; r++) {
      final row = [s[r], s[r + 4], s[r + 8], s[r + 12]];
      for (var c = 0; c < 4; c++) {
        s[4 * c + r] = row[(c + r) % 4];
      }
    }
  }

  /// Row `r` rotates right by `r`.
  static void _invShiftRows(List<int> s) {
    for (var r = 1; r < 4; r++) {
      final row = [s[r], s[r + 4], s[r + 8], s[r + 12]];
      for (var c = 0; c < 4; c++) {
        s[4 * c + r] = row[(c - r) % 4];
      }
    }
  }

  static void _mixColumns(List<int> s) {
    for (var c = 0; c < 4; c++) {
      final i = 4 * c;
      final a0 = s[i], a1 = s[i + 1], a2 = s[i + 2], a3 = s[i + 3];
      s[i] = _gmul(a0, 2) ^ _gmul(a1, 3) ^ a2 ^ a3;
      s[i + 1] = a0 ^ _gmul(a1, 2) ^ _gmul(a2, 3) ^ a3;
      s[i + 2] = a0 ^ a1 ^ _gmul(a2, 2) ^ _gmul(a3, 3);
      s[i + 3] = _gmul(a0, 3) ^ a1 ^ a2 ^ _gmul(a3, 2);
    }
  }

  static void _invMixColumns(List<int> s) {
    for (var c = 0; c < 4; c++) {
      final i = 4 * c;
      final a0 = s[i], a1 = s[i + 1], a2 = s[i + 2], a3 = s[i + 3];
      s[i] = _gmul(a0, 14) ^ _gmul(a1, 11) ^ _gmul(a2, 13) ^ _gmul(a3, 9);
      s[i + 1] = _gmul(a0, 9) ^ _gmul(a1, 14) ^ _gmul(a2, 11) ^ _gmul(a3, 13);
      s[i + 2] = _gmul(a0, 13) ^ _gmul(a1, 9) ^ _gmul(a2, 14) ^ _gmul(a3, 11);
      s[i + 3] = _gmul(a0, 11) ^ _gmul(a1, 13) ^ _gmul(a2, 9) ^ _gmul(a3, 14);
    }
  }

  /// Multiplication in GF(2^8).
  static int _gmul(int a, int b) {
    var x = a & 0xff;
    var y = b;
    var result = 0;
    while (y > 0) {
      if ((y & 1) != 0) result ^= x;
      final carry = x & 0x80;
      x = (x << 1) & 0xff;
      if (carry != 0) x ^= 0x1b;
      y >>= 1;
    }
    return result;
  }

  static List<int> _expandKey(List<int> key) {
    final nk = key.length ~/ 4;
    final totalWords = 4 * (_rounds_(nk) + 1);
    final w = List<int>.filled(totalWords * 4, 0);
    for (var i = 0; i < key.length; i++) {
      w[i] = key[i];
    }
    var rcon = 1;
    for (var i = nk; i < totalWords; i++) {
      var temp = [
        w[(i - 1) * 4],
        w[(i - 1) * 4 + 1],
        w[(i - 1) * 4 + 2],
        w[(i - 1) * 4 + 3],
      ];
      if (i % nk == 0) {
        temp = [_sbox[temp[1]], _sbox[temp[2]], _sbox[temp[3]], _sbox[temp[0]]];
        temp[0] ^= rcon;
        rcon = _gmul(rcon, 2);
      } else if (nk > 6 && i % nk == 4) {
        temp = [_sbox[temp[0]], _sbox[temp[1]], _sbox[temp[2]], _sbox[temp[3]]];
      }
      for (var j = 0; j < 4; j++) {
        w[i * 4 + j] = w[(i - nk) * 4 + j] ^ temp[j];
      }
    }
    return w;
  }

  static int _rounds_(int nk) => nk + 6;

  static final List<int> _sbox = List<int>.unmodifiable(const [
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16,
  ]);

  static final List<int> _invSbox = List<int>.unmodifiable(
    () {
      final inverse = List<int>.filled(256, 0);
      for (var i = 0; i < 256; i++) {
        inverse[_sbox[i]] = i;
      }
      return inverse;
    }(),
  );
}
