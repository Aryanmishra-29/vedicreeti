export interface RateLimitConfig {
  maxRequests: number;
  windowMs: number;
}

// In-memory fixed window store
// Keys: IP address or User ID
// Values: Request count and window reset timestamp
const store = new Map<string, { count: number; resetTime: number }>();

export async function withRateLimit(
  req: Request,
  handler: (req: Request) => Promise<Response>,
  config: RateLimitConfig = { maxRequests: 60, windowMs: 60000 }
): Promise<Response> {
  // 1. Extract identifier
  // Supabase edge proxies set x-forwarded-for for original client IPs
  const identifier = req.headers.get('x-forwarded-for')?.split(',')[0].trim() || 
                     req.headers.get('x-real-ip') || 
                     'unknown-client';

  const now = Date.now();
  let record = store.get(identifier);

  // 2. Check Window Reset
  if (!record || now > record.resetTime) {
    // Start a new time window
    record = { count: 0, resetTime: now + config.windowMs };
  }

  // Increment counter
  record.count += 1;
  store.set(identifier, record);

  // 3. Break Limit Handler
  if (record.count > config.maxRequests) {
    // Calculate seconds remaining in the window for the Retry-After header
    const retryAfterSeconds = Math.max(1, Math.ceil((record.resetTime - now) / 1000));
    
    // 4. Client Backoff Response
    return new Response(
      JSON.stringify({ 
        error: 'Too Many Requests', 
        message: `Rate limit exceeded. Please try again in ${retryAfterSeconds} seconds.`,
        retryAfter: retryAfterSeconds
      }), 
      { 
        status: 429, 
        headers: { 
          'Content-Type': 'application/json',
          'Retry-After': retryAfterSeconds.toString()
        } 
      }
    );
  }

  // Proceed to actual function handler if within limits
  return await handler(req);
}
