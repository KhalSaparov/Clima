import 'package:flutter/material.dart';

const String API_BOX = 'api_data';
const String WEATHER_DATA = 'weatherData';
const String WEATHER_ONE_CALL = 'weatherOneCall';
const String CITY_RU = 'cityRU';
const String enLanguage = '🇬🇧';
const String rusLanguage = '🇷🇺';

const snackBarRu = SnackBar(
  content: Text('Пожалуйста включите интернет'),
);

const snackBarEn = SnackBar(
  content: Text('Please turn on mobile internet or Wi-Fi'),
);

const snackBarRuError = SnackBar(
  content: Text('Неверный ввод города'),
);

const snackBarEnError = SnackBar(
  content: Text('Invalid input city name'),
);

const kTempTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 90.0,
);

const kMessageTextStyle = TextStyle(
  fontFamily: 'Lobster',
  fontSize: 30.0,
);

const kLanguageTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 35.0,
);

const kIconTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 30.0,
);

const kRowTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 20.0,
);

const kColumnTextStyle = TextStyle(
  fontFamily: 'Comfortaa',
  fontWeight: FontWeight.w900,
  fontSize: 18.0,
);

const kButtonTextStyle = TextStyle(
  fontSize: 30.0,
  fontFamily: 'Spartan MB',
  color: Colors.white,
);

const kConditionTextStyle = TextStyle(
  fontSize: 90.0,
);

const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  icon: Icon(
    Icons.location_city,
    color: Colors.white,
  ),
  hintText: 'Enter city name',
  hintStyle: TextStyle(color: Colors.grey),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);
