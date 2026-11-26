import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/searchcategory.dart';
import 'package:sccm_kiosk/UI/store_information.dart';
import 'package:sccm_kiosk/UI/subcategory.dart';
import 'package:sccm_kiosk/widgets/fx.dart';

// ---- Easy size settings (change these numbers to resize) ----
// Shop boxes: smaller number = smaller boxes (more per row).
const double _shopBoxWidth = 150;
// Category boxes: smaller number = smaller boxes.
const double _categoryBoxWidth = 165;
// Category logos (anchors etc.): biggest logo size in pixels.
const double _categoryLogoMax = 110;
// Category logos as a share of screen height (0.13 = 13%).
const double _categoryLogoShare = 0.16;
// --------------------------------------------------------------

const List<Color> _accents = [
  Color(0xFFF59E0B),
  Color(0xFF22C55E),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFA855F7),
];

const List<String> _letters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
];

const List<String> _floors = [
  'Lower Ground Floor',
  'Upper Ground Floor',
  'First Floor',
  'Second Floor',
  'Third Floor',
  'Fourth Floor',
  'Fifth Floor',
];

class Categories extends StatefulWidget {
  final dynamic dbbeacon;
  const Categories(this.dbbeacon, {super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  dynamic get dbbeacon => widget.dbbeacon;

  List<dynamic>? allStores;
  List<dynamic>? categories;
  List<dynamic>? letterStores;
  List<dynamic>? floorStores;
  String letter = 'A';
  String floor = 'Lower Ground Floor';
  int _loadRetries = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Stores are downloaded by the first screen, so keep checking for a while
  // if the local database is still empty.
  Future<void> _load() async {
    final all = await dbbeacon.queryAllRows();
    final cats = await dbbeacon.querycategories();
    final byLetter = await dbbeacon.queryalpabet(letter);
    final byFloor = await dbbeacon.queryfloorwise(floor);
    if (!mounted) return;
    setState(() {
      allStores = all;
      categories = cats;
      letterStores = byLetter;
      floorStores = byFloor;
    });
    if (all.isEmpty && _loadRetries < 15) {
      _loadRetries++;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _load();
      });
    }
  }

  void _openStore(dynamic store) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => StoreInformation(store)));
  }

  // ---------- small building blocks ----------

  Widget _message(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: FadeSlideIn(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 22),
          ),
        ),
      ),
    );
  }

  Widget _loadingGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _shopBoxWidth,
        childAspectRatio: 0.92,
      ),
      itemCount: 10,
      itemBuilder: (context, i) => const Padding(
        padding: EdgeInsets.all(8),
        child: ShimmerBox(radius: 24),
      ),
    );
  }

  Widget _storeGrid(List<dynamic> stores) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _shopBoxWidth,
        childAspectRatio: 0.92,
      ),
      itemCount: stores.length,
      itemBuilder: (context, i) {
        final store = stores[i];
        return _StoreTile(
          store: store,
          index: i,
          onTap: () => _openStore(store),
        );
      },
    );
  }

  Widget _chips(List<String> labels, String selected, ValueChanged<String> onSelect) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        itemCount: labels.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final label = labels[i];
          final sel = label == selected;
          return TapScale(
            onTap: () => onSelect(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: label.length > 2 ? 22 : 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: sel
                    ? const Color(0xFF7C3AED)
                    : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: sel ? const Color(0xFFA78BFA) : Colors.white24,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.55),
                          blurRadius: 16,
                        ),
                      ]
                    : const [],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filteredTab({
    required List<String> labels,
    required String selected,
    required ValueChanged<String> onSelect,
    required List<dynamic>? stores,
  }) {
    return Column(
      children: [
        _chips(labels, selected, onSelect),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, 0.04), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey<String>(selected),
              child: stores == null
                  ? _loadingGrid()
                  : stores.isEmpty
                      ? _message('No stores found here.')
                      : _storeGrid(stores),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryGrid(List<dynamic> cats) {
    final h = MediaQuery.of(context).size.height;
    final iconSize =
        (h * _categoryLogoShare).clamp(60.0, _categoryLogoMax).toDouble();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _categoryBoxWidth,
        childAspectRatio: 0.9,
      ),
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final cat = cats[i];
        final accent = _accents[i % _accents.length];
        final name = cat['storecategoryname'].toString();
        final image =
            'http://api.sccm.in${cat['storecategoryimage'].toString()}';
        return FadeSlideIn(
          delay: Duration(milliseconds: 45 * (i % 14)),
          offset: const Offset(0, 0.2),
          child: Floating(
            phase: i * 0.09,
            amplitude: 3,
            child: TapScale(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SubCategory(
                        cat['storecategoryname'].toString(),
                        dbbeacon,
                        cat['storecategoryid'].toString())));
              },
              child: FxCard(
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.45),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Image.network(
                          image,
                          height: iconSize,
                          width: iconSize,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => Icon(
                            Icons.storefront,
                            color: accent,
                            size: iconSize * 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stores = allStores;
    final cats = categories;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const FadeSlideIn(
            child: Text(
              'Sarath City Capital Mall',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TapScale(
                onTap: () {
                  if (stores != null) {
                    showSearch<dynamic>(
                      context: context,
                      delegate: CustomDelegate(stores, false, dbbeacon),
                    );
                  }
                },
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.30,
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Search Store',
                            style: TextStyle(color: Colors.white70)),
                        Icon(Icons.search, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: 1),
                tabs: const [
                  Tab(text: 'ALL'),
                  Tab(text: 'CATEGORIES'),
                  Tab(text: 'A-Z'),
                  Tab(text: 'FLOOR WISE'),
                ],
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
        body: TabBarView(
          children: [
            // ALL
            stores == null
                ? _loadingGrid()
                : stores.isEmpty
                    ? _message(
                        'No stores to show yet.\nStores are downloaded from the server - please check the internet connection.')
                    : _storeGrid(stores),
            // CATEGORIES
            cats == null
                ? _loadingGrid()
                : cats.isEmpty
                    ? _message('No categories to show yet.')
                    : _categoryGrid(cats),
            // A-Z
            _filteredTab(
              labels: _letters,
              selected: letter,
              stores: letterStores,
              onSelect: (value) async {
                final result = await dbbeacon.queryalpabet(value);
                if (!mounted) return;
                setState(() {
                  letter = value;
                  letterStores = result;
                });
              },
            ),
            // FLOOR WISE
            _filteredTab(
              labels: _floors,
              selected: floor,
              stores: floorStores,
              onSelect: (value) async {
                final result = await dbbeacon.queryfloorwise(value);
                if (!mounted) return;
                setState(() {
                  floor = value;
                  floorStores = result;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Pops in (scale + fade) after a delay, with a little overshoot.
class _PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _PopIn({required this.child, this.delay = Duration.zero});

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
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
class _StoreTile extends StatelessWidget {
  final dynamic store;
  final int index;
  final VoidCallback onTap;
  const _StoreTile({
    required this.store,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accents[index % _accents.length];
    final name = store['storename'].toString();
    final logo = store['storelogo'].toString();
    final floorText = (store['storefloor'] ?? '').toString();

    return _PopIn(
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