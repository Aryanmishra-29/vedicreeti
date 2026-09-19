CREATE TABLE IF NOT EXISTS public.user_wishlist (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, product_id)
);

-- Enable RLS
ALTER TABLE public.user_wishlist ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their own wishlist" 
ON public.user_wishlist FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert into their own wishlist" 
ON public.user_wishlist FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete from their own wishlist" 
ON public.user_wishlist FOR DELETE 
USING (auth.uid() = user_id);
