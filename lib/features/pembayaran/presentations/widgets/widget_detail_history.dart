import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/cores/utils/helper.dart';
import 'package:frontend/features/pembayaran/data/models/checkout_model.dart';

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

Widget buildItemCard(CartItem item) {
  final subtotal = (item.hargaJual) * (item.quantity);

  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Item Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.build,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatIDR(item.hargaJual.toDouble()),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      ' × ${item.quantity}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtotal
          Text(
            formatIDR(subtotal.toDouble()),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

void showTransactionDetail({
  required BuildContext context,
  required Transaction transaction,
}) {
  final va = transaction.paymentInstruction?.vaNumber;
  final bank = transaction.paymentInstruction?.bank;
  final isPending = transaction.statusPembayaran.toLowerCase() == 'pending';
  final showVaSection = isPending && va != null && bank != null;

  // Calculate total from items for verification
  double calculatedTotal = 0;
  if (transaction.cartItems != null) {
    calculatedTotal = transaction.cartItems!.fold<double>(
        0, (sum, item) => sum + ((item.hargaJual) * (item.quantity)));
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Transaction Info
                    buildDetailRow("Order ID", transaction.id),
                    buildDetailRow("Tanggal",
                        formatDateIndonesia(transaction.tanggalTransaksi)),
                    buildDetailRow("Status Pembayaran",
                        transaction.statusPembayaran.toUpperCase()),
                    buildDetailRow(
                      "Metode Pembayaran",
                      getPaymentMethodDisplay(transaction.metodePembayaran,
                          transaction.paymentInfo),
                    ),
                    if (transaction.alamat != null)
                      buildDetailRow("Alamat", transaction.alamat!),

                    // Items Section
                    if (transaction.cartItems != null &&
                        transaction.cartItems!.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Detail Items",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...transaction.cartItems!
                          .map((item) => buildItemCard(item)),

                      // Items Summary
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total ${transaction.cartItems!.length} item(s)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              formatIDR(calculatedTotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 24),
                    buildDetailRow("Total Pembayaran",
                        formatIDR(double.tryParse(transaction.total)),
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
                      buildDetailRow("Bank", bank!.toUpperCase()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: buildDetailRow("Nomor VA", va!)),
                          IconButton(
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: va));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Nomor VA disalin ke clipboard"),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Cara Pembayaran:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1. Transfer tepat sebesar ${formatIDR(double.tryParse(transaction.total))}\n'
                              '2. Ke nomor VA: $va\n'
                              '3. Pembayaran akan otomatis terkonfirmasi',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
