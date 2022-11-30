import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:raghusharan/models/person.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:image_picker/image_picker.dart';


class AddPersonForm extends StatefulWidget {
  const AddPersonForm({Key? key}) : super(key: key);

  @override
  _AddPersonFormState createState() => _AddPersonFormState();
}

class _AddPersonFormState extends State<AddPersonForm> {
  final _nameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  bool hasInternet =false;
  String? _imageFile;  // picked image will be store here.
  final ImagePicker _picker = ImagePicker(); //
  String id = "#UId" + DateTime.now().microsecondsSinceEpoch.toString().substring(8,16);

  final _personFormKey = GlobalKey<FormState>();

  late final Box box;

  String? _fieldNameValidator(String? value) {
    if (value == null || value.isEmpty || value.length < 3) {
      return 'Name must be more than 2 charater';
    }
    return null;
  }

  String? _fieldPhoneNumberValidator(String? value) {
    if (value!.length != 10) {
      return 'please enter valid number';
    }
    return null;
  }

  // Add info to people box
  _addInfo() async {
    Person newPerson = Person(
      name: _nameController.text,
      phonenumber: _phonenumberController.text,
      email: _emailController.text,
      dob: _dobController.text,
      id: id,
      status: hasInternet == true ? "Stored Remotely" : "Stored Locally",
      imageUrl: _imageFile.toString(),
    );
    box.add(newPerson);
    print('Info added to box!');
  }

  @override
  void initState() {
    super.initState();
    box = Hive.box('peopleBox');
  }

  void _pickImageBase64() async{
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      Uint8List imagebytes = await image.readAsBytes();
      String _base64String = base64.encode(imagebytes);
      print(_base64String);

      final imageTemp = File(image.path);
      setState(() {
        this._imageFile = _base64String;   // setState to image the UI and show picked image on screen.
      });
    }on PlatformException catch (e){
      if (kDebugMode) {
        print('error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _personFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              hintText: "Enter name here.....",
              labelText: "Name *",
            ),
            controller: _nameController,
            validator: _fieldNameValidator,
            maxLength: 15,
          ),
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              hintText: "Enter PhoneNumber here.....",
              labelText: "PhoneNumber *"
            ),
            controller: _phonenumberController,
            validator: _fieldPhoneNumberValidator,
            maxLength: 10,
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              hintText: "Enter Email here.....",
              labelText: "Email *"
            ),
            controller: _emailController,
            validator: (value){
              if(value!.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)){
                return "Enter Correct Email Address";
              }else{
                return null;
              }
            },
            maxLength: 25,
          ),
          TextFormField(
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.black,
                    width: 1.5),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              hintText: "Enter DOB here.....",
              labelText: "DOB",
            ),
            controller: _dobController,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1800),
                  //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime.now());

              if (pickedDate != null) {
                print(
                    pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                DateFormat('yyyy-MM-dd').format(pickedDate);
                print(
                    formattedDate); //formatted date output using intl package =>  2021-03-16
                setState(() {
                  _dobController.text =
                      formattedDate; //set output date to TextField value.
                });
              } else {

              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 24.0),
            child: Container(
              width: double.maxFinite,
              height: 50,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all( _imageFile != null ? Colors.green: Colors.red),
                ),
                onPressed: () => _pickImageBase64(),
                child: Text(_imageFile != null ? 'Profile picture picked successfully':'Pick profile picture'),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 18.0),
            child: Container(
              width: double.maxFinite,
              height: 45,
              child: ElevatedButton(
                onPressed: () async{
                 hasInternet = await InternetConnectionChecker().hasConnection;
                  if (_personFormKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        title: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        content: Text(
                          "User Added Successfully",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'Gilroy-Bold',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: <Widget>[
                          Center(
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              color: Colors.green,
                              onPressed: () {
                                _addInfo();
                                Navigator.of(ctx).pop();
                                Navigator.of(ctx).pop();
                              },
                              child: Text(
                                "Ok",
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Gilroy'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text('Add'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
