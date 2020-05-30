// import 'package:crypto_font_icons/crypto_font_icons.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:typicons_flutter/typicons.dart';
// import 'crypto_data.dart';

// class ESPList extends StatefulWidget {
//   ESPList({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _ESPListState createState() => _ESPListState();
// }

// class _ESPListState extends State<ESPList> {

// @override
// Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child:Container(
//           height: MediaQuery.of(context).size.height,
//           child:Stack(
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Expanded(
//                       flex: 3,
//                       child: SizedBox(),
//                     ),
//                     _title(),
//                     SizedBox(
//                       height: 50,
//                     ),
//                     _emailPasswordWidget(),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     _submitButton(),
//                     Expanded(
//                       flex: 2,
//                       child: SizedBox(),
//                     )
//                   ],
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: _signupAccountLabel(),
//               ),
//               Positioned(top: 40, left: 0, child: _backButton()),
//               Positioned(
//                   top: -MediaQuery.of(context).size.height * .15,
//                   right: -MediaQuery.of(context).size.width * .4,
//                   child: BezierContainer())
//             ],
//           ),
//         )
//       )
//     );
//   }
// }