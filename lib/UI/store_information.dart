import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/indoor_map.dart';
import 'package:sccm_kiosk/widgets/store_tile.dart' show PopIn;

// ---- Easy size settings ----
// Width split: info panel vs map (they add up to 100). Bigger map = bigger second number.
const int _infoWidth = 30;
const int _mapWidth = 70;
// Logo size as a share of screen height, and its min / max in pixels.
const double _logoShare = 0.16;
const double _logoMin = 70;
const double _logoMax = 130;
// Store name text size limits.
const double _nameMin = 15;
const double _nameMax = 22;
// ----------------------------

const List<Color> _accents = [
  Color(0xFFF59E0B),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFA855F7),
];

class StoreInformation extends StatefulWidget {
  final dynamic storedata;
  const StoreInformation(this.storedata, {super.key});

  @override
  State<StoreInformation> createState() => _StoreInformationState();
}

class _StoreInformationState extends State<StoreInformation> {
  dynamic get storedata => widget.storedata;

  String _clean(dynamic v) {
    final s = (v ?? '').toString().trim();
    return (s.isEmpty || s.toLowerCase() == 'null') ? '' : s;
  }

  Widget _chip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(0.18),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required List<String> values,
    required Color accent,
    required int order,
  }) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 350 + 110 * order),
      offset: const Offset(-0.08, 0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.22),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  for (final v in values)
                    Text(
                      v,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _details(double h) {
    final name = _clean(storedata['storename']);
    final floor = _clean(storedata['storefloor']);
    final category = _clean(storedata['storecategoryname']);
    final logo = _clean(storedata['storelogo']);
    final phones = _clean(storedata['storecontactno'])
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final email = _clean(storedata['storeemail']);
    final open = _clean(storedata['storeopen']);
    final close = _clean(storedata['storeclose']);
    final timing = (open.isNotEmpty && close.isNotEmpty) ? '$open - $close' : '';

    final accent = _accents[name.hashCode.abs() % _accents.length];
    final logoSize = (h * _logoShare).clamp(_logoMin, _logoMax).toDouble();

    var order = 0;
    final rows = <Widget>[
      if (floor.isNotEmpty)
        _infoRow(
            icon: Icons.location_on_outlined,
            label: 'Level',
            values: [floor],
            accent: accent,
            order: order++),
      if (phones.isNotEmpty)
        _infoRow(
            icon: Icons.call_outlined,
            label: 'Contact',
            values: phones,
            accent: accent,
            order: order++),
      if (timing.isNotEmpty)
        _infoRow(
            icon: Icons.access_time,
            label: 'Timings',
            values: [timing],
            accent: accent,
            order: order++),
      if (email.isNotEmpty)
        _infoRow(
            icon: Icons.mail_outline,
            label: 'Email',
            values: [email],
            accent: accent,
            order: order++),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Logo: white circle, no dark backdrop, gentle glow + float.
          PopIn(
            child: Floating(
              amplitude: 4,
              period: const Duration(seconds: 4),
              child: Container(
                width: logoSize,
                height: logoSize,
                padding: EdgeInsets.all(logoSize * 0.12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.55),
                      blurRadius: 26,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    logo,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: accent),
                      );
                    },
                    errorBuilder: (context, error, stack) => Center(
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: logoSize * 0.4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 200),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: (h * 0.032).clamp(_nameMin, _nameMax).toDouble(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeSlideIn(
            delay: const Duration(milliseconds: 280),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category.isNotEmpty)
                  _chip(category, accent, Icons.storefront_outlined),
                if (floor.isNotEmpty) _chip(floor, accent, Icons.layers_outlined),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...rows,
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _mapPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
        borderRadius: BorderRadius.circular(32),
        // Live Indoor Insights map: starts at the entrance kiosk and opens
        // the route to this store automatically.
        child: IndoorMapView(
          storeName: _clean(storedata['storename']),
          storeId: _clean(storedata['storeid']),
          floor: _clean(storedata['storefloor']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const FadeSlideIn(
          child: Text(
            'Store Information',
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Row(
          children: [
            Expanded(
              flex: _infoWidth,
              child: FadeSlideIn(
                offset: const Offset(-0.08, 0),
                child: GlassCard(
                  radius: 32,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: SizedBox.expand(child: _details(h)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: _mapWidth,
              child: FadeSlideIn(
                offset: const Offset(0.08, 0),
                delay: const Duration(milliseconds: 150),
                child: _mapPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}