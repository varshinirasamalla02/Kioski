import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/searchdine.dart';
import 'package:sccm_kiosk/UI/store_information.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/store_tile.dart';

// ---- Easy size setting ----
// Shop boxes: smaller number = smaller boxes (more per row).
const double _shopBoxWidth = 150;
// ---------------------------

const Color _dineMain = Color(0xFFF97316);
const Color _dineLight = Color(0xFFFDBA74);

// Floors that have food courts (same as the original app).
const List<String> _foodFloors = ['Lower Ground Floor', 'Fourth Floor'];

class DineDashboard extends StatefulWidget {
  final dynamic dbbeacon;
  const DineDashboard(this.dbbeacon, {super.key});

  @override
  State<DineDashboard> createState() => _DineDashboardState();
}

class _DineDashboardState extends State<DineDashboard> {
  dynamic get dbbeacon => widget.dbbeacon;

  List<dynamic>? allFood;
  List<dynamic>? cafes;
  List<dynamic>? bars;
  List<dynamic>? floorFood;
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
    final all = await dbbeacon.queryallfood();
    final cafeList = await dbbeacon.querycafes();
    final barList = await dbbeacon.querybars();
    final byFloor = await dbbeacon.queryfloorwisefood(floor);
    if (!mounted) return;
    setState(() {
      allFood = all;
      cafes = cafeList;
      bars = barList;
      floorFood = byFloor;
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
        child: ShimmerBox(radius: 22),
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
        return StoreTile(
          store: store,
          index: i,
          onTap: () => _openStore(store),
        );
      },
    );
  }

  Widget _tab(List<dynamic>? stores, String emptyText) {
    if (stores == null) return _loadingGrid();
    if (stores.isEmpty) return _message(emptyText);
    return _storeGrid(stores);
  }

  Widget _floorChips() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        itemCount: _foodFloors.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final label = _foodFloors[i];
          final sel = label == floor;
          return TapScale(
            onTap: () async {
              final result = await dbbeacon.queryfloorwisefood(label);
              if (!mounted) return;
              setState(() {
                floor = label;
                floorFood = result;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: sel ? _dineMain : Colors.white.withOpacity(0.08),
                border: Border.all(color: sel ? _dineLight : Colors.white24),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: _dineMain.withOpacity(0.55),
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

  Widget _foodCourtsTab() {
    final list = floorFood;
    return Column(
      children: [
        _floorChips(),
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
              key: ValueKey<String>(floor),
              child: _tab(list, 'No food courts found on this floor.'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = allFood;
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
              'Dining',
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
                  if (all != null) {
                    showSearch<dynamic>(
                      context: context,
                      delegate: CustomDelegateDine(all, false, dbbeacon),
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
                        Text('Search food court',
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
                    colors: [Color(0xFFF97316), Color(0xFFEC4899)],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: 1),
                tabs: const [
                  Tab(text: 'ALL'),
                  Tab(text: 'CAFES / RESTAURANTS'),
                  Tab(text: 'FOOD COURTS'),
                  Tab(text: 'BARS'),
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
            _tab(
              all,
              'No dining places to show yet.\nStores are downloaded from the server - please check the internet connection.',
            ),
            _tab(cafes, 'No cafes or restaurants found.'),
            _foodCourtsTab(),
            _tab(bars, 'No bars found.'),
          ],
        ),
      ),
    );
  }
}