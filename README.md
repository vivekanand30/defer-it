# Defer It

Defer It is an offline-first inbox for links, notes, and any content you want to revisit later. Capture ideas manually or directly from other apps via the share sheet, then set reminders so nothing slips through the cracks.

## 🚀 Features

- Material 3 adaptive interface with GetWidget components
- Organised dashboard tabs for Today, Upcoming, Overdue, and Done
- Quick add bottom sheet for shared or manual items with smart reminder presets
- Local storage powered by Drift (SQLite) and encrypted settings via secure storage
- Local notifications with snooze and done actions, managed in the background with Workmanager
- Works on Android, iOS, Web, Windows, macOS, and Linux

## 🧪 Development

Install Flutter 3.x and run the following commands from the project root:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter build apk
```

## 📁 Project Structure

See the `lib/` directory for the core app code, organised by feature and responsibility (models, database, services, screens, widgets, theme).

## 🛡️ License

This project is provided for educational purposes.
