import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/welcomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'NiNe 2.0',
      theme: ThemeData(
         primarySwatch: Colors.green,
         textTheme:GoogleFonts.latoTextTheme(textTheme).copyWith(
           body1: GoogleFonts.montserrat(textStyle: textTheme.body1),
         ),
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:april282020/src/database_helpers.dart';
// import 'package:path_provider/path_provider.dart';

//     void main() => runApp(MyApp());

//     class MyApp extends StatelessWidget {
//       @override
//       Widget build(BuildContext context) {
//         return MaterialApp(
//           theme: ThemeData(primarySwatch: Colors.blue),
//           home: MyHomePage(),
//         );
//       }
//     }

//     class MyHomePage extends StatelessWidget {
//       @override
//       Widget build(BuildContext context) {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Saving data'),
//           ),
//           body: Row(
//             //mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: RaisedButton(
//                   child: Text('Read'),
//                   onPressed: () {
//                     _read();
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: RaisedButton(
//                   child: Text('Save'),
//                   onPressed: () {
//                     _save();
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       }

//       // Replace these two methods in the examples that follow

//       _read() async {
//         try {
//           final directory = await getApplicationDocumentsDirectory();
//           final file = File('${directory.path}/data.json');
//           String text = await file.readAsString();
//           Map<String, dynamic> map = jsonDecode(text); // import 'dart:convert';
//           print(map['makanan']);
//         } catch (e) {
//           print("Couldn't read file");
//         }
//       }

//       _save() async {
//         final directory = await getApplicationDocumentsDirectory();
//         final file = File('${directory.path}/data.json');
//         final text = '{"makanan":"kariayam","minuman":"air sirap"}';
//         await file.writeAsString(text);
//         print('saved');
//       }
//     }