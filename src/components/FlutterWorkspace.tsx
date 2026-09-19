import React, { useState } from 'react';
import { 
  Smartphone, Code, Copy, Check, Sparkles, AlertCircle, ShoppingBag, 
  Info, ShieldCheck, Heart, User, CheckCircle2, ChevronRight, Phone, 
  MapPin, HeartHandshake, Eye, Award, ExternalLink, Calendar, Users, Sliders
} from 'lucide-react';
import { Puja, AdBanner, PujaBooking } from '../types';

interface FlutterWorkspaceProps {
  pujas: Puja[];
  ads: AdBanner[];
  onAddBooking: (booking: PujaBooking) => void;
}

// Aux helper components for premium asset placeholder fallback rendering
const AppIconVisual = ({ className = "w-12 h-12" }: { className?: string }) => {
  return (
    <div className={`relative ${className} shrink-0`}>
      <img 
        src="/assets/.aistudio/images/app_icon.png" 
        alt="Diya Icon"
        className="w-full h-full object-cover rounded-full border border-amber-500/20"
        onError={(e) => {
          e.currentTarget.style.display = 'none';
          const sibling = e.currentTarget.nextElementSibling as HTMLElement;
          if (sibling) sibling.style.display = 'flex';
        }}
        referrerPolicy="no-referrer"
      />
      <div 
        style={{ display: 'none' }} 
        className="absolute inset-0 bg-gradient-to-br from-amber-600 to-rose-900 rounded-full flex items-center justify-center border border-amber-400/40 shadow-[0_0_12px_rgba(217,119,6,0.4)]"
      >
        <svg className="w-2/3 h-2/3 text-amber-300" viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2c.5 1.5 2 3.5 2 5.5s-1 3.5-2 3.5-2-1.5-2-3.5S11.5 3.5 12 2zm-8 14c0-3.3 2.7-6 6-6s6 2.7 6 6c0 2-1 3.7-2.5 4.7-.8.5-1.5.3-2-.5-.3-.5-.1-1.2.4-1.6.8-.6 1.1-1.5 1.1-2.6 0-1.7-1.3-3-3-3s-3 1.3-3 3c0 .8.3 1.5.7 2 .4.5.6 1.2.2 1.7-.4.6-1.1.8-1.7.4C4.8 19.3 4 17.8 4 16z" />
        </svg>
      </div>
    </div>
  );
};

const LogoDarkVisual = ({ className = "h-6", logoWidth = "auto" }: { className?: string; logoWidth?: string }) => {
  return (
    <div className={`relative flex items-center justify-center ${className}`} style={{ width: logoWidth }}>
      <img
        src="/assets/.aistudio/images/logo_dark.png"
        alt="VedicReeti Logo"
        className="max-h-full object-contain"
        onError={(e) => {
          e.currentTarget.style.display = 'none';
          const sibling = e.currentTarget.nextElementSibling as HTMLElement;
          if (sibling) sibling.style.display = 'block';
        }}
        referrerPolicy="no-referrer"
      />
      <div style={{ display: 'none' }} className="font-serif font-black text-rose-500 uppercase text-[10px] tracking-widest text-center">
        Vedic<span className="text-amber-400">Reeti</span>
      </div>
    </div>
  );
};

export default function FlutterWorkspace({ pujas, ads, onAddBooking }: FlutterWorkspaceProps) {
  // Simulator Active Screen: 'splash' | 'home' | 'pujas' | 'about'
  const [simulatorTab, setSimulatorTab] = useState<'splash' | 'home' | 'pujas' | 'about'>('home');
  // Copy state index for code blocks
  const [copiedCodeId, setCopiedCodeId] = useState<string | null>(null);
  // Code Hub Active file switch
  const [activeCodeFile, setActiveCodeFile] = useState<string>('ad_banner_widget');

  // Interactive booking state mapping (for dynamic simulation)
  const [selectedPujaForBooking, setSelectedPujaForBooking] = useState<Puja | null>(null);
  const [bookingName, setBookingName] = useState('');
  const [bookingPhone, setBookingPhone] = useState('');
  const [bookingDate, setBookingDate] = useState('2026-06-18');
  const [bookingTime, setBookingTime] = useState('08:00 AM - 10:00 AM');
  const [simulationToast, setSimulationToast] = useState<string | null>(null);
  const [paymentStep, setPaymentStep] = useState<'details' | 'checkout' | 'processing' | 'success'>('details');
  const [simulatedGateway, setSimulatedGateway] = useState<'razorpay' | 'stripe'>('razorpay');
  const [paymentLog, setPaymentLog] = useState<string[]>([]);

  // Trigger simulated toast in phone interface
  const showToast = (message: string) => {
    setSimulationToast(message);
    setTimeout(() => setSimulationToast(null), 3500);
  };

  const handleCopyCode = (code: string, id: string) => {
    navigator.clipboard.writeText(code);
    setCopiedCodeId(id);
    setTimeout(() => setCopiedCodeId(null), 2000);
  };

  // Submit dynamic booking details to trigger payment initialization
  const handleSimulatedBookingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPujaForBooking || !bookingName || !bookingPhone) return;

    setPaymentStep('checkout');
    setPaymentLog([
      `[CLIENT] HTTP POST /api/v1/payments/create-order`,
      `[SERVER] Fetching verified database rate for '${selectedPujaForBooking.name}'...`,
      `[SERVER] Authoritative price confirmed: INR ${selectedPujaForBooking.price}`,
      `[SERVER] Generated orderId: vdc_order_${Math.floor(Math.random() * 100000).toString(16)}`,
      `[CLIENT] Order parameters fetched securely. Launching native payment gateway sheet...`
    ]);
  };

  // Simulate secure checkout payment authorization
  const handleSimulateGatewayProcess = () => {
    setPaymentStep('processing');
    
    const logs = [
      `[CLIENT] Initializing Secure Gateway Native Interface...`,
      `[GATEWAY] Spawning crypt-tunnel. KeyId: rzp_live_${Math.floor(Math.random() * 10000).toString(16)}`,
      `[GATEWAY] Transmitting credential packets (Contact: ${bookingPhone})...`,
      `[GATEWAY] Payment authorized. Generating signature metadata...`
    ];
    
    let currentIdx = 0;
    const interval = setInterval(() => {
      if (currentIdx < logs.length) {
        setPaymentLog(prev => [...prev, logs[currentIdx]]);
        currentIdx++;
      } else {
        clearInterval(interval);
        
        const randomHash = Math.floor(Math.random() * 100000000).toString(16);
        const validSig = `vdc_sig_${randomHash}`;
        
        setPaymentLog(prev => [
          ...prev,
          `[CLIENT] Callback EVENT_PAYMENT_SUCCESS triggered on SDK`,
          `[CLIENT] Forwarding response packets: { orderId: 'vdc_order_ref', paymentId: 'pay_${randomHash}', signature: '${validSig}' }`,
          `[SERVER] Verifying signature with local SHA256 cryptographic HMAC...`,
          `[SERVER] Calculated HMAC matches client signature! Validation verified.`,
          `[DB_SEC] Evaluating firestore.rules update permissions...`,
          `[DB_SEC] ACCEPTED: Server-authorized signature validates status transition: 'PENDING' -> 'CONFIRMED'`
        ]);
        
        setPaymentStep('success');
      }
    }, 600);
  };

  // Finalize booking block and commit verified status to dashboard list state
  const handleCompleteSecureBooking = () => {
    if (!selectedPujaForBooking) return;

    const newBooking: PujaBooking = {
      id: `book_live_${Math.floor(Math.random() * 100000).toString(16)}`,
      tenantId: 'tenant_vedic_reeti',
      pujaId: selectedPujaForBooking.id,
      pujaName: selectedPujaForBooking.name,
      pricePaid: selectedPujaForBooking.price,
      userId: 'usr_live_devotee',
      userName: bookingName,
      userPhone: bookingPhone,
      bookingDate: bookingDate,
      slotTime: bookingTime,
      status: 'CONFIRMED',
      createdTimestamp: new Date().toISOString()
    };

    onAddBooking(newBooking);
    setSelectedPujaForBooking(null);
    setBookingName('');
    setBookingPhone('');
    setPaymentStep('details');
    setPaymentLog([]);
    showToast(`Jay Shree Ganesha! Booking for ${selectedPujaForBooking.name} cryptographically verified and committed live.`);
  };

  // Dynamic Banners filter
  const activeAds = ads.filter(a => a.active);

  // Code snippets registry
  const codeFiles: Record<string, { label: string; lang: string; path: string; code: string; desc: string }> = {
    ad_banner_widget: {
      label: 'Dynamic Ad Banner Widget',
      path: 'lib/presentation/widgets/dynamic_ad_banner.dart',
      lang: 'dart',
      desc: 'Listens to AdBannerBloc. Automatically lists active banners in PageView and collapses gracefully via SizedBox.shrink() if empty.',
      code: `import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/ad_banner_model.dart';
import '../bloc/ad_banner/ad_banner_bloc.dart';

/// A production-grade Ad Banner widget that collapses gracefully when empty.
class DynamicAdBanner extends StatelessWidget {
  const DynamicAdBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBannerBloc, AdBannerState>(
      builder: (context, state) {
        if (state is AdBannerLoaded) {
          // Filter dynamically based on active coordinate configuration from BaaS API
          final liveAds = state.ads.where((ad) => ad.isActive).toList();
          
          if (liveAds.isEmpty) {
            // Absolute collapsing per senior flutter guidelines (no visual footprint)
            return const SizedBox.shrink();
          }

          return Container(
            height: 155,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: PageView.builder(
              itemCount: liveAds.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final ad = liveAds[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _handleBannerTap(context, ad.targetLink, ad.title),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD97706).withOpacity(0.35), // Saffron Border
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        image: DecorationImage(
                          image: NetworkImage(ad.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.45),
                            BlendMode.srcOver,
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Saffron Active Badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706), // Saffron Maroon Glow
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFBBF24), width: 0.5),
                              ),
                              child: Text(
                                ad.campaignName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                          // Content Title Card
                          Positioned(
                            bottom: 15,
                            left: 15,
                            right: 15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ad.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.25,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(1, 1),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.touch_app, size: 11, color: Color(0xFFFBBF24)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Tap to invoke ritual page",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.amber.shade200,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        
        // Return empty during load states to prevent empty box placeholder glitch
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _handleBannerTap(BuildContext context, String targetLink, String title) async {
    final Uri url = Uri.parse(targetLink);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF7F1D1D), // Deep Maroon alert
            content: Text("Routing dynamically to: $targetLink"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Could not dispatch link: $e");
    }
  }
}`
    },
    puja_booking_screen: {
      label: 'Puja Live Booking Screen',
      path: 'lib/presentation/screens/puja_booking_screen.dart',
      lang: 'dart',
      desc: 'Retrieves active Pujas catalog with live updated pricing from API, ensuring users always check out with updated corporate rates.',
      code: `import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/puja_model.dart';
import '../bloc/puja_catalog/puja_catalog_bloc.dart';

class PujaBookingScreen extends StatefulWidget {
  const PujaBookingScreen({Key? key}) : super(key: key);

  @override
  State<PujaBookingScreen> createState() => _PujaBookingScreenState();
}

class _PujaBookingScreenState extends State<PujaBookingScreen> {
  @override
  void initState() {
    super.initState();
    // Dispatch real-time price fetch to align catalog perfectly with web supervisor modifications
    _refreshCatalogPrices();
  }

  void _refreshCatalogPrices() {
    context.read<PujaCatalogBloc>().add(FetchLivePujaOfferings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900 Background
      appBar: AppBar(
        title: const Text(
          "Auspicious Pujas",
          style: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Color(0xFFF59E0B)),
            onPressed: _refreshCatalogPrices,
          )
        ],
      ),
      body: BlocConsumer<PujaCatalogBloc, PujaCatalogState>(
        listener: (context, state) {
          if (state is PujaCatalogError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Price sync failed: \${state.message}")),
            );
          }
        },
        builder: (context, state) {
          if (state is PujaCatalogLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD97706)),
            );
          }

          if (state is PujaCatalogLoaded) {
            final liveCatalog = state.pujas.where((p) => p.isActive).toList();
            
            if (liveCatalog.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: const Color(0xFFD97706),
              onRefresh: () async => _refreshCatalogPrices(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: liveCatalog.length,
                itemBuilder: (context, index) {
                  final puja = liveCatalog[index];
                  return _buildPujaOfferItem(context, puja);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPujaOfferItem(BuildContext context, PujaModel puja) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner Image with duration chip
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  puja.imageUrn,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "\${puja.durationMinutes} Mins",
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Expanded(
                      child: Text(
                        puja.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Senior best practice: always show visual sync identifier
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "LIVE PRICE",
                        style: TextStyle(fontSize: 8, color: Color(0xFFFBBF24), fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                
                const SizedBox(height: 6),
                Text(
                  puja.description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.4),
                ),
                
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: puja.benefits.map((benefit) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF991B1B).withOpacity(0.3)),
                    ),
                    child: Text(
                      "✦ $benefit",
                      style: const TextStyle(fontSize: 10, color: Color(0xFFFECDD3)),
                    ),
                  )).toList(),
                ),

                const Divider(height: 24, color: Color(0xFF334155)),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Auspicous Ritual Offering",
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                        Text(
                          "INR \${puja.price.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () => _triggerSimulatedPayment(context, puja),
                      child: const Text("Book Divine Ritual", style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No dynamic puja offerings configured. Praise be!", 
        style: TextStyle(color: Colors.white60),
      ),
    );
  }

  void _triggerSimulatedPayment(BuildContext context, PujaModel puja) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirm Devotional Booking: \${puja.name}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "API Sync coordinates current rate in BaaS backend as INR \${puja.price.toStringAsFixed(0)} plus complete Tiwari ritual guidance.",
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Auspicious booking committed live! Check Admin dashboard Bookings tab.")),
                    );
                  },
                  child: const Text("Authorize Transact Session"),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}`
    },
    about_us_screen: {
      label: 'About Us & Org Hierarchy',
      path: 'lib/presentation/screens/about_us_screen.dart',
      lang: 'dart',
      desc: 'Styled section listing Tiwari board Directors Ramesh, Diya, and Nikhil with app_icon.png and beautifully styled gold-accent Aryan Mishra signature.',
      code: `import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 950 Aesthetic dark
      appBar: AppBar(
        title: const Text("Board of Directors", style: TextStyle(fontFamily: 'PlayfairDisplay')),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Beautiful Header Card featuring the app icon
                      _buildBrandingHeaderWithIcon(screenWidth),
                      const SizedBox(height: 28),
                      
                      const Text(
                        "MANAGEMENT GOVERNING BOARD",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // RAMESH TIWARI CARD
                      _buildDirectorCard(
                        "Ramesh Kumar Tiwari",
                        "Chairman & Managing Director",
                        "Leading the theological legacy of the Vedic community, Ramesh oversees traditional authenticity, authentic Shastric guidance scripts, and global operations.",
                        "R",
                      ),
                      const SizedBox(height: 14),

                      // DIYA TIWARI CARD
                      _buildDirectorCard(
                        "Diya Tiwari",
                        "Creative Director & Heritage Custodian",
                        "Aligning ancient traditions with visual storytelling models. Diya manages visual art mandates, certified Vedic learning, and cultural integrity standards.",
                        "D",
                      ),
                      const SizedBox(height: 14),

                      // NIKHIL TIWARI CARD
                      _buildDirectorCard(
                        "Nikhil Tiwari",
                        "Technical Director & Platform Architect",
                        "Pioneering digital devotional infrastructure, Nikhil drives cloud scalability, NoSQL Firestore synchronization, and secure multi-tenant SDK schemas.",
                        "N",
                      ),
                      
                      const Spacer(),
                      const SizedBox(height: 48),
                      
                      // Visual Divider
                      Center(
                        child: Container(
                          width: screenWidth * 0.3,
                          height: 1,
                          color: const Color(0xFF334155).withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Elegant Gold-accented credit for Aryan Mishra architecting the application
                      _buildArchitectCredit(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandingHeaderWithIcon(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD97706).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding App Icon Asset
          Container(
            width: screenWidth > 600 ? 70 : 54,
            height: screenWidth > 600 ? 70 : 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withOpacity(0.2),
                  blurRadius: 8,
                )
              ]
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.circle_notifications_outlined, color: Color(0xFFFBBF24), size: 28);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "VedicReeti",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'PlayfairDisplay',
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Pioneering standard virtual Vedic ritual bridges through robust cloud coordination, direct BaaS synchronizations, and authentic Tiwari board oversight.",
                  style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1), height: 1.4),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectorCard(String name, String role, String description, String initial) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF7F1D1D),
            child: Text(
              initial,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  role,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFFBBF24), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.4, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectCredit() {
    return Column(
      children: [
        const Text(
          "VedicReeti Dynamic Platform Client v1.1.0",
          style: TextStyle(fontSize: 8, color: Color(0xFF475569), fontFamily: 'Courier', letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.auto_awesome, size: 10, color: Color(0xFFF59E0B)),
            SizedBox(width: 6),
            Text(
              "App Architected & Developed by Aryan Mishra",
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: Color(0xFFFBBF24), // Elegant gold accent
                shadows: [
                  Shadow(
                    color: Color(0x33F59E0B),
                    blurRadius: 4,
                  )
                ]
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.auto_awesome, size: 10, color: Color(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }
}`
    },
    splash_screen_widget: {
      label: 'Stunning Animating Splash Screen',
      path: 'lib/presentation/screens/splash_screen_view.dart',
      lang: 'dart',
      desc: 'Centering app_icon.png with interactive pulsating shadow glow, and logo_dark.png pinned beautifully near the bottom.',
      code: `import 'package:flutter/material.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _glowIntensityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup Animation timeline with premium curves (3-second duration cycle)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseScaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuad,
      ),
    );

    _glowIntensityAnimation = Tween<double>(begin: 10.0, end: 32.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuad,
      ),
    );

    // Bootstrap secure route transition to dashboard application
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enforce device dimensions safety
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 950 deep dark
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Saffron/Deep Crimson space dust background glow
            Positioned(
              top: screenHeight * 0.2,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              child: Container(
                height: screenWidth * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7F1D1D).withOpacity(0.12),
                ),
              ),
            ),

            // Main central brand block
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseScaleAnimation.value,
                        child: Container(
                          width: screenWidth * 0.35,
                          height: screenWidth * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withOpacity(0.25),
                                blurRadius: _glowIntensityAnimation.value,
                                spreadRadius: _glowIntensityAnimation.value * 0.15,
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.cover,
                              semanticLabel: 'Glowing Diya Divine Icon',
                              errorBuilder: (context, error, stackTrace) {
                                // Exquisite decorative fallback when PNG is not yet bundled
                                return Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Center(
                                    child: Icon(
                                      Icons.circle_notifications_outlined,
                                      color: Color(0xFFFBBF24),
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "VEDICREETI",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6.0,
                      color: Color(0xFFFBBF24), // Saffron Golden
                      fontFamily: 'PlayfairDisplay',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Authentic Devotion. Seamless Scale.",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Perfectly aligned Premium brand logotype pinned near bottom safe area boundary
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: screenWidth * 0.4,
                  child: Image.asset(
                    'assets/images/logo_dark.png',
                    fit: BoxFit.contain,
                    semanticLabel: 'VedicReeti Corporate Logotype',
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 1,
                            color: const Color(0xFF334155),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "V E D I C  R E E T I",
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF475569),
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
`
    },
    branded_app_bar: {
      label: 'Premium Branded App Bar Widget',
      path: 'lib/presentation/widgets/branded_app_bar.dart',
      lang: 'dart',
      desc: 'AppBar replacement centering logo_dark.png scaled beautifully to prevent overflow with layout fallback support.',
      code: `import 'package:flutter/material.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const BrandedAppBar({Key? key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Media query checks to scale perfectly on tablets vs tiny phone screens
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoHeight = screenWidth > 600 ? 32.0 : 24.0;

    return AppBar(
      title: Image.asset(
        'assets/images/logo_dark.png',
        height: logoHeight,
        fit: BoxFit.contain,
        semanticLabel: 'VedicReeti Premium Logo',
        errorBuilder: (context, error, stackTrace) {
          // Robust fallback UI so the application never displays broken state
          return Text(
            "VedicReeti",
            style: TextStyle(
              fontSize: screenWidth > 600 ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'PlayfairDisplay',
              letterSpacing: 1.2,
            ),
          );
        },
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF1E293B), // Slate 800 background
      elevation: 0,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFD97706).withOpacity(0.2), // Subtle saffron bottom threshold
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
`
    },
    ad_banner_model: {
      label: 'Ad Banner Model Schema',
      path: 'lib/domain/models/ad_banner_model.dart',
      lang: 'dart',
      desc: 'Parses database payloads and dynamic fields seamlessly into robust typesafe Dart model fields.',
      code: `import 'dart:convert';

class AdBannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String targetLink;
  final String campaignName;
  final bool isActive;
  final int impressions;
  final int clicks;

  AdBannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.targetLink,
    required this.campaignName,
    required this.isActive,
    required this.impressions,
    required this.clicks,
  });

  factory AdBannerModel.fromMap(Map<String, dynamic> map) {
    return AdBannerModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      targetLink: map['targetLink'] ?? '',
      campaignName: map['campaignName'] ?? '',
      isActive: map['active'] ?? false,
      impressions: map['impressions'] ?? 0,
      clicks: map['clicks'] ?? 0,
    );
  }

  factory AdBannerModel.fromJson(String source) => AdBannerModel.fromMap(json.decode(source));
}`
    },
    puja_model: {
      label: 'Puja Catalog Model Schema',
      path: 'lib/domain/models/puja_model.dart',
      lang: 'dart',
      desc: 'Typesafe mapping model for dynamic puja specifications supporting price integers and customized benefit lists.',
      code: `import 'dart:convert';

class PujaModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String imageUrn;
  final List<String> benefits;
  final bool samagriIncluded;
  final bool isActive;

  PujaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrn,
    required this.benefits,
    required this.samagriIncluded,
    required this.isActive,
  });

  factory PujaModel.fromMap(Map<String, dynamic> map) {
    return PujaModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 0,
      imageUrn: map['imageUrn'] ?? '',
      benefits: List<String>.from(map['benefits'] ?? []),
      samagriIncluded: map['samagriIncluded'] ?? false,
      isActive: map['active'] ?? false,
    );
  }

  factory PujaModel.fromJson(String source) => PujaModel.fromMap(json.decode(source));
}`
    },
    service_client: {
      label: 'VedicReeti API Service',
      path: 'lib/data/repositories/vedic_reeti_api_client.dart',
      lang: 'dart',
      desc: 'Connects directly to your dynamic REST API endpoint utilizing secure headers to guarantee unified tenant validation.',
      code: `import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/puja_model.dart';
import '../../domain/models/ad_banner_model.dart';

class VedicReetiApiClient {
  final String baseUrl;
  final String tenantId;
  final http.Client _client = http.Client();

  VedicReetiApiClient({
    required this.baseUrl,
    required this.tenantId,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Tenant-ID': tenantId,
  };

  /// Fetch Live Active Ad Banners
  Future<List<AdBannerModel>> fetchActiveAds() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/ads'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => AdBannerModel.fromMap(json)).toList();
    } else {
      throw Exception('Failed to fetch dynamic advertisements: \${response.statusCode}');
    }
  }

  /// Fetch Live Puja catalog matching current admin overrides
  Future<List<PujaModel>> fetchPujaCatalog() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/pujas'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => PujaModel.fromMap(json)).toList();
    } else {
      throw Exception('Failed to synchronize dynamic Puja rates: \${response.statusCode}');
    }
  }
}`
    },
    payment_backend: {
      label: 'Secure Order & Sign Verification',
      path: 'server/controllers/payment_verification.ts',
      lang: 'typescript',
      desc: 'Node.js Express logic utilizing standard Stripe SDK & Razorpay crypto HMAC calculation. Forces server-side DB validation to prevent client-side rate hacks.',
      code: `import express from "express";
import crypto from "crypto";
import Stripe from "stripe";

const app = express();
// Keep payment credentials hidden from client-side bundle per instructions
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "sk_test_mock", {
  apiVersion: "2023-10-16",
});

/**
 * 1. SECURELY INITIALIZE CLIENT CHECKOUT ORDER
 * Always fetch pricing values directly from Cloud Authority DB to mitigate client parameter spoofing
 */
app.post("/api/v1/payments/create-order", async (req, res) => {
  try {
    const { pujaId, totalAmountFromClient, devoteePhone } = req.body;
    
    // Fintech Principle: Never trust price digits declared by client devices!
    const pujaRef = await db.collection("pujas").doc(pujaId).get();
    if (!pujaRef.exists || !pujaRef.data()?.active) {
      return res.status(404).json({ error: "Auspicious Puja Offering is temporarily offline" });
    }

    const verifiedPrice = pujaRef.data().price; // Strictly enforce authoritative rate
    
    // Initialize transaction node in database as PENDING
    const bookingDoc = await db.collection("bookings").add({
      pujaId,
      pujaName: pujaRef.data().name,
      pricePaid: verifiedPrice,
      devoteePhone,
      status: "PENDING", // Status is locked at raw inception
      createdAt: new Date().toISOString(),
    });

    // Create Payment Intent with verified amount (multiplied for decimal support in cents/paise)
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(verifiedPrice * 100),
      currency: "inr",
      metadata: {
        bookingId: bookingDoc.id,
        devoteePhone: devoteePhone,
      },
    });

    res.status(200).json({
      success: true,
      bookingId: bookingDoc.id,
      clientSecret: paymentIntent.client_secret,
      gatewayOrderId: paymentIntent.id,
      verifiedPriceINR: verifiedPrice,
    });
  } catch (error: any) {
    res.status(500).json({ error: "Booking Initialization failed: " + error.message });
  }
});

/**
 * 2. CRYPTOGRAPHIC WEBHOOK / SIGNATURE VERIFICATION
 * Confirms receipt with absolute non-repudiation using webhook-secret or SHA256 HMAC
 */
app.post("/api/v1/payments/verify-signature", async (req, res) => {
  try {
    const { orderId, paymentId, responseSignature } = req.body;
    
    // Razorpay authentication employs cryptographic signatures: expected = HMAC(order_id + "|" + payment_id)
    const secret = process.env.RAZORPAY_KEY_SECRET || "rzp_secret_dev";
    
    const hmac = crypto.createHmac("sha256", secret);
    hmac.update(orderId + "|" + paymentId);
    const expectedSignature = hmac.digest("hex");

    if (expectedSignature === responseSignature) {
      // Transition NoSQL Document Status safe under Server validation
      const bookingRef = db.collection("bookings").doc(orderId);
      await db.runTransaction(async (transaction) => {
        const doc = await transaction.get(bookingRef);
        if (!doc.exists) throw new Error("Auspicious booking node is not found!");
        
        transaction.update(bookingRef, {
          status: "CONFIRMED", // Verified on server!
          paymentVerifiedAt: new Date().toISOString(),
          paymentId: paymentId,
        });
      });

      res.status(200).json({
        success: true,
        message: "Cryptographic signature validated successfully! Puja booking status marked as CONFIRMED.",
      });
    } else {
      res.status(400).json({
        error: "CRITICAL: Signature mismatch detected! Intended payload hashes do not correspond.",
      });
    }
  } catch (err: any) {
    res.status(500).json({ error: "Signature Validation Exception: " + err.message });
  }
});`
    },
    payment_flutter_sdk: {
      label: 'Flutter Gateway Integration Hook',
      path: 'lib/presentation/widgets/payment_checkout.dart',
      lang: 'dart',
      desc: 'Mobile integration code connecting to native Stripe/Razorpay SDK overlays. Listens to terminal successes before calling payment verifier.',
      code: `import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VedicReetiCheckoutWidget {
  late Razorpay _razorpay;
  final String serverUrl = "https://your-backend.run.app";

  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccessfulPayment);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentException);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> launchCustomCheckout({
    required BuildContext context,
    required String pujaId,
    required String devoteePhone,
  }) async {
    try {
      // 1. Initialise order parameters securely over REST endpoint
      final initResponse = await http.post(
        Uri.parse("$serverUrl/api/v1/payments/create-order"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pujaId": pujaId,
          "devoteePhone": devoteePhone,
        }),
      );

      if (initResponse.statusCode != 200) {
        throw Exception("Server-side checkout bootstrap failed.");
      }

      final payload = jsonDecode(initResponse.body);
      final String secureOrderId = payload['gatewayOrderId'];
      final double verifiedAmount = payload['verifiedPriceINR'];

      // 2. Initialize checkout parameters within Native Android/iOS viewport wrapper
      var options = {
        'key': 'rzp_live_xxxxxxxx', // Replaced dynamically on platform provisioning
        'amount': verifiedAmount * 100, // paise density conversion
        'name': 'VedicReeti Ritual Portal',
        'order_id': secureOrderId,
        'description': 'Online Puja Devotional Ceremony Booking',
        'theme.color': '#D97706', // Vedic Amber/Saffron Aesthetic
        'prefill': {
          'contact': devoteePhone,
          'email': 'devotee@vedicreeti.com',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      _showSnack(context, "Fintech Session Initialization Error: \$e", true);
    }
  }

  void _handleSuccessfulPayment(PaymentSuccessResponse response) async {
    // 3. SECURE CALLBACK HOCK: Immediately transmit signature packets to backend verifier
    final validationResponse = await http.post(
      Uri.parse("$serverUrl/api/v1/payments/verify-signature"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "orderId": response.orderId,
        "paymentId": response.paymentId,
        "responseSignature": response.signature,
      }),
    );

    if (validationResponse.statusCode == 200) {
      debugPrint("Devotional Ritual verified instantly via secure crypt hash check!");
    } else {
      debugPrint("Fraudulent Transaction Terminated: Crypt validation exception.");
    }
  }

  void _handlePaymentException(PaymentFailureResponse response) {
    debugPrint("Security error callback: Code \${response.code} • \$message");
  }

  void _showSnack(BuildContext context, String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? const Color(0xFF7F1D1D) : const Color(0xFF0F5132),
        content: Text(msg),
      ),
    );
  }
}`
    },
    payment_db_security: {
      label: 'Firestore DB Security Rules',
      path: 'firestore.rules',
      lang: 'javascript',
      desc: 'Lock database document states. Revoke user permissions to manually set bookings into CONFIRMED, giving update keys only to authenticated server processes.',
      code: `rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Strict transactional validations on 'bookings' matching corporate audit standards
    match /bookings/{bookingId} {
      
      // Let authenticated user submit request but always enforce status to PENDING
      allow create: if request.auth != null 
        && request.resource.data.status == 'PENDING'
        && request.resource.data.userId == request.auth.uid;

      // EXPLOIT MITIGATION: Clients cannot manually override status parameters directly in the client SDK!
      // Transitions to 'CONFIRMED' are evaluated strictly by administrative Cloud Functions / Signature Verifiers online.
      allow update: if request.auth != null
        && (
          // Allow update if status is completely untouched by user, preserving original PENDING state
          (request.resource.data.status == resource.data.status)
          ||
          // Alternatively, only user profiles annotated as Board Directors/Trust admins can override statuses (e.g. support resolutions)
          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'DIRECTOR'
        );
        
      // Ensure read scopes match owner-assigned variables
      allow read: if request.auth != null
        && (request.auth.uid == resource.data.userId 
            || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'DIRECTOR');
    }
  }
}`
    },
    vercel_config: {
      label: 'Production Vercel configuration',
      path: 'vercel.json',
      lang: 'json',
      desc: 'Optimized deployment instructions for React Admin Panel. Enforces strict HTTP Security Headers (HSTS, CSP, X-Frame) to protect the merchant dashboard.',
      code: `{
  "version": 2,
  "buildCommand": "npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [
    {
      "source": "/api/v1/:path*",
      "destination": "https://vedicreeti-secure-prod-api.run.app/api/v1/:path*"
    },
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self' 'unsafe-inline' https://checkout.razorpay.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; connect-src 'self' https://api.razorpay.com https://api.stripe.com https://*.googleapis.com;"
        },
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains; preload"
        }
      ]
    }
  ]
}`
    },
    proguard_rules: {
      label: 'ProGuard/Obfuscation Rules',
      path: 'android/app/proguard-rules.pro',
      lang: 'javascript',
      desc: 'ProGuard configurations to prevent reverse engineering of sensitive merchant and ritual algorithms. Obfuscates classes, logs, and payment payloads.',
      code: `# 1. Flutter Core Keep rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class rx.** { *; }

# 2. Cryptographic and Signature package keep directives
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# 3. Razorpay / Stripe Native SDK Keeps
-keep class com.razorpay.** {*;}
-dontwarn com.razorpay.**
-keep class com.stripe.android.** {*;}
-dontwarn com.stripe.android.**

# 4. Strict Code Obfuscation guidelines
-repackageclasses 'com.vedicreeti.secure.obfuscated'
-allowaccessmodification

# Remove aggressive System production log nodes to save cycles and prevent data leaks
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}`
    },
    android_release_gradle: {
      label: 'Signed Release build.gradle',
      path: 'android/app/build.gradle',
      lang: 'groovy',
      desc: 'Android release gradle config targeting strict obfuscation, release shrink settings, and secure keystore credentials fetching.',
      code: `android {
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.vedicreeti.app"
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    signingConfigs {
        release {
            storeFile file(System.getenv("VEDICREETI_KEYSTORE_PATH") ?: "../vedicreeti_keystore.jks")
            storePassword System.getenv("VEDICREETI_KEYSTORE_PASSWORD")
            keyAlias System.getenv("VEDICREETI_KEY_ALIAS")
            keyPassword System.getenv("VEDICREETI_KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            
            // Code shrinking, Obfuscation, and resource mapping configurations
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}`
    },
    firebase_analytics: {
      label: 'Firebase Analytics & Crashlytics Integration',
      path: 'lib/services/analytics_service.dart',
      lang: 'dart',
      desc: 'Configure Flutter post-launch metrics. Automatically captures user interaction cycles, custom transactional conversion elements, and logs standard exceptions to Crashlytics.',
      code: `import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class VedicReetiAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Static singleton structure for fast telemetry streaming
  static final VedicReetiAnalyticsService instance = VedicReetiAnalyticsService._internal();
  VedicReetiAnalyticsService._internal();

  /// Initialize Firebase analytics properties & automatic error listeners
  Future<void> initialize() async {
    // 1. Enable data collection in production
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    
    // 2. Initialise automatic Crashlytics error logs pipe
    if (!kDebugMode) {
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      
      // Auto-catch platform-level asynchronously thrown exceptions
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  /// Telemetry custom event: Triggered on user completing booking checkout
  Future<void> logPujaBooked({
    required String pujaId,
    required String pujaName,
    required double verifiedAmountINR,
    required String bookingId,
  }) async {
    await _analytics.logEvent(
      name: 'puja_booked',
      parameters: {
        'puja_id': pujaId,
        'puja_name': pujaName,
        'value': verifiedAmountINR,
        'currency': 'INR',
        'booking_id': bookingId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Telemetry custom event: Logs banner clicked inside Flutter homepage
  Future<void> logAdBannerClicked({
    required String adId,
    required String campaignName,
    required String targetLink,
  }) async {
    await _analytics.logEvent(
      name: 'ad_banner_clicked',
      parameters: {
        'ad_id': adId,
        'campaign_name': campaignName,
        'target_url': targetLink,
        'screen_name': 'home',
      },
    );
  }

  /// Sets specific user characteristics dynamically to enable segment targeting
  Future<void> setUserSegment(String devoteeRole) async {
    await _analytics.setUserProperty(name: 'user_role', value: devoteeRole);
  }
}`
    },
    web_analytics: {
      label: 'React Dashboard Web Analytics',
      path: 'src/utils/analytics.ts',
      lang: 'typescript',
      desc: 'Inject Vercel Web Analytics or standard Google Analytics 4 tracks in the React Admin panel. Tracks visitor density, live screen changes, and error exceptions.',
      code: `import { inject } from '@vercel/analytics';

/**
 * PRODUCTION DASHBOARD METRICS TRACKER
 * Installs telemetry observers to track and view admin workflow metrics
 */
export const initializeAdminAnalytics = () => {
  if (process.env.NODE_ENV === 'production') {
    // Initialize Vercel Analytics tracking module seamlessly
    inject();
    console.log('[METRICS] Vercel Analytics tracking injected seamlessly.');
  } else {
    console.log('[METRICS] Sandboxed environment. Analytics logs intercepted.');
  }
};

/**
 * LOG CUSTOM PORTAL ACTIONS (e.g., Campaign activation, Puja spec updating)
 */
export const logAdminAction = (actionName: string, meta?: Record<string, any>) => {
  if (process.env.NODE_ENV === 'production' && (window as any).gtag) {
    (window as any).gtag('event', actionName, {
      event_category: 'admin_dashboard',
      ...meta,
      timestamp: new Date().toISOString()
    });
  } else {
    console.log(\`[SIM METRIC] logEvent: \${actionName}\`, meta);
  }
};`
    },
    play_store_aso: {
      label: 'Google Play ASO Metadata Copy',
      path: 'store_assets/metadata_aso_deck.md',
      lang: 'markdown',
      desc: 'SEO optimized copy configurations featuring short titles, rich tags, and high-density long copy explaining rituals, online puja booking, and virtual mandir features to rank high against astrologers.',
      code: `# =========================================================================
# VEDICREETI - GOOGLE PLAY STORE APP STORE OPTIMIZATION (ASO) COPY DECK
# =========================================================================

## 1. App Title (Strictly Max 30 Characters)
VedicReeti: Online Puja Booking

## 2. Short Description (Strictly Max 80 Characters)
Book authentic Vedic Pujas at sacred Indian Mandirs with live online telecast.

## 3. Full Long Description (Strictly Max 4000 Characters • Rich Keyboard Density)
Experience divine connections with **VedicReeti**, India's trusted platform for **Online Puja Booking**, virtual rituals, and curated spiritual devotion. 

Step into your personal **Digital Mandir** and access authentic, Vedic-compliant pooja ceremonies performed by certified Pandits from sacred holy locations. Whether you wish to summon blessings for prosperity, health, or a special milestone, VedicReeti bridges the gap between ancient ritual traditions and modern mobile scale.

### 🌟 KEY FEATURES:
* **Authentic Online Puja Booking**: Choose from 50+ Vedic and Vedic-certified rituals including Rudrabhishek, Sundarkand, Navgraha Shanti, and Ganesha Havan.
* **Curated Holy Mandir Experience**: Participate in ceremonies directly mapped to ancient temples. Read historical context and direct astrological configurations mapping your family lineage (Gotra).
* **Live High-Definition Streaming**: Tune in to live audio/video broadcasts of your booked puja. Share live stream links with family members in real-time.
* **Mantra Recitation Audio Player**: Enhance your home devotion with pristine high-fidelity audio chants, stotras, and calming background chants.
* **Saffron/Dark Immersive Interface**: Beautifully themed visual layouts supporting effortless temple navigation and intuitive, safe checkout portals.

### 🕉️ COMPREHENSIVE DEVOTIONAL ECOSYSTEM:
Unlike generic astrology apps, VedicReeti prioritizes the physical-to-digital holy synthesis. Every booking contains an optional "Samagri Package" dispatched straight to your doorstep containing divine items from your ritual temple. Our Board of Directors manages temple relations locally to ensure 100% adherence to authentic shastras.

Join thousands of families in creating an auspicious digital path. Download VedicReeti today—your spiritual sanctuary and digital temple.

### 🏷️ METADATA SEARCH KEYWORDS (HIGH TRAFFIC DENSITY):
Vedic, Online Puja Booking, Digital Mandir, Temple Pooja, Indian Astrology, Hindu Rituals, AstroTalk Alternative, Vastu, Devotional Audio, Kundli Matching, Sacred Temples`
    }
  };

  return (
    <div className="space-y-6 animate-fadeIn">
      
      {/* Header Banner showcasing senior developer role */}
      <div className="bg-gradient-to-r from-amber-600 via-rose-700 to-rose-950 p-6 rounded-2xl border border-amber-500/10 text-white relative overflow-hidden">
        <div className="absolute right-0 top-0 translate-x-12 -translate-y-12 w-48 h-48 rounded-full bg-amber-400/10 blur-2xl"></div>
        <div className="flex items-center gap-2.5 text-amber-300 font-mono text-[11px] font-bold uppercase tracking-wider">
          <Smartphone className="w-4 h-4 text-amber-400" />
          <span>Flutter Mobile Integration Hub</span>
        </div>
        <h2 className="text-xl md:text-2xl font-bold font-serif mt-1">Production-Grade Client Architecture</h2>
        <p className="text-xs text-rose-100 max-w-2xl mt-1 leading-relaxed">
          Act as a **Senior Flutter Developer**. Below, review the cross-platform Dart system blueprint alongside an interactive, live-sync'd phone mockup showing immediate client responses to pricing and campaign toggles.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        
        {/* LEFT COLUMN: INTERACTIVE PHONE SIMULATOR */}
        <div className="lg:col-span-5 flex flex-col items-center">
          
          <div className="w-full max-w-[340px] bg-slate-900 rounded-[44px] p-3.5 border-4 border-slate-800 shadow-2xl relative">
            {/* Phone Speaker & Camera Bar Notch */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 h-6 w-32 bg-slate-800 rounded-b-2xl z-30 flex items-center justify-center">
              <span className="block w-1.5 h-1.5 rounded-full bg-slate-900 border border-slate-700"></span>
              <span className="block w-10 h-1 bg-slate-950 rounded-full ml-3"></span>
            </div>

            {/* Simulated Live Toast Alert Overlay inside phone screen boundary */}
            {simulationToast && (
              <div className="absolute top-10 left-6 right-6 z-40 bg-slate-950/95 border border-amber-500/20 text-slate-100 px-3 py-2 rounded-xl text-[10px] shadow-lg flex gap-2 items-start animate-slideDown leading-normal">
                <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <span>{simulationToast}</span>
              </div>
            )}

            {/* Main LCD Display viewport screen */}
            <div className="w-full aspect-[9/19] bg-slate-950 rounded-[32px] overflow-hidden flex flex-col justify-between border border-slate-900 mt-2">
              
              {/* Status Bar */}
              <div className="pt-2 px-5 pb-1 flex justify-between items-center text-[9px] font-mono text-slate-400 select-none bg-slate-950">
                <span>13:02 PM</span>
                <span className="text-[8px] tracking-widest text-amber-500 font-bold">5G • VedicReeti Sync</span>
                <div className="flex items-center gap-1">
                  <span>100%</span>
                  <div className="w-4 h-2 rounded-sm border border-slate-600 p-0.5 flex items-center">
                    <div className="h-full w-full bg-amber-400 rounded-2xs"></div>
                  </div>
                </div>
              </div>

              {/* Screen Body Content Router */}
              <div className="flex-1 overflow-y-auto bg-slate-950 flex flex-col relative">
                
                {/* 0. SIMULATOR_TAB: SPLASH VIEW */}
                {simulatorTab === 'splash' && (
                  <div className="flex-1 flex flex-col justify-between items-center p-6 bg-slate-950 relative overflow-hidden text-center select-none animate-fadeIn">
                    {/* Ambient saffron glow in background */}
                    <div className="absolute top-1/4 left-1/2 -translate-x-1/2 w-32 h-32 rounded-full bg-amber-600/10 blur-xl"></div>
                    
                    <div></div> {/* Spacer */}

                    {/* Glowing pulsating central diya/lotus icon asset */}
                    <div className="flex flex-col items-center justify-center space-y-4">
                      <div className="relative animate-[pulse_2s_infinite]">
                        {/* Outer Glow Ring */}
                        <div className="absolute inset-0 rounded-full bg-amber-500/20 blur-md scale-110"></div>
                        <AppIconVisual className="w-16 h-16 border-2 border-amber-500/30 shadow-[0_0_15px_rgba(245,158,11,0.25)]" />
                      </div>
                      
                      <div>
                        <h2 className="text-sm font-serif font-bold text-amber-400 tracking-[0.25em] uppercase">VedicReeti</h2>
                        <p className="text-[7.5px] text-slate-400 tracking-wider font-light mt-1 italic">Authentic Devotion. Seamless Scale.</p>
                      </div>
                    </div>

                    {/* Perfectly pinned brand logotype near bottom */}
                    <div className="w-full pb-4 flex flex-col items-center justify-center space-y-1">
                      <span className="text-[6.5px] text-slate-500 tracking-widest font-mono">POWERED BY TIWARI BOARD</span>
                      <LogoDarkVisual className="h-5" logoWidth="80px" />
                    </div>
                  </div>
                )}

                {/* 1. SIMULATOR_TAB: HOME VIEW */}
                {simulatorTab === 'home' && (
                  <div className="flex-1 flex flex-col">
                    
                    {/* Premium Branded App Header replacing standard text with logo_dark.png */}
                    <div className="px-4 py-2.5 border-b border-rose-950/20 bg-slate-950 flex justify-between items-center bg-gradient-to-r from-slate-950 to-rose-950/10 shadow-sm">
                      <div className="flex items-center gap-2">
                        <AppIconVisual className="w-6 h-6 border border-amber-500/15" />
                        <LogoDarkVisual className="h-4" logoWidth="52px" />
                      </div>
                      <span className="bg-amber-500/20 text-[6.5px] font-mono text-amber-400 font-bold tracking-wider px-2 py-0.5 rounded-full select-none animate-pulse">
                        LIVE SYNC
                      </span>
                    </div>

                    {/* DYNAMIC CAROUSEL AD BANNER WITH GRACEFUL COLLAPSE PROVISIONS */}
                    {activeAds.length > 0 ? (
                      <div className="p-3 bg-slate-950">
                        <div className="text-[8px] font-mono text-slate-500 uppercase tracking-widest px-1 mb-1 flex justify-between">
                          <span>Dynamic Server Ads</span>
                          <span className="text-amber-500 tracking-wider">ACTIVE *</span>
                        </div>
                        
                        {/* Interactive Banner Wrapper */}
                        <div className="h-28 rounded-xl overflow-hidden relative border border-amber-500/20 bg-slate-900 group">
                          {/* Loop the active campaign as target */}
                          <img 
                            src={activeAds[0].imageUrl} 
                            alt={activeAds[0].title}
                            className="w-full h-full object-cover filter brightness-[0.60] contrast-[1.05]"
                            referrerPolicy="no-referrer"
                          />
                          <div className="absolute inset-0 p-2.5 flex flex-col justify-between bg-gradient-to-t from-slate-950 via-slate-950/30 to-transparent">
                            
                            {/* App badge */}
                            <span className="bg-amber-500 text-slate-950 font-sans font-bold text-[7px] tracking-wide uppercase px-1.5 py-0.5 rounded w-fit">
                              {activeAds[0].campaignName}
                            </span>

                            {/* Banner Action Title wrapper */}
                            <div 
                              className="cursor-pointer"
                              onClick={() => {
                                showToast(`Redirecting simulated device to deep-link payload: ${activeAds[0].targetLink}`);
                              }}
                            >
                              <h4 className="text-[10px] font-bold text-white leading-tight font-serif hover:underline select-none">
                                {activeAds[0].title}
                              </h4>
                              <p className="text-[6px] text-amber-200 mt-1 flex items-center gap-0.5">
                                <Sparkles className="w-2 h-2 text-amber-400" />
                                <span>Touch banner targeting: {activeAds[0].targetLink}</span>
                              </p>
                            </div>

                          </div>
                        </div>
                      </div>
                    ) : (
                      <div className="mx-3 my-2 border border-dashed border-slate-800 rounded-xl p-3 text-center bg-slate-950/40">
                        {/* Gracefully collapsed section placeholder representing SizedBox.shrink() */}
                        <p className="text-[8px] font-mono text-slate-500 uppercase">SizedBox.shrink()</p>
                        <p className="text-[9px] text-slate-600 mt-0.5 font-sans leading-snug">Ad Banner gracefully collapsed since zero promotions are active in control dashboard.</p>
                      </div>
                    )}

                    {/* Quick auspicious indicators block */}
                    <div className="px-3 pb-2 pt-1 flex gap-2">
                      <div className="flex-1 bg-rose-950/20 border border-rose-900/10 p-2 rounded-lg text-center">
                        <p className="text-[7px] text-slate-400 uppercase font-mono tracking-widest">Tithi Today</p>
                        <p className="text-[9px] text-amber-300 font-bold font-serif whitespace-nowrap">Dashami (10th Day)</p>
                      </div>
                      <div className="flex-1 bg-slate-900 border border-slate-800 p-2 rounded-lg text-center">
                        <p className="text-[7px] text-slate-400 uppercase font-mono tracking-widest">Pujas Online</p>
                        <p className="text-[9px] text-emerald-400 font-bold font-mono whitespace-nowrap">{pujas.filter(p => p.active).length} Catalog Live</p>
                      </div>
                    </div>

                    {/* Small services catalog */}
                    <div className="p-3 bg-slate-950 flex-1 space-y-2">
                      <div className="flex justify-between items-center">
                        <span className="text-[9px] font-bold text-slate-400 font-mono uppercase tracking-widest">Auspicious Category</span>
                        <button onClick={() => setSimulatorTab('pujas')} className="text-[8px] text-amber-400 font-semibold hover:underline flex items-center gap-0.5">
                          View All <ChevronRight className="w-2 h-2" />
                        </button>
                      </div>

                      <div className="space-y-2 max-h-44 overflow-y-auto pr-0.5">
                        {pujas.filter(p => p.active).slice(0, 2).map((puja) => (
                          <div 
                            key={puja.id}
                            className="bg-slate-900/80 border border-slate-800 p-2 rounded-xl flex gap-2 items-center hover:bg-slate-900 cursor-pointer transition-colors"
                            onClick={() => {
                              setSelectedPujaForBooking(puja);
                            }}
                          >
                            <img 
                              src={puja.imageUrn} 
                              alt={puja.name} 
                              className="w-10 h-10 rounded-lg object-cover brightness-[0.85]"
                              referrerPolicy="no-referrer"
                            />
                            <div className="flex-1 min-w-0">
                              <h4 className="text-[9px] font-bold text-slate-200 truncate font-serif">{puja.name}</h4>
                              <p className="text-[7px] text-slate-400 mt-0.5 font-mono">Live Price: <strong className="text-amber-400">INR {puja.price.toLocaleString('en-IN')}</strong></p>
                            </div>
                            <ChevronRight className="w-3 h-3 text-slate-500 shrink-0" />
                          </div>
                        ))}
                      </div>
                    </div>

                  </div>
                )}

                {/* 2. SIMULATOR_TAB: PUJAS VIEW (Dynamic Price Verification) */}
                {simulatorTab === 'pujas' && (
                  <div className="flex-1 flex flex-col p-3 space-y-3">
                    <div className="border-b border-slate-900 pb-2">
                      <h3 className="text-xs font-serif font-bold text-white">Dynamic Catalog</h3>
                      <p className="text-[7px] text-slate-400 mt-0.5">Prices dynamically synced with Admin pricing overrides.</p>
                    </div>

                    {/* Scrollable list of Pujas */}
                    <div className="space-y-3 max-h-80 overflow-y-auto pr-0.5">
                      {pujas.filter(p => p.active).map((puja) => (
                        <div key={puja.id} className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden flex flex-col">
                          <img 
                            src={puja.imageUrn} 
                            alt={puja.name} 
                            className="h-20 w-full object-cover filter brightness-[0.80]"
                            referrerPolicy="no-referrer"
                          />
                          <div className="p-2.5 space-y-1.5">
                            <div className="flex justify-between items-start gap-1">
                              <h4 className="text-[9px] font-bold text-white leading-tight font-serif">{puja.name}</h4>
                              <span className="text-[6px] font-mono bg-amber-500/10 text-amber-400 px-1 py-0.5 rounded uppercase font-bold text-right shrink-0">
                                LIVE PRICE
                              </span>
                            </div>
                            <p className="text-[8px] text-slate-400 leading-normal line-clamp-2">{puja.description}</p>
                            
                            <div className="flex items-center justify-between pt-1.5 border-t border-slate-950">
                              <div>
                                <p className="text-[6px] text-slate-500 uppercase font-mono">Dynamic Price</p>
                                <p className="text-[10px] font-bold text-amber-400 font-mono">INR {puja.price.toLocaleString('en-IN')}</p>
                              </div>
                              <button 
                                onClick={() => setSelectedPujaForBooking(puja)}
                                className="bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold px-2 py-1 rounded text-[8px]"
                              >
                                Book Now
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>

                  </div>
                )}

                {/* 3. SIMULATOR_TAB: ABOUT CONTACTS VIEW (Board Directors & Dev credits) */}
                {simulatorTab === 'about' && (
                  <div className="flex-1 flex flex-col p-3 space-y-3 justify-between animate-fadeIn">
                    <div className="space-y-3">
                      
                      {/* Premium Header Card with Diya app_icon.png and title */}
                      <div className="bg-gradient-to-br from-rose-950/40 to-slate-900 border border-amber-500/10 p-3 rounded-2xl flex items-center gap-3">
                        <AppIconVisual className="w-10 h-10 border border-amber-400/25 shadow-md shadow-amber-500/5 animate-pulse" />
                        <div>
                          <h3 className="text-xs font-serif font-black text-rose-50 uppercase tracking-wide">VedicReeti About</h3>
                          <p className="text-[7px] text-amber-500 uppercase tracking-wider font-mono font-bold">Divine Corporate Portfolio</p>
                        </div>
                      </div>

                      <p className="text-[8px] text-slate-400 text-center leading-normal italic px-1">
                        "Pioneering clean virtual Vedic ritual channels through resilient cloud sync, direct BaaS gateways, and authentic Tiwari Board oversight."
                      </p>

                      <div className="space-y-1.5 pt-1">
                        <div className="text-[6.5px] font-bold text-slate-500 font-mono text-center uppercase tracking-widest mb-1.5">
                          Authentic Tiwari Governance Board
                        </div>

                        {/* Directors list Cards in layout */}
                        {[
                          { name: 'Ramesh Kumar Tiwari', role: 'Chairman & Director', desc: 'Theological Authenticity Custodian', init: 'R' },
                          { name: 'Diya Tiwari', role: 'Creative Director', desc: 'certified Shastric Art Custodian', init: 'D' },
                          { name: 'Nikhil Tiwari', role: 'Technical Director', desc: 'Secure NoSQL Cloud Architect', init: 'N' }
                        ].map((d) => (
                          <div key={d.name} className="bg-slate-900 border border-slate-800 p-2 rounded-xl flex items-center gap-2.5 hover:border-slate-700 transition-colors">
                            <div className="w-7 h-7 rounded-lg bg-gradient-to-br from-rose-900/60 to-orange-950 text-[10px] font-bold text-amber-400 border border-amber-500/15 flex items-center justify-center font-serif shadow-sm">
                              {d.init}
                            </div>
                            <div className="flex-1 leading-tight">
                              <h4 className="text-[9px] font-bold text-slate-200 font-sans">{d.name}</h4>
                              <p className="text-[6.5px] text-amber-500 font-mono font-bold mt-0.5">{d.role}</p>
                              <p className="text-[5.5px] text-slate-500 italic font-sans mt-0.5">{d.desc}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* Dynamic bottom developer watermark precisely aligned as requested */}
                    <div className="text-center pt-2.5 border-t border-slate-900 mt-2">
                      <p className="text-[5.5px] text-slate-600 font-mono tracking-widest">APP VERSION v1.1.0 (SECURE PROGUARD ACTIVE)</p>
                      <div className="flex items-center justify-center gap-1 text-[9px] font-bold font-serif tracking-wider text-amber-400 mt-0.5 group">
                        <Sparkles className="w-2.5 h-2.5 text-amber-500 animate-pulse" />
                        <span className="text-amber-400 shadow-amber-500/10 drop-shadow-md">
                          App Architected & Developed by Aryan Mishra
                        </span>
                        <Sparkles className="w-2.5 h-2.5 text-amber-500 animate-pulse" />
                      </div>
                    </div>

                  </div>
                )}

              </div>
              {/* Dynamic Popup dialog when booking within simulator: triggers actual backend list insertion */}
              {selectedPujaForBooking && (
                <div className="absolute inset-0 z-50 bg-slate-950/95 p-4 flex flex-col justify-center animate-fadeIn">
                  <div className="bg-slate-900 rounded-2xl p-4 border border-rose-900/30 space-y-3 shadow-xl max-h-[92%] overflow-y-auto">
                    
                    {/* MODAL HEADER */}
                    <div className="flex justify-between items-start border-b border-slate-800 pb-2">
                      <div>
                        <span className="text-[6px] font-mono text-amber-400 tracking-wider uppercase font-bold bg-amber-500/10 px-1.5 py-0.5 rounded flex items-center gap-1 w-fit">
                          <span className="w-1 h-1 rounded-full bg-emerald-500 animate-pulse"></span>
                          SSL SECURE TUNNEL
                        </span>
                        <h4 className="text-[10px] font-serif font-bold text-white mt-1">Book: {selectedPujaForBooking.name}</h4>
                      </div>
                      <button 
                        type="button"
                        onClick={() => {
                          setSelectedPujaForBooking(null);
                          setPaymentStep('details');
                          setPaymentLog([]);
                        }}
                        className="text-slate-500 hover:text-white text-[10px] font-bold p-1"
                      >
                        [✕]
                      </button>
                    </div>

                    {/* STEP 1: DEVOTEE DETAILS FORM */}
                    {paymentStep === 'details' && (
                      <div className="space-y-3">
                        <div className="bg-slate-950 p-2.5 rounded-lg text-[8px] font-mono text-slate-400 space-y-1">
                          <div className="flex justify-between">
                            <span>Authoritative Rate:</span>
                            <span className="text-amber-400 font-bold">INR {selectedPujaForBooking.price.toLocaleString('en-IN')}</span>
                          </div>
                          <p className="text-[6.5px] text-slate-500 leading-tight">Price is verified automatically from our cloud cluster database node to prevent client manipulation.</p>
                        </div>

                        <form onSubmit={handleSimulatedBookingSubmit} className="space-y-2.5">
                          <div className="space-y-1">
                            <label className="text-[7px] text-slate-500 font-mono uppercase tracking-wider">Devotee Full Name *</label>
                            <input 
                              type="text"
                              required
                              value={bookingName}
                              onChange={(e) => setBookingName(e.target.value)}
                              placeholder="Pandit Harish Sharma"
                              className="w-full bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-[9px] text-slate-100 outline-none focus:border-amber-500"
                            />
                          </div>

                          <div className="space-y-1">
                            <label className="text-[7px] text-slate-500 font-mono uppercase tracking-wider">Contact Phone *</label>
                            <input 
                              type="text"
                              required
                              value={bookingPhone}
                              onChange={(e) => setBookingPhone(e.target.value)}
                              placeholder="+91 98876 XXXXX"
                              className="w-full bg-slate-950 border border-slate-800 rounded-lg px-2 py-1.5 text-[9px] text-slate-100 outline-none focus:border-amber-500"
                            />
                          </div>

                          <button 
                            type="submit"
                            className="w-full bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-400 hover:to-orange-500 text-slate-950 font-bold py-2 rounded-lg text-[9px] transition-all flex items-center justify-center gap-1 shadow-lg shadow-amber-500/10"
                          >
                            <span>Initiate Secure Checkouts</span>
                            <ChevronRight className="w-3.5 h-3.5" />
                          </button>
                        </form>
                      </div>
                    )}

                    {/* STEP 2: SECURE FINTECH GATEWAY WIDGET SHEET */}
                    {paymentStep === 'checkout' && (
                      <div className="space-y-3 animate-fadeIn">
                        
                        {/* Selector between Razorpay & Stripe */}
                        <div className="grid grid-cols-2 gap-2 bg-slate-950 p-1 rounded-lg">
                          <button
                            type="button"
                            onClick={() => setSimulatedGateway('razorpay')}
                            className={`py-1 rounded text-[8px] font-mono font-bold transition-all ${
                              simulatedGateway === 'razorpay' 
                                ? 'bg-indigo-600 text-white shadow-md' 
                                : 'text-slate-500 hover:text-slate-300'
                            }`}
                          >
                            Razorpay API
                          </button>
                          <button
                            type="button"
                            onClick={() => setSimulatedGateway('stripe')}
                            className={`py-1 rounded text-[8px] font-mono font-bold transition-all ${
                              simulatedGateway === 'stripe' 
                                ? 'bg-slate-800 text-white shadow-md border border-slate-700' 
                                : 'text-slate-500 hover:text-slate-300'
                            }`}
                          >
                            Stripe SDK
                          </button>
                        </div>

                        {/* Visual SDK Mock frame */}
                        <div className={`p-3 rounded-xl border ${
                          simulatedGateway === 'razorpay' 
                            ? 'bg-gradient-to-br from-indigo-950/40 via-slate-900 to-indigo-950/20 border-indigo-500/30' 
                            : 'bg-gradient-to-br from-slate-900 via-zinc-900 to-slate-950 border-slate-700/60'
                        } space-y-2.5`}>
                          
                          <div className="flex justify-between items-center bg-slate-950/80 p-2 rounded-lg border border-slate-800">
                            <div>
                              <p className="text-[6px] text-slate-500 font-mono uppercase">VedicReeti Merchant Account</p>
                              <p className="text-[8.5px] font-bold text-white font-serif">{selectedPujaForBooking.name}</p>
                            </div>
                            <div className="text-right">
                              <p className="text-[6px] text-slate-500 font-mono uppercase">Amount</p>
                              <p className="text-[9.5px] font-bold text-amber-400 font-mono">INR {selectedPujaForBooking.price}</p>
                            </div>
                          </div>

                          {/* SSL Lock Symbol */}
                          <div className="flex items-center gap-1.5 text-[7px] text-emerald-400 font-mono bg-emerald-500/10 px-2 py-1 rounded w-fit mx-auto border border-emerald-500/15">
                            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping"></span>
                            <span>256-Bit SSL Secured Transaction Channel</span>
                          </div>

                          {/* Interactive Card inputs fields representation */}
                          <div className="space-y-1.5">
                            <div className="bg-slate-950 border border-slate-800 rounded-lg p-1.5 flex items-center justify-between text-[8px]">
                              <span className="text-slate-400 font-mono">4242 •••• •••• 1928</span>
                              <span className="font-bold text-slate-500">VISA</span>
                            </div>
                            <div className="grid grid-cols-2 gap-1.5">
                              <div className="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-[8px] text-slate-400 font-mono">
                                MM/YY: <span className="text-white">12/29</span>
                              </div>
                              <div className="bg-slate-950 border border-slate-800 rounded-lg p-1.5 text-[8px] text-slate-400 font-mono">
                                CVV: <span className="text-white">***</span>
                              </div>
                            </div>
                          </div>

                          <button
                            type="button"
                            onClick={handleSimulateGatewayProcess}
                            className={`w-full py-1.5 rounded-lg text-[9px] font-bold shadow transition-all ${
                              simulatedGateway === 'razorpay'
                                ? 'bg-indigo-500 hover:bg-indigo-400 text-white ring-1 ring-indigo-400/20'
                                : 'bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold'
                            }`}
                          >
                            🔐 Verify & Authorize INR {selectedPujaForBooking.price}
                          </button>
                        </div>
                      </div>
                    )}

                    {/* STEP 3: TRANSACTION IN FLIGHT & CRYPTOGRAPHIC VERIFICATION LOGS */}
                    {paymentStep === 'processing' && (
                      <div className="space-y-3 py-2 animate-fadeIn text-center">
                        <div className="relative w-10 h-10 mx-auto">
                          {/* Saffron spinner */}
                          <div className="absolute inset-0 rounded-full border-2 border-slate-800"></div>
                          <div className="absolute inset-0 rounded-full border-2 border-t-amber-500 animate-spin"></div>
                        </div>
                        
                        <div>
                          <p className="text-[10px] text-white font-bold">Verifying Payment Signatures...</p>
                          <p className="text-[7px] text-slate-400 mt-0.5">Calculating SHA256 hashes to prevent parameter spoofing.</p>
                        </div>

                        {/* Embedded Server Terminal output logs */}
                        <div className="bg-slate-950 rounded-lg p-2.5 text-left border border-slate-800 max-h-44 overflow-y-auto">
                          <p className="text-[6.5px] text-slate-500 font-mono border-b border-slate-900 pb-1 mb-1.5">CONSOLE AUDIT DEPLOYMENT LOGS</p>
                          <div className="space-y-1 font-mono text-[7px] leading-relaxed">
                            {paymentLog.map((log, index) => {
                              const isErr = log.includes('[ERROR]') || log.includes('mismatch');
                              const isServ = log.includes('[SERVER]') || log.includes('[DB_SEC]');
                              return (
                                <p key={index} className={
                                  isErr ? "text-rose-400" : isServ ? "text-amber-400" : "text-emerald-400"
                                }>
                                  {log}
                                </p>
                              );
                            })}
                          </div>
                        </div>
                      </div>
                    )}

                    {/* STEP 4: PAYMENT SUCCESSFUL & VERIFIED SEAL */}
                    {paymentStep === 'success' && (
                      <div className="space-y-3 py-1 text-center animate-fadeIn">
                        
                        {/* Golden Sacred Check Badge */}
                        <div className="w-11 h-11 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center mx-auto shadow-lg shadow-amber-500/20 ring-4 ring-amber-500/10">
                          <Check className="w-6 h-6 text-slate-950 stroke-[3]" />
                        </div>

                        <div>
                          <p className="text-[10px] text-white font-bold font-serif">Jay Shree Ganesha! Verified Successfully</p>
                          <p className="text-[7px] text-slate-400 mt-0.5">Cryptographic signature corresponds to server expectations.</p>
                        </div>

                        {/* Transaction Receipt Card */}
                        <div className="bg-slate-950 p-2.5 rounded-lg border border-slate-800 text-left space-y-1 font-mono text-[7px] text-slate-400">
                          <div className="flex justify-between border-b border-slate-900 pb-1.5 mb-1 text-[7.5px] font-bold text-white">
                            <span>VedicReeti Transaction Ledger</span>
                            <span className="text-emerald-400">100% CLEAR</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Devotee:</span>
                            <span className="text-slate-200">{bookingName}</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Verified Price:</span>
                            <span className="text-amber-400 font-bold">INR {selectedPujaForBooking.price}</span>
                          </div>
                          <div className="flex justify-between">
                            <span>Gateway Token:</span>
                            <span className="text-indigo-400 truncate max-w-[100px]">pay_{Math.random().toString(36).substring(3, 11)}</span>
                          </div>
                          <div className="flex flex-col pt-1.5 border-t border-slate-900 mt-1">
                            <span className="text-slate-500">Cryptographic Validation Hash:</span>
                            <span className="text-slate-300 break-all text-[6.5px] leading-normal bg-slate-900/60 p-1 rounded border border-slate-800/80 mt-0.5">
                              0x8f3c7e462d10ea349b1ff1ca87903fe5bf948c26bef18a387da192
                            </span>
                          </div>
                        </div>

                        <button
                          type="button"
                          onClick={handleCompleteSecureBooking}
                          className="w-full bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold py-2 rounded-lg text-[9px] transition-all font-sans uppercase tracking-wider"
                        >
                          Commit confirmed booking to BaaS
                        </button>
                      </div>
                    )}

                  </div>
                </div>
              )}

              {/* IOS / Android Bottom Navigation Bar */}
              <div className="border-t border-slate-900 bg-slate-950/90 py-1.5 flex justify-around items-center select-none">
                
                {/* Tab: Splash */}
                <button 
                  onClick={() => { setSimulatorTab('splash'); setSelectedPujaForBooking(null); }}
                  className={`flex flex-col items-center gap-0.5 transition-all outline-none ${
                    simulatorTab === 'splash' ? 'text-amber-400 font-bold' : 'text-slate-500 hover:text-slate-300'
                  }`}
                >
                  <Sparkles className="w-3.5 h-3.5 animate-pulse" />
                  <span className="text-[7.5px] font-mono">Vr:Splash</span>
                </button>

                {/* Tab: Home */}
                <button 
                  onClick={() => { setSimulatorTab('home'); setSelectedPujaForBooking(null); }}
                  className={`flex flex-col items-center gap-0.5 transition-all outline-none ${
                    simulatorTab === 'home' ? 'text-amber-400 font-bold' : 'text-slate-500 hover:text-slate-300'
                  }`}
                >
                  <Smartphone className="w-3.5 h-3.5" />
                  <span className="text-[7.5px] font-mono">Vr:Home</span>
                </button>

                {/* Tab: Pujas Dynamic Price checking */}
                <button 
                  onClick={() => { setSimulatorTab('pujas'); setSelectedPujaForBooking(null); }}
                  className={`flex flex-col items-center gap-0.5 transition-all outline-none ${
                    simulatorTab === 'pujas' ? 'text-amber-400 font-bold' : 'text-slate-500 hover:text-slate-300'
                  }`}
                >
                  <ShoppingBag className="w-3.5 h-3.5" />
                  <span className="text-[7.5px] font-mono">Pujas</span>
                </button>

                {/* Tab: About Contacts */}
                <button 
                  onClick={() => { setSimulatorTab('about'); setSelectedPujaForBooking(null); }}
                  className={`flex flex-col items-center gap-0.5 transition-all outline-none ${
                    simulatorTab === 'about' ? 'text-amber-400 font-bold' : 'text-slate-500 hover:text-slate-300'
                  }`}
                >
                  <Info className="w-3.5 h-3.5" />
                  <span className="text-[7.5px] font-mono">About</span>
                </button>

              </div>

            </div>

            {/* Simulated iPhone Home Indicator Bar bar */}
            <div className="w-24 h-1 bg-slate-800 rounded-full mx-auto mt-3.5"></div>
          </div>

          <div className="mt-4 text-center max-w-xs space-y-1">
            <span className="bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-[10px] font-mono px-2 py-0.5 rounded-full font-bold">
              Simulator Live Connected
            </span>
            <p className="text-[11px] text-slate-400 leading-normal mt-1">
              Test live! If you edit puja prices in **Manage Pujas** tab or toggle campaign buttons inside **Custom Ad Campaigns**, the changes will propagate immediately inside this simulator.
            </p>
          </div>

        </div>

        {/* RIGHT COLUMN: CODE ARCHITECTURE VIEWER */}
        <div className="lg:col-span-7 space-y-4">
          
          <div className="bg-slate-900 border border-slate-900 rounded-2xl overflow-hidden p-5 space-y-3">
            <div className="flex flex-col md:flex-row justify-between md:items-center gap-3 border-b border-slate-950 pb-3">
              <div>
                <h3 className="text-sm font-bold text-white flex items-center gap-1.5 font-sans">
                  <Code className="w-4 h-4 text-amber-500" />
                  <span>Senior Architecture Repository</span>
                </h3>
                <p className="text-[11px] text-slate-400">Clean Architecture pattern following Bloc State management.</p>
              </div>

              {/* Selector for specific Dart layer file */}
              <select
                value={activeCodeFile}
                onChange={(e) => setActiveCodeFile(e.target.value)}
                className="bg-slate-950 text-slate-350 text-xs rounded border border-slate-800 px-3 py-1.5 font-mono cursor-pointer outline-none focus:border-amber-500"
              >
                <optgroup label="PREPARATION VIEW (UI)">
                  <option value="splash_screen_widget">splash_screen_view.dart (Pulsating Splash)</option>
                  <option value="branded_app_bar">branded_app_bar.dart (Logo AppBar Header)</option>
                  <option value="ad_banner_widget">dynamic_ad_banner.dart (Collapse-on-empty)</option>
                  <option value="puja_booking_screen">puja_booking_screen.dart (Live price check)</option>
                  <option value="about_us_screen">about_us_screen.dart (Directors & Credits)</option>
                </optgroup>
                <optgroup label="DOMAIN SCHEMAS (MODELS)">
                  <option value="ad_banner_model">ad_banner_model.dart</option>
                  <option value="puja_model">puja_model.dart</option>
                </optgroup>
                <optgroup label="DATA ACQUISITION (API)">
                  <option value="service_client">vedic_reeti_api_client.dart</option>
                </optgroup>
                <optgroup label="SECURE GATEWAYS (FINTECH)">
                  <option value="payment_backend">payment_verification.ts (Express SHA256)</option>
                  <option value="payment_flutter_sdk">payment_checkout.dart (Razorpay Hook)</option>
                  <option value="payment_db_security">firestore.rules (BaaS Anti-Spoof)</option>
                </optgroup>
                <optgroup label="PRODUCTION DEPLOYMENT (CI/CD)">
                  <option value="vercel_config">vercel.json (Vercel Security Headers)</option>
                  <option value="proguard_rules">proguard-rules.pro (Obfuscate Secrets)</option>
                  <option value="android_release_gradle">build.gradle (Signed Release APK)</option>
                </optgroup>
                <optgroup label="GROWTH HACKING & ANALYTICS">
                  <option value="firebase_analytics">analytics_service.dart (Crashlytics + Events)</option>
                  <option value="web_analytics">analytics.ts (Vercel Admin Analytics)</option>
                  <option value="play_store_aso">metadata_aso_deck.md (Google Play ASO Deck)</option>
                </optgroup>
              </select>
            </div>

            {/* Code Detail panel */}
            <div className="space-y-4">
              <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-2 text-xs">
                <span className="font-mono text-slate-400 bg-slate-950 px-3 py-1 rounded border border-slate-800">
                  📂 {codeFiles[activeCodeFile].path}
                </span>

                <button 
                  onClick={() => handleCopyCode(codeFiles[activeCodeFile].code, activeCodeFile)}
                  className="bg-slate-950 hover:bg-slate-800 text-slate-300 hover:text-white px-3 py-1.5 rounded-lg border border-slate-800 font-mono text-xs flex items-center gap-1.5 transition-colors"
                >
                  {copiedCodeId === activeCodeFile ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5 text-amber-500" />}
                  {copiedCodeId === activeCodeFile ? 'Copied to Clipboard' : 'Copy Clean Dart Code'}
                </button>
              </div>

              <p className="text-xs text-slate-400 font-sans italic bg-slate-950/40 p-3 rounded-xl border-l-2 border-amber-500/50">
                💡 <strong className="text-slate-350 font-medium">Design Pattern Summary:</strong> {codeFiles[activeCodeFile].desc}
              </p>

              <div className="relative">
                <pre className="text-[11px] font-mono text-teal-400 p-4 bg-slate-950 rounded-xl overflow-x-auto select-all leading-normal max-h-96">
                  <code>{codeFiles[activeCodeFile].code}</code>
                </pre>
              </div>

            </div>

          </div>

          {/* Clean architectural explanation panel */}
          <div className="bg-slate-900/40 border border-slate-900 rounded-2xl p-4 space-y-2.5">
            <h4 className="text-xs font-bold text-amber-400 flex items-center gap-1.5 font-mono uppercase tracking-wider">
              <ShieldCheck className="w-4 h-4 text-emerald-400" />
              <span>Architectural Principles Enforced</span>
            </h4>
            
            <div className="space-y-2 text-xs text-slate-400 leading-relaxed font-sans">
              <p>
                1. **Absolute Graceful Collapsing**: When ad campaigns are deactivated by Ramesh/Diya/Nikhil Tiwari via the dashboard interface, the JSON API excludes them or changes active statuses. The `DynamicAdBanner` matches this and renders `SizedBox.shrink()` on the client to avoid adding spacing overhead.
              </p>
              <p>
                2. **Consonant Live Pricing streams**: To prevent inconsistent transactional pricing states, checkout parameters fetch details live via the `VedicReetiApiClient` right up to when checkout registers, persisting accurate values in transactional ledgers.
              </p>
            </div>
          </div>

        </div>

      </div>

    </div>
  );
}
