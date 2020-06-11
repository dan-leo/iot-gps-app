import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';

Position _currentPosition;
int timeElapsed = 0;

void postGPS() {
  if (_currentPosition != null)
    print("$timeElapsed | LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}");
  else
    print("$timeElapsed | Waiting for GPS lock ...");
  // setState(() {
  timeElapsed++;
  // });
}


Future<void> scheduleTask() async {
  // Create a periodic task that prints 'Hello World' every 1s
  final scheduler = NeatPeriodicTaskScheduler(
    interval: Duration(milliseconds: 1000),
    name: 'stream-gps',
    timeout: Duration(milliseconds: 500),
    task: () async => postGPS(),
    minCycle: Duration(milliseconds: 500),
  );

  scheduler.start();
  await ProcessSignal.sigterm.watch().first;
  await scheduler.stop();
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  String _currentAddress;
  bool runOnce = true;

  @override
  Widget build(BuildContext context) {
    if (runOnce) {
      scheduleTask();
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
}