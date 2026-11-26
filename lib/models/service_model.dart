// ignore_for_file: prefer_collection_literals

class ServiceModel {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<ServiceList>? list;

  ServiceModel(
      {this.responseCode, this.status, this.message, this.admsg, this.list});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = <ServiceList>[];
      json['list'].forEach((v) {
        list!.add(ServiceList.fromJson(v));
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

class ServiceList {
  int? sNO;
  String? serviceName;
  String? imageUrl;

  ServiceList({this.sNO, this.serviceName, this.imageUrl});

  ServiceList.fromJson(Map<String, dynamic> json) {
    sNO = json['SNO'];
    serviceName = json['ServiceName'];
    imageUrl = json['ImageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['SNO'] = sNO;
    data['ServiceName'] = serviceName;
    data['ImageUrl'] = imageUrl;
    return data;
  }
}
