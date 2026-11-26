import 'dart:async';

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
//import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:sccm_kiosk/UI/home.dart';
import 'package:sccm_kiosk/UI/screensaver.dart';
import 'package:sccm_kiosk/utils/provider.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  Timer? _timer;
  final _navigatorKey = GlobalKey<NavigatorState>();
  screensaver() {
    _navigatorKey.currentState!
        .pushNamedAndRemoveUntil('screensaver', (_) => false);
  }

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  if (!kIsWeb && Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          //print(request);
          return null;
        },
      );
    }
  }

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<ProviderClass>(
          create: (context) => ProviderClass(),
        ),
      ],
      child: Listener(
          onPointerDown: (_) {
            if (_timer != null) {
              _timer!.cancel();
            }
            _timer = Timer(const Duration(minutes: 5), screensaver);
          }, // best place to reset timer imo

          //onPointerMove: (_) => print('move'),
          onPointerUp: (_) {
            if (_timer != null) {
              _timer!.cancel();
            }
            _timer = Timer(const Duration(minutes: 5), screensaver);
          },
          behavior: HitTestBehavior.translucent,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: fxTheme(),
            builder: fxAppBuilder,
            home: Navigator(
                initialRoute: 'screensaver',
                key: _navigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(builder: (context) {
                    return ScreenSaver();
                  });
                }),
            routes: <String, WidgetBuilder>{
              "/homepage": (BuildContext context) => Homepage(),
              "/screensaver": (BuildContext context) => ScreenSaver()
            },
          ))));
}

// class WebViewExample extends StatefulWidget {
//   @override
//   _WebViewExampleState createState() => _WebViewExampleState();
// }

// class _WebViewExampleState extends State<WebViewExample> {
//   final Completer<WebViewController> _controller =
//       Completer<WebViewController>();
//   final FirebaseMessaging messaging = FirebaseMessaging.instance;
//   bool notifications = false;
//   @override
//   void initState() {
//     super.initState();

//     messaging.getToken().then((value) {
//       print(value);
//     });

//     if (Platform.isAndroid) {
//       WebView.platform = SurfaceAndroidWebView();
//     }
//     initfirebase();
//   }

//   initfirebase() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage event) {
//       print("message recieved");

//       setState(() {
//         notifications = true;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: Colors.green,
//       appBar: AppBar(
//         title: const Text('SCCM KIOSK'),
//       ),

//       body: notifications
//           ? Center(child: Text('notification received'))
//           : Builder(builder: (BuildContext context) {
//               return WebView(
//                 initialUrl:
//                     'http://admin.sccm.in/MapNavigation/Store?location=S-136',
//                 javascriptMode: JavascriptMode.unrestricted,
//                 onWebViewCreated: (WebViewController webViewController) {
//                   _controller.complete(webViewController);
//                 },
//                 onProgress: (int progress) {
//                   print('WebView is loading (progress : $progress%)');
//                 },
//                 javascriptChannels: <JavascriptChannel>{
//                   _toasterJavascriptChannel(context),
//                 },
//                 navigationDelegate: (NavigationRequest request) {
//                   if (request.url.startsWith('https://www.youtube.com/')) {
//                     print('blocking navigation to $request}');
//                     return NavigationDecision.prevent;
//                   }
//                   print('allowing navigation to $request');
//                   return NavigationDecision.navigate;
//                 },
//                 onPageStarted: (String url) {
//                   print('Page started loading: $url');
//                 },
//                 onPageFinished: (String url) {
//                   print('Page finished loading: $url');
//                 },
//                 gestureNavigationEnabled: true,
//                 backgroundColor: const Color(0x00000000),
//               );
//             }),
//     );
//   }

//   JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
//     return JavascriptChannel(
//         name: 'Toaster',
//         onMessageReceived: (JavascriptMessage message) {
//           // ignore: deprecated_member_use
//           Scaffold.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         });
//   }
// }