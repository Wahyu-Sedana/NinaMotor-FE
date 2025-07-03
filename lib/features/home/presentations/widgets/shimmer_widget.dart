import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerKategori() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

Widget shimmerProduk() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Container(height: 14, width: 100, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Container(height: 12, width: 60, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Container(height: 14, width: 80, color: Colors.grey.shade300),
        ],
      ),
    ),
  );
}
