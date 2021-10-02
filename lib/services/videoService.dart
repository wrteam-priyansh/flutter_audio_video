import 'package:image_picker/image_picker.dart';

class VideoService {
  static Future pickVideo() async {
    try {
      XFile? videoFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (videoFile == null) {
        throw Exception("Could not pick video");
      }
      return videoFile;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
