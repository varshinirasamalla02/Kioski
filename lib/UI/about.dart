// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutState();
  }
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'About',
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
        body: const SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            '''
Sarath City Capital Mall is situated in the busy neighborhood of Hyderabad’s technology corridor – Hi-Tech City ,Gachibowli – Miyapur Road that serves the entire cosmopolitan community of this part of Hyderabad.

It rises 8 floors into the sky and each floor is a humongous 27,00,000 square feet in expanse. That makes the mall retail space 19,31,000 square feet. The largest in the nation of India!

Plus, it has a parking space for 1400 cars and 4000 bikes over four levels of parking amounting to another 10,00,000 square feet. It has a clear carpet space of 12,79,000 square feet for over 430 brands across fashion, accessories, fresh food and grocery, footwear, luggage, time wear, collectibles, digital fashion, electronics, wellness, jewelry, food and beverage and gifts. It has lots of space devoted to Home and Home Décor and fast turning out to be the home for Entertainment and Adventure.

Sarath City Capital Mall has everything from Prestigious International brands to Local Niche brands that serves the customer in various ways. The mall features AMB Cinemas, a luxury 7 screen multiplex co-owned by Asian Cinemas and Mahesh Babu, the Telugu cinema superstar. The mall is seeing a flock of new brands opening stores every week.

BAZAAR, an elegantly designed market place where you could find quaint curious and everyday items is now open. Very interesting propositions have booked space within and this location will be a major hotspot. Several other attractions of the mall include Tridom – the Indoor Adventure Park, Sky zone – The Trampoline Park, Ski Capital – the Snow theme Park in large spaces and many more making the mall the most happening destination.

Two food courts are in the mall . One, on the Lower Ground floor and another on the Fourth floor serving over 1000 customers at one go. Also, an expanse of premium restaurants is slated to open over the next 6 months. A Microbrewery,Night Clubs,Lounges and a convention center are in works too.

Co-working spaces are planned on the top floor overlooking the entire city. The crowning glory shall be a 900-seater open air auditorium on the fifth-floor hosting music and culture festivals.

It is going to better over the months to come!

Sarath City Capital Mall is promoted by Mr. Sarath Gopal Boppana and Skill Promoters Private Limited- Mr. Aslam Syed & Mr. Naveed Syed. Their vision and hard work are showing results for all to see and enjoy.
''',
            textAlign: TextAlign.justify,
          ),
        )));
  }
}