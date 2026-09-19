import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.0";
import { encode as hexEncode } from "https://deno.land/std@0.168.0/encoding/hex.ts";
import { withRateLimit } from '../_shared/rate_limiter.ts';

// Initialize with SERVICE ROLE KEY to bypass RLS
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' 
);

const WEBHOOK_SECRET = Deno.env.get('RAZORPAY_WEBHOOK_SECRET') ?? '';

serve(async (req) => {
  return await withRateLimit(req, async (req) => {
    try {
      const signature = req.headers.get('x-razorpay-signature');
      if (!signature) throw new Error('Missing signature');

      const bodyText = await req.text();

      // 1. Cryptographic Verification
      const encoder = new TextEncoder();
      const key = await crypto.subtle.importKey(
        "raw", encoder.encode(WEBHOOK_SECRET), 
        { name: "HMAC", hash: "SHA-256" }, 
        false, ["sign"]
      );
      
      const signatureBuffer = await crypto.subtle.sign(
        "HMAC", key, encoder.encode(bodyText)
      );
      
      const expectedSignature = new TextDecoder().decode(hexEncode(new Uint8Array(signatureBuffer)));

      if (expectedSignature !== signature) {
        throw new Error("Invalid signature");
      }

      const payload = JSON.parse(bodyText);

      // 2. Gateway reports success
      if (payload.event === 'payment.captured' || payload.event === 'order.paid') {
        const paymentEntity = payload.payload.payment.entity;
        const razorpayOrderId = paymentEntity.order_id;
        const razorpayPaymentId = paymentEntity.id;

        if (!razorpayOrderId) throw new Error("No order_id in webhook payload");

        // 3. Strict State Transition
        const { error } = await supabase
          .from('orders')
          .update({ 
            payment_status: 'successful',
            razorpay_payment_id: razorpayPaymentId
          })
          .eq('razorpay_order_id', razorpayOrderId)
          .eq('payment_status', 'pending');

        if (error) {
          throw new Error(`Order update failed: ${error.message}`);
        }
        
        return new Response(JSON.stringify({ message: 'Order marked successful' }), { status: 200 });
      }

      return new Response(JSON.stringify({ message: 'Ignored event' }), { status: 200 });

    } catch (err) {
      console.error("Webhook Error:", err.message);
      return new Response(JSON.stringify({ error: err.message }), { status: 400 });
    }
  }, { maxRequests: 30, windowMs: 60000 });
});
