import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sccm_kiosk/models/floor_maps_model.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

// ---- Easy size settings ----
// Floor name text size in the left list (smaller number = smaller text).
const double _floorFont = 13;
// Round badge size (LG, UG, 1, 2 ...).
const double _badgeSize = 36;
// ----------------------------

class FloorMaps extends StatefulWidget {
  final FloorMapsModel floorMapsModel;

  /// true when shown inside another page (the Services page), so it does not
  /// draw its own app bar and back button.
  final bool embedded;
  const FloorMaps(this.floorMapsModel, {super.key, this.embedded = false});

  @override
  State<FloorMaps> createState() => _FloorMapsState();
}

class _FloorMapsState extends State<FloorMaps>
    with SingleTickerProviderStateMixin {
  int selected = 0;
  final TransformationController _tc = TransformationController();
  late final AnimationController _zoomAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280));
  Animation<Matrix4>? _zoomTween;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _zoomAnim.addListener(() {
      final t = _zoomTween;
      if (t != null) _tc.value = t.value;
    });
  }

  @override
  void dispose() {
    _zoomAnim.dispose();
    _tc.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 target) {
    _zoomTween = Matrix4Tween(begin: _tc.value, end: target).animate(
        CurvedAnimation(parent: _zoomAnim, curve: Curves.easeOutCubic));
    _zoomAnim
      ..reset()
      ..forward();
  }

  void _zoom(double factor) {
    final current = _tc.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(1.0, 5.0).toDouble();
    if (next == current) return;
    final f = next / current;
    final cx = _viewport.width / 2;
    final cy = _viewport.height / 2;
    final change = Matrix4.translationValues(cx, cy, 0) *
        Matrix4.diagonal3Values(f, f, 1) *
        Matrix4.translationValues(-cx, -cy, 0);
    _animateTo(change * _tc.value);
  }

  void _resetZoom() => _animateTo(Matrix4.identity());

  void _select(int index) {
    if (index == selected) return;
    setState(() => selected = index);
    _zoomAnim.stop();
    _tc.value = Matrix4.identity();
  }

  String _badge(String floor) {
    final f = floor.toLowerCase();
    if (f.contains('lower')) return 'LG';
    if (f.contains('upper')) return 'UG';
    if (f.contains('first')) return '1';
    if (f.contains('second')) return '2';
    if (f.contains('third')) return '3';
    if (f.contains('fourth')) return '4';
    if (f.contains('fifth')) return '5';
    if (f.contains('sixth')) return '6';
    return floor.isEmpty
        ? '?'
        : floor.substring(0, floor.length < 2 ? floor.length : 2).toUpperCase();
  }

  Widget _floorButton(String floor, int index) {
    final sel = index == selected;
    return FadeSlideIn(
      delay: Duration(milliseconds: 120 + 70 * index),
      offset: const Offset(-0.15, 0),
      child: TapScale(
        onTap: () => _select(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: sel
                ? const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)])
                : null,
            color: sel ? null : Colors.white.withOpacity(0.07),
            border: Border.all(
                color: sel ? const Color(0xFFC4B5FD) : Colors.white12),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.5),
                      blurRadius: 18,
                    ),
                  ]
                : const [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? Colors.white : Colors.white.withOpacity(0.12),
                ),
                child: Text(
                  _badge(floor),
                  style: TextStyle(
                    color: sel ? const Color(0xFF7C3AED) : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: _badgeSize * 0.34,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // full name is always visible: it wraps onto a second line
              Expanded(
                child: Text(
                  floor,
                  maxLines: 2,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _floorFont,
                    height: 1.15,
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: sel ? Colors.white : Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) {
    return TapScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF14162B).withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _mapPanel(List<MapsList> maps) {
    final item = maps[selected];
    final url = 'http://api.sccm.in${item.imageUrl ?? ''}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
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
        child: LayoutBuilder(
          builder: (context, c) {
            _viewport = Size(c.maxWidth, c.maxHeight);
            return Stack(
              children: [
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.96, end: 1)
                            .animate(animation),
                        child: child,
                      ),
                    ),
                    child: InteractiveViewer(
                      key: ValueKey<String>(url),
                      transformationController: _tc,
                      minScale: 1,
                      maxScale: 5,
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.contain,
                        width: c.maxWidth,
                        height: c.maxHeight,
                        placeholder: (context, _) => const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Color(0xFF7C3AED)),
                        ),
                        errorWidget: (context, _, error) => const Center(
                          child: Text(
                            'Could not load this floor map.',
                            style: TextStyle(
                                color: Color(0xFF6B6B80), fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Floor name + zoom buttons live above the map, never on the picture.
  Widget _header(MapsList item) {
    return Row(
      children: [
        Flexible(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(-0.1, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey<String>(item.floor ?? ''),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.45),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.layers_outlined,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.floor ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        _zoomButton(Icons.remove, () => _zoom(1 / 1.6)),
        _zoomButton(Icons.add, () => _zoom(1.6)),
        _zoomButton(Icons.center_focus_strong, _resetZoom),
      ],
    );
  }

  Widget _mapColumn(List<MapsList> maps) {
    return Column(
      children: [
        _header(maps[selected]),
        const SizedBox(height: 12),
        Expanded(child: _mapPanel(maps)),
      ],
    );
  }

  Widget _body() {
    final maps = widget.floorMapsModel.list ?? <MapsList>[];
    if (maps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Floor maps are not available yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 22),
          ),
        ),
      );
    }
    if (selected >= maps.length) selected = 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      child: Row(
        children: [
          Expanded(
            flex: 30,
            child: FadeSlideIn(
              offset: const Offset(-0.08, 0),
              child: GlassCard(
                radius: 32,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 72),
                  itemCount: maps.length,
                  itemBuilder: (context, i) =>
                      _floorButton(maps[i].floor ?? '', i),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 70,
            child: FadeSlideIn(
              offset: const Offset(0.08, 0),
              delay: const Duration(milliseconds: 150),
              child: _mapColumn(maps),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _body();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const FadeSlideIn(
          child: Text(
            'Floor Maps',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
      body: _body(),
    );
  }
}
