import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class DatabaseService {
  final String baseUrl = 'http://localhost:3000/parking_system_api';

//Store Owner Details
  Future<Map<String, dynamic>> uploadProfile(
      String name,
      String email,
      String mobile,
      String gender,
      String groupName,
      String parkingArea,
      String address,
      String qrImage,
      dynamic file // Pass the file as File object
      ) async {
    final url = Uri.parse('$baseUrl/upload_parking_owner_details');

    // Create multipart request
    var request = http.MultipartRequest('POST', url);

    // Add text fields
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['mobile'] = mobile;
    request.fields['gender'] = gender;
    request.fields['group_name'] = groupName;
    request.fields['parking_area'] = parkingArea;
    request.fields['address'] = address;
    request.fields['qr_image'] = qrImage;

    if (file != null) {
      if (kIsWeb) {
        // Handle file upload for web (using bytes)
        Uint8List fileBytes = file.bytes;
        var mimeType = lookupMimeType('', headerBytes: fileBytes);

        var multipartFile = http.MultipartFile.fromBytes(
          'licence_file', // This should match the field in the Node.js API
          fileBytes,
          filename: 'uploaded_file', // You can customize the filename
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );
        request.files.add(multipartFile);
      } else {
        // Handle file upload for mobile/desktop (using path)
        var mimeType = lookupMimeType(file.path);
        var fileStream = http.ByteStream(Stream.castFrom(file.openRead()));
        var fileLength = await file.length();

        var multipartFile = http.MultipartFile(
          'licence_file',
          fileStream,
          fileLength,
          filename: basename(file.path),
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );
        request.files.add(multipartFile);
      }
    }

    try {
      // Send the request and wait for response
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        var result = json.decode(responseBody.body);
        print(result['id']);

        // Return both success status and id
        return {
          'success': result['success'] == true,
          'id': result['id'],
        };
      } else {
        throw Exception('Failed to upload profile');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  //Store Coordinator Details
  Future<void> storeCoordinatorDetails({
    required String name,
    required String number,
    required String email,
    required String parkingArea,
    required String groupName,
    required int parkingId,
    dynamic selectedFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/coordinator_detail_register');
      final body = json.encode({
        'name': name,
        'number': number,
        'email': email,
        'parkingArea': parkingArea,
        'groupName': groupName,
        'parkingId': parkingId,
        'selectedFile': {
          'name': selectedFile?.name,
          'size': selectedFile?.size,
          'data': base64Encode(selectedFile?.bytes),
        },
      });
      final headers = {"Content-Type": "application/json"};

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Coordinator details stored successfully');
      } else {
        throw Exception('Failed to store details');
      }
    } catch (error) {
      print('Error storing coordinator details: $error');
    }
  }
  Future<void> scanBikeEntry({required String numberPlate}) async {

    final response = await http.post(
      Uri.parse('$baseUrl/bike-entry'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"number_plate": numberPlate}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Bike entry recorded: ${jsonResponse['data']}')),
      );
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Failed to record entry')),
      );
    }
  }
  Future<void> scanBikeExit({required String numberPlate}) async {

    final response = await http.post(
      Uri.parse('$baseUrl/bike-exit'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"number_plate": numberPlate}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final charge = jsonResponse['data']['charge'];
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Exit recorded. Total charge: ₹$charge')),
      );
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Failed to record exit')),
      );
    }
  }
}
