// lib/games/2048/widgets/tile_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TileWidget extends StatelessWidget {
  final int number;

  const TileWidget({super.key, required this.number});

  // "Summer Sky" color palette 
  Color _getTileColor(int number) {
    switch (number) {
      case 2: return Colors.white;
      case 4: return const Color(0xFFE3F2FD); // Lightest Blue
      case 8: return const Color(0xFF90CAF9); // Light Blue
      case 16: return const Color(0xFF64B5F6); // Medium Blue
      case 32: return const Color(0xFF42A5F5); // Blue
      case 64: return const Color(0xFF2196F3); // Strong Blue
      case 128: return const Color(0xFFFFF176); // Lightest Yellow
      case 256: return const Color(0xFFFFEE58); // Light Yellow
      case 512: return const Color(0xFFFFD54F); // Yellow
      case 1024: return const Color(0xFFFFC107); // Amber/Gold
      case 2048: return const Color(0xFFFBC02D); // Deep Gold
      default: return Colors.grey.shade300; // Empty tile color
    }
  }

  Color _getTextColor(int number) {
    if (number >= 128) {
      return Colors.white; // White text for yellow tiles
    }
    return const Color(0xFF0D47A1); // Dark blue text for white/blue tiles
  }

  double _getFontSize(int number) {
    if (number < 100) return 40;
    if (number < 1000) return 34;
    return 28;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _getTileColor(number),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: number > 0
            ? Text(
                number.toString(),
                style: GoogleFonts.poppins( // A friendly, rounded font
                  color: _getTextColor(number),
                  fontSize: _getFontSize(number),
                  fontWeight: FontWeight.bold,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}