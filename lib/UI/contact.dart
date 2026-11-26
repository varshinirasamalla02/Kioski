import 'package:flutter/material.dart';
import 'package:sccm_kiosk/models/contact_model.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class Contact extends StatefulWidget {
  ContactModel contactdata;
  Contact(this.contactdata);
  @override
  State<StatefulWidget> createState() {
    return ContactState(contactdata);
  }
}

class ContactState extends State<Contact> {
  ContactUsModel model1 = ContactUsModel(
      "MALL ENQUIRIES", "SHAZIA", "+919652572307", "execops@skillpromoters.co");
  ContactUsModel model2 = ContactUsModel("BRANDING & PROMOTION", "ASIM MUMTAZ",
      "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model3 = ContactUsModel("EVENT QUERIES", "ASIM MUMTAZ",
      "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model4 = ContactUsModel("DIGITAL ADS/SALES", "ASIM MUMTAZ",
      "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model5 = ContactUsModel("MALL LEASING", "VENU GOPAL",
      "+916300616394 & +917288036955", "venugopal.g@skillpromoters.co");
  ContactUsModel model6 = ContactUsModel("SPECIAL/CUSTOM EVENTS", "ASIM MUMTAZ",
      "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model7 = ContactUsModel("COLLABORATION & PARTNERSHIPS",
      "ASIM MUMTAZ", "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model8 = ContactUsModel("CHARITIES & PARTNERSHIPS(EVENTS)",
      "ASIM MUMTAZ", "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model9 = ContactUsModel("DEALS & OFFERS", "SMM TEAM", "",
      "socialmedia@sarathcitycapitalmall.com");
  ContactUsModel model10 = ContactUsModel(
      "SOCIAL MEDIA", "SMM TEAM", "", "socialmedia@sarathcitycapitalmall.com");
  ContactUsModel model11 = ContactUsModel("CINEMA SHOOTING", "ASIM MUMTAZ",
      "+919246104727", "asim@skillpromoters.co");
  ContactUsModel model12 = ContactUsModel("KIOSK LEASING QUERIES", "VENU GOPAL",
      "+916300616394 & +917288036955", "venugopal.g@skillpromoters.co");
  ContactUsModel model13 =
      ContactUsModel("CAREERS", "HR", "", "info@sarathcitycapitalmall.com");
  ContactUsModel model14 =
      ContactUsModel("The Bazaar", "Mr. Himayat", "+91 92468 39014", "");
  //List<ContactUsModel> contactdetails = [];
  ContactModel contactdata;
  ContactState(this.contactdata);

  @override
  void initState() {
    super.initState();
    // contactdetails.add(model1);
    // contactdetails.add(model2);
    // contactdetails.add(model3);
    // contactdetails.add(model4);
    // contactdetails.add(model5);
    // contactdetails.add(model6);
    // contactdetails.add(model7);
    // contactdetails.add(model8);
    // contactdetails.add(model9);
    // contactdetails.add(model10);
    // contactdetails.add(model11);
    // contactdetails.add(model12);
    // contactdetails.add(model13);
    // contactdetails.add(model14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Contact Details',
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
      body: GridView.count(
          primary: true,
          padding: const EdgeInsets.all(35.0),
          crossAxisCount: 2,
          childAspectRatio: 5.30,
          //mainAxisSpacing: 1.0,
          //crossAxisSpacing: 1.0,
          children: List.generate(contactdata.list!.length, (index) {
            return FadeSlideIn(delay: Duration(milliseconds: 45 * (index % 14)), child: FxCard(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    color: Colors.purple[300],
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          contactdata.list![index].title.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ))),
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name : ${contactdata.list![index].name}'),
                        Text('Phone No: ${contactdata.list![index].phoneno}'),
                        Text('Email: ${contactdata.list![index].email}')
                      ],
                    ))
              ],
            )));
          })),
    );
  }
}

class ContactUsModel {
  String title;
  String name;
  String phone;
  String email;
  ContactUsModel(this.title, this.name, this.phone, this.email);
}