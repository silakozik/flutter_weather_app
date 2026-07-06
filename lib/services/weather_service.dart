import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
    static const String apiKey = 'c5b3e01795cc7758b40a2ac7685f710a';

    Future<WeatherModel> getWeather(String cityName) async {
        final url = Uri.https(
            'api.openweathermap.org',
            '/data/2.5/weather',
            {
                'q': cityName,
                'appid': apiKey,
                'units': 'metric',
            },
        );

        final response = await http.get(url);
        
        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return WeatherModel.fromJson(data);
        } else if (response.statusCode == 404) {
            throw Exception('City not found');
        } else {
            throw Exception('Failed to load weather data');
        }
    }
}