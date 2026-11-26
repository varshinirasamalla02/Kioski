import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sccm_kiosk/config/indoor_insights.dart';

void _log(String message) {
  if (indoorDebugLogs) debugPrint('[IndoorMap] $message');
}

/// Keeps ONE Indoor Insights browser alive for the whole app:
///  * it is loaded in the background when the app starts (preload), and
///  * it stays loaded when you leave a page, so the next page opens instantly.
class IndoorMapHost {
  IndoorMapHost._();
  static final IndoorMapHost instance = IndoorMapHost._();

  final InAppWebViewKeepAlive keepAlive = InAppWebViewKeepAlive();
  HeadlessInAppWebView? headless;
  bool _preloadStarted = false;

  /// true when the map may be showing an old route and needs a fresh start.
  bool dirty = false;

  static InAppWebViewSettings get settings => InAppWebViewSettings(
        javaScriptEnabled: true,
        cacheEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
      );

  /// Call once when the app starts. Loads the map in the background.
  Future<void> preload() async {
    if (kIsWeb || _preloadStarted) return;
    _preloadStarted = true;
    try {
      final h = HeadlessInAppWebView(
        keepAlive: keepAlive,
        initialUrlRequest: URLRequest(url: WebUri(indoorKioskUrl)),
        initialSettings: settings,
        onLoadStop: (controller, url) => _log('preloaded in background: $url'),
      );
      headless = h;
      await h.run();
      _log('background preload started');
    } catch (e) {
      headless = null;
      _log('preload not available: $e');
    }
  }

  /// When a page is closed, quietly bring the map back to the entrance so the
  /// next visitor starts from a clean screen.
  Future<void> resetInBackground(InAppWebViewController c) async {
    try {
      await c.loadUrl(urlRequest: URLRequest(url: WebUri(indoorKioskUrl)));
      dirty = false;
    } catch (e) {
      dirty = true;
      _log('background reset failed: $e');
    }
  }
}

/// Lets a page control the map (back / refresh).
class IndoorMapController {
  InAppWebViewController? _c;
  void _attach(InAppWebViewController c) => _c = c;
  void _detach() => _c = null;

  Future<bool> canGoBack() async {
    try {
      return await _c?.canGoBack() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> goBack() async {
    try {
      await _c?.goBack();
    } catch (_) {}
  }

  Future<void> reload() async {
    try {
      await _c?.loadUrl(urlRequest: URLRequest(url: WebUri(indoorKioskUrl)));
    } catch (_) {}
  }
}

/// The Indoor Insights map. With a [storeName] it opens the route from the
/// entrance kiosk to that store automatically.
class IndoorMapView extends StatefulWidget {
  final String storeName;
  final String storeId;
  final String floor;
  final IndoorMapController? controller;
  const IndoorMapView({
    super.key,
    this.storeName = '',
    this.storeId = '',
    this.floor = '',
    this.controller,
  });

  @override
  State<IndoorMapView> createState() => _IndoorMapViewState();
}

class _IndoorMapViewState extends State<IndoorMapView> {
  final IndoorMapHost _host = IndoorMapHost.instance;
  InAppWebViewController? _c;
  bool _loading = true;
  bool _failed = false;
  bool _autoStarted = false;
  int _progress = 0;
  Timer? _revealTimer;

  bool get _isStore => widget.storeName.trim().isNotEmpty;
  bool get _useTemplate => indoorDirectionsTemplate.isNotEmpty;

  String _startUrl() {
    if (!_isStore || !_useTemplate) return indoorKioskUrl;
    return indoorDirectionsTemplate
        .replaceAll('{kiosk}', indoorKioskId)
        .replaceAll('{storeId}', Uri.encodeComponent(widget.storeId))
        .replaceAll('{name}', Uri.encodeComponent(widget.storeName))
        .replaceAll('{floor}', Uri.encodeComponent(widget.floor));
  }

  // Never keep the cover screen on for more than 7 seconds.
  void _armReveal() {
    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(seconds: 7), () {
      if (mounted && _loading) setState(() => _loading = false);
    });
  }

  Future<void> _onCreated(InAppWebViewController c) async {
    _c = c;
    widget.controller?._attach(c);
    try {
      final progress = await c.getProgress() ?? 0;
      final needFreshStart = _host.dirty;
      _host.dirty = true; // we are about to use it
      if (!mounted) return;
      if (progress >= 100) {
        if (needFreshStart || (_isStore && _useTemplate)) {
          setState(() {
            _loading = true;
            _progress = 0;
          });
          _armReveal();
          await c.loadUrl(
              urlRequest: URLRequest(url: WebUri(_startUrl())));
        } else {
          // Already loaded in the background: show it straight away.
          setState(() {
            _loading = false;
            _progress = 100;
          });
          _startAuto();
        }
      } else {
        _armReveal();
      }
    } catch (e) {
      _log('attach error: $e');
    }
  }

  // Opens the Directory, finds the store and presses Directions.
  Future<void> _startAuto() async {
    final c = _c;
    if (c == null || !_isStore || _useTemplate || _autoStarted) return;
    _autoStarted = true;
    final script =
        _autoScript.replaceFirst('%NAME%', jsonEncode(widget.storeName.trim()));
    try {
      await c.evaluateJavascript(source: script);
    } catch (e) {
      _log('could not run auto directions: $e');
    }
  }

  void _reload() {
    final c = _c;
    if (c == null) return;
    setState(() {
      _loading = true;
      _failed = false;
      _progress = 0;
    });
    _armReveal();
    c.loadUrl(urlRequest: URLRequest(url: WebUri(_startUrl())));
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    final c = _c;
    if (c != null) _host.resetInBackground(c);
    widget.controller?._detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InAppWebView(
          keepAlive: kIsWeb ? null : _host.keepAlive,
          headlessWebView: kIsWeb ? null : _host.headless,
          initialUrlRequest: URLRequest(url: WebUri(_startUrl())),
          initialSettings: IndoorMapHost.settings,
          onWebViewCreated: _onCreated,
          onLoadStart: (controller, url) {
            if (!mounted) return;
            _autoStarted = false;
            setState(() {
              _loading = true;
              _failed = false;
              _progress = 0;
            });
            _armReveal();
          },
          onProgressChanged: (controller, p) {
            if (!mounted) return;
            setState(() {
              _progress = p;
              if (p >= 70) _loading = false;
            });
          },
          onLoadStop: (controller, url) {
            _log('page loaded: $url');
            if (!mounted) return;
            setState(() {
              _loading = false;
              _progress = 100;
            });
            _startAuto();
          },
          onReceivedError: (controller, request, error) {
            if (!mounted) return;
            if (request.isForMainFrame ?? true) {
              setState(() {
                _loading = false;
                _failed = true;
              });
            }
          },
          onConsoleMessage: (controller, message) {
            if (message.message.startsWith('[IndoorAuto]')) {
              _log(message.message);
            }
          },
          onUpdateVisitedHistory: (controller, url, isReload) =>
              _log('url: $url'),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_loading,
            child: AnimatedOpacity(
              opacity: _loading ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                color: const Color(0xFF14162B),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Color(0xFFA78BFA)),
                    ),
                    SizedBox(height: 14),
                    Text('Finding the way...',
                        style: TextStyle(
                            color: Colors.white70, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_progress < 100 && !_failed)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
              minHeight: 3,
              backgroundColor: Colors.transparent,
              color: const Color(0xFFA78BFA),
            ),
          ),
        if (_failed)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF14162B),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: Colors.white54, size: 48),
                  const SizedBox(height: 14),
                  const Text(
                    'The map could not be loaded.\nPlease check the internet connection.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('TRY AGAIN'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Page script: checks 4 times a second (for up to 30 seconds), because the
// site draws its screens with JavaScript after it loads. Every step is
// reported to the console with the prefix [IndoorAuto].
const String _autoScript = r'''
(function () {
  if (window.__sccmTimer) { clearInterval(window.__sccmTimer); }
  var NAME = %NAME%;
  function log(m) { try { console.log('[IndoorAuto] ' + m); } catch (e) {} }
  function norm(s) {
    return (s || '').toLowerCase().replace(/[^a-z0-9 ]+/g, ' ')
      .replace(/\s+/g, ' ').trim();
  }
  var target = norm(NAME);
  function vis(el) {
    var r = el.getBoundingClientRect();
    return r.width > 2 && r.height > 2;
  }
  function clickEl(el) {
    var t = el;
    for (var i = 0; i < 5 && t; i++) {
      var tag = (t.tagName || '').toLowerCase();
      var role = t.getAttribute ? t.getAttribute('role') : null;
      if (tag === 'a' || tag === 'button' || role === 'button' ||
          role === 'tab' || t.onclick ||
          getComputedStyle(t).cursor === 'pointer') break;
      t = t.parentElement;
    }
    t = t || el;
    ['pointerdown', 'mousedown', 'pointerup', 'mouseup', 'click'].forEach(
      function (ev) {
        t.dispatchEvent(new MouseEvent(ev,
          { bubbles: true, cancelable: true, view: window }));
      });
  }
  // Looks only at small elements (not big containers) so it stays fast.
  function findText(match, sel) {
    var best = null, bestLen = 1e9;
    var els = document.querySelectorAll(sel);
    for (var i = 0; i < els.length; i++) {
      var el = els[i];
      if (el.tagName.toLowerCase() === 'input' || el.children.length > 8) continue;
      var t = norm(el.textContent);
      if (!t || t.length > 80) continue;
      if (match(t) && t.length < bestLen && vis(el)) { best = el; bestLen = t.length; }
    }
    return best;
  }
  function setInput(inp, val) {
    var setter = Object.getOwnPropertyDescriptor(
      window.HTMLInputElement.prototype, 'value').set;
    inp.focus();
    setter.call(inp, val);
    inp.dispatchEvent(new Event('input', { bubbles: true }));
    inp.dispatchEvent(new Event('change', { bubbles: true }));
  }
  var ALL = 'a,button,li,div,span,p,h1,h2,h3,h4,h5,[role=button],[role=tab],[role=option]';
  var step = 0, tries = 0;
  window.__sccmTimer = setInterval(function () {
    tries++;
    if (tries > 120) {
      clearInterval(window.__sccmTimer);
      log('gave up at step ' + step + ' (' + NAME + ')');
      return;
    }
    try {
      if (step === 0) {
        var inp = document.querySelector(
          'input[type=search],input[type=text],input:not([type])');
        if (inp && vis(inp)) {
          setInput(inp, NAME);
          step = 1;
          log('typed "' + NAME + '" in the search box');
          return;
        }
        var tab = findText(function (t) { return t === 'directory'; }, ALL);
        if (tab) { clickEl(tab); log('opened the Directory tab'); }
        return;
      }
      if (step === 1) {
        var res = findText(function (t) {
          return t === target ||
            (t.indexOf(target) === 0 && t.length <= target.length + 25);
        }, ALL);
        if (res) {
          clickEl(res);
          step = 2;
          log('selected "' + norm(res.textContent) + '"');
        }
        return;
      }
      if (step === 2) {
        var d = findText(function (t) {
          return t === 'directions' || t === 'get directions' ||
            t === 'navigate' || t === 'directions here' ||
            (t.indexOf('direction') >= 0 && t.length <= 22);
        }, ALL);
        if (d) {
          clickEl(d);
          step = 3;
          clearInterval(window.__sccmTimer);
          log('pressed Directions');
        }
      }
    } catch (e) { log('error: ' + e); }
  }, 250);
})();
''';