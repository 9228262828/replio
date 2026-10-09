import 'package:flutter/material.dart';

import 'models.dart';

const replioGreen = Color(0xFF3B7A57);
const replioOrange = Color(0xFFE6A15C);
const replioCream = Color(0xFFF5F2E9);
const replioDark = Color(0xFF17231D);
const replioMint = Color(0xFF78C6A3);
const replioRed = Color(0xFFC95D63);
const replioGold = Color(0xFFE6B85C);

ThemeData replioTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: replioGreen,
      brightness: brightness,
      primary: replioGreen,
      secondary: replioOrange,
    ),
    scaffoldBackgroundColor: dark ? replioDark : replioCream,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF213028) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Color statusColor(StockStatus status) {
  switch (status) {
    case StockStatus.good:
      return replioGreen;
    case StockStatus.low:
      return replioGold;
    case StockStatus.refillNow:
      return replioOrange;
    case StockStatus.out:
      return replioRed;
  }
}

String statusLabel(StockStatus status) {
  switch (status) {
    case StockStatus.good:
      return 'GOOD';
    case StockStatus.low:
      return 'LOW';
    case StockStatus.refillNow:
      return 'REFILL NOW';
    case StockStatus.out:
      return 'OUT';
  }
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Kitchen':
      return Icons.kitchen_outlined;
    case 'Bathroom':
      return Icons.bathtub_outlined;
    case 'Cleaning':
      return Icons.cleaning_services_outlined;
    case 'Food':
      return Icons.restaurant_outlined;
    case 'Pets':
      return Icons.pets_outlined;
    case 'Office':
      return Icons.work_outline_rounded;
    default:
      return Icons.inventory_2_outlined;
  }
}

String numberText(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

String shortDate(DateTime value) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

class ReplioLogo extends StatelessWidget {
  final double size;

  const ReplioLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: replioGreen,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            color: Colors.white,
            size: size * .48,
          ),
          Positioned(
            right: size * .12,
            bottom: size * .10,
            child: Container(
              width: size * .28,
              height: size * .28,
              decoration: const BoxDecoration(
                color: replioOrange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: size * .18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final StockStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }
}
