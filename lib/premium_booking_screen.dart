import 'package:flutter/material.dart';
class PremiumBookingScreen extends StatefulWidget {
  const PremiumBookingScreen({super.key});
  @override
  State<PremiumBookingScreen> createState() => _PremiumBookingScreenState();
}
class _PremiumBookingScreenState extends State<PremiumBookingScreen> {
  int _currentStep = 0;
  String? selectedService;
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Book Premium Service', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.deepOrange),
        ),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          elevation: 0,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing Booking...')));
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == 2 ? 'Confirm Booking' : 'Continue',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text('Back', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Details'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select your preferred Puja or Ritual.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Service Type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      items: ['Baglamukhi Pujan', 'Mangal Bhat', 'Dashavatar Puja'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => selectedService = val),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Date'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('When would you like the service performed?', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.deepOrange),
                            const SizedBox(width: 16),
                            Text(
                              selectedDate == null ? 'Select a Date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: const Text('Review'),
              isActive: _currentStep >= 2,
              content: _buildPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 24),
                    _summaryRow('Service', selectedService ?? 'None Selected'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                    _summaryRow('Date', selectedDate == null ? 'None Selected' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                    _summaryRow('Status', 'Pending Confirmation'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _summaryRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(val, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Extreme softness
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
