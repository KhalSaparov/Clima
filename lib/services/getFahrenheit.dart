class GetFahrenheit {
  GetFahrenheit({required this.celsius});
  double celsius;
  int toFahrenheit() {
    double tempF = (celsius * 9 / 5) + 32;
    return tempF.toInt();
  }
}
