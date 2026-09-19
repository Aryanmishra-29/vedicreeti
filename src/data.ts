/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { ApiEndpoint, Puja, AdBanner, UserRole } from './types';

export const INITIAL_PUJAS: Puja[] = [
  {
    id: 'puja_rudrabhishek_01',
    name: 'Maha Rudrabhishek Puja',
    description: 'A powerful Vedic ritual dedicated to Lord Shiva to wash away sins, seek protection, and invite prosperity, health, and spiritual growth.',
    price: 5100,
    durationMinutes: 120,
    imageUrn: 'https://images.unsplash.com/photo-1609137144814-1e9a3b2b8045?auto=format&fit=crop&q=80&w=600',
    benefits: ['Devastates obstacles', 'Brings peace and marital harmony', 'Averts health complications'],
    samagriIncluded: true,
    active: true,
    createdAt: '2026-01-15T08:00:00Z',
    updatedAt: '2026-05-20T11:30:00Z'
  },
  {
    id: 'puja_satyanarayan_02',
    name: 'Satyanarayan Vrat Katha & Puja',
    description: 'Performed to express gratitude to Lord Vishnu, seeking grace, family well-being, success in business, and general domestic bliss.',
    price: 3100,
    durationMinutes: 90,
    imageUrn: 'https://images.unsplash.com/photo-1608976451610-8ec1f6004bca?auto=format&fit=crop&q=80&w=600',
    benefits: ['Fosters abundance', 'Spiritual cleaning of workspace/home', 'Overcomes monetary distress'],
    samagriIncluded: true,
    active: true,
    createdAt: '2026-02-10T10:00:00Z',
    updatedAt: '2026-04-18T09:15:00Z'
  },
  {
    id: 'puja_griyapravesh_03',
    name: 'Griha Pravesh & Vastu Shanti Puja',
    description: 'Consecrates new living habitats or buildings to cleanse Negative/Vastu doshas, offering prayers to invite protective ancestral energy and auspiciousness.',
    price: 11000,
    durationMinutes: 180,
    imageUrn: 'https://images.unsplash.com/photo-1561361513-2d000a50f0db?auto=format&fit=crop&q=80&w=600',
    benefits: ['Eradicates house-warming evil eyes', 'Harmonizes elemental residential energy', 'Establishes cosmic protection'],
    samagriIncluded: false,
    active: true,
    createdAt: '2026-03-01T12:00:00Z',
    updatedAt: '2026-03-01T12:00:00Z'
  },
  {
    id: 'puja_ganesha_04',
    name: 'Ganesh Chaturthi Special Havan',
    description: 'Sacred fire ceremony dedicated to Lord Ganesha to usher in auspicious beginnings, clear financial blockages, and promote academic success.',
    price: 4500,
    durationMinutes: 75,
    imageUrn: 'https://images.unsplash.com/photo-1567591974577-fb3174549f48?auto=format&fit=crop&q=80&w=600',
    benefits: ['Disposes persistent barriers', 'Blesses venture starting points', 'Sharpens focus and analytical skills'],
    samagriIncluded: true,
    active: false,
    createdAt: '2026-04-20T14:30:00Z',
    updatedAt: '2026-05-15T07:10:00Z'
  }
];

export const INITIAL_ADS: AdBanner[] = [
  {
    id: 'ad_shravan_01',
    title: 'Maha Shivratri Special Offer: 20% Off Maha Rudrabhishek',
    imageUrl: 'https://images.unsplash.com/photo-1609137144814-1e9a3b2b8045?auto=format&fit=crop&q=80&w=1200',
    targetLink: 'vedicreeti://pujas/puja_rudrabhishek_01',
    campaignName: 'Shivratri Celebration Campaign',
    active: true,
    impressions: 48500,
    clicks: 6920,
    startDate: '2026-05-01T00:00:00Z',
    endDate: '2026-06-01T00:00:00Z'
  },
  {
    id: 'ad_puja_kits_02',
    title: 'Premium Brass Puja Samagri Kit - Handcrafted in Varanasi',
    imageUrl: 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?auto=format&fit=crop&q=80&w=1200',
    targetLink: 'https://store.vedicreeti.com/kits/premium-brass- Varanasi',
    campaignName: 'Samagri Store Launch',
    active: true,
    impressions: 21900,
    clicks: 1432,
    startDate: '2026-04-15T00:00:00Z',
    endDate: '2026-07-15T00:00:00Z'
  },
  {
    id: 'ad_rashifal_03',
    title: 'Personalized Kundali & Vedic Horoscope Reading with Acharya',
    imageUrl: 'https://images.unsplash.com/photo-1515942400420-2b98fed1f515?auto=format&fit=crop&q=80&w=1200',
    targetLink: 'vedicreeti://astrology/kundali_private_reading',
    campaignName: 'Weekly Astrology Drive',
    active: false,
    impressions: 112000,
    clicks: 12900,
    startDate: '2026-01-01T00:00:00Z',
    endDate: '2026-04-01T00:00:00Z'
  }
];

export const DIRECTORS: UserRole[] = [
  {
    userId: 'user_ramesh_01',
    name: 'Ramesh Kumar Tiwari',
    email: 'ramesh.tiwari@vedicreeti.com',
    role: 'DIRECTOR',
    permissions: [
      'tenant:manage',
      'puja:create', 'puja:edit', 'puja:delete',
      'booking:view', 'booking:manage',
      'ad:create', 'ad:edit', 'ad:delete',
      'rbac:view', 'rbac:grant', 'rbac:revoke'
    ],
    assignedAt: '2026-01-01T00:00:00Z'
  },
  {
    userId: 'user_diya_02',
    name: 'Diya Tiwari',
    email: 'diya.tiwari@vedicreeti.com',
    role: 'DIRECTOR',
    permissions: [
      'tenant:manage',
      'puja:create', 'puja:edit', 'puja:delete',
      'booking:view', 'booking:manage',
      'ad:create', 'ad:edit', 'ad:delete',
      'rbac:view', 'rbac:grant', 'rbac:revoke'
    ],
    assignedAt: '2026-01-01T00:00:00Z'
  },
  {
    userId: 'user_nikhil_03',
    name: 'Nikhil Tiwari',
    email: 'nikhil.tiwari@vedicreeti.com',
    role: 'DIRECTOR',
    permissions: [
      'tenant:manage',
      'puja:create', 'puja:edit', 'puja:delete',
      'booking:view', 'booking:manage',
      'ad:create', 'ad:edit', 'ad:delete',
      'rbac:view', 'rbac:grant', 'rbac:revoke'
    ],
    assignedAt: '2026-01-01T00:00:00Z'
  }
];

export const NO_SQL_SCHEMA_DOCS = {
  title: "VedicReeti Multi-Tenant BaaS Schema",
  platform: "Cloud Firestore / document-oriented NoSQL Engine",
  designPrinciples: [
    "Tenant isolation using standard top-level tenant referencing or subcollections.",
    "Denormalization (e.g., storing Puja Name and Price in the Booking document) to guarantee persistence of historical pricing structure and isolate real-time catalog changes.",
    "Flexible and scalable campaign structure for fast, low-latency banner ad delivery targeting Flutter mobile clients.",
    "Granular authorization schemas containing explicitly declared permission arrays assigned to admin tokens."
  ],
  collections: [
    {
      name: "tenants",
      description: "Acts as root for all micro-platforms / customized apps built on this BaaS. Supports Multi-Tenancy.",
      idFormat: "tenant_{tenant_slug}",
      fields: [
        { name: "id", type: "string", desc: "Unique tenant identifier (e.g. 'vedicreeti_v1')." },
        { name: "organizationName", type: "string", desc: "Legal organization name." },
        { name: "status", type: "string (enum)", desc: "'ACTIVE' | 'SUSPENDED' | 'DEVELOPMENT'" },
        { name: "apiKey", type: "string", desc: "Sha-256 hashed public token for Flutter visualizer calls." },
        { name: "createdAt", type: "timestamp", desc: "Tenant registration coordinate time." }
      ],
      sampleJson: `{
  "id": "tenant_vedic_reeti",
  "organizationName": "VedicReeti Devotional Private Limited",
  "status": "ACTIVE",
  "apiKey": "vr_pub_live_f1e98bb4f26012...",
  "createdAt": "2026-01-01T00:00:00Z"
}`
    },
    {
      name: "pujas",
      description: "Stores catalogs of devotional services dynamically served to applications and editable via administrative console portals.",
      idFormat: "puja_{service_name_slug}",
      fields: [
        { name: "id", type: "string", desc: "Standard unique Puja key." },
        { name: "name", type: "string", desc: "Human readable localized name of Puja divine procedure." },
        { name: "description", type: "string", desc: "Theological importance, explanation, instructions." },
        { name: "price", type: "number", desc: "Base booking price in INR (dynamic)." },
        { name: "durationMinutes", type: "number", desc: "Length of the divine ritual session." },
        { name: "imageUrn", type: "string", desc: "Resource path/S3/Cloud Storage URL of visual iconography/banner." },
        { name: "benefits", type: "array<string>", desc: "Spiritual benefits resulting from performing this auspicious ritual." },
        { name: "samagriIncluded", type: "boolean", desc: "Flag depicting whether Vedic ritual materials are bundled in the base charge." },
        { name: "active", type: "boolean", desc: "Visibility status governing active mobile app queries." },
        { name: "createdAt", type: "timestamp", desc: "Creation date." },
        { name: "updatedAt", type: "timestamp", desc: "Last updated coordinate." }
      ],
      sampleJson: `{
  "id": "puja_rudrabhishek_01",
  "name": "Maha Rudrabhishek Puja",
  "description": "Vedic prayer dedicated to Shiva consisting of powerful chanting and eleven ritual baths.",
  "price": 5100,
  "durationMinutes": 120,
  "imageUrn": "https://storage.googleapis.com/vedicreeti-assets/pujas/rudra.jpg",
  "benefits": [
    "Negates critical health risks",
    "Establishes peace and domestic harmony"
  ],
  "samagriIncluded": true,
  "active": true,
  "createdAt": "2026-01-15T08:00:00Z",
  "updatedAt": "2026-05-20T11:30:00Z"
}`
    },
    {
      name: "bookings",
      description: "Stores user booked sessions. Employs dynamic denormalization of name, price details to build an isolated transactional ledger unaffected by later catalog pricing changes.",
      idFormat: "booking_{uuid}",
      fields: [
        { name: "id", type: "string", desc: "Primary transaction booking key." },
        { name: "tenantId", type: "string", desc: "Foreign tenant mapping reference." },
        { name: "pujaId", type: "string", desc: "Foreign reference tracking catalog item." },
        { name: "pujaName", type: "string", desc: "Denormalized snapshot of Puja's name when purchase completed." },
        { name: "pricePaid", type: "number", desc: "Snapshot of price dynamic charge locked at time-of-booking." },
        { name: "userId", type: "string", desc: "Authenticated Client ID (Firebase Auth UID)." },
        { name: "userName", type: "string", desc: "Client Full Name." },
        { name: "userPhone", type: "string", desc: "Contact/Dynamic Callback target." },
        { name: "bookingDate", type: "string (YYYY-MM-DD)", desc: "Target day requested for divine session." },
        { name: "slotTime", type: "string", desc: "Hour window allocated for performance (e.g. '08:00 AM - 10:00 AM')." },
        { name: "status", type: "string (enum)", desc: "'PENDING' | 'CONFIRMED' | 'COMPLETED' | 'CANCELLED'." },
        { name: "createdTimestamp", type: "timestamp", desc: "When order logged in backend engine." }
      ],
      sampleJson: `{
  "id": "book_92bf608d_a071",
  "tenantId": "tenant_vedic_reeti",
  "pujaId": "puja_rudrabhishek_01",
  "pujaName": "Maha Rudrabhishek Puja",
  "pricePaid": 5100,
  "userId": "usr_devotee_781",
  "userName": "Amitabh Sharma",
  "userPhone": "+91 98765 43210",
  "bookingDate": "2026-06-12",
  "slotTime": "06:00 AM - 08:00 AM",
  "status": "CONFIRMED",
  "createdTimestamp": "2026-05-26T12:00:00Z"
}`
    },
    {
      name: "ads",
      description: "Stores advertisement campaigns dynamically consumed by Flutter dynamic carousels. Handled by internal ad server microservice.",
      idFormat: "ad_{campaign_unique_slug_hash}",
      fields: [
        { name: "id", type: "string", desc: "Banner promotion unique ID." },
        { name: "title", type: "string", desc: "Header overlay textual indicator." },
        { name: "imageUrl", type: "string", desc: "Visual asset payload storage location." },
        { name: "targetLink", type: "string", desc: "Action handler payload (Deep-link scheme to Flutter routes or general URLs)." },
        { name: "campaignName", type: "string", desc: "Organizational marketing metric keyword." },
        { name: "active", type: "boolean", desc: "Switch indicating active ad status. If false, not dispatched in app query." },
        { name: "impressions", type: "number", desc: "Total times loaded on customer viewports (metrics aggregation)." },
        { name: "clicks", type: "number", desc: "Aggregated link click coordinate actions." },
        { name: "startDate", type: "timestamp", desc: "Auspicious campaign activation time." },
        { name: "endDate", type: "timestamp", desc: "Campaign target deactivation deadline." }
      ],
      sampleJson: `{
  "id": "ad_shravan_01",
  "title": "Maha Shivratri Special Offer: 20% Off Maha Rudrabhishek",
  "imageUrl": "https://storage.googleapis.com/banners/shivratri_banner.jpg",
  "targetLink": "vedicreeti://pujas/puja_rudrabhishek_01",
  "campaignName": "Shivratri Celebration Campaign",
  "active": true,
  "impressions": 48500,
  "clicks": 6920,
  "startDate": "2026-05-01T00:00:00Z",
  "endDate": "2026-06-01T00:00:00Z"
}`
    },
    {
      name: "roles",
      description: "Governs administrative RBAC mapping for dashboard client configurations. Houses the authorized board list of Ramesh, Diya, and Nikhil Tiwari.",
      idFormat: "roles_{firebase_uid}",
      fields: [
        { name: "userId", type: "string", desc: "Firebase Security Auth identification coordinate." },
        { name: "name", type: "string", desc: "Administrator official legal name." },
        { name: "email", type: "string", desc: "Corporate credential email matching login identities." },
        { name: "role", type: "string (enum)", desc: "'DIRECTOR' | 'PUJARI' | 'SUPPORT_STAFF' (Directors have terminal override rights)." },
        { name: "permissions", type: "array<string>", desc: "Action keys allowed on API routes (e.g. 'puja:edit', 'ad:create', 'rbac:grant')." },
        { name: "assignedAt", type: "timestamp", desc: "Access rights authorization genesis coordinates." }
      ],
      sampleJson: `{
  "userId": "user_ramesh_01",
  "name": "Ramesh Kumar Tiwari",
  "email": "ramesh.tiwari@vedicreeti.com",
  "role": "DIRECTOR",
  "permissions": [
    "tenant:manage",
    "puja:create",
    "puja:edit",
    "puja:delete",
    "booking:view",
    "booking:manage",
    "ad:create",
    "ad:edit",
    "ad:delete",
    "rbac:view",
    "rbac:grant",
    "rbac:revoke"
  ],
  "assignedAt": "2026-01-01T00:00:00Z"
}`
    }
  ]
};

export const REST_API_ENDPOINTS: ApiEndpoint[] = [
  // Pujas Setup
  {
    method: 'GET',
    path: '/api/v1/pujas',
    category: 'PUJAS',
    description: 'Fetch all Puja offerings from catalog. Automatically filters hidden/inactive entries unless requested by authorized dashboard user.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {user_token} (Optional for public app views)'
    },
    exampleResponseBody: `[
  {
    "id": "puja_rudrabhishek_01",
    "name": "Maha Rudrabhishek Puja",
    "description": "A powerful Vedic ritual dedicated to Lord Shiva...",
    "price": 5100,
    "durationMinutes": 120,
    "imageUrn": "https://storage.googleapis.com/.../rudra.jpg",
    "benefits": ["Devastates obstacles", "Brings peace"],
    "samagriIncluded": true,
    "active": true
  }
]`
  },
  {
    method: 'POST',
    path: '/api/v1/admin/pujas',
    category: 'PUJAS',
    description: 'Create a new catalog entry. Restricted strictly to Directors with "puja:create" clearance.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {director_token}'
    },
    requestBodyDescription: 'Define core properties of Puja entry.',
    exampleRequestBody: `{
  "name": "Sunderkand Path & Aarti",
  "description": "Auspicious recital to seek power & mental stability.",
  "price": 4100,
  "durationMinutes": 60,
  "imageUrn": "https://storage.googleapis.com/.../sunderkand.jpg",
  "benefits": ["Dispenses fear", "Restores physical agility"],
  "samagriIncluded": true,
  "active": true
}`,
    exampleResponseBody: `{
  "success": true,
  "message": "Puja catalog entry inserted successfully.",
  "data": {
    "id": "puja_sunderkand_path_05",
    "name": "Sunderkand Path & Aarti",
    "price": 4100,
    "active": true,
    "createdAt": "2026-05-26T12:00:00Z"
  }
}`
  },
  {
    method: 'PUT',
    path: '/api/v1/admin/pujas/:id',
    category: 'PUJAS',
    description: 'Update price or properties dynamically. Changes reflect in Flutter store instantly.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {director_token}'
    },
    requestBodyDescription: 'Fields to update.',
    exampleRequestBody: `{
  "price": 5500,
  "samagriIncluded": true
}`,
    exampleResponseBody: `{
  "success": true,
  "message": "Puja dynamic catalog modifications updated config.",
  "data": {
    "id": "puja_rudrabhishek_01",
    "name": "Maha Rudrabhishek Puja",
    "price": 5500,
    "samagriIncluded": true,
    "updatedAt": "2026-05-26T12:05:00Z"
  }
}`
  },

  // Puja Bookings List
  {
    method: 'POST',
    path: '/api/v1/bookings',
    category: 'BOOKINGS',
    description: 'Submit dynamic Puja booking session. Takes a snap of actual price from active catalog to guard audit trail.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {user_token}'
    },
    requestBodyDescription: 'Selected slot parameter, phone number & selected Puja identity.',
    exampleRequestBody: `{
  "pujaId": "puja_rudrabhishek_01",
  "userName": "Abhishek Dubey",
  "userPhone": "+91 9988776655",
  "bookingDate": "2026-06-18",
  "slotTime": "08:00 AM - 10:00 AM"
}`,
    exampleResponseBody: `{
  "bookingId": "book_ab10c8f1_04fe",
  "status": "PENDING",
  "pricePaid": 5100,
  "message": "Payment initial gateway lock loaded. Awaiting checkout webhook."
}`
  },
  {
    method: 'GET',
    path: '/api/v1/admin/bookings',
    category: 'BOOKINGS',
    description: 'Retrieve dynamic ledger logs. Filterable by parameters.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {admin_token}'
    },
    exampleResponseBody: `[
  {
    "id": "book_92bf608d_a071",
    "pujaName": "Maha Rudrabhishek Puja",
    "pricePaid": 5100,
    "userName": "Amitabh Sharma",
    "bookingDate": "2026-06-12",
    "status": "CONFIRMED"
  }
]`
  },

  // Ad Management Routing
  {
    method: 'GET',
    path: '/api/v1/ads',
    category: 'ADS',
    description: 'Fetch active custom ads directly into the Flutter homepage banner slideshow framework.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti'
    },
    exampleResponseBody: `[
  {
    "id": "ad_shravan_01",
    "title": "Maha Shivratri Special Offer: 20% Off Maha Rudrabhishek",
    "imageUrl": "https://storage.googleapis.com/.../shivratri_banner.jpg",
    "targetLink": "vedicreeti://pujas/puja_rudrabhishek_01"
  }
]`
  },
  {
    method: 'POST',
    path: '/api/v1/admin/ads',
    category: 'ADS',
    description: 'Launch dynamic promotions on home sliders. Direct exclusive authorization for Ramesh, Diya, or Nikhil Tiwari.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {director_token}'
    },
    exampleRequestBody: `{
  "title": "Navratri Special Bhagwati Havan Online",
  "imageUrl": "https://storage.googleapis.com/banners/navratri_spl.jpg",
  "targetLink": "vedicreeti://pujas/puja_havan_02",
  "campaignName": "Navratri Festive Devotions",
  "startDate": "2026-10-01T00:00:00Z",
  "endDate": "2026-10-10T00:00:00Z",
  "active": true
}`,
    exampleResponseBody: `{
  "success": true,
  "adId": "ad_navratri_2026_special",
  "message": "Marketing campaign initialized on dynamic home screen queues."
}`
  },
  {
    method: 'PUT',
    path: '/api/v1/admin/ads/:id',
    category: 'ADS',
    description: 'Modify promo content or instantly toggle dynamic campaign status state (active/inactive).',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {director_token}'
    },
    exampleRequestBody: `{
  "active": false
}`,
    exampleResponseBody: `{
  "success": true,
  "adId": "ad_shravan_01",
  "active": false,
  "message": "Custom ad status updated. Mobile apps synchronized instantly."
}`
  },

  // RBAC Routing Control
  {
    method: 'GET',
    path: '/api/v1/admin/rbac/roles',
    category: 'RBAC',
    description: 'Read the dashboard security configuration. Verifies the access profile list mapping.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {director_token}'
    },
    exampleResponseBody: `[
  {
    "userId": "user_ramesh_01",
    "name": "Ramesh Kumar Tiwari",
    "email": "ramesh.tiwari@vedicreeti.com",
    "role": "DIRECTOR",
    "permissions": ["puja:create", "puja:edit", "ad:create", "rbac:grant"]
  }
]`
  },
  {
    method: 'POST',
    path: '/api/v1/admin/rbac/roles/grant',
    category: 'RBAC',
    description: 'Grant a granular authorization string to personnel, or update administrative capabilities map.',
    headers: {
      'X-Tenant-ID': 'tenant_vedic_reeti',
      'Authorization': 'Bearer {director_token}'
    },
    exampleRequestBody: `{
  "targetUserId": "user_support_09",
  "role": "SUPPORT_STAFF",
  "permissions": ["booking:view", "booking:manage"]
}`,
    exampleResponseBody: `{
  "success": true,
  "message": "Granted SUPPORT_STAFF profile mapping coordinates with 2 permission keys."
}`
  }
];
