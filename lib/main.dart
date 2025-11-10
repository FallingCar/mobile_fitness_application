import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geolocator.dart';

String formatDate(DateTime d){
  return d.toString().substring(0,19);
}

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GeolocatorDistance ds;
  late Stream<double> distanceStream;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?' , _steps = '?';
  int flag = 0;
  String startSteps = '?';
  bool isStarted = false;
  double _startDistance = 0.0;
  double _currentDistance = 0.0;


  @override
  void initState() {
    super.initState();
    initPlatformState();
    ds = GeolocatorDistance();
    ds.beginCalculateDistance();
    distanceStream = ds.getDistanceStream();
  }

  void onStepCount(StepCount event) {
    if(isStarted == true){
      if(flag == 0){
        startSteps = event.steps.toString();
        flag = 1;
      }
      setState(() {
        _steps = event.steps.toString();
        _steps = (int.parse(_steps) - int.parse(startSteps)).toString();
      });
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event){
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error){
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;
    
    if(!granted){
      granted = await Permission.activityRecognition.request() == PermissionStatus.granted;
    }
    return granted;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if(!granted){
      // print('App is not working');
    }
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    (await _pedestrianStatusStream.listen(onPedestrianStatusChanged))
    .onError(onPedestrianStatusError);
    
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if(!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fitness Tracker'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps Taken',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 40),
              ),
              Divider(
                height: 75,
                thickness: 0,
                 color: Colors.black,
              ),
              Text(
                'Pedestrian Status',
                style: TextStyle(fontSize: 20),
              ),
              Icon(
                _status == 'walking'
                ? Icons.directions_walk
                : _status == 'stopped'
                ? Icons.accessibility_new
                : Icons.error,
                size: 75,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                  ? TextStyle(fontSize: 20)
                  :TextStyle(fontSize: 15, color: Colors.red),
                ),
              ),
              Divider(
                height: 75,
                thickness: 0,
                 color: Colors.black,
              ),
              Text(
                'Distance Traveled',
                style: TextStyle(fontSize: 20),
              ),
              StreamBuilder<double>(
                stream: distanceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _currentDistance = snapshot.data!;
                    double sessionDistance = isStarted
                        ? (snapshot.data! - _startDistance)
                        : 0.0;

                    if (sessionDistance < 0) sessionDistance = 0.0; // to fix negetives from appearing

                    return Text(
                      '${(sessionDistance * 0.000621371192).toStringAsFixed(2)} miles',
                      style: const TextStyle(fontSize: 40),
                    );
                  }
                  else {
                    return const Text(
                      'Calculating...',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    );
                  }
                },
              ),
              Divider(
                height: 75,
                thickness: 0,
                 color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // space from screen edges
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () 
                        {
                          isStarted = true;
                          flag = 0;
                          _startDistance = _currentDistance;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black,

                        ),
                        child: const Text('Start'),
                      ),
                    ),
                    const SizedBox(width: 16), // space between buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () 
                        {
                          ds.resetDistanceTaken();
                          isStarted = false;
                          _steps = "0";
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.black,

                        ),
                        child: const Text('Stop'),

                      ),
                    ),
                  ],
                ),
              )
            ]
          ),
        )
      )
    );
  }

}