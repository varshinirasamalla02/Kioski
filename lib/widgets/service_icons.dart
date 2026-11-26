/// Finds the bundled icon for a service by its name (used when the server
/// image can't be loaded, and on the service detail page).
String? serviceAssetFor(String name) {
  final n = name.toLowerCase();
  const keys = <String, String>{
    'baggage': 'bagage',
    'wheel': 'wheel_chair',
    'wifi': 'wifi',
    'family': 'family_restrooms',
    'handicap': 'handicap_restrooms',
    'valet': 'valet_parking',
    'lost': 'lost_and_found',
    'information': 'info_desk',
    'escalator': 'escalators',
    'elevator': 'elevators',
    'cab': 'cabs_pickup_point',
    'taxi': 'cabs_pickup_point',
    'atm': 'atms',
    'security': 'security',
    'stroller': 'baby',
    'baby': 'baby',
  };
  for (final e in keys.entries) {
    if (n.contains(e.key)) return 'assets/service/${e.value}.png';
  }
  return null;
}