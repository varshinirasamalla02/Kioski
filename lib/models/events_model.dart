// ignore_for_file: prefer_collection_literals

class EventsModel {
  int? responseCode;
  String? status;
  String? message;
  String? admsg;
  List<EventList>? list;

  EventsModel({responseCode, status, message, admsg, list});

  EventsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    status = json['status'];
    message = json['message'];
    admsg = json['admsg'];
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list!.add(EventList.fromJson(v));
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

class EventList {
  String? eventID;
  String? eventName;
  String? description;
  String? imageUrl;
  String? startDate;
  String? endDate;
  String? websiteUrl;
  String? contactNo;
  String? ageGroup;
  String? openTime;
  String? closeTime;
  String? sponsored;
  String? eventType;

  EventList(
      {eventID,
      eventName,
      description,
      imageUrl,
      startDate,
      endDate,
      websiteUrl,
      contactNo,
      ageGroup,
      openTime,
      closeTime,
      sponsored,
      eventType});

  EventList.fromJson(Map<String, dynamic> json) {
    eventID = json['EventID'];
    eventName = json['EventName'];
    description = json['Description'];
    imageUrl = json['ImageUrl'];
    startDate = json['StartDate'];
    endDate = json['EndDate'];
    websiteUrl = json['WebsiteUrl'];
    contactNo = json['ContactNo'];
    ageGroup = json['AgeGroup'];
    openTime = json['OpenTime'];
    closeTime = json['CloseTime'];
    sponsored = json['Sponsored'];
    eventType = json['EventType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['EventID'] = eventID;
    data['EventName'] = eventName;
    data['Description'] = description;
    data['ImageUrl'] = imageUrl;
    data['StartDate'] = startDate;
    data['EndDate'] = endDate;
    data['WebsiteUrl'] = websiteUrl;
    data['ContactNo'] = contactNo;
    data['AgeGroup'] = ageGroup;
    data['OpenTime'] = openTime;
    data['CloseTime'] = closeTime;
    data['Sponsored'] = sponsored;
    data['EventType'] = eventType;
    return data;
  }
}
