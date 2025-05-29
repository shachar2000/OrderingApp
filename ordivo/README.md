# Flutter Multi-Platform Application – Ordivo

A Flutter application that supports Android, iOS, Linux, macOS, Windows, and Web. The project includes a modern UI with multiple screens and is built using up-to-date Flutter technologies.

---

## Project Structure

- `lib/` – Main source code of the application:
  - `main.dart` – The main entry point of the app.
  - `pages/` – Contains the different screens of the app:
    - `home.dart`, `login.dart`, `register.dart`, `orders.dart`, and more.
    - `classes/` – Helper files for app logic (e.g., login/register services).

- `assets/` – Media and image files used in the app.

- `android/`, `ios/`, `linux/`, `macos/`, `windows/` – Configuration and runtime files for each platform.

- `web/` – Web deployment support.

---

## Technologies

- [Flutter](https://flutter.dev)
- [Dart](https://dart.dev)
- Full configuration for all supported platforms (Mobile + Desktop + Web)

---

## How to Run the Project

1. Install Flutter:  
   [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

2. Run the following command to fetch dependencies:

   ```bash
   flutter pub get

3. To run the app:

   ```bash
   flutter run

4. To run on a specific platform:

   ```bash
   flutter run -d chrome      # For Web  
   flutter run -d windows     # For Windows  
   flutter run -d linux       # For Linux  
   flutter run -d android     # For Android  
   flutter run -d macos       # For macOS  
