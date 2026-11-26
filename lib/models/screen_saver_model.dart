// ignore_for_file: prefer_collection_literals

class ScreenSaverModel {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<ScreenList>? list;

  ScreenSaverModel(
      {this.responseCode, this.status, this.message, this.admsg, this.list});

  ScreenSaverModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list!.add(ScreenList.fromJson(v));
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

class ScreenList {
  int? iD;
  String? imageUrl;

  ScreenList({this.iD, this.imageUrl});

  ScreenList.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    imageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ID'] = iD;
    data['ImageUrl'] = imageUrl;
    return data;
  }
}
