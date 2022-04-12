import 'dart:async';
import 'dart:developer';

import 'package:clima/services/get_weather_data.dart';
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

  late GetWeather getWeather;
  late GetWeatherOneCall getWeatherOneCall;
  late String language = rusLanguage;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivityState();
    updateUI(widget.locationWeather);
    updateUIOneCall(widget.oneCallWeather);
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
                image: AssetImage(weatherModel.getWeatherPicture(
                    getWeather.condition, getWeatherOneCall.getDayNight()[0])),
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
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
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
                                  log('$e');
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
                        ),
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            child: _connectivityResult == ConnectivityResult.mobile ||
                                    _connectivityResult == ConnectivityResult.wifi
                                ? null
                                : Text(getWeather.getDifference()),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                language == rusLanguage
                                    ? language = enLanguage
                                    : language = rusLanguage;
                              });
                            },
                            child: Text(
                              language,
                              style: kLanguageTextStyle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
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
                                  log('$e');
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
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            getWeather.getCurrentTemp(language),
                            style: kTempTextStyle,
                          ),
                          Text(
                            weatherModel.getWeatherIcon(
                                getWeather.condition, getWeatherOneCall.getDayNight()[0]),
                            style: kConditionTextStyle,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        getWeather.getCityName(language),
                        style: kMessageTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        weatherModel.getMessage(getWeather.getTemp(language), language),
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
                          itemCount: getWeatherOneCall.getHour().length,
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
                                            weatherModel.getWeatherIcon(
                                                getWeatherOneCall.getHourlyCon()[position],
                                                getWeatherOneCall.getDayNight()[position]),
                                            style: kIconTextStyle,
                                          ),
                                          Text(
                                            '${getWeatherOneCall.getHourlyTemp(language)[position]}°',
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
                              itemCount: getWeatherOneCall.getDay().length,
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
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${getWeatherOneCall.getDailyTemp(language)[position]}',
                                              style: kColumnTextStyle,
                                              textAlign: TextAlign.end,
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
      getWeather = GetWeather.fromJson(weatherData);
    });
  }

  void updateUIOneCall(dynamic weatherData) async {
    setState(() {
      getWeatherOneCall = GetWeatherOneCall.fromJson(weatherData);
    });
  }
}
