import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:email_validator/email_validator.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:image_picker/image_picker.dart';

import '../GoogleApi/cloud_api.dart';

class ParkingAreaRegister extends StatefulWidget {
  const ParkingAreaRegister({super.key});

  @override
  State<ParkingAreaRegister> createState() => _ParkingAreaRegisterState();
}

class _ParkingAreaRegisterState extends State<ParkingAreaRegister> {
  final TextEditingController _group = TextEditingController();
  final TextEditingController _parkingArea = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _geoLocation = TextEditingController();
  final TextEditingController _ownerName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _number = TextEditingController();

  String? _gender;
  GlobalKey<AutoCompleteTextFieldState<String>> autoCompleteKey =
  GlobalKey<AutoCompleteTextFieldState<String>>();

  CloudApi? cloudApi;
  bool _uploading = false;
  String? _downloadUrl;

  @override
  void initState(){
    super.initState();
    _loadCloudApi();

  }

  Future<void> _loadCloudApi() async {
    String jsonCredentials = await rootBundle
        .loadString('assets/GoogleJson/clean-emblem-394910-8dd84a4022c3.json');
    setState(() {
      cloudApi = CloudApi(jsonCredentials);
    });
  }
  Future<void> _pickAndUploadImage() async {
    setState(() {
      _uploading = true; // Start uploading, show progress indicator
    });

    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file picked')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    if (cloudApi == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud API not initialized')),
      );
      setState(() {
        _uploading = false; // Cancel upload, hide progress indicator
      });
      return;
    }

    Uint8List imageBytes = await pickedFile.readAsBytes();
    String fileName = pickedFile.name; // Provide a default name

    try {
      await cloudApi!.save(fileName, imageBytes);
      final downloadUrl = await cloudApi!.getDownloadUrl(fileName);

      // Store the image bytes to display it
      setState(() {
        _downloadUrl = downloadUrl;
        _uploading = false; // Upload finished, hide progress indicator
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      setState(() {
        _uploading = false; // Error in upload, hide progress indicator
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Owner Details'),
      ),
      body: Form(
        key: autoCompleteKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              //Owner Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _ownerName,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Owner Name is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Owner Name',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset('assets/icons/Name.svg',height: 20,width: 20,),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Phone Number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff1D1617).withOpacity(0.11),
                              blurRadius: 40,
                              spreadRadius: 0.0,
                            )
                          ],
                          color: const Color.fromRGBO(247, 247, 249, 1),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: const CountryCodePicker(
                          onChanged: print,
                          initialSelection: 'IN',
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          favorite: ['IN'],
                          enabled: true,
                          hideMainText: false,
                          showFlagMain: true,
                          showFlag: true,
                          hideSearch: false,
                          showFlagDialog: true,
                          alignLeft: true,
                          padding: EdgeInsets.all(1.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff1D1617).withOpacity(0.11),
                              blurRadius: 40,
                              spreadRadius: 0.0,
                            )
                          ],
                          color: const Color.fromRGBO(247, 247, 249, 1),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10)
                          ],
                          controller: _number,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return "Number is Empty";
                            } else if (text.length <= 9) {
                              return "Put the 10 Digit Number";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Mobile Number',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                    'assets/icons/Phone.svg'),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              //Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _email,
                    validator: (text) {
                      if (text != null && !EmailValidator.validate(text)) {
                        return "Enter Valid Mail";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Email',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(9),
                          child: SvgPicture.asset(
                              'assets/icons/Email.svg'),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Gender
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
                    items: ['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Gender',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/Gender.svg',height: 20,width: 20,),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _group,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Group Name is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Group Name',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/Group_Name.svg'),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Parking Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _parkingArea,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Parking Area is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Parking Area',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                            'assets/icons/Parking.svg',fit: BoxFit.scaleDown),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Address
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1D1617).withOpacity(0.11),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      )
                    ],
                    color: const Color.fromRGBO(247, 247, 249, 1),
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _address,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Address is Empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: 'Address',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(9),
                          child: SvgPicture.asset(
                              'assets/icons/Address.svg',height: 20,width: 20,),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              //Upload Qr Photo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _uploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Upload QR Photo',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_downloadUrl != null)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Uploaded Image:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.network(
                        _downloadUrl!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}


