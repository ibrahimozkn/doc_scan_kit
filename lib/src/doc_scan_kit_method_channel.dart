import 'package:doc_scan_kit/src/options/android_options.dart';
import 'package:doc_scan_kit/src/options/ios_options.dart';
import 'package:doc_scan_kit/src/options/scan_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'doc_scan_kit_platform_interface.dart';

/// An implementation of [DocScanKitPlatform] that uses method channels.
class MethodChannelDocScanKit extends DocScanKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doc_scan_kit');

  /// Instance id.
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  @override
  Future<List<ScanResult>> scanner(
    final DocumentScanKitOptionsAndroid androidOptions,
    final DocumentScanKitOptionsiOS iosOptions,
  ) async {
    return (await methodChannel.invokeMethod<List<Object?>>(
                'scanKit#startDocumentScanner', <String, dynamic>{
          'androidOptions': androidOptions.toJson(),
          'id': id,
          'iosOptions': iosOptions.toJson()
        }))
            ?.map(
          (e) {
            e as Map;
            return ScanResult(
                imagePath: e['path'],
                imagesBytes: e['bytes'],
                text: e['text'],
                barcode: e['barcode']);
          },
        ).toList() ??
        [];
  }

  @override

  /// Close the detector and release resources.
  Future<void> close() {
    return methodChannel
        .invokeMethod<void>("scanKit#closeDocumentScanner", {'id': id});
  }
}
