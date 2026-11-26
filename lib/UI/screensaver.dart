import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:convert';

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sccm_kiosk/UI/temphome.dart';
import 'package:sccm_kiosk/bloc/screensaver_block.dart';
import 'package:sccm_kiosk/models/all_offers_model.dart';
import 'package:sccm_kiosk/models/contact_model.dart';
import 'package:sccm_kiosk/models/events_model.dart';
import 'package:sccm_kiosk/models/floor_maps_model.dart';

import 'package:sccm_kiosk/models/kiosk_data_model.dart';
import 'package:sccm_kiosk/models/screen_saver_model.dart';
import 'package:sccm_kiosk/models/service_model.dart';
import 'package:sccm_kiosk/utils/databse.dart';
import 'package:sccm_kiosk/utils/eventdatabase.dart';
import 'package:sccm_kiosk/utils/offersdatabase.dart';
import 'package:http/http.dart' as http;
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/info_panel.dart';
import 'package:sccm_kiosk/widgets/indoor_map.dart';

class ScreenSaver extends StatefulWidget {
  ScreenSaver({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<ScreenSaver> with TickerProviderStateMixin {
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
  late Timer _pagetimer;
  DateTime _dateTime = DateTime.now();

  bool progress = false;
  final bloc = Screensaverbloc();
  ContactModel contactdata = ContactModel();
  ServiceModel serviceModel = ServiceModel();
  FloorMapsModel floormapsmodel = FloorMapsModel();
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
  int _currentPage = 0;
  int pagelength = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );
  @override
  void initState() {
    super.initState();
    // Load the Indoor Insights map in the background so it opens instantly.
    IndoorMapHost.instance.preload();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _dateTime = DateTime.now();

      setState(() {});
    });

    _pagetimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < pagelength - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      // this.bannaerdata.then((value) {
      //   banarlength = value.length;
      // });
      // if (banarlength != 0) {
      if (_pageController.hasClients)
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      //}
    });
    _deleteCacheDir();

    bloc.getscreens();
    initfirebase();
    getdata();
    getofferdata();
    geteventdata();
    getcontacs();
    getservices();
    getfloormaps();
  }

  @override
  void dispose() {
    //_controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _deleteCacheDir() async {
    if (kIsWeb) return;
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  getcontacs() async {
    await http
        .get(Uri.parse('http://api.sccm.in/api/Kiosk/contacts'))
        .then((value) {
      final jsondata = jsonDecode(value.body);
      contactdata = ContactModel.fromJson(jsondata);
    });
  }

  getservices() async {
    try {
      await http
          .get(Uri.parse('http://api.sccm.in/api/Kiosk/services'))
          .then((value) {
        final jsondata = jsonDecode(value.body);
        serviceModel = ServiceModel.fromJson(jsondata);
      });
    } catch (error) {
      //

    }
  }

  getfloormaps() async {
    await http
        .get(Uri.parse('http://api.sccm.in/api/Kiosk/floorplans'))
        .then((value) {
      final jsondata = jsonDecode(value.body);
      floormapsmodel = FloorMapsModel.fromJson(jsondata);
    });
  }

  initfirebase() {
    // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //   getdata();
    //   getofferdata();
    //   geteventdata();
    //   getcontacs();
    //   getservices();
    //   setState(() {
    //     notifications = true;
    //   });
    // });
  }

  // Downloads the store list. Old data is replaced only after a successful
  // download, so a slow or failed request no longer empties the directory.
  getdata() async {
    try {
      final value = await http
          .get(Uri.parse('http://api.sccm.in/api/Kiosk/All'))
          .timeout(const Duration(seconds: 40));
      debugPrint('Stores API: status ${value.statusCode}');
      if (value.statusCode == 200) {
        final jsondecode = jsonDecode(value.body);
        kioskdata = Kioskdata.fromJson(jsondecode);
        final items = kioskdata.list;
        debugPrint('Stores API: ${items?.length ?? 0} stores received');
        if (items != null) {
          await dbbeacon.delete();
          for (final element in items) {
            await _insert(
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
          }
          debugPrint('Stores saved to database');
        }
      }
    } catch (e) {
      debugPrint('Stores API failed: $e');
    }
  }

  getofferdata() async {
    try {
      final value = await http
          .get(Uri.parse('http://api.sccm.in/api/Kiosk/Offers'))
          .timeout(const Duration(seconds: 40));
      debugPrint('Offers API: status ${value.statusCode}');
      if (value.statusCode == 200) {
        final jsondecode = jsonDecode(value.body);
        alloffers = AllOfers.fromJson(jsondecode);
        final items = alloffers.list;
        if (items != null) {
          await offerdb.delete();
          for (final element in items) {
            await _insertoffers(
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
          }
        }
      }
    } catch (e) {
      debugPrint('Offers API failed: $e');
    }
  }

  geteventdata() async {
    try {
      final value = await http
          .get(Uri.parse('http://api.sccm.in/api/Kiosk/Events'))
          .timeout(const Duration(seconds: 40));
      debugPrint('Events API: status ${value.statusCode}');
      if (value.statusCode == 200) {
        final jsondecode = jsonDecode(value.body);
        allevents = EventsModel.fromJson(jsondecode);
        final items = allevents.list;
        if (items != null) {
          await eventdb.delete();
          for (final element in items) {
            await _insertevents(
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
          }
        }
      }
    } catch (e) {
      debugPrint('Events API failed: $e');
    }
  }

  rotationtimer() {
    setState(() {
      rotation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    Homepage1(serviceModel, contactdata, floormapsmodel)));
          },
          child: Row(
            children: [
              Expanded(
                  flex: 70,
                  child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 22, 10, 18),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: StreamBuilder(
                      stream: bloc.screendata,
                      builder:
                          (context, AsyncSnapshot<ScreenSaverModel> snapshot) {
                        if (snapshot.hasData) {
                          pagelength = snapshot.data!.list!.length;
                          return PageView.builder(
                            itemCount: snapshot.data!.list!.length,
                            controller: _pageController,
                            itemBuilder: (context, index) {
                              return Image.network(
                                snapshot.data!.list![index].imageUrl.toString(),
                                fit: BoxFit.fill,
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return InkWell(
                              onTap: () {
                                bloc.getscreens();
                              },
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                //crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.wifi_off_outlined,
                                    size: 50,
                                  ),
                                  Text('Something went wrong'),
                                  Text('Tap to refresh...')
                                ],
                              )));
                        }
                        return const Center(child: CircularProgressIndicator());
                      }),
                                ),
                              ),
                            ],
                          ),
                        )),
              Expanded(flex: 30, child: KioskInfoPanel(_dateTime)),
            ],
          ),
        ));
  }

  Future<void> _insert(
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

  Future<void> _insertoffers(offerid, storeid, storename, catid, offername, itemimage,
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

  Future<void> _insertevents(eventid, eventname, desc, url, startdate, enddate, website,
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