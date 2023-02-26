import 'package:flutter_test/flutter_test.dart';
import 'package:kang_image_picker/kang_image_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('getPlatformVersion', () async {
    expect(await KangImagePicker.getPlatformVersion(), '42');
  });
}
