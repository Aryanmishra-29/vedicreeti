-- Enable pg_cron extension if not already enabled
create extension if not exists pg_cron;
create extension if not exists pg_net;

-- Create the cron job to call the wishlist-reminder edge function
-- Runs every Monday at 10:00 AM ('0 10 * * 1')
SELECT cron.schedule(
    'invoke-wishlist-reminder',
    '0 10 * * 1',
    $$
    select
      net.http_post(
        url:='https://your-project-ref.supabase.co/functions/v1/wishlist-reminder',
        headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
      ) as request_id;
    $$
);
