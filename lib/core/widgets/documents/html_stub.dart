// Stub implementations for dart:html when not available (WebAssembly builds)
// This library provides the same API as dart:html for conditional imports

class Window {
  void open(String url, String target) {
    throw UnsupportedError('dart:html is not available in WebAssembly builds');
  }
  
  Future<Response> fetch(String url) {
    throw UnsupportedError('dart:html is not available in WebAssembly builds');
  }
}

class Response {
  Future<String> text() {
    throw UnsupportedError('dart:html is not available in WebAssembly builds');
  }
}

class AnchorElement {
  String? href;
  String? target;
  String? download;
  
  AnchorElement({this.href});
  
  void click() {
    throw UnsupportedError('dart:html is not available in WebAssembly builds');
  }
  
  void remove() {
    throw UnsupportedError('dart:html is not available in WebAssembly builds');
  }
}

class IFrameElement {
  String? src;
  final Style style = Style();
  
  IFrameElement();
}

class Style {
  String? border;
  String? width;
  String? height;
}

class BodyElement {
  void append(dynamic element) {
    throw UnsupportedError('dart:html is not available in WebAssembly builds');
  }
}

class Document {
  BodyElement? get body => null;
}

// Export as top-level getters to match dart:html API
Window get window => Window();
Document get document => Document();
