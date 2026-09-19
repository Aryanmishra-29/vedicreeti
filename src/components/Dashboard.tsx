/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState } from 'react';
import { 
  Database, Code, Sliders, Users, Layers, Play, Copy, Check, 
  Plus, Edit2, Shield, Calendar, Award, Phone, Image, ExternalLink, 
  CheckCircle, RefreshCw, Eye, Tag, Trash2, Heart, HeartHandshake,
  Smartphone
} from 'lucide-react';
import { Puja, PujaBooking, AdBanner, UserRole, ApiEndpoint } from '../types';
import { INITIAL_PUJAS, INITIAL_ADS, DIRECTORS, NO_SQL_SCHEMA_DOCS, REST_API_ENDPOINTS } from '../data';
import FlutterWorkspace from './FlutterWorkspace';

export default function Dashboard() {
  // Live Simulated BaaS DB States
  const [pujas, setPujas] = useState<Puja[]>(INITIAL_PUJAS);
  const [ads, setAds] = useState<AdBanner[]>(INITIAL_ADS);
  const [rbacUsers, setRbacUsers] = useState<UserRole[]>(DIRECTORS);
  const [bookings, setBookings] = useState<PujaBooking[]>([
    {
      id: 'book_92bf608d_a071',
      tenantId: 'tenant_vedic_reeti',
      pujaId: 'puja_rudrabhishek_01',
      pujaName: 'Maha Rudrabhishek Puja',
      pricePaid: 5100,
      userId: 'usr_devotee_781',
      userName: 'Amitabh Sharma',
      userPhone: '+91 98765 43210',
      bookingDate: '2026-06-12',
      slotTime: '06:00 AM - 08:00 AM',
      status: 'CONFIRMED',
      createdTimestamp: '2026-05-26T12:00:00Z'
    },
    {
      id: 'book_e3b1c8f1_04fe',
      tenantId: 'tenant_vedic_reeti',
      pujaId: 'puja_satyanarayan_02',
      pujaName: 'Satyanarayan Vrat Katha & Puja',
      pricePaid: 3100,
      userId: 'usr_devotee_402',
      userName: 'Savitri Devi',
      userPhone: '+91 91234 56789',
      bookingDate: '2026-06-15',
      slotTime: '10:00 AM - 12:00 PM',
      status: 'PENDING',
      createdTimestamp: '2026-05-26T12:30:00Z'
    }
  ]);

  // Active workspace tab switcher
  const [activeTab, setActiveTab] = useState<'bookings' | 'pujas' | 'ads' | 'schema' | 'api' | 'directors' | 'flutter'>('bookings');

  // Ad Campaign form states
  const [adFormInput, setAdFormInput] = useState({
    title: '',
    imageUrl: '',
    targetLink: '',
    campaignName: 'Navratri Festive Promo',
    active: true
  });
  const [adSuccessMessage, setAdSuccessMessage] = useState<string | null>(null);

  // Puja pricing edit modal states
  const [editingPujaId, setEditingPujaId] = useState<string | null>(null);
  const [editPriceVal, setEditPriceVal] = useState<number>(0);
  const [isAddingPuja, setIsAddingPuja] = useState(false);
  const [pujaFormInput, setPujaFormInput] = useState({
    name: '',
    price: 3100,
    durationMinutes: 90,
    description: '',
    imageUrn: 'https://images.unsplash.com/photo-1609137144814-1e9a3b2b8045?auto=format&fit=crop&q=80&w=600',
    benefitsStr: 'Invites positive energy, Cleanses cosmic atmosphere',
    samagriIncluded: true
  });

  // API Playground State
  const [selectedApi, setSelectedApi] = useState<ApiEndpoint>(REST_API_ENDPOINTS[0]);
  const [customRequestBody, setCustomRequestBody] = useState<string>('');
  const [customHeaders, setCustomHeaders] = useState<Record<string, string>>({
    'X-Tenant-ID': 'tenant_vedic_reeti',
    'Authorization': 'Bearer JWT_DIRECTOR_RAMESH_TOKEN'
  });
  const [apiResponse, setApiResponse] = useState<any>(null);
  const [apiMetadata, setApiMetadata] = useState<{
    latency: number;
    statusCode: number;
    timestamp: string;
  } | null>(null);
  const [isSimulatingRequest, setIsSimulatingRequest] = useState(false);

  // Copy Schema Indicator state
  const [copiedColId, setCopiedColId] = useState<string | null>(null);

  // Common Copy helper
  const handleCopyText = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedColId(id);
    setTimeout(() => setCopiedColId(null), 2000);
  };

  // REST api selections setup helper
  const handleSelectApi = (api: ApiEndpoint) => {
    setSelectedApi(api);
    setCustomRequestBody(api.exampleRequestBody || '');
    setApiResponse(null);
    setApiMetadata(null);
  };

  // Submit Ad Campaign
  const handleAddAdCampaign = (e: React.FormEvent) => {
    e.preventDefault();
    if (!adFormInput.title || !adFormInput.imageUrl) return;

    const newAd: AdBanner = {
      id: `ad_campaign_${Math.floor(Math.random() * 10000).toString(16)}`,
      title: adFormInput.title,
      imageUrl: adFormInput.imageUrl,
      targetLink: adFormInput.targetLink || 'vedicreeti://dynamic/home',
      campaignName: adFormInput.campaignName,
      active: adFormInput.active,
      impressions: 0,
      clicks: 0,
      startDate: new Date().toISOString(),
      endDate: new Date(Date.now() + 86400000 * 30).toISOString()
    };

    setAds(prev => [newAd, ...prev]);
    setAdSuccessMessage('Mahalakshmi Grace! Custom Banner ad server payload created.');
    setAdFormInput({
      title: '',
      imageUrl: '',
      targetLink: '',
      campaignName: 'Festive Season Promo',
      active: true
    });
    setTimeout(() => setAdSuccessMessage(null), 4000);
  };

  // Modify Puja Pricing
  const handleUpdatePrice = (pujaId: string) => {
    setPujas(prev => prev.map(p => {
      if (p.id === pujaId) {
        return { ...p, price: editPriceVal, updatedAt: new Date().toISOString() };
      }
      return p;
    }));
    setEditingPujaId(null);
  };

  // Toggle dynamic Puja active/inactive status
  const handleTogglePujaActive = (pujaId: string) => {
    setPujas(prev => prev.map(p => {
      if (p.id === pujaId) {
        return { ...p, active: !p.active, updatedAt: new Date().toISOString() };
      }
      return p;
    }));
  };

  // Create new Puja dynamically
  const handleCreatePuja = (e: React.FormEvent) => {
    e.preventDefault();
    const benefitsArray = pujaFormInput.benefitsStr.split(',').map(b => b.trim());
    const newPuja: Puja = {
      id: `puja_id_${Date.now()}`,
      name: pujaFormInput.name || 'Universal Vedic Pooja',
      description: pujaFormInput.description || 'Chant rituals by certified Tiwari Acharyas.',
      price: Number(pujaFormInput.price),
      durationMinutes: Number(pujaFormInput.durationMinutes),
      imageUrn: pujaFormInput.imageUrn,
      benefits: benefitsArray,
      samagriIncluded: pujaFormInput.samagriIncluded,
      active: true,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    setPujas(prev => [...prev, newPuja]);
    setIsAddingPuja(false);
    setPujaFormInput({
      name: '',
      price: 3100,
      durationMinutes: 90,
      description: '',
      imageUrn: 'https://images.unsplash.com/photo-1609137144814-1e9a3b2b8045?auto=format&fit=crop&q=80&w=600',
      benefitsStr: 'Invites positive energy, Cleanses cosmic atmosphere',
      samagriIncluded: true
    });
  };

  // Delete Ad Campaign
  const handleDeleteAd = (adId: string) => {
    setAds(prev => prev.filter(item => item.id !== adId));
  };

  // Toggle dynamic Ad active/inactive status
  const handleToggleAd = (adId: string) => {
    setAds(prev => prev.map(a => {
      if (a.id === adId) {
        return { ...a, active: !a.active };
      }
      return a;
    }));
  };

  // Modify Booking Status (Simulating admin interaction)
  const handleUpdateBookingStatus = (bookingId: string, nextStatus: any) => {
    setBookings(prev => prev.map(b => {
      if (b.id === bookingId) {
        return { ...b, status: nextStatus };
      }
      return b;
    }));
  };

  // Simulate server-side sandbox request
  const handleTriggerApiSimulation = () => {
    setIsSimulatingRequest(true);
    setApiResponse(null);
    setApiMetadata(null);

    const simulatedLatency = Math.floor(Math.random() * 210) + 80;

    setTimeout(() => {
      if (!customHeaders['X-Tenant-ID'] || customHeaders['X-Tenant-ID'] !== 'tenant_vedic_reeti') {
        setApiResponse({
          status: 'error',
          code: 'UNAUTHORIZED_TENANT',
          message: 'Secure tenant-boundary key mismatch. Check X-Tenant-Id headers.'
        });
        setApiMetadata({ latency: simulatedLatency, statusCode: 401, timestamp: new Date().toISOString() });
        setIsSimulatingRequest(false);
        return;
      }

      // Check endpoints
      const urlPath = selectedApi.path;
      if (urlPath === '/api/v1/pujas') {
        setApiResponse(pujas);
      } else if (urlPath.includes('/admin/pujas')) {
        setApiResponse({
          success: true,
          message: 'Pujas list configurations updated live in dynamic cache.',
          pujasCount: pujas.length
        });
      } else if (urlPath === '/api/v1/ads') {
        setApiResponse(ads.filter(a => a.active));
      } else if (urlPath === '/api/v1/admin/rbac/roles') {
        setApiResponse(rbacUsers);
      } else if (urlPath === '/api/v1/bookings') {
        setApiResponse(bookings);
      } else {
        setApiResponse({
          success: true,
          timestamp: new Date().toISOString(),
          context: 'Devotional endpoint simulated cleanly under Tiwari authorization rules.'
        });
      }

      setApiMetadata({
        latency: simulatedLatency,
        statusCode: 200,
        timestamp: new Date().toISOString()
      });
      setIsSimulatingRequest(false);
    }, simulatedLatency);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans selection:bg-amber-500 selection:text-slate-950">
      
      {/* Dynamic Saffron Header with Maroon / Gold gradients */}
      <header className="border-b border-rose-950/40 bg-slate-950/85 backdrop-blur-md sticky top-0 z-40 px-6 py-4 flex flex-col lg:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="bg-gradient-to-br from-amber-500 via-orange-600 to-rose-700 p-2.5 rounded-xl text-white shadow-lg shadow-amber-500/10 border border-amber-400/20">
            <Award className="w-5 h-5 text-amber-300 animate-pulse" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold tracking-tight text-white font-serif">VedicReeti</h1>
              <span className="text-[10px] uppercase font-mono tracking-widest px-2 py-0.5 rounded bg-amber-500/10 text-amber-400 font-bold border border-amber-500/20">
                BAAS CONTROL PANEL
              </span>
            </div>
            <p className="text-xs text-slate-400">Scalable Devotional Engine • Administrative Backend Supervisor</p>
          </div>
        </div>

        {/* Real-time Telemetry Block */}
        <div className="flex flex-wrap items-center gap-4 text-xs font-mono">
          <div className="bg-rose-950/20 border border-rose-900/30 rounded-lg px-3 py-1.5 flex items-center gap-2">
            <span className="block w-2 h-2 rounded-full bg-amber-500 animate-ping"></span>
            <span className="text-amber-400 font-medium">BaaS Zone: Active (Multi-Tenant)</span>
          </div>
          <div className="bg-slate-900 border border-slate-800 rounded-lg px-3 py-1.5 flex items-center gap-2 text-slate-300">
            <Shield className="w-3.5 h-3.5 text-amber-500" />
            <span>Auth Scope: <strong className="text-white">DIRECTOR</strong></span>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="flex-1 w-full max-w-7xl mx-auto px-4 md:px-6 py-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        {/* Left Hand Navigation Sidebar with Saffron Highlights */}
        <div className="lg:col-span-3 space-y-4">
          <div className="bg-slate-900/60 border border-slate-900 rounded-2xl p-4 space-y-2">
            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest px-2 pb-2 border-b border-slate-950">
              OPERATIONAL SHIELD
            </p>

            {/* TAB: MANAGE BOOKINGS */}
            <button 
              id="tab-bookings-nav"
              onClick={() => { setActiveTab('bookings'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'bookings'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-300 font-semibold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Calendar className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide">Manage Bookings</span>
              </div>
              <span className="text-[10px] font-mono bg-amber-500/10 px-1.5 py-0.5 rounded text-amber-400 font-semibold">
                {bookings.length}
              </span>
            </button>

            {/* TAB: PUJA PRICING */}
            <button 
              id="tab-pujas-nav"
              onClick={() => { setActiveTab('pujas'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'pujas'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-300 font-semibold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Sliders className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide">Manage Pujas</span>
              </div>
              <span className="text-[10px] font-mono bg-amber-500/10 px-1.5 py-0.5 rounded text-amber-400 font-semibold">
                {pujas.length}
              </span>
            </button>

            {/* TAB: AD CAMPAIGNS */}
            <button 
              id="tab-ads-nav"
              onClick={() => { setActiveTab('ads'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'ads'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-300 font-semibold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Layers className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide">Custom Ad Campaigns</span>
              </div>
              <span className="text-[10px] font-mono bg-amber-500/10 px-1.5 py-0.5 rounded text-amber-400 font-semibold">
                {ads.length}
              </span>
            </button>

            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest px-2 pt-4 pb-2 border-b border-slate-950">
              ARCHITECTURE SCHEMATICS
            </p>

            {/* TAB: NO-SQL SCHEMA */}
            <button 
              id="tab-schema-nav"
              onClick={() => { setActiveTab('schema'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'schema'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-300 font-semibold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Database className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide">NoSQL Firestore Schema</span>
              </div>
              <span className="text-[9px] uppercase font-mono px-1.5 py-0.5 rounded bg-slate-950 text-slate-500">
                Data
              </span>
            </button>

            {/* TAB: API PLAYGROUND */}
            <button 
              id="tab-api-nav"
              onClick={() => { setActiveTab('api'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'api'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-300 font-semibold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Code className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide">REST API Playground</span>
              </div>
              <span className="text-[9px] uppercase font-mono px-1.5 py-0.5 rounded bg-slate-950 text-slate-500">
                Test
              </span>
            </button>

            <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest px-2 pt-4 pb-2 border-b border-slate-950">
              BOARD DIRECTORY
            </p>

            {/* TAB: FLUTTER APP CLIENT & SDK */}
            <button 
              id="tab-flutter-nav"
              onClick={() => { setActiveTab('flutter'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'flutter'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-500 font-bold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Smartphone className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide text-amber-400 font-bold">Flutter Mobile Hub</span>
              </div>
              <span className="text-[10px] font-mono bg-amber-500/10 px-1.5 py-0.5 rounded text-amber-400 font-bold border border-amber-500/20">
                SDK
              </span>
            </button>

            {/* TAB: ABOUT DIRECTORS */}
            <button 
              id="tab-directors-nav"
              onClick={() => { setActiveTab('directors'); setApiResponse(null); }}
              className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl transition-all ${
                activeTab === 'directors'
                  ? 'bg-rose-950/30 border-l-4 border-amber-500 text-amber-300 font-semibold'
                  : 'text-slate-400 hover:text-white hover:bg-slate-900/50'
              }`}
            >
              <div className="flex items-center gap-2.5 text-xs">
                <Users className="w-4 h-4 text-amber-500" />
                <span className="tracking-wide">About Directors Security</span>
              </div>
              <span className="block w-2.5 h-2.5 rounded-full bg-amber-500"></span>
            </button>
          </div>

          {/* Quick Hindu Calendar Almanac Widget (Vedic Aesthetic Context) */}
          <div className="border border-amber-950/30 bg-gradient-to-br from-slate-950 to-rose-950/25 rounded-2xl p-4 space-y-2">
            <h4 className="text-[10px] font-bold text-amber-400 flex items-center gap-1.5 uppercase tracking-wider font-mono">
              <HeartHandshake className="w-3.5 h-3.5 text-amber-500" />
              <span>Auspicious Alamanac</span>
            </h4>
            <div className="space-y-1 text-xs">
              <div className="flex justify-between">
                <span className="text-slate-500">Vikram Samvat</span>
                <span className="text-amber-200 font-mono">2083 (Shukla Paksha)</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Lunar Tithi</span>
                <span className="text-amber-200 font-mono">Dashami Ritusamhara</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Mantra Rhythm</span>
                <span className="text-rose-400 font-semibold">Rigveda Swara Live</span>
              </div>
            </div>
          </div>
        </div>

        {/* Right workspace workspace components */}
        <div className="lg:col-span-9 space-y-6">

          {/* 1. MANAGE BOOKINGS WORKSPACE */}
          {activeTab === 'bookings' && (
            <div className="space-y-6">
              <div className="bg-gradient-to-r from-slate-900 to-slate-900/40 border border-slate-900 rounded-2xl p-5 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                  <h2 className="text-lg font-bold text-white flex items-center gap-2">
                    <Calendar className="w-5 h-5 text-amber-500" />
                    <span>Dynamic Puja Booking Management</span>
                  </h2>
                  <p className="text-xs text-slate-400 mt-1">
                    Track live rituals submitted by Flutter devotional end-users. Access locked snapshots of transactional payment ledger histories unaffected by catalog price swings.
                  </p>
                </div>
              </div>

              {/* Transactions list */}
              <div className="border border-slate-900 bg-slate-950 rounded-2xl overflow-hidden">
                <div className="p-4 bg-slate-900 border-b border-slate-900 flex justify-between items-center">
                  <span className="text-xs font-mono text-slate-400 font-bold uppercase tracking-wider">Live Booking Transactions ({bookings.length})</span>
                  <div className="text-[10px] text-slate-500 italic">Auto-Sync via Firestore Client Streams</div>
                </div>

                <div className="divide-y divide-slate-900">
                  {bookings.map((b) => (
                    <div key={b.id} className="p-4 hover:bg-slate-900/40 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4">
                      
                      {/* Booking Summary */}
                      <div className="space-y-2">
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-mono bg-rose-500/10 text-rose-400 px-2.5 py-0.5 rounded-full font-bold border border-rose-500/20">
                            {b.id}
                          </span>
                          <span className="text-xs text-slate-400 font-semibold">Devotee: <strong className="text-white font-sans">{b.userName}</strong></span>
                        </div>
                        
                        <div>
                          <h4 className="text-sm font-bold text-amber-100">{b.pujaName}</h4>
                          <div className="flex flex-wrap items-center gap-x-4 gap-y-1 mt-1 text-xs text-slate-400">
                            <span className="flex items-center gap-1">
                              <Calendar className="w-3.5 h-3.5 text-amber-500" />
                              Requested Date: <strong className="text-slate-200">{b.bookingDate} ({b.slotTime})</strong>
                            </span>
                            <span className="flex items-center gap-1">
                              <Phone className="w-3.5 h-3.5 text-emerald-500" />
                              {b.userPhone}
                            </span>
                          </div>
                        </div>
                      </div>

                      {/* Payment, Status & Action controls */}
                      <div className="flex items-center justify-between md:justify-end gap-6 border-t md:border-t-0 pt-3 md:pt-0 border-slate-900">
                        <div className="text-right">
                          <p className="text-[10px] text-slate-500 font-mono">Snapshot Price Locked</p>
                          <p className="text-sm font-bold text-amber-400 font-mono">INR {b.pricePaid.toLocaleString('en-IN')}</p>
                        </div>

                        {/* Status pill with update toggler dropdown widget */}
                        <div className="flex items-center gap-2.5">
                          <span className={`px-2.5 py-1 text-[10px] font-mono font-bold rounded-lg border ${
                            b.status === 'CONFIRMED' ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' :
                            b.status === 'PENDING' ? 'bg-amber-500/10 text-amber-400 border-amber-500/20' :
                            b.status === 'COMPLETED' ? 'bg-indigo-500/10 text-indigo-400 border-indigo-500/20' :
                            'bg-slate-800 text-slate-400 border-slate-700'
                          }`}>
                            {b.status}
                          </span>

                          <select
                            value={b.status}
                            onChange={(e) => handleUpdateBookingStatus(b.id, e.target.value as any)}
                            className="bg-slate-900 text-slate-300 text-xs rounded border border-slate-800 px-2 py-1 outline-none focus:border-amber-500"
                          >
                            <option value="PENDING">Pending</option>
                            <option value="CONFIRMED">Confirm</option>
                            <option value="COMPLETED">Completed</option>
                            <option value="CANCELLED">Cancel</option>
                          </select>
                        </div>

                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* 2. MANAGE PUJA PRICING WORKSPACE */}
          {activeTab === 'pujas' && (
            <div className="space-y-6">
              
              <div className="bg-gradient-to-r from-slate-900 to-slate-900/40 border border-slate-900 rounded-2xl p-5 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                  <h2 className="text-lg font-bold text-white flex items-center gap-2">
                    <Sliders className="w-5 h-5 text-amber-500" />
                    <span>Dynamic Puja Offerings Catalog</span>
                  </h2>
                  <p className="text-xs text-slate-400 mt-1">
                    Define and update services in real time. Adjust pricing parameters to instantly reflect on-demand rates throughout your app's frontend catalog viewports.
                  </p>
                </div>

                <button 
                  id="add-puja-btn"
                  onClick={() => setIsAddingPuja(!isAddingPuja)}
                  className="bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold px-3.5 py-2 rounded-xl text-xs flex items-center gap-1.5 transition-all self-start sm:self-auto"
                >
                  <Plus className="w-4 h-4" />
                  <span>{isAddingPuja ? 'Close Form' : 'Add Puja Offering'}</span>
                </button>
              </div>

              {/* Dynamic Puja Creator Form */}
              {isAddingPuja && (
                <form onSubmit={handleCreatePuja} className="bg-slate-900 border border-amber-500/20 rounded-2xl p-6 space-y-4">
                  <div className="border-b border-slate-800 pb-2.5">
                    <h3 className="text-sm font-semibold text-amber-300">New puja dynamic template configuration</h3>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase tracking-widest font-mono">Puja Ritual Title *</label>
                      <input 
                        type="text" 
                        required 
                        placeholder="e.g. Mahamrityunjaya Mantra Jaap"
                        value={pujaFormInput.name}
                        onChange={(e) => setPujaFormInput({ ...pujaFormInput, name: e.target.value })}
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase tracking-widest font-mono">Dynamic Price (INR) *</label>
                      <input 
                        type="number" 
                        required 
                        value={pujaFormInput.price}
                        onChange={(e) => setPujaFormInput({ ...pujaFormInput, price: Number(e.target.value) })}
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-amber-400 font-mono focus:border-amber-500 outline-none"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase tracking-widest font-mono">Duration (Minutes)</label>
                      <input 
                        type="number" 
                        value={pujaFormInput.durationMinutes}
                        onChange={(e) => setPujaFormInput({ ...pujaFormInput, durationMinutes: Number(e.target.value) })}
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none"
                      />
                    </div>
                  </div>

                  <div className="space-y-1">
                    <label className="text-[10px] text-slate-400 uppercase tracking-widest font-mono">Theological Description</label>
                    <textarea 
                      placeholder="Enter puja importance described in context of Vedic scriptures..."
                      value={pujaFormInput.description}
                      onChange={(e) => setPujaFormInput({ ...pujaFormInput, description: e.target.value })}
                      className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none"
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase tracking-widest font-mono">Image URL / Path</label>
                      <input 
                        type="text" 
                        value={pujaFormInput.imageUrn}
                        onChange={(e) => setPujaFormInput({ ...pujaFormInput, imageUrn: e.target.value })}
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase tracking-widest font-mono">Benefits (Comma separated)</label>
                      <input 
                        type="text" 
                        value={pujaFormInput.benefitsStr}
                        onChange={(e) => setPujaFormInput({ ...pujaFormInput, benefitsStr: e.target.value })}
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none"
                      />
                    </div>
                  </div>

                  <div className="flex items-center gap-2 py-1">
                    <input 
                      type="checkbox" 
                      id="samagri-check"
                      checked={pujaFormInput.samagriIncluded}
                      onChange={(e) => setPujaFormInput({ ...pujaFormInput, samagriIncluded: e.target.checked })}
                      className="rounded text-amber-500 bg-slate-950 border-slate-800"
                    />
                    <label htmlFor="samagri-check" className="text-xs text-slate-400 font-mono">Vedic Ritual Samagri (holy leaves, oils, ghee, wooden components) included in pricing base?</label>
                  </div>

                  <button 
                    type="submit"
                    className="bg-gradient-to-r from-amber-500 to-rose-700 text-white font-bold px-4 py-2 rounded-xl text-xs shadow-md"
                  >
                    Commit Puja Object Instance To Cloud
                  </button>
                </form>
              )}

              {/* Pujas grid list */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {pujas.map((p) => (
                  <div key={p.id} className="bg-slate-900/40 border border-slate-900 rounded-2xl overflow-hidden flex flex-col justify-between">
                    <div>
                      {/* Image Preview Banner */}
                      <div className="h-32 w-full position-relative">
                        <img 
                          src={p.imageUrn} 
                          alt={p.name} 
                          className="h-full w-full object-cover filter brightness-[0.70] contrast-[1.05]"
                          referrerPolicy="no-referrer"
                        />
                        <div className="absolute top-3 left-3 bg-slate-950/80 backdrop-blur-md px-2.5 py-1 rounded text-[10px] font-mono font-bold text-amber-400 border border-amber-500/10">
                          ID: {p.id}
                        </div>
                      </div>

                      <div className="p-4 space-y-3">
                        <div className="flex justify-between items-start gap-2">
                          <h3 className="text-sm font-bold text-white">{p.name}</h3>
                          <span className={`px-2 py-0.5 rounded text-[10px] uppercase font-mono border ${
                            p.active ? 'bg-emerald-500/15 text-emerald-400 border-emerald-500/10' : 'bg-slate-800 text-slate-400 border-slate-700'
                          }`}>
                            {p.active ? 'Active (Live)' : 'Inactive'}
                          </span>
                        </div>
                        <p className="text-xs text-slate-400 leading-relaxed line-clamp-2">{p.description}</p>
                        
                        <div className="flex flex-wrap gap-1.5 mt-2">
                          {p.benefits.map((benefit, bIdx) => (
                            <span key={bIdx} className="bg-rose-950/15 text-rose-300 text-[10px] px-2 py-0.5 rounded border border-rose-950/20 font-sans">
                              ✦ {benefit}
                            </span>
                          ))}
                        </div>

                        <div className="flex items-center justify-between pt-2 text-[11px] font-mono text-slate-400 border-t border-slate-950">
                          <span>Duration: <strong>{p.durationMinutes} Mins</strong></span>
                          <span>Samagri Included: <strong className="text-slate-200">{p.samagriIncluded ? 'Yes' : 'No'}</strong></span>
                        </div>
                      </div>
                    </div>

                    <div className="p-4 bg-slate-900/60 border-t border-slate-950 flex flex-col md:flex-row md:items-center justify-between gap-3">
                      
                      {/* Pricing inline editor */}
                      <div className="flex items-center gap-2">
                        {editingPujaId === p.id ? (
                          <div className="flex items-center gap-1.5">
                            <input 
                              type="number"
                              className="bg-slate-950 border border-slate-800 rounded px-2 py-1 w-20 text-xs font-mono text-amber-400"
                              value={editPriceVal}
                              onChange={(e) => setEditPriceVal(Number(e.target.value))}
                            />
                            <button 
                              onClick={() => handleUpdatePrice(p.id)}
                              className="bg-emerald-500 text-slate-950 hover:bg-emerald-400 p-1 rounded font-bold text-xs"
                            >
                              Save
                            </button>
                            <button 
                              onClick={() => setEditingPujaId(null)}
                              className="bg-slate-800 text-slate-400 p-1 rounded text-xs"
                            >
                              X
                            </button>
                          </div>
                        ) : (
                          <div className="space-y-0.5">
                            <p className="text-[10px] text-slate-500 uppercase font-mono tracking-widest">Pricing Target</p>
                            <div className="flex items-center gap-1.5">
                              <span className="text-sm font-bold font-mono text-amber-400">INR {p.price.toLocaleString('en-IN')}</span>
                              <button 
                                onClick={() => { setEditingPujaId(p.id); setEditPriceVal(p.price); }}
                                className="text-slate-400 hover:text-amber-500"
                                title="Edit pricing dynamic parameters"
                              >
                                <Edit2 className="w-3.5 h-3.5" />
                              </button>
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Display toggle trigger */}
                      <button 
                        onClick={() => handleTogglePujaActive(p.id)}
                        className={`text-xs font-semibold px-2.5 py-1.5 rounded-lg border transition-all ${
                          p.active 
                            ? 'bg-rose-950/25 border-rose-950 text-rose-400 hover:bg-rose-950/40' 
                            : 'bg-emerald-950/20 border-emerald-950 text-emerald-400 hover:bg-emerald-950/30'
                        }`}
                      >
                        {p.active ? 'Deactivate Live Promo' : 'Activate Puja Catalog'}
                      </button>

                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* 3. CUSTOM AD CAMPAIGNS WORKSPACE (With Saffron/Gold/Maroon dark theme inputs) */}
          {activeTab === 'ads' && (
            <div className="space-y-6">
              
              <div className="bg-gradient-to-r from-rose-950/40 to-slate-900/40 border border-rose-900/20 rounded-2xl p-6">
                <div className="flex items-center gap-2 text-amber-500 text-xs tracking-wider uppercase font-semibold">
                  <Layers className="w-3.5 h-3.5" />
                  <span>Internal Advertisement Campaigns Module</span>
                </div>
                <h2 className="text-xl font-bold text-white mt-1">Saffron Campaign Ad Server Settings</h2>
                <p className="text-xs text-slate-400 mt-1">
                  Upload promotional banners, configure redirection paths (deep links targeting Flutter homepages), and monitor click performance indexes dynamically here.
                </p>
              </div>

              {adSuccessMessage && (
                <div className="bg-emerald-950/20 border border-emerald-500/20 px-4 py-3 rounded-xl flex items-center gap-2 text-xs text-emerald-400 animate-fadeIn">
                  <CheckCircle className="w-4 h-4 text-emerald-500" />
                  <span className="font-mono">{adSuccessMessage}</span>
                </div>
              )}

              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                
                {/* Campaigns Configuration Form with Maroon / Gold accentuation */}
                <div className="lg:col-span-5 bg-gradient-to-b from-slate-900 to-slate-950 border border-slate-900 rounded-2xl p-5 space-y-4">
                  <div className="border-b border-slate-900 pb-2">
                    <h3 className="text-xs font-semibold uppercase tracking-widest text-amber-400 font-mono">Create Dynamic Ad Campaign</h3>
                    <p className="text-[10px] text-slate-500">Inputs instantly commit to active API query sets.</p>
                  </div>

                  <form onSubmit={handleAddAdCampaign} className="space-y-3.5">
                    
                    {/* Input: Campaign Name */}
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase font-mono tracking-wider">Campaign Identity</label>
                      <input 
                        type="text"
                        value={adFormInput.campaignName}
                        onChange={(e) => setAdFormInput({ ...adFormInput, campaignName: e.target.value })}
                        placeholder="e.g. Durga Puja Festive Special Offers"
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none font-sans"
                        required
                      />
                    </div>

                    {/* Input: Ad Title */}
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase font-mono tracking-wider">Ad Banner Title / Heading</label>
                      <input 
                        type="text"
                        value={adFormInput.title}
                        onChange={(e) => setAdFormInput({ ...adFormInput, title: e.target.value })}
                        placeholder="e.g. Standard 30% discount on first booking of Durga Havan"
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-250 focus:border-amber-500 outline-none"
                        required
                      />
                    </div>

                    {/* Input: Image URL with Preset / suggestion hints */}
                    <div className="space-y-1">
                      <div className="flex justify-between">
                        <label className="text-[10px] text-slate-400 uppercase font-mono tracking-wider">Image / Banner URL</label>
                        <button 
                          type="button"
                          onClick={() => setAdFormInput({ ...adFormInput, imageUrl: 'https://images.unsplash.com/photo-1609137144814-1e9a3b2b8045?auto=format&fit=crop&q=80&w=1200' })}
                          className="text-[9px] text-amber-500 hover:underline"
                        >
                          Use Stock Shivratri Demo
                        </button>
                      </div>
                      <input 
                        type="text"
                        value={adFormInput.imageUrl}
                        onChange={(e) => setAdFormInput({ ...adFormInput, imageUrl: e.target.value })}
                        placeholder="https://images.unsplash.com/..."
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none font-mono"
                        required
                      />
                    </div>

                    {/* Input: Redirect Link */}
                    <div className="space-y-1">
                      <label className="text-[10px] text-slate-400 uppercase font-mono tracking-wider">Target Link / Deep Schema Route</label>
                      <input 
                        type="text"
                        value={adFormInput.targetLink}
                        onChange={(e) => setAdFormInput({ ...adFormInput, targetLink: e.target.value })}
                        placeholder="vedicreeti://pujas/puja_rudrabhishek_01"
                        className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-slate-200 focus:border-amber-500 outline-none font-mono"
                      />
                    </div>

                    {/* Toggle: Active State */}
                    <div className="flex items-center justify-between py-2 border-y border-slate-950">
                      <span className="text-xs text-slate-400 font-medium">Activate Campaign Instantly?</span>
                      <button 
                        type="button"
                        onClick={() => setAdFormInput({ ...adFormInput, active: !adFormInput.active })}
                        className={`text-xs px-3 py-1 rounded-full font-mono font-bold uppercase transition-colors ${
                          adFormInput.active ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-slate-800 text-slate-400 border border-slate-700'
                        }`}
                      >
                        {adFormInput.active ? 'ACTIVE' : 'INACTIVE'}
                      </button>
                    </div>

                    <button 
                      type="submit"
                      className="w-full bg-gradient-to-r from-amber-500 via-orange-600 to-rose-700 hover:from-amber-600 hover:to-rose-800 text-white font-bold py-2.5 rounded-xl text-xs shadow-md transition-all flex items-center justify-center gap-1.5"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Commit Active Banner Campaign</span>
                    </button>
                  </form>
                </div>

                {/* Live Active Banners Layout Queue on Server */}
                <div className="lg:col-span-7 space-y-4">
                  <div className="text-xs font-mono text-slate-400 font-bold uppercase tracking-wider px-1">
                    Live Active Server Banners ({ads.length})
                  </div>

                  <div className="space-y-4">
                    {ads.map((ad) => (
                      <div key={ad.id} className="bg-slate-900/40 border border-slate-900 rounded-2xl overflow-hidden p-4 space-y-3 relative group">
                        
                        {/* Background preview image overlayed */}
                        <div className="h-32 rounded-xl overflow-hidden relative border border-slate-800">
                          <img 
                            src={ad.imageUrl} 
                            alt={ad.title} 
                            className="w-full h-full object-cover brightness-[0.60] transition-transform duration-300 group-hover:scale-105"
                            referrerPolicy="no-referrer"
                          />
                          <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/20 to-transparent p-4 flex flex-col justify-between">
                            <div className="flex justify-between items-start gap-2">
                              <span className="bg-amber-500/15 border border-amber-500/30 text-amber-400 text-[10px] uppercase font-mono font-bold px-2 py-0.5 rounded-md">
                                {ad.campaignName}
                              </span>
                              
                              <button 
                                onClick={() => handleDeleteAd(ad.id)}
                                className="bg-rose-500/20 text-rose-400 hover:bg-rose-500 p-1.5 rounded-lg transition-colors hover:text-slate-950"
                                title="Delete campaign configuration"
                              >
                                <Trash2 className="w-3.5 h-3.5" />
                              </button>
                            </div>

                            <div>
                              <p className="text-xs text-amber-200 mt-2 font-mono font-bold uppercase tracking-wide">Target Redirection Deep-Link:</p>
                              <code className="text-[10px] text-slate-300 truncate block max-w-sm">{ad.targetLink}</code>
                            </div>
                          </div>
                        </div>

                        {/* Title and Stats Row */}
                        <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-2 pt-1">
                          <div className="space-y-0.5">
                            <h4 className="text-sm font-bold text-white leading-snug">{ad.title}</h4>
                            <div className="flex items-center gap-2 text-[10px] text-slate-500 font-mono">
                              <span>CAMPAIGN ID: {ad.id}</span>
                            </div>
                          </div>

                          <div className="flex gap-2 text-right text-[11px] font-mono shrink-0">
                            <div className="bg-slate-950 rounded px-2.5 py-1 border border-slate-800">
                              <span className="text-slate-500 uppercase text-[9px] block">Imps</span>
                              <span className="text-slate-300 font-bold">12k+</span>
                            </div>
                            <div className="bg-indigo-950/20 rounded px-2.5 py-1 border border-indigo-950/40">
                              <span className="text-indigo-400 uppercase text-[9px] block">Clicks</span>
                              <span className="text-indigo-300 font-bold">4.2%</span>
                            </div>
                          </div>
                        </div>

                        {/* Operational State Controller */}
                        <div className="flex items-center justify-between pt-2.5 border-t border-slate-950 text-xs">
                          <span className="text-slate-500 font-mono">Campaign status control:</span>
                          <button 
                            onClick={() => handleToggleAd(ad.id)}
                            className={`px-3 py-1 rounded-lg border text-xs font-mono uppercase font-bold transition-all ${
                              ad.active ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-slate-800 text-slate-400 border border-slate-700'
                            }`}
                          >
                            {ad.active ? 'Active on App' : 'INACTIVE'}
                          </button>
                        </div>

                      </div>
                    ))}
                  </div>

                </div>

              </div>

            </div>
          )}

          {/* 4. NOSQL FIRE_STORE SCHEMA VISUALIZER WORKSPACE */}
          {activeTab === 'schema' && (
            <div className="space-y-6">
              <div className="bg-gradient-to-r from-slate-900 to-slate-900/40 border border-slate-900 rounded-2xl p-6">
                <div className="flex items-center gap-2 text-amber-500 text-xs tracking-wider uppercase font-semibold">
                  <Database className="w-3.5 h-3.5" />
                  <span>NoSQL Architecture Specifications</span>
                </div>
                <h2 className="text-xl font-bold text-white mt-1">{NO_SQL_SCHEMA_DOCS.title}</h2>
                <p className="text-xs text-slate-400 mt-1">
                  Engineered using a flexible document mapping model, targeting scalable Firestore partitions. Multi-tenancy is enforced cleanly via global tenancy parameters.
                </p>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                  {NO_SQL_SCHEMA_DOCS.designPrinciples.map((principle, idx) => (
                    <div key={idx} className="flex gap-2.5 bg-slate-950/60 border border-slate-900 p-3 rounded-xl text-xs">
                      <div className="bg-amber-500/20 text-amber-400 px-2.5 py-1 rounded height-fit flex items-center justify-center font-mono font-bold self-start border border-amber-500/20">
                        {idx + 1}
                      </div>
                      <p className="text-slate-300 leading-relaxed font-sans">{principle}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* Collections Cards Map */}
              <div className="space-y-4">
                {NO_SQL_SCHEMA_DOCS.collections.map((col) => (
                  <div key={col.name} className="bg-slate-900/40 border border-slate-900 rounded-2xl overflow-hidden shadow-sm">
                    <div className="bg-slate-900 p-4 border-b border-slate-900 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-mono font-bold text-amber-400 bg-amber-500/10 border border-amber-500/20 px-2.5 py-0.5 rounded">
                            collection: {col.name}
                          </span>
                          <span className="text-[10px] text-slate-500 font-mono">
                            ID: <code className="text-slate-300 bg-slate-950 px-1 rounded">{col.idFormat}</code>
                          </span>
                        </div>
                        <p className="text-xs text-slate-400 mt-1">{col.description}</p>
                      </div>

                      <button 
                        onClick={() => handleCopyText(col.sampleJson, col.name)}
                        className="bg-slate-950 hover:bg-slate-900 border border-slate-800 text-slate-300 hover:text-white px-3 py-1.5 rounded-lg text-xs flex items-center gap-1.5 transition-colors font-mono self-end sm:self-auto"
                      >
                        {copiedColId === col.name ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                        {copiedColId === col.name ? 'Copied' : 'Copy sample schema'}
                      </button>
                    </div>

                    <div className="grid grid-cols-1 lg:grid-cols-2">
                      {/* Left: Fields List */}
                      <div className="p-4 space-y-3 max-h-96 overflow-y-auto border-r border-slate-950">
                        <div className="text-[9px] font-bold text-slate-500 uppercase tracking-widest pb-1 border-b border-slate-950">
                          Field attributes map
                        </div>
                        <div className="divide-y divide-slate-950">
                          {col.fields.map((f) => (
                            <div key={f.name} className="py-2 flex items-start gap-4">
                              <div className="w-1/3">
                                <span className="text-xs font-semibold text-slate-200 font-mono block">{f.name}</span>
                                <span className="text-[9px] font-mono text-amber-500 block">{f.type}</span>
                              </div>
                              <div className="w-2/3">
                                <p className="text-xs text-slate-400 leading-relaxed">{f.desc}</p>
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>

                      {/* Right: Code Sample */}
                      <div className="p-4 bg-slate-950/80 flex flex-col justify-between">
                        <div>
                          <p className="text-[9px] font-bold text-slate-500 uppercase tracking-widest pb-2 border-b border-slate-900">
                            Document JSON Instance Example
                          </p>
                          <pre className="text-[11px] font-mono text-teal-400 p-3 overflow-x-auto rounded bg-slate-950/40 leading-normal select-all">
                            {col.sampleJson}
                          </pre>
                        </div>
                      </div>

                    </div>
                  </div>
                ))}
              </div>

            </div>
          )}

          {/* 5. REST API ENDPOINTS PLAYGROUND */}
          {activeTab === 'api' && (
            <div className="space-y-6">
              <div className="bg-gradient-to-r from-slate-900 to-slate-900/40 border border-slate-900 rounded-2xl p-6">
                <div className="flex items-center gap-2 text-amber-500 text-xs tracking-wider uppercase font-semibold">
                  <Code className="w-3.5 h-3.5" />
                  <span>Active Api Playground Sandbox</span>
                </div>
                <h2 className="text-xl font-bold text-white mt-1">Simulated Rest Endpoints Control Room</h2>
                <p className="text-xs text-slate-400 mt-1">
                  Perform sample CRUD calls directly against local BaaS mock database instances. Verify structural request formats instantly.
                </p>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
                
                {/* Left: Endpoint selectors */}
                <div className="lg:col-span-5 space-y-2.5 max-h-[500px] overflow-y-auto">
                  <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest px-1">Choose API Endpoint Route</p>
                  {REST_API_ENDPOINTS.map((api, idx) => {
                    const isSelected = selectedApi.path === api.path && selectedApi.method === api.method;
                    return (
                      <button
                        key={idx}
                        onClick={() => handleSelectApi(api)}
                        className={`w-full text-left p-3 rounded-xl border transition-all text-xs space-y-1 ${
                          isSelected 
                            ? 'bg-rose-950/20 border-amber-500/40 shadow-inner' 
                            : 'bg-slate-900/60 border-slate-900'
                        }`}
                      >
                        <div className="flex justify-between items-center">
                          <span className={`px-2 py-0.5 rounded font-mono text-[9px] font-bold border ${
                            api.method === 'GET' ? 'bg-indigo-500/10 text-indigo-400 border-indigo-500/20' : 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20'
                          }`}>
                            {api.method}
                          </span>
                          <span className="text-[9px] uppercase font-mono text-slate-500">{api.category}</span>
                        </div>
                        <p className="font-mono text-slate-200 truncate mt-1">{api.path}</p>
                        <p className="text-[11px] text-slate-500 line-clamp-1">{api.description}</p>
                      </button>
                    );
                  })}
                </div>

                {/* Right: Interactive console */}
                <div className="lg:col-span-7 bg-slate-900 border border-slate-900 rounded-2xl overflow-hidden p-5 flex flex-col justify-between">
                  <div>
                    <div className="border-b border-slate-950 pb-3 flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="bg-amber-500/10 border border-amber-500/20 text-amber-400 rounded px-2 py-0.5 font-mono text-xs font-bold uppercase">
                          {selectedApi.method}
                        </span>
                        <code className="text-white font-mono text-xs font-semibold">{selectedApi.path}</code>
                      </div>
                      <span className="text-[10px] text-slate-500 font-mono tracking-wider">SECURE ENDPOINT</span>
                    </div>

                    <div className="space-y-4 mt-4">
                      {/* Headers simulation */}
                      <div className="space-y-1">
                        <label className="text-[10px] text-slate-500 uppercase tracking-widest font-mono">Request Headers parameters</label>
                        <div className="bg-slate-950 rounded-xl p-3 border border-slate-900 space-y-1.5 text-xs font-mono text-slate-400">
                          <div className="flex justify-between">
                            <span>X-Tenant-ID:</span>
                            <span className="text-amber-400">tenant_vedic_reeti</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Authorization:</span>
                            <span className="text-slate-350 truncate max-w-xs">{customHeaders['Authorization']}</span>
                          </div>
                        </div>
                      </div>

                      {/* Request body info */}
                      {selectedApi.exampleRequestBody && (
                        <div className="space-y-1.5">
                          <label className="text-[10px] text-slate-500 uppercase tracking-widest font-mono">Example Payload Schema</label>
                          <pre className="text-[10px] font-mono text-rose-300 bg-slate-950/80 p-3 rounded-lg overflow-x-auto leading-normal">
                            {selectedApi.exampleRequestBody}
                          </pre>
                        </div>
                      )}

                      <button
                        onClick={handleTriggerApiSimulation}
                        disabled={isSimulatingRequest}
                        className="w-full bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 text-slate-950 font-bold py-2 px-4 rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5"
                      >
                        {isSimulatingRequest ? (
                          <>
                            <RefreshCw className="w-4 h-4 animate-spin" />
                            <span>Connecting Cloud Firestore Databases...</span>
                          </>
                        ) : (
                          <>
                            <Play className="w-4 h-4 text-slate-950" />
                            <span>Execute Sandbox Sandbox Call</span>
                          </>
                        )}
                      </button>

                      {apiMetadata && (
                        <div className="border border-slate-950 bg-slate-950 rounded-xl overflow-hidden mt-4">
                          <div className="bg-slate-900 px-3 py-1.5 border-b border-slate-950 flex justify-between items-center text-[10px] font-mono">
                            <span className="text-slate-400">Response output body</span>
                            <div className="flex gap-2.5 text-slate-500">
                              <span>Code: <strong className="text-emerald-400">{apiMetadata.statusCode}</strong></span>
                              <span>Latency: <strong className="text-amber-400">{apiMetadata.latency}ms</strong></span>
                            </div>
                          </div>
                          <div className="p-3">
                            <pre className="text-xs font-mono text-teal-400 overflow-x-auto select-all max-h-48 leading-normal">
                              {JSON.stringify(apiResponse, null, 2)}
                            </pre>
                          </div>
                        </div>
                      )}

                    </div>
                  </div>
                </div>

              </div>
            </div>
          )}

          {/* 6. ABOUT THE DIRECTORS - TIWARI RBAC CONFIG WORKSPACE */}
          {activeTab === 'directors' && (
            <div className="space-y-6">
              
              <div className="bg-gradient-to-r from-slate-900 to-slate-900/40 border border-slate-900 rounded-2xl p-6">
                <div className="flex items-center gap-2 text-amber-500 text-xs tracking-wider uppercase font-semibold">
                  <Shield className="w-3.5 h-3.5" />
                  <span>Administrative Role-Based Access Control</span>
                </div>
                <h2 className="text-xl font-bold text-white mt-1">Tiwari Board of Directors Privileged Index</h2>
                <p className="text-xs text-slate-400 mt-1">
                  Directors retain complete operational overrides. Review individual accounts assigned to Ramesh, Diya, and Nikhil Tiwari below.
                </p>
              </div>

              {/* Grid of Directors Profiles with high aesthetic layout details */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {rbacUsers.map((user) => (
                  <div key={user.userId} className="bg-slate-900/40 border border-slate-900 rounded-2xl overflow-hidden shadow">
                    
                    {/* Header profile background */}
                    <div className="bg-gradient-to-r from-rose-950/20 to-amber-950/20 p-5 border-b border-slate-950 text-center relative">
                      <div className="absolute top-3 right-3 bg-amber-500/10 border border-amber-500/20 text-amber-400 text-[10px] uppercase font-mono px-2 py-0.5 rounded-full font-bold">
                        {user.role}
                      </div>

                      {/* Avatar initials with Saffron visual ring */}
                      <div className="w-16 h-16 rounded-full mx-auto bg-slate-950 border-2 border-amber-500/40 flex items-center justify-center text-white text-lg font-serif font-bold shadow-lg">
                        {user.name.split(' ').map(n => n[0]).join('')}
                      </div>

                      <h3 className="text-sm font-bold text-slate-100 mt-3 font-serif">{user.name}</h3>
                      <p className="text-xs text-slate-400 font-mono mt-0.5">{user.email}</p>
                    </div>

                    {/* Authorized Permissions list */}
                    <div className="p-4 space-y-3.5">
                      <div className="flex items-center justify-between text-[10px] uppercase font-mono pb-1.5 border-b border-slate-950 text-slate-500">
                        <span>Assigned Permissions</span>
                        <span className="text-amber-400">{user.permissions.length} keys</span>
                      </div>

                      <div className="flex flex-wrap gap-1.5 max-h-40 overflow-y-auto">
                        {user.permissions.map((perm) => (
                          <span key={perm} className="bg-rose-950/15 text-rose-300 text-[10px] font-mono px-2 py-0.5 rounded border border-rose-950/20 truncate">
                            {perm}
                          </span>
                        ))}
                      </div>

                      <div className="pt-3 border-t border-slate-950 text-[10px] text-slate-500 font-mono flex items-center justify-between">
                        <span>Provisioned Date:</span>
                        <span className="text-slate-300">2026-05-26</span>
                      </div>
                    </div>

                  </div>
                ))}
              </div>

              {/* RBAC Technical details overview */}
              <div className="border border-slate-900 bg-slate-950 p-5 rounded-2xl space-y-2 text-xs">
                <h4 className="font-bold text-amber-400 flex items-center gap-1.5 font-mono uppercase tracking-wider text-[11px]">
                  <Shield className="w-4 h-4 text-amber-500" />
                  <span>Security Sandbox Operations Protocol</span>
                </h4>
                <p className="text-slate-400 leading-relaxed font-sans">
                  Each user authentication flow validates against secure JSON Web Tokens issued by standard Firebase Auth pipelines. Active Firestore Security Rules automatically match corresponding <strong>uid</strong> mappings nested in authorization files to restrict catalogs, pricing overrides, and promotions parameters strictly to our elite Directors board.
                </p>
              </div>

            </div>
          )}

          {/* 7. FLUTTER APP CLIENT & SDK WORKSPACE */}
          {activeTab === 'flutter' && (
            <FlutterWorkspace 
              pujas={pujas}
              ads={ads}
              onAddBooking={(newBooking) => setBookings(prev => [newBooking, ...prev])}
            />
          )}

        </div>
      </main>

      {/* Elegant Saffron/Gold/Maroon Footer with Professional Developer Credit */}
      <footer className="border-t border-rose-950/40 bg-slate-950/90 text-slate-400 px-6 py-6 mt-12">
        <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4 text-xs font-mono">
          
          <div className="flex items-center gap-2">
            <span className="block w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse"></span>
            <span className="text-slate-400 text-[11px]">
              VedicReeti BaaS control interfaces operationalized in real-time sandbox.
            </span>
          </div>

          <div className="flex items-center gap-1.5 text-center md:text-right">
            <span className="text-slate-500">System Architected & Developed by</span>
            <span className="bg-gradient-to-r from-amber-400 via-amber-300 to-amber-500 bg-clip-text text-transparent font-bold tracking-wide font-sans text-xs">
              Aryan Mishra
            </span>
            <span className="text-amber-500 font-serif">✦</span>
          </div>

        </div>
      </footer>

    </div>
  );
}
