// ignore_for_file: prefer_collection_literals

class ContactModel {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<ContactList>? list;

  ContactModel(
      {this.responseCode, this.status, this.message, this.admsg, this.list});

  ContactModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = <ContactList>[];
      json['list'].forEach((v) {
        list!.add(ContactList.fromJson(v));
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

class ContactList {
  String? title;
  String? name;
  String? phoneno;
  String? email;

  ContactList({this.title, this.name, this.phoneno, this.email});

  ContactList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    name = json['name'];
    phoneno = json['phoneno'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['name'] = name;
    data['phoneno'] = phoneno;
    data['email'] = email;
    return data;
  }
}
