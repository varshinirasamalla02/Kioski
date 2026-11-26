import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/store_information.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

class CustomDelegate<T> extends SearchDelegate<T> {
  dynamic allcatagoriesdata;
  dynamic listToShow;
  final dbbeacon;

  late bool map;

  CustomDelegate(this.allcatagoriesdata, this.map, this.dbbeacon);

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: () => {Navigator.of(context).pop()});

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  getsearchdata(text) async {
    listToShow = await dbbeacon.querysearchdata(text.toString());
  }

  getalldata() async {
    listToShow = await dbbeacon.querysearc();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //getsearchdata(query.trim());
    if (query.isNotEmpty) {
      listToShow = allcatagoriesdata
          .where(
              (e) => e['storename'].toString().toLowerCase().startsWith(query))
          .toList();
    } else {
      listToShow = null;
    }

    return listToShow != null
        ? listToShow.length == 0
            ? const Center(
                child: Text('No results found'),
              )
            : GridView.count(
                primary: true,
                padding: const EdgeInsets.all(15.0),
                crossAxisCount: 5,
                children: List.generate(listToShow.length, (index) {
                  return FadeSlideIn(delay: Duration(milliseconds: 45 * (index % 14)), child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TapScale(onTap: () {
                            if (index < listToShow.length) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StoreInformation(listToShow[index])));
                            }
                          },
                          child: FxCard(
                              child: Container(
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              image: DecorationImage(
                                  image: NetworkImage(listToShow[index]
                                          ['storelogo']
                                      .toString()),
                                  fit: BoxFit.fill),
                            ),
                            child: Container(
                              height: 20,
                              width: double.infinity,
                              color: Colors.grey[100],
                              child: Center(
                                  child: Text(
                                listToShow[index]['storename'].toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            width: 120,
                            height: 150,
                          )))));
                }))
        : Container();
  }
}