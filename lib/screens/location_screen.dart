import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key, this.locationWeather}) : super(key: key);

  final dynamic locationWeather;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = WeatherModel();

  late int temp;
  late String weatherIcon;
  late String weatherPicture;
  late String weatherMessage;
  late String cityName;
  late GetWeather welcome;

  List tempData = [
    10,
    20,
    30,
    30,
    30,
    30,
    30,
  ];

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temp = 0;
        weatherIcon = 'Error';
        weatherPicture = 'images/location_background.jpg';
        weatherMessage = 'Unable to get weather data';
        cityName = '';
        return;
      }
      final getWeather = GetWeather.fromJson(weatherData);

      temp = getWeather.temperature.toInt();
      weatherMessage = weatherModel.getMessage(temp);

      weatherIcon = weatherModel.getWeatherIcon(getWeather.condition);
      weatherPicture = weatherModel.getWeatherPicture(getWeather.condition);

      cityName = getWeather.name;

      double lat = getWeather.lat;
      double lon = getWeather.lon;
      print(lat);
      print(lon);

      var w = weatherModel.getWeatherOneCall(lat, lon);
      final getWeatherOneCall = GetWeather.fromJson(weatherData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(weatherPicture),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.dstATop),
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          onPressed: () async {
                            var weatherData = await weatherModel.getLocationWeather();
                            updateUI(weatherData);
                          },
                          child: const Icon(
                            Icons.near_me,
                            size: 50.0,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            var typedName = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CityScreen(),
                              ),
                            );
                            if (typedName != null) {
                              var weatherData = await weatherModel.getCityWeather(typedName);
                              updateUI(weatherData);
                            }
                          },
                          child: const Icon(
                            Icons.location_city,
                            size: 50.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '$temp°',
                            style: kTempTextStyle,
                          ),
                          Text(
                            weatherIcon,
                            style: kConditionTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(
                        '$weatherMessage in $cityName',
                        textAlign: TextAlign.right,
                        style: kMessageTextStyle.copyWith(fontSize: 30.0),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: tempData.length,
                        itemBuilder: (BuildContext context, int position) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${tempData[position]}',
                                  style: kTempTextStyle.copyWith(fontSize: 30.0),
                                ),
                                Text(
                                  '${tempData[position]}',
                                  style: kTempTextStyle.copyWith(fontSize: 30.0),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: tempData.length,
                        itemBuilder: (BuildContext context, int position) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  '${tempData[position]}',
                                  style: kTempTextStyle.copyWith(fontSize: 30.0),
                                ),
                                Text(
                                  '${tempData[position]}',
                                  style: kTempTextStyle.copyWith(fontSize: 30.0),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getRow(int i, dynamic temp) {
    return Column(
      children: [
        Text(
          weatherIcon,
          style: kConditionTextStyle,
        ),
        Text(
          '${temp[i]}°',
          style: kTempTextStyle.copyWith(fontSize: 30.0),
        ),
      ],
    );
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
