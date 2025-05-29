# gymtrak

**gymtrak** is a cross-platform fitness and health tracking application built with Flutter. It helps users manage their workouts, medication plans, and bloodwork results, providing a comprehensive tool for personal health management.

## Features

- **Workout Tracking:** Log and monitor your workouts, exercises, and progress.
- **Medication Management:** Organize medication plans, set reminders, and manage medication folders.
- **Bloodwork Results:** Store, categorize, and review bloodwork results for easy reference.
- **Folder Organization:** Create, rename, and delete folders for both medication plans and bloodwork results.
- **Cross-Platform Support:** Runs on Windows, Linux, macOS, iOS, Android, and Web.
- **Notifications:** Receive reminders and notifications for important health events (requires permissions).

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Platform-specific requirements (Android Studio, Xcode, etc.)

### Installation

1. Clone the repository:
   ```sh
   git clone <your-repo-url>
   cd gymtrak/gymtrak
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

3. Run the app:
   - For mobile/web:
     ```sh
     flutter run
     ```
   - For desktop (Windows/Linux/macOS):
     ```sh
     flutter run -d windows
     # or
     flutter run -d linux
     # or
     flutter run -d macos
     ```

## Project Structure

- `lib/` - Main Dart source code (UI, logic, pages, utilities)
- `assets/` - Icons and other static assets
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` - Platform-specific code and configuration

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.

## License

This project is licensed under the MIT License.

---

*This project is under active development. Features and UI may change.*