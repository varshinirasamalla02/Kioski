import 'package:flutter/material.dart';
import 'package:sccm_kiosk/widgets/fx.dart';
import 'package:sccm_kiosk/widgets/store_tile.dart' show PopIn;

// ---- Easy size setting ----
// Event poster width: smaller number = smaller posters (more per row).
const double _eventBoxWidth = 190;
// ---------------------------

const Color _evA = Color(0xFF06B6D4);
const Color _evB = Color(0xFF7C3AED);

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

// Makes finished events look a little faded.
const List<double> _fadedMatrix = <double>[
  0.4, 0.5, 0.1, 0, 0,
  0.2, 0.7, 0.1, 0, 0,
  0.2, 0.5, 0.3, 0, 0,
  0, 0, 0, 1, 0,
];

String _clean(dynamic v) {
  final s = (v ?? '').toString().trim();
  return (s.isEmpty || s.toLowerCase() == 'null') ? '' : s;
}

String _fmtDate(dynamic v, {bool withYear = true}) {
  final raw = _clean(v);
  if (raw.isEmpty) return '';
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  final base = '${d.day} ${_months[d.month - 1]}';
  return withYear ? '$base ${d.year}' : base;
}

String _dateRange(dynamic start, dynamic end) {
  final a = _fmtDate(start);
  final b = _fmtDate(end);
  if (a.isEmpty) return b;
  if (b.isEmpty || a == b) return a;
  return '$a - $b';
}

String _stripHtml(String s) {
  return s
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class Events extends StatefulWidget {
  final dynamic dbevent;
  const Events(this.dbevent, {super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  dynamic get dbevent => widget.dbevent;

  List<dynamic>? upcoming;
  List<dynamic>? past;
  int _loadRetries = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Events are downloaded by the first screen, so keep checking for a while
  // if the local database is still empty.
  Future<void> _load() async {
    final p = await dbevent.queryevents('Past');
    final u = await dbevent.queryevents('Upcoming');
    if (!mounted) return;
    setState(() {
      past = p;
      upcoming = u;
    });
    if (p.isEmpty && u.isEmpty && _loadRetries < 15) {
      _loadRetries++;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _load();
      });
    }
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
        maxCrossAxisExtent: _eventBoxWidth,
        childAspectRatio: 0.72,
      ),
      itemCount: 8,
      itemBuilder: (context, i) => const Padding(
        padding: EdgeInsets.all(8),
        child: ShimmerBox(radius: 24),
      ),
    );
  }

  Widget _grid(List<dynamic>? events, String emptyText, bool isPast) {
    if (events == null) return _loadingGrid();
    if (events.isEmpty) return _message(emptyText);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _eventBoxWidth,
        childAspectRatio: 0.72,
      ),
      itemCount: events.length,
      itemBuilder: (context, i) {
        final event = events[i];
        return _EventCard(
          event: event,
          index: i,
          isPast: isPast,
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => _EventDetail(event)));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const FadeSlideIn(
            child: Text(
              'Events',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
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
                  gradient: const LinearGradient(colors: [_evA, _evB]),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: 1),
                tabs: const [
                  Tab(text: 'UPCOMING EVENTS'),
                  Tab(text: 'PAST EVENTS'),
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
            _grid(upcoming, 'No upcoming events right now.', false),
            _grid(past, 'No past events.', true),
          ],
        ),
      ),
    );
  }
}

/// One event poster: image fills the card, name + date sit on a soft shade.
class _EventCard extends StatelessWidget {
  final dynamic event;
  final int index;
  final bool isPast;
  final VoidCallback onTap;
  const _EventCard({
    required this.event,
    required this.index,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = _clean(event['EventName']);
    final url = _clean(event['ImageUrl']);
    final date = _fmtDate(event['StartDate'], withYear: false);

    Widget poster = Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ShimmerBox(radius: 0);
      },
      errorBuilder: (context, error, stack) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_evB, _evA],
          ),
        ),
        child: const Center(
          child: Icon(Icons.event, color: Colors.white70, size: 46),
        ),
      ),
    );
    if (isPast) {
      poster = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_fadedMatrix),
        child: poster,
      );
    }

    return PopIn(
      delay: Duration(milliseconds: 45 * (index % 14)),
      child: Floating(
        phase: (index % 9) * 0.11,
        amplitude: 3,
        period: Duration(milliseconds: 3400 + (index % 5) * 300),
        child: TapScale(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isPast ? Colors.black : _evB).withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  poster,
                  // shade so the text is always readable
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.82),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.15,
                            ),
                          ),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 11, color: Color(0xFF67E8F9)),
                                const SizedBox(width: 5),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: Color(0xFF67E8F9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (isPast)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: const Text(
                          'ENDED',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
}

/// Event page: big poster you can zoom, plus the event details.
class _EventDetail extends StatelessWidget {
  final dynamic event;
  const _EventDetail(this.event);

  Widget _row(IconData icon, String label, String value, int order) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 300 + 100 * order),
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
                color: _evA.withOpacity(0.22),
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
                  Text(
                    value,
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

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final name = _clean(event['EventName']);
    final url = _clean(event['ImageUrl']);
    final dates = _dateRange(event['StartDate'], event['EndDate']);
    final open = _clean(event['OpenTime']);
    final close = _clean(event['CloseTime']);
    final timing = (open.isNotEmpty && close.isNotEmpty) ? '$open - $close' : open;
    final age = _clean(event['AgeGroup']);
    final contact = _clean(event['ContactNo']);
    final website = _clean(event['WebsiteUrl']);
    final desc = _stripHtml(_clean(event['Description']));

    var order = 0;
    final rows = <Widget>[
      if (dates.isNotEmpty) _row(Icons.calendar_month, 'Date', dates, order++),
      if (timing.isNotEmpty) _row(Icons.access_time, 'Time', timing, order++),
      if (age.isNotEmpty) _row(Icons.group_outlined, 'Age group', age, order++),
      if (contact.isNotEmpty) _row(Icons.call_outlined, 'Contact', contact, order++),
      if (website.isNotEmpty) _row(Icons.language, 'Website', website, order++),
    ];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const FadeSlideIn(
          child: Text(
            'Event Details',
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
              flex: 38,
              child: FadeSlideIn(
                offset: const Offset(-0.08, 0),
                child: GlassCard(
                  radius: 32,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  child: SizedBox.expand(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 150),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: (h * 0.04).clamp(18.0, 28.0).toDouble(),
                                height: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...rows,
                          if (desc.isNotEmpty)
                            FadeSlideIn(
                              delay: Duration(milliseconds: 300 + 100 * order),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  desc,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 62,
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        InteractiveViewer(
                          minScale: 1,
                          maxScale: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: _evB),
                                );
                              },
                              errorBuilder: (context, error, stack) =>
                                  const Center(
                                child: Text(
                                  'Could not load the poster.',
                                  style: TextStyle(
                                      color: Color(0xFF6B6B80), fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 14,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF14162B).withOpacity(0.8),
                            ),
                            child: const Text(
                              'Pinch to zoom',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 1),
                            ),
                          ),
                        ),
                      ],
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
