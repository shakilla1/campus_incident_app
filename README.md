# Campus Incident App

Campus incident reporting app built with Flutter, Provider and Firebase.

## Setup

1. Create the Flutter project and copy these files over it:

       flutter create Campus Incident App

2. Add the packages:

       flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage provider image_picker

3. In the Firebase console create a project, then enable:
   - Authentication > Email/Password
   - Firestore Database
   - Storage

4. Connect the app to the project (this generates lib/firebase_options.dart):

       dart pub global activate flutterfire_cli
       flutterfire configure

5. Paste firebase/firestore.rules into Firestore > Rules and firebase/storage.rules into Storage > Rules, then publish both.

6. Android: set minSdk to 23 in android/app/build.gradle(.kts).
   iOS: add NSCameraUsageDescription and NSPhotoLibraryUsageDescription to ios/Runner/Info.plist.

7. Run on an emulator or phone:

       flutter run

## Creating a staff account

Everyone registers as a student. To make a staff account, register it normally, verify the email, then open Firestore > users > (that user's document) and change role from student to staff. Sign out and back in.

## Email domains

The allowed domains are in lib/utils/constants.dart (allowedEmailDomains) and in the regex inside firebase/firestore.rules. Change both if needed.
