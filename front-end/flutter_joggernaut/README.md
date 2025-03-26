# Joggernaut Front-End

## Setup guide to run app on a virtual device

1. Install Flutter and Set Up Android Studio
  - Follow the official Flutter installation guide based on your operating system:  
    - [Flutter Installation](https://docs.flutter.dev/get-started/install/windows/mobile)

2. Set Up a Virtual Device in Android Studio
  - Open **Android Studio**
  - Navigate to **AVD Manager** (Android Virtual Device Manager)
  - Create and configure an emulator 

3. Run the Virtual Device and Connect to VS Code
  - Start the virtual device from **AVD Manager** or **VS Code** (sa right corner ng screen) or run:
  - Open your Flutter project in **VS Code**
  - Once virtual device is open and connected, run without debugging main.dart

4. Start the Backend Server
  - App should be good to go

## Setup guide to run app on your physical device

1. Change hostURL in `..\lib\utils\urls.dart`
  -  Replace `10.0.2.2` with the ip address of the device where you are running the backend server

2. Build and run the apk file
  - Run `flutter build apk` in `..front-end\flutter_jogernaut`
  - Locate `app-release.apk` in `..\front-end\flutter_joggernaut\build\app\outputs\flutter-apk`
  - Run the backend server `poetry run python manage.py runserver 0.0.0.0:8000`
  - Transfer the apk file to your physical device and install
  
