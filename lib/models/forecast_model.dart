class ForecastDayModel {
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final String condition;
  final String description;
  final String icon;

  ForecastDayModel({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.condition,
    required this.description,
    required this.icon,
  });

  static List<ForecastDayModel> fromForecastJson(Map<String, dynamic> json) {
    final items = (json['list'] as List).cast<Map<String, dynamic>>();
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      final dateKey = (item['dt_txt'] as String).split(' ').first;
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    final forecasts = <ForecastDayModel>[];

    for (final entry in grouped.entries) {
      final dayItems = entry.value;
      var minTemp = double.infinity;
      var maxTemp = double.negativeInfinity;

      for (final item in dayItems) {
        final temp = (item['main']['temp'] as num).toDouble();
        if (temp < minTemp) minTemp = temp;
        if (temp > maxTemp) maxTemp = temp;
      }

      var representative = dayItems.first;
      for (final item in dayItems) {
        final hour = int.parse(
          (item['dt_txt'] as String).split(' ')[1].substring(0, 2),
        );
        if (hour >= 12) {
          representative = item;
          break;
        }
      }

      forecasts.add(
        ForecastDayModel(
          date: DateTime.parse(entry.key),
          minTemperature: minTemp,
          maxTemperature: maxTemp,
          condition: representative['weather'][0]['main'] ?? '',
          description: representative['weather'][0]['description'] ?? '',
          icon: representative['weather'][0]['icon'] ?? '01d',
        ),
      );
    }

    forecasts.sort((a, b) => a.date.compareTo(b.date));
    return forecasts.take(5).toList();
  }

  String get dayLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final forecastDay = DateTime(date.year, date.month, date.day);
    final dayDiff = forecastDay.difference(today).inDays;

    if (dayDiff == 0) return 'Bugün';
    if (dayDiff == 1) return 'Yarın';

    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return weekdays[forecastDay.weekday - 1];
  }
}
