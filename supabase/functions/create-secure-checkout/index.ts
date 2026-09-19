import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.0";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const requestBodyText = await req.clone().text();
    console.log('Function triggered with body:', requestBodyText);
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

    // Create client using SERVICE_ROLE_KEY
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    const { items, delivery_address, user_id, payment_method } = await req.json();

    if (!user_id) {
      return new Response(JSON.stringify({ error: 'Missing user_id in payload.' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    if (!items || !Array.isArray(items) || items.length === 0) {
      throw new Error('No items provided');
    }

    let calculatedTotal = 0;
    const validatedItems = [];

    // Process items securely
    for (const item of items) {
      console.log(`Checking product ID from Flutter: ${item.product_id}`);
      const { data: product, error } = await supabaseAdmin
        .from('products')
        .select('*')
        .eq('id', item.product_id)
        .single();
      
      if (error) {
        console.error('DATABASE QUERY ERROR:', error);
        return new Response(JSON.stringify({ error: 'Query failed: ' + error.message }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
      }

      if (!product) throw new Error(`Product not found: ${item.product_id}`);

      const unitPrice = product.sale_price ?? product.price ?? 0;
      calculatedTotal += unitPrice * item.quantity;

      validatedItems.push({
        product_id: product.id,
        quantity: item.quantity,
        price_at_purchase: unitPrice
      });
    }

    // Convert to paise for Razorpay
    const amountInPaise = Math.round(calculatedTotal * 100);

    const RAZORPAY_KEY_ID = Deno.env.get('RAZORPAY_KEY_ID') || 'rzp_test_T0lFQczj7ejIAV';
    const RAZORPAY_KEY_SECRET = Deno.env.get('RAZORPAY_KEY_SECRET');

    if (!RAZORPAY_KEY_SECRET) throw new Error('Razorpay Secret is missing');

    const authString = btoa(`${RAZORPAY_KEY_ID}:${RAZORPAY_KEY_SECRET}`);
    const receiptId = `rcpt_${Date.now()}`;

    let razorpayResponse;
    let rzpData;
    let generatedOrderId = `cod_${Date.now()}`;

    // Create Razorpay Order ONLY if not COD
    if (payment_method !== 'COD') {
      try {
        razorpayResponse = await fetch('https://api.razorpay.com/v1/orders', {
          method: 'POST',
          headers: {
            'Authorization': `Basic ${authString}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            amount: amountInPaise,
            currency: 'INR',
            receipt: receiptId,
          }),
        });

        rzpData = await razorpayResponse.json();
        if (!razorpayResponse.ok) {
          throw new Error(rzpData.error?.description || 'Razorpay order failed');
        }
        generatedOrderId = rzpData.id;
      } catch (rzpError) {
        console.error('Razorpay creation failed:', rzpError);
        throw new Error(`Razorpay API Error: ${rzpError.message || rzpError}`);
      }
    }

    // Insert pending order
    const { data: orderData, error: orderError } = await supabaseAdmin
      .from('orders')
      .insert({
        user_id: user_id,
        total_amount: calculatedTotal,
        payment_status: 'pending',
        payment_method: payment_method || 'ONLINE',
        order_status: 'processing',
        razorpay_order_id: generatedOrderId,
        delivery_address: delivery_address || { is_dummy: true, note: "User did not provide address" }
      })
      .select('id')
      .single();

    if (orderError) throw new Error(`Failed to create order: ${orderError.message}`);

    // Insert order items
    const orderItemsPayload = validatedItems.map(vi => ({
      order_id: orderData.id,
      product_id: vi.product_id,
      quantity: vi.quantity,
      price_at_purchase: vi.price_at_purchase
    }));

    const { error: itemsError } = await supabaseAdmin
      .from('order_items')
      .insert(orderItemsPayload);

    if (itemsError) throw new Error(`Failed to insert items: ${itemsError.message}`);

    return new Response(
      JSON.stringify({
        order_id: generatedOrderId,
        amount: calculatedTotal,
        payment_method: payment_method || 'ONLINE',
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    );
  }
});
