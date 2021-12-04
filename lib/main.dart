import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'const.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    runApp(MyApp());
  } catch (e) {
    print(e.toString());
  }
}

class MyApp extends StatelessWidget {
  final String appTitle = 'Weather Flutter';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLoading = false;
  dynamic weatherData;
  dynamic weatherMain;
  dynamic windData;

  Future<bool> checkPermissionForStorage() async {
    if (!await Permission.location.isGranted) {
      PermissionStatus status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _getGeoLocationPosition() async {
    bool check = await checkPermissionForStorage();
    if(check==true){
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.latitude);
      print(position.longitude);
      getWeatherData(position);
    }
  }

  void getWeatherData(Position position) async{
    Response response = await get(Uri.parse('http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$appId'));
    this.setState(() {
      var result = jsonDecode(response.body);
      weatherData = result["main"];
      weatherMain = result["weather"][0];
      windData = result["wind"];
      isLoading = false;
    });
    print(weatherData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App")
      ),
      body: (weatherData==null) ? Center(
        child: Container(
          child: MaterialButton(
            onPressed: () async{
              bool check = await checkPermissionForStorage();
              setState(() {
                isLoading = true;
              });
              if(check==true){
                _getGeoLocationPosition();
              }else{
                print("No");
              }
            },
            child: Text("Get Location"),
          ),
        ),
      ) : isLoading == true ? Center(
        child: Container(child: CircularProgressIndicator()),
      ) :
      Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Weather: ${weatherMain["main"].toString()}"),
              Text("Description: ${weatherMain["description"].toString()}"),
              Text("Humidity: ${weatherData["humidity"].toString()} %"),
              Text("Pressure: ${weatherData["pressure"].toString()} hPa"),
              Text("Wind Speed: ${windData["speed"].toString()} m/s"),
            ],
          ),
        ),
      ),
    );
  }
}

