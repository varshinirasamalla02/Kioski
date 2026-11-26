import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class Offers extends StatefulWidget {
  dynamic offerdb;
  Offers(this.offerdb);
  @override
  State<StatefulWidget> createState() {
    return OffersState(offerdb);
  }
}

class OffersState extends State<Offers> {
  dynamic offerdb;
  OffersState(this.offerdb);
  dynamic offerdata;
  @override
  void initState() {
    super.initState();
    getofferdata();
  }

  getofferdata() async {
    offerdata = await offerdb.queryAllRows();
    setState(() {});
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
          'Offers ',
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
      body: offerdata != null
          ? offerdata.length == 0
              ? const Center(
                  child: Text('No offers available'),
                )
              : GridView.count(
                  primary: true,
                  padding: const EdgeInsets.all(35.0),
                  crossAxisCount: 3,
                  childAspectRatio: 2.15,
                  //mainAxisSpacing: 1.0,
                  //crossAxisSpacing: 1.0,
                  children: List.generate(offerdata.length, (index) {
                    return FadeSlideIn(delay: Duration(milliseconds: 45 * (index % 14)), child: Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: TapScale(onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DisplayImage(
                                      offerdata[index]['ItemImages'],
                                      offerdata[index]['store'])));
                            },
                            child: FxCard(
                                child: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.network(
                                  offerdata[index]['ItemImages'],
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Store Name:  "),
                                                Text(offerdata[index]['store'])
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Offer:  "),
                                                Text(offerdata[index]
                                                    ['OfferName'])
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Start Date:  "),
                                                Text(offerdata[index]
                                                    ['startDate'])
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("End Date:  "),
                                                Text(
                                                    offerdata[index]['endDate'])
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Floor:  "),
                                                Text(offerdata[index]['Floor'])
                                              ],
                                            ),
                                          ],
                                        )))
                              ],
                            )))));
                  }))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class DisplayImage extends StatelessWidget {
  String image;
  String name;
  DisplayImage(this.image, this.name);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
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
      body: InteractiveViewer(child: Center(child: Image.network(image))),
    );
  }
}