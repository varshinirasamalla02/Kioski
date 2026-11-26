// ignore_for_file: prefer_collection_literals

class AllOfers {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<OfferList>? list;

  AllOfers({responseCode, status, message, admsg, list});

  AllOfers.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list!.add(OfferList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['responseCode'] = responseCode;
    data['status'] = status;
    data['message'] = message;
    data['admsg'] = admsg;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OfferList {
  int? offerID;
  String? storeID;
  String? store;
  String? categoryID;
  String? offerName;
  String? itemImages;
  String? itemPromo;
  String? itemDetails;
  String? imageUrl;
  String? promo;
  String? startDate;
  String? endDate;
  String? floor;

  OfferList(
      {offerID,
      storeID,
      store,
      categoryID,
      offerName,
      itemImages,
      itemPromo,
      itemDetails,
      imageUrl,
      promo,
      startDate,
      endDate,
      floor});

  OfferList.fromJson(Map<String, dynamic> json) {
    offerID = json['offerID'];
    storeID = json['StoreID'];
    store = json['store'];
    categoryID = json['CategoryID'];
    offerName = json['OfferName'];
    itemImages = json['ItemImages'];
    itemPromo = json['itemPromo'];
    itemDetails = json['itemDetails'];
    imageUrl = json['imageUrl'];
    promo = json['promo'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    floor = json['Floor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['offerID'] = offerID;
    data['StoreID'] = storeID;
    data['store'] = store;
    data['CategoryID'] = categoryID;
    data['OfferName'] = offerName;
    data['ItemImages'] = itemImages;
    data['itemPromo'] = itemPromo;
    data['itemDetails'] = itemDetails;
    data['imageUrl'] = imageUrl;
    data['promo'] = promo;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['Floor'] = floor;
    return data;
  }
}
