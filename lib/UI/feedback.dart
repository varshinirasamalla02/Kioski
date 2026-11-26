import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:profanity_filter/profanity_filter.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class FeedBack extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FeedBackState();
  }
}

class _FeedBackState extends State<FeedBack> {
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _phonecontroller = TextEditingController();
  TextEditingController _feedbackcontroller = TextEditingController();
  FocusNode namenode = FocusNode();
  FocusNode phonenode = FocusNode();
  FocusNode feedbacknode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool feedback = false;
  String text = '';
  final filter = ProfanityFilter();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
          title: const Text(
            'FeedBack Form',
            style: TextStyle(color: Colors.white),
          ),
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
        body: feedback
            ? Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                    text,
                    textAlign: TextAlign.center,
                  )),
                  ElevatedButton(
                      onPressed: () {
                        _namecontroller.clear();
                        _feedbackcontroller.clear();
                        _phonecontroller.clear();
                        setState(() {
                          feedback = false;
                        });
                      },
                      child: const Text('Give another feedback')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back'))
                ],
              )
            :
            // : GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         namenode.unfocus();
            //         phonenode.unfocus();
            //         feedbacknode.unfocus();
            //       });
            //     },
            //     child:
            SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                              textInputAction: TextInputAction.next,
                              focusNode: namenode,
                              controller: _namecontroller,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-z A-Z .]')),
                              ],
                              validator: (val) =>
                                  val!.length == 0 ? 'Enter Name' : null,
                              decoration:
                                  fxInput('Enter Name'),
                            )),
                            Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                              textInputAction: TextInputAction.next,
                              focusNode: phonenode,
                              controller: _phonecontroller,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                              ],
                              validator: (val) =>
                                  val!.length != 10 ? 'Enter Phone No' : null,
                              decoration: fxInput('Phone Number'),
                            )),
                            Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(
                              textInputAction: TextInputAction.next,
                              focusNode: feedbacknode,
                              controller: _feedbackcontroller,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-z A-Z 0-9 . ,]')),
                              ],
                              validator: (val) =>
                                  val!.length == 0 ? 'Enter Feedback' : null,
                              decoration: fxInput('Feedback'),
                            )),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.03),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      // showDialog(
                                      //     barrierDismissible: true,
                                      //     context: context,
                                      //     builder: (context) {
                                      //       return Center(
                                      //         child: CircularProgressIndicator(),
                                      //       );
                                      //     });
                                      // namenode.unfocus();
                                      // phonenode.unfocus();
                                      // feedbacknode.unfocus();
                                      //setState(() {});
                                      final form = _formKey.currentState!;
                                      if (form.validate()) {
                                        form.save();
                                        bool nameprofinity = filter
                                            .hasProfanity(_namecontroller.text);
                                        bool feedbackprofinity =
                                            filter.hasProfanity(
                                                _feedbackcontroller.text);

                                        if (nameprofinity ||
                                            feedbackprofinity) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Remove profanity from the text');
                                        } else {
                                          await http.post(
                                              Uri.parse(
                                                  'http://api.sccm.in/api/Kiosk/feedback'),
                                              body: {
                                                'Name': _namecontroller.text,
                                                'ContactNo':
                                                    _phonecontroller.text,
                                                'Feedback':
                                                    _feedbackcontroller.text
                                              }).then((value) => {
                                                if (jsonDecode(value.body)[
                                                        'message'] ==
                                                    'Success')
                                                  {
                                                    setState(() {
                                                      feedback = true;
                                                      text =
                                                          'Thank you for submitting the feedback.\n Sarath City Capitalmall';
                                                    }),
                                                    // Navigator.of(context).pop(),
                                                    // Navigator.of(context).pop(),
                                                  }
                                              });
                                        }
                                      }
                                    },
                                    child: const Text('Submit')))
                          ],
                        ))),
              ));
  }
}