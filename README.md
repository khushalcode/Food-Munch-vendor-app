# Food Munch: Vendor App

The store owner app. Manage incoming orders, items, add-ons, campaigns, staff and earnings.

| | |
|---|---|
| Package | `com.foodmunch.vendor` |
| Version | 1.0.1+3 |
| Flutter / Dart | Flutter 3.44+ (stable), Dart `^3.10.0` |
| Backend | `https://foodmunch.com` |

## Features

- **Orders:** realtime order alerts with sound, accept / reject / edit, status updates, receipt printing over Bluetooth thermal printers
- **Catalog:** items, add-ons, categories, coupons, campaigns, advertisements, banners
- **Finance:** reports with charts, disbursements, payment methods, subscription plans
- **Store:** profile, business settings, delivery men, reviews, chat, rental module
- **Extras:** AI helpers, reels, foreground service for background order alerts, multi-language (EN, AR, BN, ES)

## Folder structure

```
lib/
├── api/
├── common/
├── features/     # addon, advertisement, campaign, coupon, dashboard, deliveryman,
│                 # disbursement, order, order_edit, reports, review, store,
│                 # subscription, rental_module, reels, ...
├── helper/
├── interface/
├── theme/
├── util/
└── main.dart
```

Every feature folder follows `controllers / domain / screens / widgets`.

## Run and build

```bash
flutter pub get
flutter run
flutter build apk --release --split-per-abi
```

## Configuration

- App name and backend URL: `lib/util/app_constants.dart`
- Firebase: `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
- Google Maps key: `AndroidManifest.xml` (`com.google.android.geo.API_KEY`)
- Bluetooth printing needs Bluetooth permissions granted on the device
- Signing: see the [root README](../README.md#release-signing)

## CI

Built automatically as `vendor-apk` by the [root workflow](../.github/workflows/build-apk.yml).