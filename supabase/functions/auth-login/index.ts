import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, password } = await req.json();

    if (!email || !password) {
      return new Response(JSON.stringify({ error: "Invalid credentials or input format provided." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const ip = req.headers.get("x-real-ip") || req.headers.get("x-forwarded-for") || "unknown";

    // Initialize Supabase Admin Client for database access bypassing RLS
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const now = new Date();

    // 1. IP Rate Limiting (10 req/min)
    const ipKey = `ip:${ip}`;
    let { data: ipTracker } = await adminClient.from('auth_trackers').select('*').eq('key', ipKey).single();
    
    let ipAttempts = 1;
    if (ipTracker) {
      const lastAttempt = new Date(ipTracker.last_attempt);
      const oneMinAgo = new Date(now.getTime() - 60000);
      if (lastAttempt < oneMinAgo) {
        ipAttempts = 1;
      } else {
        ipAttempts = ipTracker.attempts + 1;
      }
    }

    await adminClient.from('auth_trackers').upsert({
      key: ipKey,
      attempts: ipAttempts,
      last_attempt: now.toISOString()
    });

    if (ipAttempts > 10) {
      return new Response(JSON.stringify({ error: "Invalid credentials or input format provided." }), {
        status: 429,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Account Lockout Check
    const emailKey = `email:${email}`;
    let { data: emailTracker } = await adminClient.from('auth_trackers').select('*').eq('key', emailKey).single();

    let failedAttempts = 0;

    if (emailTracker) {
      // Check if locked
      if (emailTracker.locked_until) {
        const lockedUntil = new Date(emailTracker.locked_until);
        if (lockedUntil > now) {
          return new Response(JSON.stringify({ error: "Invalid credentials or input format provided." }), {
            status: 403,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }
      }

      // Reset attempts if it's been more than 30 minutes since last failed attempt
      const lastAttempt = new Date(emailTracker.last_attempt);
      const thirtyMinsAgo = new Date(now.getTime() - 1800000);
      
      if (lastAttempt > thirtyMinsAgo) {
        failedAttempts = emailTracker.attempts;
      } else {
        // Clear old tracker
        failedAttempts = 0;
        await adminClient.from('auth_trackers').delete().eq('key', emailKey);
      }
    }

    // 3. Progressive Delay
    if (failedAttempts > 0) {
      // Wait (failedAttempts * 500) milliseconds
      const delayMs = failedAttempts * 500;
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }

    // 4. Attempt login with normal anon client (so we don't accidentally bypass Auth logic)
    const authClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    );

    const { data, error } = await authClient.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      failedAttempts += 1;
      
      let lockedUntil: string | null = null;
      if (failedAttempts >= 5) {
        // Lock for 15 minutes
        const lockTime = new Date(now.getTime() + 900000);
        lockedUntil = lockTime.toISOString();
        console.log(`[EMAIL NOTIFICATION] Account ${email} locked due to 5 consecutive failed login attempts. Send reset link here.`);
      }

      await adminClient.from('auth_trackers').upsert({
        key: emailKey,
        attempts: failedAttempts,
        locked_until: lockedUntil,
        last_attempt: now.toISOString()
      });

      return new Response(JSON.stringify({ error: "Invalid credentials or input format provided." }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 5. Successful login: Clear failed attempts for this email
    if (failedAttempts > 0) {
      await adminClient.from('auth_trackers').delete().eq('key', emailKey);
    }

    return new Response(
      JSON.stringify({
        session: data.session,
        user: data.user,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Server error:", error);
    return new Response(
      JSON.stringify({ error: "An internal server error occurred." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
