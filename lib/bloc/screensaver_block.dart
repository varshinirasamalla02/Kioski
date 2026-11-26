import 'dart:async';

import 'package:sccm_kiosk/models/screen_saver_model.dart';
import 'package:sccm_kiosk/service/api.dart';

class Screensaverbloc implements Bloc {
  final _repository = Repository();
  final _formtreamcontroller = StreamController<ScreenSaverModel>();

  Stream<ScreenSaverModel> get screendata => _formtreamcontroller.stream;

  void getscreens() async {
    try {
      ScreenSaverModel itemModel = await _repository.getscrees();
      _formtreamcontroller.sink.add(itemModel);
    } catch (error) {
      _formtreamcontroller.sink.addError(error);
    }
  }

  @override
  void dispose() {
    _formtreamcontroller.close();
  }

  // dispose() {
  //   _catagoriesFetcher.close();
  // }
}

//final bloc = Taskbloc();

class Repository {
  final formdataprovider = ApiProvider();

  Future<ScreenSaverModel> getscrees() =>
      formdataprovider.getthescreensaverdata();
}

abstract class Bloc {
  void dispose();
}
