-- 1. Create a secure public view that automatically joins product reviews with the auth.users metadata
-- This avoids the PGRST200 error because PostgREST doesn't need to resolve a foreign key to a view.
CREATE OR REPLACE VIEW public.product_reviews_with_profiles AS
SELECT 
  r.id,
  r.product_id,
  r.user_id,
  r.rating,
  r.comment,
  r.image_url,
  r.created_at,
  u.raw_user_meta_data->>'full_name' AS full_name
FROM public.product_reviews r
JOIN auth.users u ON r.user_id = u.id;

-- 2. Grant permissions so anon and authenticated users can read from this view
GRANT SELECT ON public.product_reviews_with_profiles TO anon, authenticated;
