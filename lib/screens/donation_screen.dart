import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NEW IMPORT
import '../admin_screens/admin_donation_screen.dart';

// --- DATA MODELS ---
class CampaignTransaction {
  final String name;
  final double amount;
  final String date;
  final String status;

  CampaignTransaction({required this.name, required this.amount, required this.date, required this.status});
}

class Campaign {
  final String id; // CHANGED to String for Firebase IDs
  final String mosque;
  final String title;
  final String description;
  final double raised;
  final double goal;
  final int donors;
  final int daysLeft;
  final String image;
  final String category;
  final bool verified;
  final List<CampaignTransaction> transactions;

  Campaign({
    required this.id, required this.mosque, required this.title, required this.description,
    required this.raised, required this.goal, required this.donors, required this.daysLeft,
    required this.image, required this.category, required this.verified, required this.transactions,
  });
}

// --- MAIN SCREEN WIDGET ---
class DonationScreen extends StatefulWidget {
  final Map<String, String>? masjidData; 
  const DonationScreen({super.key, this.masjidData});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  Campaign? selectedCampaign;
  bool showAmounts = true;

  @override
  Widget build(BuildContext context) {
    if (selectedCampaign != null) {
      return CampaignDetail(
        campaign: selectedCampaign!,
        onBack: () => setState(() => selectedCampaign = null),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Donations", style: TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Live donation tracker", style: TextStyle(color: Color(0xFF909090), fontSize: 12)),
          ],
        ),
        actions: [
          // 1. Your existing eye icon
          IconButton(
            icon: Icon(showAmounts ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF242424)),
            onPressed: () => setState(() => showAmounts = !showAmounts),
          ),
          
          // 2. TEMPORARY ADMIN BUTTON (We will delete this later!)
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFC67C4E)),
            tooltip: "Admin Test: Add Campaign",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDonationScreen()),
              );
            },
          )
        ],
      ),
      // NEW: StreamBuilder listens to Firestore in real-time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC67C4E)));
          }
          
          // 2. Handle Errors
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Handle Empty Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No active campaigns right now."));
          }

          // 4. Process the Live Data
          double totalRaised = 0;
          int totalDonors = 0;
          List<Campaign> liveCampaigns = [];

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            
            // Safe parsing to handle missing fields gracefully
            double raised = (data['raised'] ?? 0).toDouble();
            int donors = (data['donors'] ?? 0).toInt();
            
            totalRaised += raised;
            totalDonors += donors;

            liveCampaigns.add(Campaign(
              id: doc.id,
              mosque: data['mosque'] ?? 'Unknown Mosque',
              title: data['title'] ?? 'Untitled Campaign',
              description: data['description'] ?? '',
              raised: raised,
              goal: (data['goal'] ?? 0).toDouble(),
              donors: donors,
              daysLeft: (data['daysLeft'] ?? 0).toInt(),
              image: data['image'] ?? 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=600&q=80',
              category: data['category'] ?? 'General',
              verified: data['verified'] ?? false,
              transactions: [], // We can pull live transactions later!
            ));
          }

          // 5. Build the UI with the live data
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFC67C4E), Color(0xFFE8A07A)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.attach_money, color: Colors.white, size: 24),
                          const SizedBox(height: 8),
                          const Text("Total Raised", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(showAmounts ? "RM ${totalRaised.toStringAsFixed(0)}" : "RM ●●●●", 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.people, color: Color(0xFFC67C4E), size: 24),
                          const SizedBox(height: 8),
                          const Text("Total Donors", style: TextStyle(color: Color(0xFF909090), fontSize: 12)),
                          Text(totalDonors.toString(), 
                            style: const TextStyle(color: Color(0xFF242424), fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Text("Active Campaigns", style: TextStyle(color: Color(0xFF242424), fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Dynamic Campaign List
              ...liveCampaigns.map((campaign) => GestureDetector(
                onTap: () => setState(() => selectedCampaign = campaign),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(campaign.image, height: 140, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(campaign.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(campaign.mosque, style: const TextStyle(color: Color(0xFF909090), fontSize: 12)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(showAmounts ? "RM ${campaign.raised.toStringAsFixed(0)}" : "RM ●●●●", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("of ${showAmounts ? "RM ${campaign.goal.toStringAsFixed(0)}" : "RM ●●●●"}", style: const TextStyle(color: Color(0xFF909090), fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (campaign.goal > 0) ? (campaign.raised / campaign.goal).clamp(0.0, 1.0) : 0,
                              backgroundColor: const Color(0xFFF6EBE4),
                              color: const Color(0xFFC67C4E),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, color: Color(0xFF909090), size: 16),
                                    const SizedBox(width: 4),
                                    Text("${campaign.donors} donors", style: const TextStyle(color: Color(0xFF909090), fontSize: 12)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF6EBE4), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: Color(0xFFC67C4E), size: 14),
                                      const SizedBox(width: 4),
                                      Text("${campaign.daysLeft}d left", style: const TextStyle(color: Color(0xFFC67C4E), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

// --- DETAIL SCREEN WIDGET ---
// (Your existing CampaignDetail class stays exactly the same!)
class CampaignDetail extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback onBack;

  const CampaignDetail({super.key, required this.campaign, required this.onBack});

  @override
  State<CampaignDetail> createState() => _CampaignDetailState();
}

class _CampaignDetailState extends State<CampaignDetail> {
  final TextEditingController _amountController = TextEditingController();
  bool donated = false;
  final List<int> presets = [10, 25, 50, 100];

  Future<void> submitDonation() async {
      if (_amountController.text.isEmpty) return;
      
      double donationAmount = double.tryParse(_amountController.text) ?? 0;
      if (donationAmount <= 0) return;

      try {
        // Tell Firebase to update this specific campaign's document
        await FirebaseFirestore.instance
            .collection('donations')
            .doc(widget.campaign.id)
            .update({
              // FieldValue.increment adds to the existing number in the database
              'raised': FieldValue.increment(donationAmount),
              'donors': FieldValue.increment(1), 
            });

        // Show the success UI
        setState(() {
          donated = true;
        });
      } catch (e) {
        // Always good to handle potential errors
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connection failed. Please try again.")),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    double progress = (widget.campaign.goal > 0) ? (widget.campaign.raised / widget.campaign.goal).clamp(0.0, 1.0) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      body: Column(
        children: [
          Stack(
            children: [
              Image.network(widget.campaign.image, height: 250, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 50, left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                ),
              ),
              Positioned(
                bottom: 20, left: 20, right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.campaign.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(widget.campaign.mosque, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              )
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("RM ${widget.campaign.raised.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text("raised of RM ${widget.campaign.goal.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFF909090), fontSize: 12)),
                            ],
                          ),
                          Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Color(0xFFC67C4E), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF6EBE4),
                        color: const Color(0xFFC67C4E),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(widget.campaign.description, style: const TextStyle(color: Color(0xFF909090), height: 1.5)),
                const SizedBox(height: 24),
                if (!donated) ...[
                  const Text("Quick Donate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: presets.map((amount) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: () => setState(() => _amountController.text = amount.toString()),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _amountController.text == amount.toString() ? const Color(0xFFC67C4E) : Colors.white,
                            side: BorderSide(color: _amountController.text == amount.toString() ? const Color(0xFFC67C4E) : Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: Text("RM$amount", style: TextStyle(color: _amountController.text == amount.toString() ? Colors.white : Colors.black)),
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(padding: EdgeInsets.all(15), child: Text("RM", style: TextStyle(color: Color(0xFF909090)))),
                      hintText: "Enter custom amount",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setState((){}),
                  )
                ]
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF6EBE4)))),
            child: donated 
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: const Color(0xFFE8F7EF), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF4EC67C)),
                      SizedBox(width: 8),
                      Text("JazakAllah! Donation Received", style: TextStyle(color: Color(0xFF4EC67C), fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: _amountController.text.isNotEmpty ? submitDonation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC67C4E),
                    disabledBackgroundColor: const Color(0xFFF6EBE4),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: Text(
                    _amountController.text.isNotEmpty ? "Donate RM ${_amountController.text}" : "Select an Amount to Donate",
                    style: TextStyle(color: _amountController.text.isNotEmpty ? Colors.white : const Color(0xFFC67C4E), fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
          )
        ],
      ),
    );
  }
}