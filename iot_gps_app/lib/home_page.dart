import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Position _currentPosition;
  String _currentAddress;
  bool runOnce = true;
  int timeElapsed = 0;

  @override
  Widget build(BuildContext context) {
    if (runOnce) {
      _scheduleTask();
      runOnce = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Elapsed time: $timeElapsed"),
            (_currentPosition != null) 
              ? Text("LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}")
              : Text("Waiting for GPS lock ..."),
            if (_currentAddress != null)
              Text(_currentAddress),
            FlatButton(
              child: Text("Get location"),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  _oneSecond() {
    _getCurrentLocation();
    timeElapsed++;
  }

  _scheduleTask() async {
    // Create a periodic task that prints 'Hello World' every 1s
    final scheduler = NeatPeriodicTaskScheduler(
      interval: Duration(milliseconds: 1000),
      name: 'stream-gps',
      timeout: Duration(milliseconds: 999),
      task: () async => _oneSecond(),
      minCycle: Duration(milliseconds: 500),
    );

    scheduler.start();
    await ProcessSignal.sigterm.watch().first;
    await scheduler.stop();
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
          setState(() {
            _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });

    _postGPS();
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _postGPS() {
    try {
      if (_currentPosition != null) {
        print("$timeElapsed | LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}");
        postRequest(_currentPosition.latitude.toString(), _currentPosition.longitude.toString());
      }
      else
        print("$timeElapsed | Waiting for GPS lock ...");
    } catch (e) {
      print(e);
    }
  }
}

postRequest(String lat, String long) async {
  final accessToken = 'FBprmkoajCHYwRNmSsSv';
  var url = 'https://demo.thingsboard.io/api/v1/$accessToken/telemetry';
  // url = 'https://ptsv2.com/t/pm7ab-1591921811/post';
  var body = '{"lat": $lat, "long": $long}';

  print('Url: $url, Body: $body');

  var response = await http.post(
    url,
    headers: {
      'Accept': '*/*',
      'Content-Type': 'application/json',
    },
    body: body,
    encoding: null
  );

  if (response.body.isNotEmpty)
    print("response.body: ${response.body}");

  // todo - handle non-200 status code, etc

  return response.body;
}