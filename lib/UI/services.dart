import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/services_info.dart';
import 'package:sccm_kiosk/models/floor_maps_model.dart';
import 'package:sccm_kiosk/models/service_model.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/service_icons.dart';
import 'package:sccm_kiosk/widgets/store_tile.dart' show PopIn;

// ---- Easy size settings (change these numbers to resize) ----
// Service boxes: smaller number = smaller boxes (more per row).
const double _boxWidth = 190;
// Service icons: biggest icon size in pixels.
const double _iconMax = 100;
// Service icons as a share of screen height (0.14 = 14%).
const double _iconShare = 0.14;
// --------------------------------------------------------------

const List<Color> _accents = [
  Color(0xFFF59E0B),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFA855F7),
];

class Services extends StatefulWidget {
  final ServiceModel servicedata;
  final FloorMapsModel floorMapsModel;
  const Services(this.servicedata, this.floorMapsModel, {super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  Widget _icon(String name, String url, double size, Color accent) {
    Widget fallback() {
      final asset = serviceAssetFor(name);
      final icon = Icon(Icons.miscellaneous_services,
          size: size * 0.7, color: accent);
      if (asset == null) return icon;
      return Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => icon,
      );
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) => fallback(),
    );
  }

  Widget _tile(ServiceList item, int index, double iconSize) {
    final accent = _accents[index % _accents.length];
    final name = (item.serviceName ?? '').toString();
    final url = 'http://api.sccm.in${item.imageUrl ?? ''}';
    final glow = iconSize * 1.35;

    return PopIn(
      delay: Duration(milliseconds: 45 * (index % 14)),
      child: Floating(
        phase: (index % 9) * 0.11,
        amplitude: 3,
        period: Duration(milliseconds: 3400 + (index % 5) * 300),
        child: TapScale(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ServiceInfo(
                      name: name,
                      id: item.sNO ?? 0,
                      floorMapsModel: widget.floorMapsModel,
                    )));
          },
          child: FxCard(
            radius: 24,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // soft coloured glow behind the icon
                  Container(
                    width: glow,
                    height: glow,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withOpacity(0.38),
                          accent.withOpacity(0.0),
                        ],
                      ),
                    ),
                    // icon zooms in with a little bounce
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.7, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: _icon(name, url, iconSize, accent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.servicedata.list ?? <ServiceList>[];
    final h = MediaQuery.of(context).size.height;
    final iconSize = (h * _iconShare).clamp(56.0, _iconMax).toDouble();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const FadeSlideIn(
          child: Text(
            'Facilities & Services',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.16),
        elevation: 0,
        shape: const CircleBorder(side: BorderSide(color: Colors.white38)),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'No services to show yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 22),
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 96),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: _boxWidth,
                childAspectRatio: 0.95,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => _tile(items[i], i, iconSize),
            ),
    );
  }
}

class FacilitiesServicesModel {
  String title;
  String image;
  FacilitiesServicesModel(this.title, this.image);
}