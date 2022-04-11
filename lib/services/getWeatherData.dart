import 'package:clima/services/weather.dart';
import 'package:date_format/date_format.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class GetWeatherOneCall {
  GetWeatherOneCall({
    required this.daily,
    required this.hourly,
    required this.timeZone,
  });

  List daily;
  List hourly;
  String timeZone;

  factory GetWeatherOneCall.fromJson(Map<String, dynamic> json) => GetWeatherOneCall(
        daily: json['daily'],
        hourly: json['hourly'],
        timeZone: json['timezone'],
      );

  Map<String, dynamic> toJson() => {
        'daily': daily,
        'hourly': hourly,
        'timezone': timeZone,
      };

  List getHourlyTemp() {
    List hourlyTemp = [];
    for (var i = 0; i <= 6; i++) {
      double hTemp = double.parse(hourly[i]['temp'].toString());
      hourlyTemp.add(hTemp.toInt());
    }
    return hourlyTemp;
  }

  List getHourlyCon() {
    List hourlyCon = [];
    for (var i = 0; i <= 6; i++) {
      int hCon = hourly[i]['weather'][0]['id'];
      hourlyCon.add(WeatherModel().getWeatherIcon(hCon));
    }
    return hourlyCon;
  }

  List getHour() {
    tz.initializeTimeZones();
    final getTimeZone = tz.getLocation(timeZone);
    List hourList = [];
    for (var i = 0; i <= 6; i++) {
      var time = DateTime.fromMillisecondsSinceEpoch(hourly[i]['dt'] * 1000);
      var hour = tz.TZDateTime.from(time, getTimeZone);
      hourList.add(formatDate(hour, [HH, ':00']));
    }
    return hourList;
  }

  List getDailyTemp() {
    List dayTemp = [];
    for (var i = 0; i <= 6; i++) {
      double minTemp = double.parse(daily[i]['temp']['min'].toString());
      double maxTemp = double.parse(daily[i]['temp']['max'].toString());
      dayTemp.add('min: ${minTemp.toInt()}° max: ${maxTemp.toInt()}°');
    }
    return dayTemp;
  }

  List getDailyCon() {
    List dailyCon = [];
    for (var i = 0; i <= 6; i++) {
      int dCon = daily[i]['weather'][0]['id'];
      dailyCon.add(WeatherModel().getWeatherIcon(dCon));
    }
    return dailyCon;
  }

  List getDay() {
    final getTimeZone = tz.getLocation(timeZone);
    List dayList = [];
    for (var i = 0; i <= 6; i++) {
      var time = DateTime.fromMillisecondsSinceEpoch(daily[i]['dt'] * 1000);
      var day = tz.TZDateTime.from(time, getTimeZone);
      dayList.add(formatDate(day, [MM, ' ', dd]));
    }
    return dayList;
  }
}

class GetWeather {
  GetWeather({
    required this.name,
    required this.temperature,
    required this.condition,
    required this.lat,
    required this.lon,
  });

  String name;
  double temperature;
  int condition;
  double lat;
  double lon;

  factory GetWeather.fromJson(Map<String, dynamic> json) => GetWeather(
        name: json['name'],
        temperature: json['main']['temp'],
        condition: json['weather'][0]['id'],
        lat: json['coord']['lat'],
        lon: json['coord']['lon'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'temp': temperature,
        'id': condition,
        'lat': lat,
        'lon': lon,
      };
}
