// ignore_for_file: prefer_collection_literals

class FloorMapsModel {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<MapsList>? list;

  FloorMapsModel(
      {this.responseCode, this.status, this.message, this.admsg, this.list});

  FloorMapsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = <MapsList>[];
      json['list'].forEach((v) {
        list!.add(MapsList.fromJson(v));
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

class MapsList {
  int? iD;
  String? floor;
  String? imageUrl;

  MapsList({this.iD, this.floor, this.imageUrl});

  MapsList.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    floor = json['Floor'];
    imageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['ID'] = iD;
    data['Floor'] = floor;
    data['ImageUrl'] = imageUrl;
    return data;
  }
}
