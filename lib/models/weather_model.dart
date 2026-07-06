class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final String icon;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '01d',
    );
  }
}