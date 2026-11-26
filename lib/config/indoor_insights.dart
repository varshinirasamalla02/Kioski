/// Settings for the Indoor Insights live navigation site.
///
/// Change them here - every screen that shows the map uses these values.
const String indoorBaseUrl = 'https://sccm.indoorinsights.com/';

/// The kiosk's own position on the map (the entrance).
const String indoorKioskId = 'entrance-1';

/// Link that opens the map at the kiosk (used by the Navigation page).
const String indoorKioskUrl = '$indoorBaseUrl?kiosk=$indoorKioskId';

/// Optional: a link format that opens directions to a store directly.
/// Leave it empty to let the app search the store on the site automatically.
///
/// If you know the format, write it here using these placeholders:
///   {kiosk}  -> entrance-1        {storeId} -> the store id from the server
///   {name}   -> store name (URL-encoded)    {floor} -> floor (URL-encoded)
/// Example (only an example, not a real format):
///   '${indoorBaseUrl}?kiosk={kiosk}&destination={storeId}'
const String indoorDirectionsTemplate = '';

/// Show helpful messages in the console while the map is being driven.
const bool indoorDebugLogs = true;