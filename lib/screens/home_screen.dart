import 'package:flutter/material.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  List<ForecastDayModel> _forecast = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _weatherService.getWeather(city),
        _weatherService.getForecast(city),
      ]);

      setState(() {
        _weather = results[0] as WeatherModel;
        _forecast = results[1] as List<ForecastDayModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _backgroundGradientForWeather(_weather);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu'),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Sehir adi (orn: Istanbul)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _fetchWeather,
                    ),
                  ),
                  onSubmitted: (_) => _fetchWeather(),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red))
                else if (_weather != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildWeatherCard(_weather!),
                          if (_forecast.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildForecastList(),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  const Text(
                    'Bir sehir arayin',
                    style: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '5 Günlük Tahmin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            ..._forecast.map(_buildForecastRow),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(ForecastDayModel day) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              day.dayLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          WeatherIcon(iconCode: day.icon, size: 48),
          Expanded(
            child: Text(
              day.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${day.minTemperature.round()}° / ${day.maxTemperature.round()}°',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(WeatherModel weather) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            WeatherIcon(iconCode: weather.icon),
            Text(
              '${weather.temperature.round()}°C',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Text(
              weather.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('💧 Nem: %${weather.humidity}'),
                Text('💨 Rüzgar: ${weather.windSpeed} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _backgroundGradientForWeather(WeatherModel? weather) {
    if (weather == null) {
      return const [Color(0xFF4A6FA5), Color(0xFF2D4A73)];
    }

    final condition = weather.condition.toLowerCase();

    if (condition.contains('clear')) {
      return const [Color(0xFFFFB347), Color(0xFFFF7E5F)];
    }
    if (condition.contains('cloud')) {
      return const [Color(0xFFB0BEC5), Color(0xFF78909C)];
    }
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return const [Color(0xFF607D8B), Color(0xFF455A64)];
    }
    if (condition.contains('thunderstorm')) {
      return const [Color(0xFF424874), Color(0xFF2C2F4A)];
    }
    if (condition.contains('snow')) {
      return const [Color(0xFFE3F2FD), Color(0xFFB3E5FC)];
    }
    if (condition.contains('mist') ||
        condition.contains('fog') ||
        condition.contains('haze')) {
      return const [Color(0xFFBDBDBD), Color(0xFF757575)];
    }

    return const [Color(0xFF64B5F6), Color(0xFF1976D2)];
  }
}