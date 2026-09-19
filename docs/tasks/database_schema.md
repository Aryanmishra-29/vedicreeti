# Database Schema & Data Models

## 1. Supabase (PostgreSQL)

### 1.1 Table: `users` (Managed by Supabase Auth)
- `id` (uuid, primary key)
- `email` (text, unique)
- `created_at` (timestamp)
- `raw_user_meta_data` (jsonb, stores `full_name`)

### 1.2 Table: `products`
- `id` (uuid, primary key)
- `name` (text)
- `description` (text)
- `price` (numeric)
- `image_url` (text)
- `category` (text)
- `is_featured` (boolean)
- `created_at` (timestamp)

### 1.3 Table: `pujas`
- `id` (uuid, primary key)
- `title` (text)
- `description` (text)
- `base_price` (numeric)
- `duration_hours` (numeric)
- `pandit_required` (boolean)
- `created_at` (timestamp)

### 1.4 Table: `wishlist`
- `id` (uuid, primary key)
- `user_id` (uuid, references auth.users)
- `item_id` (uuid, references products/pujas)
- `item_type` (text - 'product' or 'puja')
- `created_at` (timestamp)
*RLS Policy:* Users can only insert/select/delete rows where `user_id = auth.uid()`.

## 2. Hive (Local Caching)

### 2.1 Box: `coreCache`
- **Purpose:** Key-Value store for API responses to enable offline mode and reduce bandwidth.
- **Keys:**
  - `panchang_{YYYY-MM-DD}`: JSON string of Vercel Panchang API response.
  - `featured_products`: JSON string of Supabase products list.
  - `festivals_list`: JSON string of upcoming festivals.

### 2.2 Box: `userPreferences`
- **Purpose:** Store non-sensitive user settings.
- **Keys:**
  - `theme_mode`: 'light' | 'dark' | 'system'
  - `language`: 'en' | 'hi' | 'mr'
  - `notifications_enabled`: boolean
