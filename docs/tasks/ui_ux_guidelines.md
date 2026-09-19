# UI/UX Guidelines & Rules

## 1. Design Philosophy
VedicReeti's design philosophy is "Premium Luxury". The interface must evoke a sense of spiritual calmness, richness, and trustworthiness.

### 1.1 Color Palette
- **Primary:** Premium Gold (`#C9A227` / `#D4AF37`)
- **Background (Dark):** Midnight Obsidian (`#0A0A0C` / `#141416`)
- **Background (Light):** Soft Ivory/Cream (`#FAF7F2`)
- **Accents:** Terracotta Orange (`#E8520A`), Soft Lilac/Blue (`#8C9EFF`) for astromical data.

## 2. Strict UI Rules

### Rule 2.1: The Zero Overflow Rule
- **Description:** RenderFlex overflows (yellow tape) are strictly unacceptable, even fractional (1.3 pixels).
- **Enforcement:** 
  - Never use hardcoded heights on containers wrapping dynamic text without `Flexible` or `Expanded`.
  - Always apply `TextOverflow.ellipsis` for multiline descriptions.
  - Wrap top-level body columns in `SingleChildScrollView` or `ListView.separated`.
  - Enforce `fontFeatures: [FontFeature.tabularFigures()]` on ticking clocks to prevent horizontal layout shifting.

### Rule 2.2: Premium Loading States
- **Description:** Basic `CircularProgressIndicator` elements are banned in main feeds.
- **Enforcement:** Use structured skeleton screens (`PremiumSkeletonCard`) wrapped in `Shimmer.fromColors`. Shimmer base/highlight colors must dynamically adapt to dark/light themes.

### Rule 2.3: Glassmorphism & Depth
- **Description:** Cards should float elegantly above the background.
- **Enforcement:** Use `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))` with translucent black/white backgrounds and subtle borders (0.5 to 1.0 width).

## 3. Typography
- **Primary Font:** Noto Sans Devanagari (or system sans-serif like Roboto/San Francisco).
- **Hierarchy:** 
  - Headers: Bold, high contrast.
  - Subtext: 50%-70% opacity, slightly smaller font size (10-12px) to reduce clutter.
