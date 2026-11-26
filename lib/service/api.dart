import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sccm_kiosk/models/screen_saver_model.dart';

class ApiProvider {
  Future<ScreenSaverModel> getthescreensaverdata() async {
    try {
      final response = await http.get(
        Uri.parse('http://api.sccm.in/api/Kiosk/Screensaver'),
      );

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        return ScreenSaverModel.fromJson(json.decode(response.body));
      } else {
        // If that call was not successful, throw an error.
        throw Exception('Failed to load post');
      }
    } catch (e) {
      throw Exception('Failed to load post');
    }
  }
}
