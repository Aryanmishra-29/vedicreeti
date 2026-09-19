# Brain Matrix: VedicReeti V2

## Project Identity
**VedicReeti V2** is defined as an enterprise-grade platform operating under the **AXON NEURAL** engineering standards. It is designed to be highly resilient, offline-capable, and exceptionally performant while maintaining premium visual aesthetics.

## Current State Analysis (V1 UI)
The existing V1 legacy codebase features a robust, premium UI architecture that must be preserved:
- **UI Architecture & Widgets**: The app uses a highly polished widget set, including `CarouselSlider` for featured banners, `BackdropFilter` for sophisticated glassmorphism effects (e.g., the mini audio player), `CachedNetworkImage` for seamless media loading, and custom-built components like `LuxuryShimmer` and `LivePanchangCard`. The design system heavily leverages Google Fonts (Playfair Display, Montserrat) and a curated premium color palette (Gold, Dark Midnight).
- **State Management**: The app utilizes lightweight, native state management techniques. `ValueNotifier` handles global reactive states such as `ThemeMode` (`themeNotifier`) and audio playback states in `GlobalAudioService`. `FutureBuilder` is used extensively for asynchronous data rendering directly from Supabase, and `setState` handles local widget state.
- **CRITICAL DIRECTIVE**: This UI is highly approved by all stakeholders. It **MUST NOT be altered visually under any circumstances**.

## The Data Layer Upgrade Plan
The legacy data layer currently relies on rudimentary `SharedPreferences` for basic caching (`CacheService`) and direct Supabase client calls within UI files.
The strategic roadmap to replace this with our new strictly defined stack is as follows:
1. **Hive Integration**: Introduce and implement `Hive` as the primary local database for 100% offline-first caching. Complex objects and lists will be stored in Hive boxes.
2. **Supabase Secure Auth & RLS**: Standardize all backend interactions through Supabase, ensuring secure Authentication and enforcing Row Level Security (RLS) on all queries.
3. **Repository Abstraction**: Abstract all data fetching into dedicated repository classes that orchestrate the interaction between the local Hive cache and the remote Supabase database.

## Strict Rules of Engagement
- **Rule 1**: Zero modifications to visual UI padding, colors, layout constraints, or existing styling.
- **Rule 2**: All new caching logic must seamlessly wrap around existing UI components (e.g., intercepting the Future before it reaches `FutureBuilder`).
- **Rule 3**: Any new data fetching must prioritize local Hive cache before network execution. Network calls should act as background refresh mechanisms to update the cache.
