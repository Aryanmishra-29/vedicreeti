import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
import { JWT } from 'https://cdn.jsdelivr.net/gh/GJZwille/deno-googleapis/mod.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    
    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error('Supabase URL or Service Role Key missing')
    }

    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey)

    // Query distinct users who have wishlist items.
    // For simplicity, we just fetch all wishlist items and group them by user.
    const { data: wishlists, error: wishlistError } = await supabase
      .from('user_wishlist')
      .select('user_id, product_id, products(name, image_url)')

    if (wishlistError) throw wishlistError

    if (!wishlists || wishlists.length === 0) {
      return new Response(JSON.stringify({ message: 'No active wishlists found.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // Group by user to just pick the first item to remind them about
    const reminders: Record<string, any> = {}
    for (const item of wishlists) {
      if (!reminders[item.user_id]) {
        reminders[item.user_id] = {
          userId: item.user_id,
          productId: item.product_id,
          productName: item.products?.name,
          productImage: item.products?.image_url,
        }
      }
    }

    // Get Firebase Service Account from Secret
    const fcmServiceAccountStr = Deno.env.get('FCM_SERVICE_ACCOUNT')
    if (!fcmServiceAccountStr) {
      throw new Error('FCM_SERVICE_ACCOUNT secret is missing')
    }
    
    const serviceAccount = JSON.parse(fcmServiceAccountStr)
    const jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })

    const token = await jwtClient.getToken()
    const projectId = serviceAccount.project_id

    const results = []

    // For each user, we need their FCM token. Let's fetch tokens if stored in user_metadata or another table.
    // Wait, the prompt didn't specify where FCM tokens are stored. Let's assume they are stored in `fcm_tokens` table or `user_metadata.fcm_token`.
    // We'll query `fcm_tokens` table if it exists, or just check user_metadata.
    // For the sake of this implementation, we will query auth.users to get user_metadata.fcm_token
    const { data: users, error: usersError } = await supabase.auth.admin.listUsers()
    
    if (usersError) throw usersError

    const userTokenMap: Record<string, string> = {}
    for (const user of users.users) {
      if (user.user_metadata?.fcm_token) {
        userTokenMap[user.id] = user.user_metadata.fcm_token
      }
    }

    for (const userId of Object.keys(reminders)) {
      const reminder = reminders[userId]
      const fcmToken = userTokenMap[userId]

      if (fcmToken) {
        // Send FCM Message
        const message = {
          message: {
            token: fcmToken,
            notification: {
              title: 'A gentle reminder for your Wishlist 🌟',
              body: `The sacred \${reminder.productName} is waiting for you.`,
              image: reminder.productImage,
            },
            data: {
              route: '/wishlist',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            android: {
              notification: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
              }
            },
            apns: {
              payload: {
                aps: {
                  category: 'FLUTTER_NOTIFICATION_CLICK',
                }
              }
            }
          }
        }

        const fcmResponse = await fetch(`https://fcm.googleapis.com/v1/projects/\${projectId}/messages:send`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer \${token.token}`,
          },
          body: JSON.stringify(message),
        })

        const fcmResult = await fcmResponse.json()
        results.push({ userId, status: fcmResponse.status, result: fcmResult })
      }
    }

    return new Response(JSON.stringify({ message: 'Reminders processed', results }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
