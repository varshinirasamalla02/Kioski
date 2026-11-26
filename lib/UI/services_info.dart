import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/floor_maps.dart';
import 'package:sccm_kiosk/models/floor_maps_model.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/service_icons.dart';
import 'package:sccm_kiosk/widgets/store_tile.dart' show PopIn;

class _Info {
  final List<String> lines;
  final String? deskPhoto; // small photo under the text
  final String? bigImage; // large picture on the right
  const _Info(this.lines, {this.deskPhoto, this.bigImage});
}

// Same content as the original page, organised by service number.
const Map<int, _Info> _infoById = {
  2: _Info(['Wifi Password:']),
  6: _Info(
    ['Lower Ground Floor', 'Contact No :+91 40-68218333'],
    deskPhoto: 'assets/hdesk.jpg',
    bigImage: 'assets/lg.png',
  ),
  9: _Info(['Lower Ground Floor exit'], bigImage: 'assets/taxi.png'),
};

class ServiceInfo extends StatelessWidget {
  final String name;
  final int id;
  final FloorMapsModel floorMapsModel;
  const ServiceInfo({
    super.key,
    required this.name,
    required this.id,
    required this.floorMapsModel,
  });

  PreferredSizeWidget _appBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: FadeSlideIn(
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white.withOpacity(0.16),
      elevation: 0,
      shape: const CircleBorder(side: BorderSide(color: Colors.white38)),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }

  Widget _heroIcon(double h) {
    final asset = serviceAssetFor(name);
    final size = (h * 0.22).clamp(90.0, 180.0).toDouble();
    return PopIn(
      child: Floating(
        amplitude: 4,
        period: const Duration(seconds: 4),
        child: Container(
          width: size * 1.3,
          height: size * 1.3,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFA78BFA).withOpacity(0.40),
                const Color(0xFFA78BFA).withOpacity(0.0),
              ],
            ),
          ),
          child: asset == null
              ? Icon(Icons.miscellaneous_services,
                  size: size * 0.7, color: Colors.white)
              : Image.asset(
                  asset,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => Icon(
                      Icons.miscellaneous_services,
                      size: size * 0.7,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _textBlock(double h, _Info? info, {bool centered = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _heroIcon(h),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: Text(
            name,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: (h * 0.05).clamp(22.0, 36.0).toDouble(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (info != null)
          for (var i = 0; i < info.lines.length; i++)
            FadeSlideIn(
              delay: Duration(milliseconds: 320 + 110 * i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withOpacity(0.07),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  info.lines[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        if (info?.deskPhoto != null)
          FadeSlideIn(
            delay: const Duration(milliseconds: 600),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                info!.deskPhoto!,
                height: h * 0.2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // Service 7 is the floor map: show the floor maps screen.
    if (id == 7) {
      return Scaffold(
        appBar: _appBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        floatingActionButton: _backButton(context),
        body: FloorMaps(floorMapsModel, embedded: true),
      );
    }

    final info = _infoById[id];
    final big = info?.bigImage;

    return Scaffold(
      appBar: _appBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: _backButton(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
        child: big == null
            ? Center(
                child: FadeSlideIn(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: GlassCard(
                      radius: 32,
                      padding: const EdgeInsets.all(28),
                      child: SingleChildScrollView(
                          child: _textBlock(h, info)),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 35,
                    child: FadeSlideIn(
                      offset: const Offset(-0.08, 0),
                      child: GlassCard(
                        radius: 32,
                        padding: const EdgeInsets.all(22),
                        child: SizedBox.expand(
                          child: SingleChildScrollView(
                              child: _textBlock(h, info)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 65,
                    child: FadeSlideIn(
                      offset: const Offset(0.08, 0),
                      delay: const Duration(milliseconds: 150),
                      child: Container(
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              big,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) =>
                                  const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}