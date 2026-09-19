import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const payload = await req.json()
    
    // We expect this function to be triggered by a Supabase Database Webhook
    // The payload type from webhook has the shape: { type: 'INSERT', record: { ... } }
    const order = payload.record

    if (!order) {
      throw new Error('No order record found in payload')
    }

    const orderId = order.id
    const amount = order.total_amount
    const deliveryAddress = order.delivery_address || {}
    const userId = order.user_id

    // Fetch user email if not in order payload
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    let customerEmail = 'customer@example.com' // Fallback
    
    // Try to fetch user email using the admin role or auth API if needed
    // Assuming the user is making the request, but since it's a webhook, we need service_role key to bypass RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { data: user, error: userError } = await supabaseAdmin.auth.admin.getUserById(userId)
    
    if (user?.user?.email) {
      customerEmail = user.user.email
    }

    const resendApiKey = Deno.env.get('RESEND_API_KEY')
    if (!resendApiKey) {
      console.warn('RESEND_API_KEY is missing. Skipping email sending.')
      return new Response(
        JSON.stringify({ message: 'Success but email skipped due to missing API key' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
      )
    }

    // HTML Email Template
    const htmlTemplate = `
      <div style="font-family: sans-serif; padding: 20px; color: #333;">
        <h1 style="color: #F97316;">Order Confirmation</h1>
        <p>Thank you for shopping with VedicReeti!</p>
        <p>Your order <strong>#${orderId}</strong> has been placed successfully.</p>
        
        <h3>Order Summary</h3>
        <p><strong>Total Amount:</strong> ₹${amount}</p>
        
        <h3>Delivery Details</h3>
        <p><strong>Name:</strong> ${deliveryAddress.name || ''}</p>
        <p><strong>Address:</strong> ${deliveryAddress.address || ''}, PIN: ${deliveryAddress.pincode || ''}</p>
        <p><strong>Phone:</strong> ${deliveryAddress.phone || ''}</p>
        
        <p style="margin-top: 30px; font-size: 12px; color: #999;">If you have any questions, reply to this email.</p>
      </div>
    `

    // Send via Resend
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'VedicReeti Orders <orders@yourdomain.com>',
        to: [customerEmail],
        subject: `Your VedicReeti Order Receipt (#${orderId})`,
        html: htmlTemplate,
      })
    })

    if (!resendResponse.ok) {
      const errorText = await resendResponse.text()
      throw new Error(`Failed to send email via Resend: ${errorText}`)
    }

    return new Response(
      JSON.stringify({ message: 'Order receipt sent successfully' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  } catch (error) {
    console.error('Error sending order receipt:', error.message)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
