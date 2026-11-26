import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/indoor_map.dart';

/// Live indoor navigation from Indoor Insights, starting at the entrance.
/// The map is loaded in the background when the app starts, so this page
/// opens almost instantly.
class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final IndoorMapController _map = IndoorMapController();

  // Back goes one step back inside the map first, then leaves the page.
  Future<void> _back() async {
    if (await _map.canGoBack()) {
      await _map.goBack();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.14),
          border: Border.all(color: Colors.white38),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(child: _roundButton(Icons.arrow_back, _back)),
        ),
        title: const FadeSlideIn(
          child: Text(
            'Navigation',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(child: _roundButton(Icons.refresh, _map.reload)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: FadeSlideIn(
          offset: const Offset(0, 0.04),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: IndoorMapView(controller: _map),
            ),
          ),
        ),
      ),
    );
  }
}