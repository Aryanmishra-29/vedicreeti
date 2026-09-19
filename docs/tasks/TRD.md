# Technical Requirements Document (TRD)

## 1. Tech Stack Overview
- **Framework:** Flutter (Dart) 
- **Minimum OS Requirements:** iOS 13.0+, Android API 24 (7.0)+
- **Backend Service:** Supabase (Database, Auth)
- **External APIs:** Vercel serverless function (Panchang calculation)
- **State Management:** Mix of `StatefulWidget`, `ValueNotifier`, and Singleton Controllers.
- **Local Database:** `Hive` (NoSQL Key-Value store)

## 2. Key Dependencies & Packages
- `supabase_flutter`: Official SDK for DB, Auth, and Edge Functions.
- `just_audio`: Handles background audio streaming and precise playback controls for Shlokas.
- `hive_flutter`: Extremely fast local storage for caching API responses and preferences.
- `easy_localization`: Handles JSON-based translation files (EN, HI, MR).
- `flutter_dotenv`: Manages secure environment variables (`.env`).
- `razorpay_flutter`: Native wrapper for the Razorpay payment gateway.
- `firebase_messaging`: Push notifications via FCM.

## 3. Environment Setup
The project requires a `.env` file at the root directory containing:
```
SUPABASE_URL=https://[YOUR_PROJECT_ID].supabase.co
SUPABASE_ANON_KEY=[YOUR_ANON_KEY]
PANCHANG_API_KEY=[YOUR_API_KEY]
RAZORPAY_KEY=[YOUR_RAZORPAY_TEST_KEY]
```

## 4. Performance Standards
- **Memory Footprint:** The app must aggressively release resources (e.g., disposing `AudioPlayer`, `AnimationController`, and canceling `Timer`s in `LivePanchangCard`).
- **API Deduplication:** The `PanchangService` must map identical simultaneous API requests to a single `Future` to prevent 429 Rate Limits and redundant payload parsing.
- **UI Thread:** Heavy JSON parsing must be offloaded to `compute` isolates if payloads exceed 2MB.

## 5. Security Protocols
- **API Keys:** Never hardcode keys in Dart code; always utilize `flutter_dotenv`.
- **User Data:** Utilize Supabase RLS to guarantee data isolation.
- **Authentication:** Enforce Native SDKs for Auth rather than manual Edge Function JWT generation.
- **Jailbreak Detection:** Utilize `flutter_jailbreak_detection` to prevent app execution on compromised devices (WIP).
