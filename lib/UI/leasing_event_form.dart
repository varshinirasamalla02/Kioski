// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sccm_kiosk/widgets/fx.dart';

class EventForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventFormState();
  }
}

class _EventFormState extends State<EventForm> {
  final TextEditingController _namecontroller1 = TextEditingController();
  final TextEditingController _phonecontroller1 = TextEditingController();
  final TextEditingController _feedbackcontroller1 = TextEditingController();
  final TextEditingController _namecontroller2 = TextEditingController();
  final TextEditingController _phonecontroller2 = TextEditingController();
  final TextEditingController _feedbackcontroller2 = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  // FocusNode namenode = FocusNode();
  // FocusNode phonenode = FocusNode();
  // FocusNode feedbacknode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Leasing & event query form',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey[200],
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        body: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(50),
              child: Form(
                  key: _formKey1,
                  child: Column(
                    children: [
                      const Text(
                        'Leasing query form',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                        textInputAction: TextInputAction.next,
                        //focusNode: namenode,
                        controller: _namecontroller1,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z A-Z .]')),
                        ],
                        validator: (val) => val!.isEmpty ? 'Enter Name' : null,
                        decoration:
                            fxInput('Enter Name'),
                      )),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                        textInputAction: TextInputAction.next,
                        //focusNode: phonenode,
                        controller: _phonecontroller1,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (val) =>
                            val!.length != 10 ? 'Enter Phone No' : null,
                        decoration: fxInput('Phone Number'),
                      )),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                        textInputAction: TextInputAction.next,
                        //focusNode: feedbacknode,
                        controller: _feedbackcontroller1,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z A-Z 0-9 . ,]')),
                        ],
                        validator: (val) => val!.isEmpty ? 'Enter query' : null,
                        decoration:
                            fxInput('Enter Query'),
                      )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: ElevatedButton(
                              onPressed: () async {
                                final form = _formKey1.currentState!;
                                if (form.validate()) {
                                  form.save();
                                  // showDialog(
                                  //     barrierDismissible: true,
                                  //     context: context,
                                  //     builder: (context) {
                                  //       return const Center(
                                  //         child: CircularProgressIndicator(),
                                  //       );
                                  //     });
                                  await http.post(
                                      Uri.parse(
                                          'http://api.sccm.in/api/Kiosk/lease'),
                                      body: {
                                        'name': _namecontroller1.text,
                                        'phoneno': _phonecontroller1.text,
                                        'query': _feedbackcontroller1.text
                                      }).then((value) {
                                    if (jsonDecode(value.body)['message'] ==
                                        'Success') {
                                      _namecontroller1.clear();
                                      _phonecontroller1.clear();
                                      _feedbackcontroller1.clear();
                                      // Navigator.of(context).pop();
                                      Fluttertoast.showToast(
                                          msg: 'submitted successfully');
                                    }
                                  });
                                }
                              },
                              child: const Text('Submit')))
                    ],
                  )),
            )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(50),
              child: Form(
                  key: _formKey2,
                  child: Column(
                    children: [
                      const Text(
                        'Event query form',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                        textInputAction: TextInputAction.next,
                        //focusNode: namenode,
                        controller: _namecontroller2,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z A-Z .]')),
                        ],
                        validator: (val) => val!.isEmpty ? 'Enter Name' : null,
                        decoration:
                            fxInput('Enter Name'),
                      )),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                        textInputAction: TextInputAction.next,
                        //focusNode: phonenode,
                        controller: _phonecontroller2,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (val) =>
                            val!.length != 10 ? 'Enter Phone No' : null,
                        decoration: fxInput('Phone Number'),
                      )),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                        textInputAction: TextInputAction.next,
                        //focusNode: feedbacknode,
                        controller: _feedbackcontroller2,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-z A-Z 0-9 . ,]')),
                        ],
                        validator: (val) => val!.isEmpty ? 'Enter query' : null,
                        decoration:
                            fxInput('Enter Query'),
                      )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: ElevatedButton(
                              onPressed: () async {
                                final form = _formKey2.currentState!;
                                if (form.validate()) {
                                  form.save();
                                  // showDialog(
                                  //     barrierDismissible: true,
                                  //     context: context,
                                  //     builder: (context) {
                                  //       return const Center(
                                  //         child: CircularProgressIndicator(),
                                  //       );
                                  //     });
                                  await http.post(
                                      Uri.parse(
                                          'http://api.sccm.in/api/Kiosk/enquiry'),
                                      body: {
                                        'name': _namecontroller2.text,
                                        'phoneno': _phonecontroller2.text,
                                        'query': _feedbackcontroller2.text
                                      }).then((value) {
                                    if (jsonDecode(value.body)['message'] ==
                                        'Success') {
                                      _namecontroller2.clear();
                                      _phonecontroller2.clear();
                                      _feedbackcontroller2.clear();
                                      // Navigator.of(context).pop();
                                      Fluttertoast.showToast(
                                          msg: 'submitted successfully');
                                    }
                                  });
                                }
                              },
                              child: const Text('Submit')))
                    ],
                  )),
            ))
          ],
        ));
  }
}