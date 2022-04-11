import 'dart:async';

import 'package:clima/services/getWeatherData.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key, this.locationWeather, this.oneCallWeather}) : super(key: key);

  final dynamic locationWeather;
  final dynamic oneCallWeather;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = WeatherModel();
  ConnectivityResult? _connectivityResult;
  late StreamSubscription _connectivitySubscription;

  late int temp;
  late String weatherIcon;
  late String weatherPicture;
  late String weatherMessage;
  late String cityName;
  late GetWeather getWeather;
  late GetWeatherOneCall getWeatherOneCall;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivityState();
    updateUI(widget.locationWeather);
    updateUIOneCall(widget.oneCallWeather);
  }

  Future<void> _checkConnectivityState() async {
    StreamSubscription _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = result;
    });
  }

  void updateUI(dynamic weatherData) async {
    setState(() {
      if (weatherData == null) {
        temp = 0;
        weatherIcon = 'Error';
        weatherPicture = 'images/location_background.jpg';
        weatherMessage = 'Unable to get weather data';
        cityName = '';
        return;
      }
      getWeather = GetWeather.fromJson(weatherData);
      temp = getWeather.temperature.toInt();
      weatherMessage = weatherModel.getMessage(temp);
      weatherIcon = weatherModel.getWeatherIcon(getWeather.condition);
      weatherPicture = weatherModel.getWeatherPicture(getWeather.condition);
      cityName = getWeather.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        TextButton(
                          onPressed: () async {
                            if (_connectivityResult == ConnectivityResult.mobile ||
                                _connectivityResult == ConnectivityResult.wifi) {
                              setState(() {
                                showSpinner = true;
                              });
                              try {
                                var weatherData = await weatherModel.getLocationWeather();
                                var weatherDataOneCall = await weatherModel.getWeatherOneCall(
                                    weatherData['coord']['lat'], weatherData['coord']['lon']);
                                updateUI(weatherData);
                                updateUIOneCall(weatherDataOneCall);
                                setState(() {
                                  showSpinner = false;
                                });
                              } catch (e) {
                                print(e);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          child: const Icon(
                            Icons.near_me,
                            size: 50.0,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_connectivityResult == ConnectivityResult.mobile ||
                                _connectivityResult == ConnectivityResult.wifi) {
                              var typedName = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CityScreen(),
                                ),
                              );
                              try {
                                if (typedName != null) {
                                  setState(() {
                                    showSpinner = true;
                                  });
                                  var weatherData = await weatherModel.getCityWeather(typedName);
                                  var weatherDataOneCall = await weatherModel.getWeatherOneCall(
                                      weatherData['coord']['lat'], weatherData['coord']['lon']);
                                  updateUI(weatherData);
                                  updateUIOneCall(weatherDataOneCall);
                                } else {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              } catch (e) {
                                print(e);
                              }
                              setState(() {
                                showSpinner = false;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        '$weatherMessage in $cityName',
                        style: kMessageTextStyle,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Divider(
                        height: 5,
                        thickness: 2,
                        indent: 5,
                        endIndent: 5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 135,
                      width: double.infinity,
                      child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: getWeatherOneCall.getHourlyTemp().length,
                          itemBuilder: (BuildContext context, int position) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${getWeatherOneCall.getHour()[position]}',
                                            style: kRowTextStyle,
                                          ),
                                          Text(
                                            '${getWeatherOneCall.getHourlyCon()[position]}',
                                            style: kIconTextStyle,
                                          ),
                                          Text(
                                            '${getWeatherOneCall.getHourlyTemp()[position]}°',
                                            style: kRowTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: getWeatherOneCall.getHourlyTemp().length,
                              itemBuilder: (BuildContext context, int position) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${getWeatherOneCall.getDay()[position]}',
                                              style: kColumnTextStyle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${getWeatherOneCall.getDailyCon()[position]}',
                                              style: kIconTextStyle,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${getWeatherOneCall.getDailyTemp()[position]}',
                                              style: kColumnTextStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      height: 0,
                                      thickness: 1,
                                      indent: 8,
                                      endIndent: 8,
                                      color: Colors.white,
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ),
                  ],
                ),
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

  void updateUIOneCall(dynamic weatherData) async {
    setState(() {
      if (weatherData == null) {
        temp = 0;
        weatherIcon = 'Error';
        weatherPicture = 'images/location_background.jpg';
        weatherMessage = 'Unable to get weather data';
        cityName = '';
        return;
      }
      getWeatherOneCall = GetWeatherOneCall.fromJson(weatherData);
    });
  }
}
