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

  factory GetWeatherOneCall.fromJson(Map<dynamic, dynamic> json) => GetWeatherOneCall(
        daily: json['daily'],
        hourly: json['hourly'],
        timeZone: json['timezone'],
      );

  Map<dynamic, dynamic> toJson() => {
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
    required this.dt,
  });

  String name;
  double temperature;
  int condition;
  double lat;
  double lon;
  int dt;

  factory GetWeather.fromJson(Map<dynamic, dynamic> json) => GetWeather(
      name: json['name'],
      temperature: json['main']['temp'],
      condition: json['weather'][0]['id'],
      lat: json['coord']['lat'],
      lon: json['coord']['lon'],
      dt: json['dt']);

  Map<dynamic, dynamic> toJson() => {
        'name': name,
        'temp': temperature,
        'id': condition,
        'lat': lat,
        'lon': lon,
        'dt': dt,
      };

  String getDifference() {
    var unix = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    var now = DateTime.now();
    var difference = now.difference(unix);
    if (difference.inMinutes <= 59) {
      if (difference.inMinutes == 1 || difference.inMinutes == 0) {
        return 'Last data update ${difference.inMinutes} minute ago';
      }
      return 'Last data update ${difference.inMinutes} minutes ago';
    } else if (difference.inHours <= 23) {
      if (difference.inHours == 1) {
        return 'Last data update ${difference.inHours} hour ago';
      }
      return 'Last data update ${difference.inHours} hours ago';
    } else {
      if (difference.inDays == 1) {
        return 'Last data update ${difference.inDays} day ago';
      }
      return 'Last data update ${difference.inDays} days ago';
    }
  }
}
