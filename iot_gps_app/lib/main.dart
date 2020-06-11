import 'package:flutter/material.dart';

import 'home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// void main() => runApp(MyApp());


// class MyApp extends StatelessWidget {
//   var counter = 0;

//   @override
//   Widget build(BuildContext context) {
//     // while (true) {
//     //   print(counter++);
//     // }
//     return MaterialApp(
//       title: 'Welcome to Flutter',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Welcome to Flutter'),
//         ),
//         body: const Center(
//           child: const Text('Hello World'),
//         ),
//       ),
//     );
//   }
// }