import 'package:flutter/material.dart';

class RemittancePage extends StatefulWidget {
  const RemittancePage({super.key});

  @override
  State<RemittancePage> createState() => _RemittancePageState();
}

class _RemittancePageState extends State<RemittancePage> {
  // Dummy Data for the Prototype
  final List<Map<String, dynamic>> _remittances = [
    {
      "id": "REM-2025-001",
      "policyNo": "POL-882192",
      "amount": "₱ 4,500.00",
      "date": "Dec 18, 2025",
      "status": "Verified",
      "method": "Bank Transfer"
    },
    {
      "id": "REM-2025-002",
      "policyNo": "POL-112344",
      "amount": "₱ 2,100.00",
      "date": "Dec 17, 2025",
      "status": "Pending",
      "method": "Gcash"
    },
    {
      "id": "REM-2025-003",
      "policyNo": "POL-991231",
      "amount": "₱ 15,000.00",
      "date": "Dec 15, 2025",
      "status": "Verified",
      "method": "Check Deposit"
    },
    {
      "id": "REM-2025-004",
      "policyNo": "POL-772122",
      "amount": "₱ 3,250.00",
      "date": "Dec 10, 2025",
      "status": "Rejected", // Good for demonstrating error handling UI
      "method": "Bank Transfer"
    },
    {
      "id": "REM-2025-005",
      "policyNo": "POL-551233",
      "amount": "₱ 4,500.00",
      "date": "Dec 05, 2025",
      "status": "Verified",
      "method": "Auto-Debit"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Remittances', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.print_outlined)), // Print Report is a common agent task
        ],
      ),
      body: Column(
        children: [
          // 1. Monthly Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Total Remitted (December)',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '₱ 29,350.00',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                // Month Selector (Visual Only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text("December 2025", style: TextStyle(fontWeight: FontWeight.w600)),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 2. The List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _remittances.length,
              itemBuilder: (context, index) {
                final item = _remittances[index];
                return _buildRemittanceCard(item);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open "Add Remittance" Modal
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload Proof"),
      ),
    );
  }

  Widget _buildRemittanceCard(Map<String, dynamic> item) {
    Color statusColor;
    IconData statusIcon;

    // Logic to determine color based on status
    switch (item['status']) {
      case 'Verified':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row 1: ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['id'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item['date'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Policy No and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['policyNo'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.payment, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          item['method'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    )
                  ],
                ),
                Text(
                  item['amount'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Row 3: Status Indicator
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  item['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (item['status'] == 'Rejected')
                  Text(
                    'View Reason >',
                    style: TextStyle(color: Colors.red[300], fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}