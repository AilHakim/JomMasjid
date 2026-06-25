import 'package:flutter/material.dart';

// --- DATA MODELS ---
class CampaignTransaction {
  final String name;
  final double amount;
  final String date;
  final String status;

  CampaignTransaction({required this.name, required this.amount, required this.date, required this.status});
}

class Campaign {
  final int id;
  final String mosque;
  final String title;
  final String description;
  final double raised;
  final double goal;
  final int donors;
  final int daysLeft;
  final String image;
  final String category;
  
  final List<CampaignTransaction> transactions;

  Campaign({
    required this.id, required this.mosque, required this.title, required this.description,
    required this.raised, required this.goal, required this.donors, required this.daysLeft,
    required this.image, required this.category, required this.transactions,
  });
}

// --- HARDCODED DATA ---
final List<Campaign> campaigns = [
  Campaign(
    id: 1,
    mosque: "Masjid Al-Hidayah",
    title: "Roof Restoration Project",
    description: "Complete replacement of damaged roof panels and waterproofing across the main prayer hall.",
    raised: 45000,
    goal: 60000,
    donors: 312,
    daysLeft: 15,
    image: "https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=600&q=80",
    category: "Infrastructure",
    transactions: [
      CampaignTransaction(name: "Structural Assessment", amount: 5000, date: "Jun 1", status: "completed"),
      CampaignTransaction(name: "Material Purchase", amount: 18000, date: "Jun 5", status: "completed"),
      CampaignTransaction(name: "Labour Contract", amount: 12000, date: "Jun 10", status: "in-progress"),
    ],
  ),
  Campaign(
    id: 2,
    mosque: "Masjid Umar Al-Khattab",
    title: "New Air Conditioning System",
    description: "Installation of energy-efficient cooling system for better comfort during prayers.",
    raised: 12000,
    goal: 25000,
    donors: 98,
    daysLeft: 30,
    image: "https://images.unsplash.com/photo-1542931287-023b922fa89b?w=600&q=80",
    category: "Facilities",
    transactions: [
      CampaignTransaction(name: "System Quote & Planning", amount: 1500, date: "Jun 2", status: "completed"),
      CampaignTransaction(name: "Equipment Order", amount: 15000, date: "Jun 15", status: "pending"),
    ],
  ),
];

// --- MAIN SCREEN WIDGET ---
class DonationScreen extends StatefulWidget {
  // Keeping your original parameter just in case your router needs it
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

    double totalRaised = campaigns.fold(0, (sum, item) => sum + item.raised);
    int totalDonors = campaigns.fold(0, (sum, item) => sum + item.donors);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Donations", style: TextStyle(color: Color(0xFF242424), fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Live donation tracker", style: TextStyle(color: Color(0xFF909090), fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(showAmounts ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF242424)),
            onPressed: () => setState(() => showAmounts = !showAmounts),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          //total raised and donors
          Row( 
            children: [
              //total raised
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
              //total donors
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

          // mosques that can be donated
          ...campaigns.map((campaign) => GestureDetector(
            onTap: () => setState(() => selectedCampaign = campaign),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Header
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(campaign.image, height: 140, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  // Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //Title and Mosque name
                      children: [
                        Text(
                          campaign.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          campaign.mosque, style: const TextStyle(color: Color(0xFF909090), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        
                        // current raised and goal 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(showAmounts ? "RM ${campaign.raised.toStringAsFixed(0)}" : "RM ●●●●", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("of ${showAmounts ? "RM ${campaign.goal.toStringAsFixed(0)}" : "RM ●●●●"}", style: const TextStyle(color: Color(0xFF909090), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        //progress line
                        LinearProgressIndicator(
                          value: campaign.raised / campaign.goal,
                          backgroundColor: const Color(0xFFF6EBE4),
                          color: const Color(0xFFC67C4E),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12), 

                        // Donors and Days Left
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Total Donors 
                            Row(
                              children: [
                                const Icon(Icons.people_outline, color: Color(0xFF909090), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  "${campaign.donors} donors", style: const TextStyle(color: Color(0xFF909090), fontSize: 12)
                                ),
                              ],
                            ),
                            
                            // Days Left
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6EBE4), 
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, color: Color(0xFFC67C4E), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${campaign.daysLeft}d left", style: const TextStyle(color: Color(0xFFC67C4E), fontSize: 12, fontWeight: FontWeight.bold
                                    )
                                  ),
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
          ))
        ],
      ),
    );
  }
}

// --- DETAIL SCREEN WIDGET ---
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

  @override
  Widget build(BuildContext context) {
    double progress = widget.campaign.raised / widget.campaign.goal;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F2ED),
      body: Column(
        children: [
          // Top Image & Back Button
          Stack(
            children: [
              Image.network(widget.campaign.image, height: 250, width: double.infinity, fit: BoxFit.cover),
              //back arrow
              Positioned(
                top: 50, left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: widget.onBack,
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                ),
              ),
              //title on image
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

          // Scrollable Content (except image)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Progress Box
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
                
                // Donation Inputs
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
                    onChanged: (val) => setState((){}), // rebuild to update button state
                  )
                ]
              ],
            ),
          ),

          // Bottom Action Button
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
                  onPressed: _amountController.text.isNotEmpty ? () => setState(() => donated = true) : null,
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