-- Drop old schema if it exists to avoid conflicts
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TYPE IF EXISTS payment_status_enum;
DROP TYPE IF EXISTS order_status_enum;

-- Create Enums
CREATE TYPE payment_status_enum AS ENUM ('pending', 'successful', 'failed');
CREATE TYPE order_status_enum AS ENUM ('processing', 'shipped', 'delivered', 'cancelled');

-- Create Orders Table
CREATE TABLE orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    total_amount NUMERIC NOT NULL,
    payment_status payment_status_enum DEFAULT 'pending' NOT NULL,
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    delivery_address JSONB NOT NULL,
    order_status order_status_enum DEFAULT 'processing' NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create Order Items Table
CREATE TABLE order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMERIC NOT NULL
);

-- Enable Row Level Security
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Orders RLS: Users can SELECT and INSERT their own orders. NO UPDATE policy.
CREATE POLICY "Users can view their own orders" 
ON orders FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own orders" 
ON orders FOR INSERT 
WITH CHECK (auth.uid() = user_id AND payment_status = 'pending' AND order_status = 'processing');

-- Order Items RLS: Users can SELECT and INSERT items if they own the parent order.
CREATE POLICY "Users can view their own order items" 
ON order_items FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
);

CREATE POLICY "Users can insert their own order items" 
ON order_items FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()
    )
);
