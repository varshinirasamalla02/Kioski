import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show FontFeature;

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sccm_kiosk/UI/about.dart';
import 'package:sccm_kiosk/UI/category.dart';
import 'package:sccm_kiosk/UI/contact.dart';
import 'package:sccm_kiosk/UI/dine.dart';
import 'package:sccm_kiosk/UI/events.dart';
import 'package:sccm_kiosk/UI/feedback.dart';
import 'package:sccm_kiosk/UI/floor_maps.dart';
import 'package:sccm_kiosk/UI/leasing_event_form.dart';
import 'package:sccm_kiosk/UI/navigation.dart';
import 'package:sccm_kiosk/UI/offers.dart';
import 'package:sccm_kiosk/UI/services.dart';
import 'package:sccm_kiosk/models/all_offers_model.dart';
import 'package:sccm_kiosk/models/contact_model.dart';
import 'package:sccm_kiosk/models/events_model.dart';
import 'package:sccm_kiosk/models/floor_maps_model.dart';
import 'package:sccm_kiosk/models/kiosk_data_model.dart';
import 'package:sccm_kiosk/models/service_model.dart';
import 'package:sccm_kiosk/utils/databse.dart';
import 'package:sccm_kiosk/utils/eventdatabase.dart';
import 'package:sccm_kiosk/utils/offersdatabase.dart';
import 'package:sccm_kiosk/utils/provider.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class Homepage1 extends StatefulWidget {
  ServiceModel servicedata;
  ContactModel contactdata;
  FloorMapsModel floorMapsModel;
  Homepage1(this.servicedata, this.contactdata, this.floorMapsModel);
  //Homepage1({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState(servicedata, contactdata, floorMapsModel);
  }
}

class HomePageState extends State<Homepage1> with TickerProviderStateMixin {
  //final FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool notifications = false;
  final dbbeacon = DatabaseBeacon.instance;
  final offerdb = OffersDatabase.instance;
  final eventdb = EventDatabase.instance;
  late Kioskdata kioskdata;
  late AllOfers alloffers;
  late EventsModel allevents;
  // late final AnimationController _controller = AnimationController(
  //   duration: const Duration(seconds: 2),
  //   vsync: this,
  // )..repeat(reverse: true);
  // late final Animation<double> _animation = CurvedAnimation(
  //   parent: _controller,
  //   curve: Curves.elasticOut,
  // );
  bool rotation = false;
  late Timer _timer;
  DateTime _dateTime = DateTime.now();
  ServiceModel servicedata;
  ContactModel contactdata;
  FloorMapsModel floorMapsModel;
  HomePageState(this.servicedata, this.contactdata, this.floorMapsModel);
  var month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  var days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  int counttoexit = 0;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _dateTime = DateTime.now();

      setState(() {});
    });

    // messaging.getToken().then((value) {});

    // initfirebase();
    // getdata();
    // getofferdata();
    // geteventdata();
  }

  @override
  void dispose() {
    //_controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  initfirebase() {
    // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //   setState(() {
    //     notifications = true;
    //   });
    // });
  }

  getdata() async {
    _delete();
    await http.get(Uri.parse('http://api.sccm.in/api/Kiosk/All')).then((value) {
      if (value.statusCode == 200) {
        final jsondecode = jsonDecode(value.body);
        kioskdata = Kioskdata.fromJson(jsondecode);
        kioskdata.list!.forEach((element) {
          _insert(
              element.storeID,
              element.name,
              element.logo,
              element.floor,
              element.entity,
              element.email,
              element.contactno,
              element.offers,
              element.keywords,
              element.open,
              element.close,
              element.categoryID,
              element.categoryName,
              element.image,
              element.offerscount);
        });
      }
    });
  }

  getofferdata() async {
    _deleteoffers();
    await http
        .get(Uri.parse('http://api.sccm.in/api/Kiosk/Offers'))
        .then((value) {
      if (value.statusCode == 200) {
        final jsondecode = jsonDecode(value.body);
        alloffers = AllOfers.fromJson(jsondecode);
        alloffers.list!.forEach((element) {
          _insertoffers(
              element.offerID,
              element.storeID,
              element.store,
              element.categoryID,
              element.offerName,
              element.itemImages,
              element.itemPromo,
              element.itemDetails,
              element.imageUrl,
              element.promo,
              element.startDate,
              element.endDate,
              element.floor);
        });
      }
    });
  }

  geteventdata() async {
    _deleteevents();
    await http
        .get(Uri.parse('http://api.sccm.in/api/Kiosk/Events'))
        .then((value) {
      if (value.statusCode == 200) {
        final jsondecode = jsonDecode(value.body);
        allevents = EventsModel.fromJson(jsondecode);
        allevents.list!.forEach((element) {
          _insertevents(
              element.eventID,
              element.eventName,
              element.description,
              element.imageUrl,
              element.startDate,
              element.endDate,
              element.websiteUrl,
              element.contactNo,
              element.ageGroup,
              element.openTime,
              element.closeTime,
              element.sponsored,
              element.eventType);
        });
      }
    });
  }

  rotationtimer() {
    setState(() {
      rotation = false;
    });
  }

  double width = 0.0;
  double height = 0.0;
  ProviderClass? providermodel;

  String _two(int n) => n.toString().padLeft(2, '0');

  String _ordinal(int d) {
    if (d >= 11 && d <= 13) return '${d}th';
    switch (d % 10) {
      case 1:
        return '${d}st';
      case 2:
        return '${d}nd';
      case 3:
        return '${d}rd';
      default:
        return '${d}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    providermodel = Provider.of<ProviderClass>(context);
    final size = MediaQuery.of(context).size;
    final eng = providermodel!.languagetype == 'english';

    void open(Widget page) => Navigator.of(context).push(fadeRoute(page));

    final items = <_MenuItem>[
      _MenuItem(eng ? 'Store Directory' : 'स्टोर निर्देशिका',
          'assets/png/Store.png', const Color(0xFFFF3F52),
          tint: const Color(0xFFFF3F52),
          onTap: () => open(Categories(dbbeacon))),
      _MenuItem(eng ? 'Navigation' : 'मार्गदर्शन', 'assets/png/gps.png',
          const Color(0xFF22C55E),
          tint: Colors.red, onTap: () => open(const Navigation())),
      _MenuItem(eng ? 'Floor Maps' : 'मंजिल के नक्शे', 'assets/png/Browse.png',
          const Color(0xFF3B82F6),
          onTap: () => open(FloorMaps(floorMapsModel))),
      _MenuItem(eng ? 'Offers' : 'ऑफर', 'assets/png/Discount.png',
          const Color(0xFFF59E0B),
          tint: Colors.red, onTap: () => open(Offers(offerdb))),
      _MenuItem(eng ? 'Dining' : 'भोजन', 'assets/png/Tas.png',
          const Color(0xFFEF4444),
          onTap: () => open(DineDashboard(dbbeacon))),
      // Rewards and Features had their navigation commented out in the
      // original app, so they stay inactive (shown dimmed).
      _MenuItem(eng ? 'Rewards' : 'पुरस्कार', 'assets/png/Gift.png',
          const Color(0xFFA855F7)),
      _MenuItem(eng ? 'Features' : 'विशेषताएँ', 'assets/png/Mobile Shop.png',
          const Color(0xFF06B6D4)),
      _MenuItem(eng ? 'Events' : 'कार्यक्रम', 'assets/png/Annoucement.png',
          const Color(0xFFF97316),
          onTap: () => open(Events(eventdb))),
      _MenuItem(eng ? 'Contact' : 'संपर्क', 'assets/png/Chat.png',
          const Color(0xFFEAB308),
          onTap: () => open(Contact(contactdata))),
      _MenuItem(eng ? 'Services' : 'सेवाएं', 'assets/png/Truck.png',
          const Color(0xFF6366F1),
          onTap: () => open(Services(servicedata, floorMapsModel))),
      _MenuItem(eng ? 'Feedback' : 'प्रतिक्रिया', 'assets/png/Review.png',
          const Color(0xFFEC4899),
          onTap: () => open(FeedBack())),
      _MenuItem(eng ? 'Leasing & event query' : 'लीजिंग और इवेंट पूछताछ',
          'assets/png/Guarantee.png', const Color(0xFF10B981),
          onTap: () => open(EventForm())),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF05060F),
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground()),
          Row(
            children: [
              Expanded(flex: 70, child: _buildMenuPanel(size, items, eng)),
              Expanded(flex: 30, child: _buildInfoPanel(size)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPanel(Size size, List<_MenuItem> items, bool eng) {
    const gap = 16.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeSlideIn(
            child: Text(
              'WELCOME TO INDIA\'S LARGEST SHOPPING MALL',
              style: TextStyle(
                  color: Colors.white70, letterSpacing: 3, fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedHeadline(
            'Sarath City Capital Mall',
            delay: const Duration(milliseconds: 200),
            style: TextStyle(
              color: Colors.white,
              fontSize: size.height * 0.055,
              fontWeight: FontWeight.w900,
            ),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 700),
            child: Text(
              eng ? 'What are you looking for ?' : 'आप क्या ढूंढ रहे हैं ?',
              style: TextStyle(
                color: const Color(0xFFE9C46A),
                fontSize: size.height * 0.03,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final tileW = (c.maxWidth - gap * 3) / 4;
                final tileH = (c.maxHeight - gap * 2) / 3;
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: gap,
                    crossAxisSpacing: gap,
                    childAspectRatio: tileW / tileH,
                  ),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final enabled = item.onTap != null;
                    return FadeSlideIn(
                      delay: Duration(milliseconds: 400 + 80 * i),
                      offset: const Offset(0, 0.25),
                      child: Floating(
                        phase: i * 0.11,
                        amplitude: 4,
                        child: TapScale(
                          onTap: item.onTap,
                          child: Opacity(
                            opacity: enabled ? 1 : 0.55,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.accent.withOpacity(0.35),
                                    blurRadius: 26,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      item.asset,
                                      fit: BoxFit.contain,
                                      color: item.tint,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.label,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: size.height * 0.024,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1B1B2F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const FadeSlideIn(
            delay: Duration(milliseconds: 1400),
            child: Center(
              child: Text(
                'A SKILL PROMOTERS ENTERPRISE',
                style: TextStyle(
                    color: Colors.white54, letterSpacing: 3, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _social(Size size, String asset, String handle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Image.asset(asset, width: size.height * 0.032),
        ),
        const SizedBox(width: 10),
        Text(handle,
            style: TextStyle(
                color: Colors.white, fontSize: size.height * 0.018)),
      ],
    );
  }

  Widget _buildInfoPanel(Size size) {
    final t = _dateTime;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 22, 28, 14),
      child: FadeSlideIn(
        offset: const Offset(0.12, 0),
        delay: const Duration(milliseconds: 250),
        child: GlassCard(
          radius: 32,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: SizedBox(
                  height: size.height * 0.09,
                  child:
                      Image.asset('assets/mall_logo.png', fit: BoxFit.contain),
                ),
              ),
              Column(
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${_two(t.hour)}:${_two(t.minute)}',
                      children: [
                        TextSpan(
                          text: ':${_two(t.second)}',
                          style: TextStyle(
                              fontSize: size.height * 0.035,
                              color: Colors.white60),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: size.height * 0.07,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '${_ordinal(t.day)} ${month[t.month - 1]} ${t.year}, ${days[t.weekday - 1]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70, fontSize: size.height * 0.022),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('SCAN HERE TO DOWNLOAD',
                      style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontSize: size.height * 0.015)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Image.asset('assets/scan_here_image.png',
                        width: size.height * 0.15),
                  ),
                  const SizedBox(height: 8),
                  Text('Available now',
                      style: TextStyle(
                          color: Colors.white, fontSize: size.height * 0.018)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/android_gplay_icon.png',
                          height: size.height * 0.05),
                      const SizedBox(width: 14),
                      Image.asset('assets/ios_iplay_icon.png',
                          height: size.height * 0.05),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  _social(size, 'assets/facebook_icon.png',
                      '@sarathcitycapitalmall'),
                  const SizedBox(height: 8),
                  _social(
                      size, 'assets/insta_icon.png', '@sarathcitycapitalmall'),
                  const SizedBox(height: 8),
                  _social(size, 'assets/twitter_icon.png',
                      '@sarathcitycapitalmall'),
                ],
              ),
              InkWell(
                onTap: () {
                  counttoexit++;
                  if (counttoexit == 14) {
                    exit(0);
                  }
                },
                child: Text('www.sarathcitycapitalmall.com',
                    style: TextStyle(
                        color: Colors.white54, fontSize: size.height * 0.016)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insert(
      storeid,
      name,
      logo,
      floor,
      entity,
      email,
      contactno,
      offers,
      keyword,
      open,
      close,
      categoryid,
      categoryname,
      image,
      offerscount) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseBeacon.storeid: storeid,
      DatabaseBeacon.storename: name,
      DatabaseBeacon.storelogo: logo,
      DatabaseBeacon.storefloor: floor,
      DatabaseBeacon.storeentity: entity,
      DatabaseBeacon.storeemail: email,
      DatabaseBeacon.storecontactno: contactno,
      DatabaseBeacon.storeoffers: offers,
      DatabaseBeacon.storekeywords: keyword,
      DatabaseBeacon.storeopen: open,
      DatabaseBeacon.storeclose: close,
      DatabaseBeacon.storecategoryid: categoryid,
      DatabaseBeacon.storecategoryname: categoryname,
      DatabaseBeacon.storecategoryimage: image,
      DatabaseBeacon.storeofferscount: offerscount
    };
    final id = await dbbeacon.insert(row);

    // dynamic allrowsdata = await dbbeacon.queryAllRows();
    // setState(() {
    //   this.allrows = allrowsdata;
    // });
    // _controller.clear();
    // print('query all rows:');
    // // allRows.forEach(print);
    // print('inserted row id: $id');
    // this.allrows.forEach(print);
  }

  void _insertoffers(offerid, storeid, storename, catid, offername, itemimage,
      itempro, itemdetails, imageurl, promo, startdate, enddate, floor) async {
    // row to insert
    Map<String, dynamic> row = {
      OffersDatabase.colofferId: offerid,
      OffersDatabase.colstoreid: storeid,
      OffersDatabase.colstore: storename,
      OffersDatabase.colcatid: catid,
      OffersDatabase.coloffername: offername,
      OffersDatabase.colimage: itemimage,
      OffersDatabase.colitempromo: itempro,
      OffersDatabase.colitemdetails: itemdetails,
      OffersDatabase.colimageurl: imageurl,
      OffersDatabase.colpromo: promo,
      OffersDatabase.colstartdate: startdate,
      OffersDatabase.colenddate: enddate,
      OffersDatabase.colfloor: floor
    };
    final id = await offerdb.insert(row);
  }

  void _insertevents(eventid, eventname, desc, url, startdate, enddate, website,
      contact, agegroup, opentime, closetime, sponserd, eventtype) async {
    // row to insert
    Map<String, dynamic> row = {
      EventDatabase.coleventid: eventid,
      EventDatabase.coleventname: eventname,
      EventDatabase.coldesc: desc,
      EventDatabase.colimage: url,
      EventDatabase.colstartdate: startdate,
      EventDatabase.colenddate: enddate,
      EventDatabase.colwebsite: website,
      EventDatabase.colcontact: contact,
      EventDatabase.colagegroup: agegroup,
      EventDatabase.colopentime: opentime,
      EventDatabase.colclosetime: closetime,
      EventDatabase.colsponsered: sponserd,
      EventDatabase.coleventtype: eventtype
    };
    final id = await eventdb.insert(row);
  }

  void _query() async {
    dynamic allrowsdata = await dbbeacon.queryAllRows();
    //print('allrow data$allrowsdata');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    //final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbbeacon.delete();
  }

  void _deleteoffers() async {
    await offerdb.delete();
  }

  void _deleteevents() async {
    await eventdb.delete();
  }

  // void _update(double rssi, String major, String minor) async {
  //   // row to update
  //   // Map<String, dynamic> row = {
  //   //   DatabaseBeacon.columnmajor: major,
  //   //   DatabaseBeacon.columnarssi: rssi,
  //   //   DatabaseBeacon.columnstore: store,
  //   //   DatabaseBeacon.columnpromo: promo,
  //   //   DatabaseBeacon.columnstart: startdate,
  //   //   DatabaseBeacon.columnend: enddate,
  //   //   DatabaseBeacon.columnimage: image
  //   // };

  //   final rowsAffected = await dbbeacon.update(rssi, major, minor);
  //   dynamic allrowsdata = await dbbeacon.queryAllRows();
  // }
}

class CurvePaintertop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.purple;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 0.50, size.height * 0.50, size.width, size.height);

    path.moveTo(size.width, size.height);

    // path.moveTo(size.width, size.height * 0.7);
    // path.quadraticBezierTo(size.width * 0.99, size.height * 0.79,
    //     size.width * 0.8, size.height * 0.8);
    // path.lineTo(size.width * 0.08, size.height * 0.8);
    // path.quadraticBezierTo(
    //     size.width * 0.001, size.height * 0.81, 0, size.height * 0.86);
    // path.lineTo(0, size.height * 0.95);
    // path.quadraticBezierTo(size.width * 0.001, size.height * 0.98,
    //     size.width * 0.08, size.height * 0.99);
    // path.lineTo(size.width * 0.8, size.height * 0.99);
    // path.quadraticBezierTo(
    //     size.width * 0.99, size.height * 0.99, size.width, size.height * 0.89);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CurvePainterbottom extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.purple;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
        size.width * 0.50, size.height * 0.50, size.width, 0);
    path.moveTo(size.width, 0);

    // path.moveTo(size.width, size.height * 0.7);
    // path.quadraticBezierTo(size.width * 0.99, size.height * 0.79,
    //     size.width * 0.8, size.height * 0.8);
    // path.lineTo(size.width * 0.08, size.height * 0.8);
    // path.quadraticBezierTo(
    //     size.width * 0.001, size.height * 0.81, 0, size.height * 0.86);
    // path.lineTo(0, size.height * 0.95);
    // path.quadraticBezierTo(size.width * 0.001, size.height * 0.98,
    //     size.width * 0.08, size.height * 0.99);
    // path.lineTo(size.width * 0.8, size.height * 0.99);
    // path.quadraticBezierTo(
    //     size.width * 0.99, size.height * 0.99, size.width, size.height * 0.89);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CurvePainterleft extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.purple;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(
        size.width * 0.50, size.height * 0.50, size.width, size.height);
    path.moveTo(size.width, size.height);

    // path.moveTo(size.width, size.height * 0.7);
    // path.quadraticBezierTo(size.width * 0.99, size.height * 0.79,
    //     size.width * 0.8, size.height * 0.8);
    // path.lineTo(size.width * 0.08, size.height * 0.8);
    // path.quadraticBezierTo(
    //     size.width * 0.001, size.height * 0.81, 0, size.height * 0.86);
    // path.lineTo(0, size.height * 0.95);
    // path.quadraticBezierTo(size.width * 0.001, size.height * 0.98,
    //     size.width * 0.08, size.height * 0.99);
    // path.lineTo(size.width * 0.8, size.height * 0.99);
    // path.quadraticBezierTo(
    //     size.width * 0.99, size.height * 0.99, size.width, size.height * 0.89);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CurvePainterright extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.purple;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
        size.width * 0.50, size.height * 0.50, 0, size.height);
    path.moveTo(0, size.height);

    // path.moveTo(size.width, size.height * 0.7);
    // path.quadraticBezierTo(size.width * 0.99, size.height * 0.79,
    //     size.width * 0.8, size.height * 0.8);
    // path.lineTo(size.width * 0.08, size.height * 0.8);
    // path.quadraticBezierTo(
    //     size.width * 0.001, size.height * 0.81, 0, size.height * 0.86);
    // path.lineTo(0, size.height * 0.95);
    // path.quadraticBezierTo(size.width * 0.001, size.height * 0.98,
    //     size.width * 0.08, size.height * 0.99);
    // path.lineTo(size.width * 0.8, size.height * 0.99);
    // path.quadraticBezierTo(
    //     size.width * 0.99, size.height * 0.99, size.width, size.height * 0.89);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _MenuItem {
  final String label;
  final String asset;
  final Color accent;
  final Color? tint;
  final VoidCallback? onTap;
  const _MenuItem(this.label, this.asset, this.accent, {this.tint, this.onTap});
}