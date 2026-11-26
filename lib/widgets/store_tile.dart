import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

const List<Color> _tileAccents = [
  Color(0xFFF59E0B),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFA855F7),
];

/// Pops in (scale + fade) after a delay, with a little overshoot.
class PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const PopIn({required this.child, this.delay = Duration.zero});

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));
  late final Animation<double> _scale =
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: const Interval(0, 0.6));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1).animate(_scale),
        child: widget.child,
      ),
    );
  }
}

/// One shop card: pops in, floats gently, logo zooms in, accent bar sweeps
/// across, and it shrinks a little while pressed.
class StoreTile extends StatelessWidget {
  final dynamic store;
  final int index;
  final VoidCallback onTap;
  const StoreTile({
    required this.store,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _tileAccents[index % _tileAccents.length];
    final name = store['storename'].toString();
    final logo = store['storelogo'].toString();
    final floorText = (store['storefloor'] ?? '').toString();

    return PopIn(
      delay: Duration(milliseconds: 40 * (index % 15)),
      child: Floating(
        phase: (index % 9) * 0.11,
        amplitude: 3,
        period: Duration(milliseconds: 3400 + (index % 5) * 300),
        child: TapScale(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.32),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      // logo zooms in with a little bounce
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.75, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: Image.network(
                          logo,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: accent),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) => Center(
                            child: Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withOpacity(0.15),
                              ),
                              child: Text(
                                name.isEmpty ? '?' : name[0].toUpperCase(),
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(6, 9, 6, 6),
                        color: accent.withOpacity(0.12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF1B1B2F),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            if (floorText.isNotEmpty && floorText != 'null')
                              Text(
                                floorText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF6B6B80), fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                      // accent bar that sweeps across the top of the name strip
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1100),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: v,
                              child: child,
                            ),
                          ),
                          child: Container(height: 3, color: accent),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}