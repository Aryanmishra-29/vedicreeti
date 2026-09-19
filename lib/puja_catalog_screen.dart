import 'package:flutter/material.dart';
class PujaCatalogScreen extends StatelessWidget {
  PujaCatalogScreen({super.key});
  final Map<String, List<String>> _catalog = {
    'Tridev': ['Brahma', 'Vishnu', 'Shiv'],
    'Tridevi': ['Saraswati', 'Lakshmi', 'Parvati'],
    'Shiv Parivar': ['Ganesh', 'Kartikeya', 'Nandi'],
    'Dashavatar': ['Matsya', 'Kurm', 'Varah', 'Narsingh', 'Vaman', 'Parshuram', 'Ram', 'Krishna', 'Buddha', 'Kalki'],
    'Shakti': ['Durga', 'Kali', 'Chamunda', 'Annapurna', 'Santoshi Mata', 'Gayatri'],
    'Navgrah': ['Surya', 'Chandra', 'Mangal', 'Budh', 'Guru', 'Shukra', 'Shani', 'Rahu', 'Ketu'],
    'Other Deities': ['Hanuman', 'Indra', 'Agni', 'Varun', 'Kuber', 'Yamraj', 'Kamdev'],
    'Special Pujas': ['Baglamukhi mata pujan', 'Dash mahavidhyae', 'Yantrodhar pujan', 'Mangal bhat', 'Dhan yog jagrit yagy', 'Rog niwaran'],
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Deity & Puja Catalog', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _catalog.keys.length,
        itemBuilder: (context, index) {
          final category = _catalog.keys.elementAt(index);
          final items = _catalog[category]!;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              iconColor: Colors.deepOrange,
              collapsedIconColor: Colors.grey,
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50, // Subtle contrast against the white card
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: items.map((item) => _buildChip(item)).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.deepOrange.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
