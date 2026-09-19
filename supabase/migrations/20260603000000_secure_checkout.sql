-- 1. Strict State Machine Enum
CREATE TYPE order_status AS ENUM ('pending', 'paid', 'failed', 'expired');

CREATE TABLE orders (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) NOT NULL,
    amount numeric NOT NULL,
    status order_status DEFAULT 'pending' NOT NULL,
    idempotency_key text UNIQUE NOT NULL, -- Prevents double-charging
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- 2. Enable Zero-Trust RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- User can read their own orders (to check if Edge Function updated it to paid)
CREATE POLICY "Users can read own orders" ON orders
FOR SELECT USING (auth.uid() = user_id);

-- User can ONLY insert an order in the 'pending' state
CREATE POLICY "Users can create pending orders" ON orders
FOR INSERT WITH CHECK (
  auth.uid() = user_id AND 
  status = 'pending'
);

-- 🚫 CRITICAL: Notice there is NO UPDATE policy for users.
-- A hacked client or compromised APK can NEVER update an order to 'paid'.

-- 3. Automatically expire pending orders older than 30 minutes (Run in pg_cron)
-- UPDATE orders 
-- SET status = 'expired' 
-- WHERE status = 'pending' AND created_at < NOW() - INTERVAL '30 minutes';
