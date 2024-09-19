import 'dart:typed_data';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:gcloud/storage.dart';
import 'package:mime/mime.dart';

class CloudApi {
  final auth.ServiceAccountCredentials _credentials;
  auth.AutoRefreshingAuthClient? _client;

  CloudApi(String json) : _credentials = auth.ServiceAccountCredentials.fromJson(json);

  Future<ObjectInfo> save(String name, Uint8List imgBytes) async {
    _client ??= await auth.clientViaServiceAccount(_credentials, Storage.SCOPES);

    var storage = Storage(_client!, 'Image Upload Google Storage');
    var bucket = storage.bucket('imagestore_camera');

    final type = lookupMimeType(name);
    final objectInfo = await bucket.writeBytes('CategoryIcon/$name', imgBytes,
        metadata: ObjectMetadata(contentType: type));

    return objectInfo;
  }

  Future<String?> getDownloadUrl(String name) async {
    _client ??= await auth.clientViaServiceAccount(_credentials, Storage.SCOPES);

    var storage = Storage(_client!, 'Image Upload Google Storage');
    var bucket = storage.bucket('imagestore_camera');

    final objectInfo = await bucket.info('CategoryIcon/$name');
    return objectInfo.downloadLink.toString();
  }
}
