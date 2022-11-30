import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:raghusharan/models/person.dart';
import 'package:intl/intl.dart';


class UpdatePersonForm extends StatefulWidget {
  final int index;
  final Person person;

  const UpdatePersonForm({
    required this.index,
    required this.person,
  });

  @override
  _UpdatePersonFormState createState() => _UpdatePersonFormState();
}

class _UpdatePersonFormState extends State<UpdatePersonForm> {
  final _personFormKey = GlobalKey<FormState>();

  late final _nameController;
  late final _phonenumberController;
  late final _emailController;
  late final _dobController;
  late final id;
  late final image;
  bool hasInternet =false;

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

  // Update info of people box
  _updateInfo() {
    Person newPerson = Person(
      name: _nameController.text,
      phonenumber: _phonenumberController.text,
      email: _emailController.text,
      dob: _dobController.text,
      id: id,
      status: hasInternet == true ? "Stored Remotely" : "Stored Locally",
      imageUrl: image,
    );

    box.putAt(widget.index, newPerson);

    print('Info updated in box!');
  }

  @override
  void initState() {
    super.initState();
    // Get reference to an already opened box
    box = Hive.box('peopleBox');
    _nameController = TextEditingController(text: widget.person.name);
    _phonenumberController = TextEditingController(text: widget.person.phonenumber);
    _emailController = TextEditingController(text: widget.person.email);
    _dobController = TextEditingController(text: widget.person.dob);
    id = widget.person.id;
    image = widget.person.imageUrl;
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
          Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 24.0),
            child: Container(
              width: double.maxFinite,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  hasInternet = await InternetConnectionChecker().hasConnection;

                  if (_personFormKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        title: Icon(
                          Icons.update_rounded,
                          color: Colors.blue,
                        ),
                        content: Text(
                          "User Updated Successfully",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue,
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
                              color: Colors.blue,
                              onPressed: () {
                                _updateInfo();
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
                child: Text('Update'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
