import 'package:image_picker/image_picker.dart';

/// 멀티뷰 촬영 시 각도 라벨이 붙은 사진
class LabeledPhoto {
  const LabeledPhoto({required this.label, required this.file});

  /// 촬영 각도 키 (front / right / left / back)
  final String label;
  final XFile file;
}
