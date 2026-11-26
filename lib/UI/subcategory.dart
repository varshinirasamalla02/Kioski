import 'package:flutter/material.dart';
import 'package:sccm_kiosk/UI/store_information.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/store_tile.dart';

// Shop box width: smaller number = smaller boxes (more per row).
const double _shopBoxWidth = 150;

class SubCategory extends StatefulWidget {
  final String name;
  final dynamic dbbeacon;
  final String catid;
  const SubCategory(this.name, this.dbbeacon, this.catid, {super.key});

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  List<dynamic>? stores;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.dbbeacon.querysubcategorydata(widget.catid);
    if (!mounted) return;
    setState(() {
      stores = result;
    });
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

  Widget _countPill(int count) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 150),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 4, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            count == 1 ? '1 store' : '$count stores',
            style: const TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = stores;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FadeSlideIn(
          child: Text(
            widget.name,
            style: const TextStyle(
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
      body: list == null
          ? _loadingGrid()
          : list.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No stores found in this category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 22),
                    ),
                  ),
                )
              : Column(
                  children: [
                    _countPill(list.length),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: _shopBoxWidth,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final store = list[i];
                          return StoreTile(
                            store: store,
                            index: i,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      StoreInformation(store)));
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}