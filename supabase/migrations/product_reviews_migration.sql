-- 1. Alter Products Table
ALTER TABLE public.products
ADD COLUMN IF NOT EXISTS total_purchases INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_reviews INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_rating FLOAT DEFAULT 5.0,
ADD COLUMN IF NOT EXISTS admin_override_rating FLOAT;

-- 2. Create Product Reviews Table
CREATE TABLE IF NOT EXISTS public.product_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS Policies for Reviews
ALTER TABLE public.product_reviews ENABLE ROW LEVEL SECURITY;

-- Anyone can read reviews
CREATE POLICY "Public reviews are viewable by everyone." 
ON public.product_reviews FOR SELECT USING (true);

-- Authenticated users can insert their own reviews
CREATE POLICY "Users can insert their own reviews." 
ON public.product_reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. Create Trigger Function to Recalculate Averages
CREATE OR REPLACE FUNCTION public.recalculate_product_rating()
RETURNS TRIGGER AS $$
DECLARE
  v_total_reviews INTEGER;
  v_average_rating FLOAT;
BEGIN
  -- Count total reviews and average rating for the given product
  SELECT COUNT(*), COALESCE(AVG(rating), 5.0)
  INTO v_total_reviews, v_average_rating
  FROM public.product_reviews
  WHERE product_id = NEW.product_id;

  -- Update the products table
  UPDATE public.products
  SET total_reviews = v_total_reviews,
      average_rating = v_average_rating
  WHERE id = NEW.product_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Create the Trigger
DROP TRIGGER IF EXISTS on_review_added ON public.product_reviews;

CREATE TRIGGER on_review_added
AFTER INSERT OR UPDATE OR DELETE ON public.product_reviews
FOR EACH ROW
EXECUTE FUNCTION public.recalculate_product_rating();

-- 5. Create Storage Bucket for Review Images (If using Supabase Storage)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('review-images', 'review-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies for review-images
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'review-images');
CREATE POLICY "Auth Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'review-images' AND auth.role() = 'authenticated');
