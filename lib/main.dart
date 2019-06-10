import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flare_flutter/flare_actor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _locality = '';
  double _temperature = 0.0;
  String _description = '';

  Future<Position> getPosition() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<Placemark> getPlacemark(double latitude, double longitude) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromCoordinates(latitude, longitude);
    return placemark[0];
  }

  Future<Map> getData(double latitude, double longitude) async {
    String api = 'http://api.openweathermap.org/data/2.5/forecast';
    String appId = '<YOUR_OWN_API_KEY>';

    String url = '$api?lat=$latitude&lon=$longitude&APPID=$appId';

    http.Response response = await http.get(url);

    Map parsed = json.decode(response.body);

    return {
      'temperature': toCelsius(parsed['list'][0]['main']['temp']),
      'description': parsed['list'][0]['weather'][0]['description'],
    };
  }

  double toCelsius(temp) {
    return temp - 273.15;
  }

  @override
  void initState() {
    super.initState();
    getPosition().then((position) {
      getPlacemark(position.latitude, position.longitude).then((data) {
        getData(position.latitude, position.longitude).then((weather) {
          setState(() {
            _locality = data.locality;
            _temperature = weather['temperature'];
            _description = weather['description'];
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Weather App'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/background.jpg',
                width: size.width,
                height: size.height,
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    '$_locality',
                    style: TextStyle(
                      fontFamily: 'Indie Flower',
                      fontSize: 50,
                    ),
                  ),
                  Text(
                    '${_temperature.toStringAsFixed(2)}ºC',
                    style: TextStyle(
                      fontFamily: 'Kumar One Outline',
                      fontSize: 50,
                    ),
                  ),
                  Container(
                    height: 250,
                    child: FlareActor(
                      'assets/animations/cloudy.flr',
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: 'get_cloudy',
                    ),
                  ),
                  Text(
                    '$_description',
                    style: TextStyle(
                      fontFamily: 'Indie Flower',
                      fontSize: 50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
