import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/pembayaran/data/models/checout_model.dart';

Widget buildDetailRow(String label, String value, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

void showTransactionDetail({
  required BuildContext context,
  required Transaction transaction,
}) {
  final va = transaction.midtransData?.vaNumber;
  final bank = transaction.midtransData?.bank;
  final isPending = transaction.statusPembayaran.toLowerCase() == 'pending';
  final showVaSection = isPending && va != null && bank != null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Text(
              "Detail Transaksi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Detail Rows
            buildDetailRow("Order ID", transaction.id),
            buildDetailRow(
                "Tanggal", formatDateIndonesia(transaction.tanggalTransaksi)),
            buildDetailRow("Status Pembayaran",
                transaction.statusPembayaran.toUpperCase()),
            buildDetailRow(
              "Metode Pembayaran",
              getPaymentMethodDisplay(
                  transaction.metodePembayaran, transaction.midtransData),
            ),
            if (transaction.alamat != null)
              buildDetailRow("Alamat", transaction.alamat!),
            buildDetailRow(
                "Total", formatIDR(double.tryParse(transaction.total)),
                isTotal: true),

            // VA Section
            if (showVaSection) ...[
              const Divider(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Instruksi Pembayaran",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              buildDetailRow("Bank", bank.toUpperCase()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: buildDetailRow("Nomor VA", va)),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: va));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Nomor VA disalin ke clipboard"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    tooltip: 'Salin Nomor VA',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan transfer sesuai total ke nomor VA di atas.',
                style: TextStyle(fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
