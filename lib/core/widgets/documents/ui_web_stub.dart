// Stub implementation for dart:ui_web when not available (WebAssembly builds)
// This library provides the same API as dart:ui_web for conditional imports

class PlatformViewRegistry {
  void registerViewFactory(String viewType, dynamic callback) {
    throw UnsupportedError('dart:ui_web is not available in WebAssembly builds');
  }
}

// Export as top-level getter to match dart:ui_web API
final platformViewRegistry = PlatformViewRegistry();
