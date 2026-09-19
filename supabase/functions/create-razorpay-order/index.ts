import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { amount, currency = 'INR', receipt = `receipt_${Date.now()}` } = await req.json();

    if (!amount) {
      return new Response(
        JSON.stringify({ error: 'Amount is required' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      );
    }

    // Amount in paise (multiply by 100)
    const amountInPaise = Math.round(amount * 100);

    const RAZORPAY_KEY_ID = Deno.env.get('RAZORPAY_KEY_ID') || 'rzp_test_T0lFQczj7ejIAV';
    const RAZORPAY_KEY_SECRET = Deno.env.get('RAZORPAY_KEY_SECRET');

    if (!RAZORPAY_KEY_SECRET) {
      throw new Error('RAZORPAY_KEY_SECRET is not configured in the environment variables');
    }

    const authString = btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);

    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${authString}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: amountInPaise,
        currency,
        receipt,
      }),
    });

    const responseData = await response.json();

    if (!response.ok) {
      console.error('Razorpay Error:', responseData);
      throw new Error(responseData.error?.description || 'Failed to create Razorpay order');
    }

    return new Response(
      JSON.stringify({ 
        order_id: responseData.id, 
        amount: responseData.amount,
        currency: responseData.currency 
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    );
  } catch (error) {
    console.error('Exception generating Razorpay order:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Internal Server Error' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    );
  }
});
