import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_system/Service/database_service.dart';

class CoordinatorDetailsPage extends StatefulWidget {
  final String groupName;
  final String parkingArea;
  final int id;

  const CoordinatorDetailsPage({super.key,
    required this.groupName,
    required this.parkingArea,
    required this.id,
  });

  @override
  State<CoordinatorDetailsPage> createState() => _CoordinatorDetailsPageState();
}

class _CoordinatorDetailsPageState extends State<CoordinatorDetailsPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _email = TextEditingController();
  dynamic selectedFile;
  Widget _buildSelectedFileDisplay() {
    if (selectedFile != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
          child: ListTile(
            title: Text(selectedFile.name),
            subtitle: Text('Size: ${selectedFile.size} bytes'),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  selectedFile = null; // Clear the selected file
                });
              },
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink(); // Return an empty widget if no file is selected
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'png'], // Adjust as needed
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first; // Get the first selected file
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Coordinator Details')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group Name: ${widget.groupName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Parking Area: ${widget.parkingArea}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            //Name
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
                  controller: _name,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Name is Empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Name',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/icons/Name.svg',
                          height: 20,
                          width: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            //Number
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
                              child:
                              SvgPicture.asset('assets/icons/Phone.svg'),
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
            const SizedBox(height: 20),
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
                        child: SvgPicture.asset('assets/icons/Email.svg'),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Select File',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            _buildSelectedFileDisplay(),
            ElevatedButton(
              onPressed: () async {
                if (_name.text.isNotEmpty && _number.text.isNotEmpty && _email.text.isNotEmpty) {
                  await DatabaseService().storeCoordinatorDetails(
                    name: _name.text,
                    number: _number.text,
                    email: _email.text,
                    parkingArea: widget.parkingArea,
                    groupName: widget.groupName,
                    parkingId: widget.id,
                    selectedFile: selectedFile,
                  );
                }
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
