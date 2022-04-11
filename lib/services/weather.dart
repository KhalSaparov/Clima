import 'package:clima/services/location.dart';
import 'package:clima/services/networking.dart';
import 'package:clima/utilities/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const apiKey = '1ed0f9ffa7250abce22959398a0d9b1e';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';
const openWeatherMapURLOneCall = 'https://api.openweathermap.org/data/2.5/onecall';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    NetworkHelper networkHelper =
        NetworkHelper('$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric');

    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      Location location = Location();
      await location.getCurrentLocation();

      NetworkHelper networkHelper = NetworkHelper(
          '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric');

      var weatherData = await networkHelper.getData();
      Hive.box(API_BOX).put(WEATHER_DATA, weatherData);
      return weatherData;
    } else {
      return Hive.box(API_BOX).get(WEATHER_DATA, defaultValue: []);
    }
  }

  Future<dynamic> getWeatherOneCall(double latitude, double longitude) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      NetworkHelper networkHelper = NetworkHelper(
          '$openWeatherMapURLOneCall?lat=$latitude&lon=$longitude&exclude=current,minutely,alerts&appid=$apiKey&units=metric');
      var weatherData = await networkHelper.getData();
      Hive.box(API_BOX).put(WEATHER_ONE_CALL, weatherData);
      return weatherData;
    } else {
      return Hive.box(API_BOX).get(WEATHER_ONE_CALL, defaultValue: []);
    }
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getWeatherPicture(int condition) {
    if (condition < 300) {
      return 'images/storm.jpg';
    } else if (condition < 400) {
      return 'images/rainy.jpg';
    } else if (condition < 600) {
      return 'images/rainy.jpg';
    } else if (condition < 700) {
      return 'images/snow.jpg';
    } else if (condition < 800) {
      return 'images/fog.jpg';
    } else if (condition == 800) {
      return 'images/shine.jpg️';
    } else if (condition <= 804) {
      return 'images/cloud.jpg';
    } else {
      return 'images/location_background.jpg';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
