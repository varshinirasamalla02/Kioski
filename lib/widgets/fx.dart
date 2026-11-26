// Reusable animation widgets for the kiosk app. No extra packages needed.
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Fades + slides its child in. Use `delay` to stagger several items.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset; // start offset as a fraction of the child's size
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.offset = const Offset(0, 0.15),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

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
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.offset, end: Offset.zero)
            .animate(_curve),
        child: widget.child,
      ),
    );
  }
}

/// Press feedback: shrinks slightly while pressed, springs back on release.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Slowly drifting colour "aurora" background. Put it behind your page:
/// Stack(children: [const AuroraBackground(), yourContent])
class AuroraBackground extends StatefulWidget {
  final List<Color> colors;
  final Color base;
  const AuroraBackground({
    super.key,
    this.base = const Color(0xFF05060F),
    this.colors = const [
      Color(0xFF7C3AED),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
    ],
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _AuroraPainter(_c.value, widget.colors, widget.base),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double t;
  final List<Color> colors;
  final Color base;
  _AuroraPainter(this.t, this.colors, this.base);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    for (var i = 0; i < colors.length; i++) {
      final a = 2 * math.pi * (t + i / colors.length);
      final center = Offset(
        size.width * (0.5 + 0.35 * math.cos(a + i)),
        size.height * (0.5 + 0.35 * math.sin(a * 0.8 + i * 2)),
      );
      final radius = size.shortestSide * 0.7;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[i].withOpacity(0.38), colors[i].withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}

/// Frosted-glass card with soft border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.blur = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Gently pulsing glow around a widget (good for "touch to start" buttons).
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double radius;
  const PulseGlow({
    super.key,
    required this.child,
    this.color = const Color(0xFF7C3AED),
    this.radius = 30,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.25 + 0.35 * _c.value),
                blurRadius: 12 + 24 * _c.value,
                spreadRadius: 1 + 5 * _c.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmering placeholder box for loading states.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;
  const ShimmerBox({super.key, this.width, this.height, this.radius = 16});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3 * _c.value, 0),
              end: Alignment(-0.5 + 3 * _c.value, 0),
              colors: [
                Colors.white.withOpacity(0.06),
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.06),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Text whose letters rise in one by one.
class AnimatedHeadline extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;
  const AnimatedHeadline(
    this.text, {
    super.key,
    this.style,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Wrap(
      children: [
        for (var i = 0; i < words.length; i++)
          FadeSlideIn(
            delay: delay + Duration(milliseconds: 90 * i),
            offset: const Offset(0, 0.4),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(words[i], style: style),
            ),
          ),
      ],
    );
  }
}

/// Slow up/down floating motion. Use `phase` (0..1) so neighbours don't move in sync.
class Floating extends StatefulWidget {
  final Widget child;
  final double amplitude;
  final Duration period;
  final double phase;
  const Floating({
    super.key,
    required this.child,
    this.amplitude = 6,
    this.period = const Duration(seconds: 4),
    this.phase = 0,
  });

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final dy =
            math.sin(2 * math.pi * (_c.value + widget.phase)) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

/// Smooth fade + slight slide page transition. Use instead of MaterialPageRoute:
/// Navigator.of(context).push(fadeRoute(const MyPage()));
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, animation, secondary, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Frosted card used for grid tiles / list items. Drop-in for `Card(child: ...)`.
class FxCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Clip clipBehavior;
  const FxCard({
    super.key,
    required this.child,
    this.radius = 20,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}

/// Glass-style text field decoration. Use: decoration: fxInput('Enter Name')
InputDecoration fxInput(String hint) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: border(Colors.white24),
    enabledBorder: border(Colors.white24),
    focusedBorder: border(const Color(0xFFA78BFA), 1.6),
    errorBorder: border(const Color(0xFFF87171)),
    focusedErrorBorder: border(const Color(0xFFF87171), 1.6),
  );
}

/// Fade + slight slide for every normal page push (used by fxTheme()).
class FxPageTransitionsBuilder extends PageTransitionsBuilder {
  const FxPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
            .animate(curved),
        child: child,
      ),
    );
  }
}

/// App-wide dark theme. Scaffolds are transparent so the aurora shows through.
ThemeData fxTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: const Color(0xFF14162B),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FxPageTransitionsBuilder(),
        TargetPlatform.iOS: FxPageTransitionsBuilder(),
        TargetPlatform.linux: FxPageTransitionsBuilder(),
        TargetPlatform.macOS: FxPageTransitionsBuilder(),
        TargetPlatform.windows: FxPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FxPageTransitionsBuilder(),
      },
    ),
  );
}

/// Wrap MaterialApp.builder with this so every screen sits on the aurora.
Widget fxAppBuilder(BuildContext context, Widget? child) {
  return Stack(
    fit: StackFit.expand,
    children: [
      const Positioned.fill(child: AuroraBackground()),
      if (child != null) child,
    ],
  );
}
