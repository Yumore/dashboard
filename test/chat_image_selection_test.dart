import 'dart:typed_data';

import 'package:dashboard/features/chat/chat_image_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'support/recording_image_picker.dart';

void main() {
  test('canceling selection does not fabricate an attachment', () async {
    final picker = RecordingImagePicker(null);
    expect(
      await ChatImageSelection(picker: picker).select(ImageSource.camera),
      isNull,
    );
    expect(picker.lastSource, ImageSource.camera);
  });

  test(
    'selected image bytes are returned locally without a chat transport',
    () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final picker = RecordingImagePicker(XFile.fromData(bytes));
      expect(
        await ChatImageSelection(picker: picker).select(ImageSource.gallery),
        bytes,
      );
      expect(picker.lastSource, ImageSource.gallery);
    },
  );
}
