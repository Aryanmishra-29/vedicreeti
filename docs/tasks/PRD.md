# Product Requirements Document (PRD)

## 1. Product Overview
**Name:** VedicReeti
**Platform:** Mobile App (Flutter - iOS/Android)
**Description:** A premium, luxury-focused spiritual and astrological companion app. VedicReeti provides users with daily live panchang (astrological timings), localized devotional audio (aartis, chalisa, shlokas), premium puja booking services, festival tracking, and an e-commerce platform for spiritual goods.

## 2. Target Audience
- Devout practitioners of Sanatan Dharma seeking accurate, live daily rituals (Panchang).
- Users looking to book verified, premium Puja experiences.
- Users looking for a modern, ad-free, aesthetically premium spiritual app.
- Multi-lingual users (Hindi, Marathi, English).

## 3. Core Features

### 3.1 Live Panchang & Astrology
- **Real-Time Data:** Integrates with a Vercel-hosted API to fetch accurate, geo-specific Panchang data (Tithi, Nakshatra, Sunrise/Sunset, Muhurtas).
- **Caching:** Uses Hive local storage to cache data, preventing redundant API calls and allowing offline reading.

### 3.2 Devotional Content
- **Audio Player:** High-quality playback of Bhajans, Aartis, and Shlokas via `just_audio`.
- **Lyrics:** Synchronized or static lyrics available in multiple languages.

### 3.3 Puja Booking & E-Commerce
- **Puja Services:** Browse and book complex Vedic rituals.
- **Store:** Premium spiritual products and idols.
- **Checkout:** Integrated secure checkout (Razorpay).

### 3.4 Personalization
- **Multi-Lingual:** Powered by `easy_localization` (EN, HI, MR).
- **Reminders:** Native notifications for upcoming fasting days (Vrats) and festivals via `Firebase Cloud Messaging`.
- **Wishlist:** Users can save Pujas and Products.

## 4. Non-Functional Requirements
- **Performance:** 60fps scrolling, minimal layout jitter (Zero Overflow rule), localized state changes.
- **Security:** Secure authentication via Supabase (email/password & OTP). API keys secured via `flutter_dotenv`.
- **UX/UI:** "Premium Luxury" design language. Strict adherence to Zero Overflow rules. Smooth skeleton loading screens (`PremiumSkeletonCard`).

## 5. Success Metrics
- Daily Active Users (DAU) engaging with the Panchang card.
- Conversion rate for premium Puja bookings.
- App store rating (Target: 4.8+).
