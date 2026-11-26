import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/offers.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class Events extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final dbevent;
  Events(this.dbevent);
  @override
  State<StatefulWidget> createState() {
    return EventsState(dbevent);
  }
}

class EventsState extends State<Events> {
  final dbevent;
  EventsState(this.dbevent);

  dynamic currentevents;
  dynamic pastevents;

  @override
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    pastevents = await dbevent.queryevents('Past');
    currentevents = await dbevent.queryevents('Upcoming');

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          //backgroundColor: Colors.grey[100],
          appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
              centerTitle: true,
              // leading: Padding(
              //   padding: const EdgeInsets.only(left: 50),
              //   child: InkWell(
              //     onTap: () {
              //       Navigator.of(context).pop();
              //     },
              //     child: const Icon(Icons.arrow_back),
              //   ),
              // ),
              title: const Text(
                'Sarath City Capital Mall',
                style: TextStyle(color: Colors.white),
              ),
              bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: TabBar(
                    isScrollable: true,
                    labelColor: Colors.white,
                    indicatorColor: const Color(0xFFA78BFA),
                    unselectedLabelColor: Colors.white60,
                    tabs: [
                      Tab(
                        text: 'Upcoming Events',
                      ),
                      Tab(
                        text: 'Past Events',
                        //categories
                      ),
                    ],
                  ))),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startDocked,
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
          body: TabBarView(children: [
            currentevents != null
                ?
                //padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                currentevents.length == 0
                    ? const Center(
                        child: Text('No upcoming events..'),
                      )
                    : GridView.count(
                        primary: true,
                        padding: const EdgeInsets.all(15.0),
                        crossAxisCount: 5,
                        //childAspectRatio: 0.9,
                        // mainAxisSpacing: 1.0,
                        // crossAxisSpacing: 1.0,
                        children: List.generate(currentevents.length, (index) {
                          return FadeSlideIn(delay: Duration(milliseconds: 45 * (index % 14)), child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TapScale(onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => DisplayImage(
                                                currentevents[index]['ImageUrl']
                                                    .toString(),
                                                currentevents[index]
                                                    ['EventName'])));
                                  },
                                  child: FxCard(
                                      child: Container(
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              currentevents[index]['ImageUrl']
                                                  .toString()),
                                          fit: BoxFit.fill),
                                    ),
                                    child: Container(
                                      height: 20,
                                      width: double.infinity,
                                      color: Colors.grey[100],
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.transparent,
                                      //      border: Border.all(color: Colors.blueAccent)
                                      // ),
                                      child: Center(
                                          child: Text(
                                        currentevents[index]['EventName']
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 9),
                                      )),
                                    ),
                                    width: 120,
                                    height: 150,
                                    // child: Image.asset('assets/b1.png',),
                                  ))
                                  /*  Card(
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.network(
                                      allrowsdata[index]['storelogo']
                                          .toString(),
                                      height: 50,
                                      width: 50,
                                    ),
                                    Text(
                                      allrowsdata[index]['storename']
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 9),
                                    )
                                  ],
                                ),
                                // elevation: 25.0,
                                // shape: CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                              ) */
                                  )));
                        }))
                : Container(),
            pastevents != null
                ? pastevents.length == 0
                    ? const Center(
                        child: Text('No past events..'),
                      )
                    : GridView.count(
                        primary: true,
                        padding: const EdgeInsets.all(35.0),
                        crossAxisCount: 5,
                        //childAspectRatio: 1.15,
                        //mainAxisSpacing: 1.0,
                        //crossAxisSpacing: 1.0,
                        children: List.generate(pastevents.length, (index) {
                          return FadeSlideIn(delay: Duration(milliseconds: 45 * (index % 14)), child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: TapScale(onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => DisplayImage(
                                                pastevents[index]['ImageUrl']
                                                    .toString(),
                                                pastevents[index]
                                                    ['EventName'])));
                                  },
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      image: DecorationImage(
                                          image: NetworkImage(
                                            pastevents[index]['ImageUrl']
                                                .toString(),
                                          ),
                                          fit: BoxFit.fill),
                                    ),
                                    child: Container(
                                      height: 10,
                                      width: double.infinity,
                                      color: Colors.grey[100],
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.transparent,
                                      //      border: Border.all(color: Colors.blueAccent)
                                      // ),
                                      child: Center(
                                          child: Text(
                                        pastevents[index]['EventName']
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 9),
                                      )),
                                    ),
                                    width: 120,
                                    height: 150,
                                    // child: Image.asset('assets/b1.png',),
                                  ))));
                        }))
                : Container(),
          ]),
        ));
  }
}