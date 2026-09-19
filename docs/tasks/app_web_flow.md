# App Flow Diagram

## 1. User Journey Flow

```mermaid
graph TD
    A[Splash Screen] -->|Initialization & Auth Check| B{Is User Logged In?}
    B -->|Yes| C[Home Screen]
    B -->|No| D[Auth Bottom Sheet / Screen]
    
    D -->|Sign Up / Login| C
    D -->|Forgot Password| E[Reset Link Sent]
    E -->|User clicks email link| F[UpdatePasswordScreen]
    F -->|Password Saved| C

    C -->|Tap Panchang Card| G[Live Panchang Screen]
    C -->|Tap Puja Card| H[Puja Details Screen]
    C -->|Tap Product Card| I[Product Details Screen]
    C -->|Tap Shloka/Aarti| J[Audio Player Screen]

    H -->|Book Now| K[Checkout Flow]
    I -->|Add to Cart| K
    
    K --> L[Razorpay Payment Gateway]
    L -->|Success| M[Order Confirmation Screen]
    L -->|Failure| N[Payment Failed Snackbar]
```

## 2. Navigation Architecture
- **Root Navigator:** Handles top-level transitions (`SplashScreen` -> `HomeScreen`). Also catches Deep Links via the Global `navigatorKey` (e.g., routing to `UpdatePasswordScreen`).
- **Bottom Navigation Bar (Custom):** 
  - `Home`: The primary dashboard containing horizontal carousels.
  - `Wishlist`: Saved Pujas and Products.
  - `Profile`: Settings, Orders, and Localization toggles.
- **Modals & Overlays:** Authentication, Language Pickers, and Quick-Cart interactions are handled via Bottom Sheets to keep the user anchored.
