import 'dart:typed_data';

void download(Uint8List bytes, String filename, String mimeType) {
  throw UnsupportedError('Web download is only available on web builds.');
}
