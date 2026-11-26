class Kioskdata {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<ListKioskData>? list;

  Kioskdata(
      {this.responseCode, this.status, this.message, this.admsg, this.list});

  Kioskdata.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list!.add(ListKioskData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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

class ListKioskData {
  String? storeID;
  String? name;
  String? logo;
  String? floor;
  String? entity;
  String? email;
  String? contactno;
  String? offers;
  String? keywords;
  String? open;
  String? close;
  String? categoryID;
  String? categoryName;
  String? image;
  int? offerscount;

  ListKioskData(
      {this.storeID,
      this.name,
      this.logo,
      this.floor,
      this.entity,
      this.email,
      this.contactno,
      this.offers,
      this.keywords,
      this.open,
      this.close,
      this.categoryID,
      this.categoryName,
      this.image,
      this.offerscount});

  ListKioskData.fromJson(Map<String, dynamic> json) {
    storeID = json['StoreID'];
    name = json['Name'];
    logo = json['Logo'];
    floor = json['Floor'];
    entity = json['Entity'];
    email = json['email'];
    contactno = json['contactno'];
    offers = json['offers'];
    keywords = json['Keywords'];
    open = json['Open'];
    close = json['Close'];
    categoryID = json['CategoryID'];
    categoryName = json['CategoryName'];
    image = json['Image'];
    offerscount = json['offerscount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StoreID'] = storeID;
    data['Name'] = name;
    data['Logo'] = logo;
    data['Floor'] = floor;
    data['Entity'] = entity;
    data['email'] = email;
    data['contactno'] = contactno;
    data['offers'] = offers;
    data['Keywords'] = keywords;
    data['Open'] = open;
    data['Close'] = close;
    data['CategoryID'] = categoryID;
    data['CategoryName'] = categoryName;
    data['Image'] = image;
    data['offerscount'] = offerscount;
    return data;
  }
}
