import 'package:image_picker/image_picker.dart';

class RecordingImagePicker extends ImagePicker {
  RecordingImagePicker(this.result);

  final XFile? result;
  ImageSource? lastSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    return result;
  }
}
