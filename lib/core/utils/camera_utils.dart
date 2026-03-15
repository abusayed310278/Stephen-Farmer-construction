import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Robust check for camera availability.
  /// Handles iOS simulator absence and image_picker's internal support check.
  static Future<bool> isCameraAvailable() async {
    // 1. Check if the platform is iOS and if it's running on a simulator.
    if (Platform.isIOS && await _isIosSimulator()) {
      return false;
    }

    // 2. Check if the image_picker plugin supports the camera source on this device.
    // Note: image_picker 1.0+ has this method.
    return _picker.supportsImageSource(ImageSource.camera);
  }

  /// Internal helper to detect iOS simulator.
  static Future<bool> _isIosSimulator() async {
    if (!Platform.isIOS) return false;
    
    // Check environment variables commonly set on simulators.
    final env = Platform.environment;
    if (env.containsKey('IPHONE_SIMULATOR_ROOT')) return true;
    if (env.keys.any((key) => key.startsWith('SIMULATOR_'))) return true;
    
    // Fallback: If we are on iOS but not a real device according to platform properties.
    // In Flutter, this is often handled by device_info_plus, but since it's not in pubspec,
    // we rely on the environment variables and the supportsImageSource check.
    return false; 
  }
}
