import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

/// Right-hand glass panel: logo, clock, date, QR code, socials.
class KioskInfoPanel extends StatelessWidget {
  final DateTime now;
  final VoidCallback? onWebsiteTap;
  const KioskInfoPanel(this.now, {super.key, this.onWebsiteTap});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June',
    'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _ordinal(int d) {
    if (d >= 11 && d <= 13) return '${d}th';
    switch (d % 10) {
      case 1:
        return '${d}st';
      case 2:
        return '${d}nd';
      case 3:
        return '${d}rd';
      default:
        return '${d}th';
    }
  }

  Widget _social(Size size, String asset, String handle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Image.asset(asset, width: size.height * 0.032),
        ),
        const SizedBox(width: 10),
        Text(handle,
            style: TextStyle(
                color: Colors.white, fontSize: size.height * 0.018)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = now;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 22, 28, 14),
      child: FadeSlideIn(
        offset: const Offset(0.12, 0),
        delay: const Duration(milliseconds: 250),
        child: GlassCard(
          radius: 32,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: SizedBox(
                  height: size.height * 0.09,
                  child:
                      Image.asset('assets/mall_logo.png', fit: BoxFit.contain),
                ),
              ),
              Column(
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${_two(t.hour)}:${_two(t.minute)}',
                      children: [
                        TextSpan(
                          text: ':${_two(t.second)}',
                          style: TextStyle(
                              fontSize: size.height * 0.035,
                              color: Colors.white60),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: size.height * 0.07,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '${_ordinal(t.day)} ${_months[t.month - 1]} ${t.year}, ${_days[t.weekday - 1]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70, fontSize: size.height * 0.022),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('SCAN HERE TO DOWNLOAD',
                      style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 2,
                          fontSize: size.height * 0.015)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Image.asset('assets/scan_here_image.png',
                        width: size.height * 0.15),
                  ),
                  const SizedBox(height: 8),
                  Text('Available now',
                      style: TextStyle(
                          color: Colors.white, fontSize: size.height * 0.018)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/android_gplay_icon.png',
                          height: size.height * 0.05),
                      const SizedBox(width: 14),
                      Image.asset('assets/ios_iplay_icon.png',
                          height: size.height * 0.05),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  _social(size, 'assets/facebook_icon.png',
                      '@sarathcitycapitalmall'),
                  const SizedBox(height: 8),
                  _social(
                      size, 'assets/insta_icon.png', '@sarathcitycapitalmall'),
                  const SizedBox(height: 8),
                  _social(size, 'assets/twitter_icon.png',
                      '@sarathcitycapitalmall'),
                ],
              ),
              InkWell(
                onTap: onWebsiteTap,
                child: Text('www.sarathcitycapitalmall.com',
                    style: TextStyle(
                        color: Colors.white54, fontSize: size.height * 0.016)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
