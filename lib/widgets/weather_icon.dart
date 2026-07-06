import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 100,
  });

  static String imageUrl(String iconCode) =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  static IconData materialIcon(String iconCode) {
    final isNight = iconCode.endsWith('n');
    final condition = iconCode.length >= 2 ? iconCode.substring(0, 2) : '01';

    return switch (condition) {
      '01' => isNight ? Icons.nightlight_round : Icons.wb_sunny,
      '02' => isNight ? Icons.nights_stay : Icons.wb_cloudy,
      '03' || '04' => Icons.cloud,
      '09' || '10' => Icons.grain,
      '11' => Icons.thunderstorm,
      '13' => Icons.ac_unit,
      '50' => Icons.foggy,
      _ => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl(iconCode),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        materialIcon(iconCode),
        size: size * 0.8,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
