import 'dart:io';
import 'package:json_table/json_table.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:april282020/src/loginPage.dart';
import 'package:april282020/src/signin.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:file_picker_cross/file_picker_cross.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // storage

//untuk enable internet, kene refer pada androidmanifest.xml.
//juga kene kasi "flutter clean" di terminal dulu sebelum buat benda ni
//so that apk sebelum ni get replaced

// untuk proceed lagi, aku perlu access pagea

class JsonPage extends StatefulWidget {

  final String username;
  final String email;
  final String imageUrl;
  JsonPage({Key key, this.username, this.email, this.imageUrl}) : super (key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<JsonPage> {
  final scrollDirection = Axis.vertical;
  AutoScrollController controller;

  // Create storage
  // final storage = new FlutterSecureStorage();

  String token = "";

  final String jsonSample='[{"name":"Ram","email":"ram@gmail.com","age":23,"DOB":"1990-12-01"},'
      '{"name":"Shyam","email":"shyam23@gmail.com","age":18,"DOB":"1995-07-01"},'
      '{"name":"John","email":"john@gmail.com","age":10,"DOB":"2000-02-24"},'
      '{"name":"Ram","age":12,"DOB":"2000-02-01"}]';

  var chatString = "";
  Position _currentPosition;

  bool _hasPermissions = false;
  double _lastRead = 0;
  DateTime _lastReadAt;

  File _image;


  FilePickerCross filePicker = FilePickerCross();
  String _fileString;
  int _fileLength = 0;

  bool chatPageActivateWithKeyboard = false;
  bool chatPageActivate = false;
  bool secondLayerNavBar = false;
  var navBarName;
  int _indexSecond = 0;
  int _index = 0;
  int _qtyItem = 0;
  int testQty = 0;
  var appName = "";
  var dataIsLoading = true;
  var pages;
  var pageName = "Loading";
  var refresh;
  var item;
  var hiddenLevel;
  var headerIcon;
  var headerColor;
  var tempGPS = "NULL";


  List listDropDownWhole = new List();
  List listDropDownWhole2nd = new List();

  int chatPageActivateIndex = 0;

  var counterDropDownItem = 0;
  var dropDownItem = new List();

  List<TextEditingController> _controllers;
  List<String> _controllersTitle = new List();
  Future getData;

  Future getImage(ImgSource source) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      cameraIcon: Icon(
        Icons.add,
        color: Colors.red,
      ),//cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    );
    setState(() {
      _image = image;
      counterDropDownItem = 0;
    });
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {

      setState(() {
        counterDropDownItem = 0;
        _currentPosition = position;
        if (_currentPosition != null){
          print("Latitude: ${_currentPosition.latitude}");
          print("Longitude: ${_currentPosition.longitude}");
          tempGPS = _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();
        }
      });
    }).catchError((e) {
      print(e);
    });

  }

  Future sendData(var url) async{ //http://192.168.0.162:1880/testing

    // pass token 
    // var token = await storage.read(key: "token");

    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      var result = response.body;
      print(result);
    }
  }

  Future fetchData(var url) async {
//    final url = "http://192.168.2.245"; //ofis pinc
//    final url = "http://192.168.2.67";
//    final url = "http://192.168.1.150";
    print("Loading");
    if(dataIsLoading){
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        dataIsLoading = false;
        print('Refreshed');
        var result = response.body;
        final map = json.decode(result);
        final pageJSON = map["page"];
        appName = map["title"];
        this.pages = pageJSON;

        pageName = this
            .pages[_index]['pageName']
            .toString()
            .toUpperCase();
        refresh = this.pages[_index]['refresh'].toString();
        item = this.pages[_index]['item'].toString();
        hiddenLevel = this.pages[_index]['hiddenLevel'].toString();
        headerIcon = this.pages[_index]['headerIcon'].toString();
        headerColor = this.pages[_index]['headerColor'].toString();
        _controllersTitle.clear();
        _qtyItem = this.pages[_index]['item'].length;


        for (int i = 0; i < this.pages.length; i++) {
          var listDropDownPage = new List();

          for (int k = 0; k < this.pages[i]['item'].length; k++) {
            if(this.pages[i]['item'][k]['i'].toString().split(',')[0] == '6'){
              var listDropDown = new List();
              var locationComma = this.pages[i]['item'][k]['i'].toString().indexOf(',');
              var wholeString = this.pages[i]['item'][k]['i'].toString();
              var eliminateComma = wholeString.substring(locationComma+1);
              locationComma = eliminateComma.indexOf(',');
              eliminateComma = eliminateComma.substring(locationComma+1);
              listDropDown.add(this.pages[i]['item'][k]['i'].toString().split(',')[1]);
              var maxIndex = eliminateComma.length;
              var separator = ',';
              var location1 = 0;
              var location2 = 0;

              for(int i = 0; i < maxIndex; i++){
                if(eliminateComma[i] == separator){
                  location2 = i;
                  listDropDown.add(eliminateComma.substring(location1,location2));
                  location1 = location2 + 1;
                }
                else if(i == maxIndex - 1){
                  listDropDown.add(eliminateComma.substring(location1,maxIndex));
                }
              }
              listDropDownPage.add(listDropDown);
            }
          }
          var listDropDownPage2 = new List();
          if(this.pages[i]['secondLayerNavBar'] == 'true'){
            navBarName = this.pages[i]['navBarName'][0];
            for (int j = 0; j < this.pages[i]['navBarName'].length; j++) {  //page
              var navName = this.pages[i]['navBarName'][j];
              var listDropDown2 = new List();
              for(int k = 0; k < this.pages[i][navName].length; k ++){
                if(this.pages[i][navName][k]['i'].toString().split(',')[0] == '6'){
                  var listDropDown3 = new List();
                  var locationComma = this.pages[i][navName][k]['i'].toString().indexOf(',');
                  var wholeString = this.pages[i][navName][k]['i'].toString();
                  var eliminateComma = wholeString.substring(locationComma+1);
                  locationComma = eliminateComma.indexOf(',');
                  eliminateComma = eliminateComma.substring(locationComma+1);
                  listDropDown3.add(this.pages[i][navName][k]['i'].toString().split(',')[1]);

                  var maxIndex = eliminateComma.length;
                  var separator = ',';
                  var location1 = 0;
                  var location2 = 0;

                  for(int i = 0; i < maxIndex; i++){
                    if(eliminateComma[i] == separator){
                      location2 = i;
                      listDropDown3.add(eliminateComma.substring(location1,location2));
                      location1 = location2 + 1;
                    }
                    else if(i == maxIndex - 1){
                      listDropDown3.add(eliminateComma.substring(location1,maxIndex));
                    }
                  }
                  listDropDown2.add(listDropDown3);
                }
              }
              listDropDownPage2.add(listDropDown2);  //listDropDownWhole2nd
            }
          }
          listDropDownWhole2nd.add(listDropDownPage2);
          listDropDownWhole.add(listDropDownPage);
        }
        if(this.pages[_index]['secondLayerNavBar'] == "true"){
          print("secondlayernavbar");
          secondLayerNavBar = true;
          navBarName = this.pages[_index]['navBarName'][_indexSecond];
          pageName = navBarName.toString().toUpperCase();
          appName = appName.split('/')[0] + "/" + this.pages[_index]['pageName'];
          counterDropDownItem = 0;
          _qtyItem = this.pages[_index][navBarName].length;

        }
        else{
          print("no secondlayernavbar");
          pageName = this.pages[_index]['pageName'].toString().toUpperCase();
          _qtyItem = this.pages[_index]['item'].length;
        }
        setState(() {
        });
        return result;
      }
    }
  }

  Future _scrollToIndex(int counter) async {

    await controller.scrollToIndex(counter, preferPosition: AutoScrollPosition.begin);
    controller.highlight(counter);
  }


  Widget _buildManualReader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          RaisedButton(
            child: Text('Read Value'),
            onPressed: () async {
              final double tmp = await FlutterCompass.events.first;
              setState(() {
                _lastRead = tmp;
                _lastReadAt = DateTime.now();
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '$_lastRead',
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  '$_lastReadAt',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<double>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double direction = snapshot.data;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        return Stack(
          children: <Widget>[
            Container(
              // color: Colors.green,
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: ((direction ?? 0) * (math.pi / 180) * -1),
                child: ClipOval(child: Image.asset('assets/compass.png')),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          RaisedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              PermissionHandler().requestPermissions(
                  [PermissionGroup.locationWhenInUse]).then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          RaisedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              PermissionHandler().openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    controller = AutoScrollController(
        viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection
    );
    
    _fetchPermissionStatus();
    getData = fetchData("https://onemango.my/flutterformjson.php");
  }


  void checkBelonging(var type, var page, var titleName, var newValue, var secondLayerExist, var navBarName){
    if(secondLayerExist == true){
      for(int index = 0; index < this.pages[_index][navBarName].length; index++){
        if(titleName == this.pages[_index][navBarName][index]['i'].split(',')[1]){
          newValue = type.toString() + "," + titleName + "," + newValue;
          counterDropDownItem = 0;
          this.pages[_index][navBarName][index]['i'] = newValue;
        }
      }

    }
    else{
      for(int index = 0; index < this.pages[_index]['item'].length; index++){
        if(titleName == this.pages[_index]['item'][index]['i'].split(',')[1]){
          newValue = type.toString() + "," + titleName + "," + newValue;
          counterDropDownItem = 0;
          this.pages[_index]['item'][index]['i'] = newValue;

        }
      }
    }
    setState(() {
      print("_index: $_index");
      print("pageName: $pageName");

    });

  }

  Future<void> _popupQuery(var title, var content) async{
    int dataType = 0;
    int substringStart = 1;
    int substringEnd = 0;
    var value;
    if(content[0] == '#'){
      dataType = 1;
    }

    for(int ctr = 1; ctr < content.length; ctr ++){
      if(content[ctr] == '#'){
        if(content[substringStart-1] == '@'){
          dataType = 0;
        }
        else if(content[substringStart-1] == '#'){
          dataType = 1;
        }
        substringEnd = ctr;
        value = content.substring(substringStart,substringEnd);
        substringStart = substringEnd + 1;
        print("$dataType : $value");
      }
      else if(content[ctr] == '@'){
        if(content[substringStart-1] == '@'){
          dataType = 0;
        }
        else if(content[substringStart-1] == '#'){
          dataType = 1;
        }
        substringEnd = ctr;
        value = content.substring(substringStart,substringEnd);
        substringStart = substringEnd + 1;

        print("$dataType : $value");
      }
      else if(ctr == content.length - 1){
        if(content[substringStart-1] == '@'){
          dataType = 0;
        }
        else if(content[substringStart-1] == '#'){
          dataType = 1;
        }
        substringEnd = ctr;
        value = content.substring(substringStart,substringEnd + 1);
        substringStart = substringEnd + 1;
        print("$dataType : $value");
      }
    }

    return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19)
              ),
              title: Text(title),
              content: Container(
                  child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[

                        ],
                      )
                  )
              )
          );
        }
    );
  }



  Future<void> _popupSelect(var title, List<dynamic> itemList, var elementInList, var pageNumber, var arrangedInPage, var pageNumberSecondLayer) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19)
          ),
          title: Text(title),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children:
                itemList.map((item){
                  return FlatButton(
                      onPressed: () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        setState(() {
                          Navigator.of(context).pop();
                          int c = 0;
                          for(c = 0; c < itemList.length; c ++){
                            if(itemList.elementAt(c) == item){
                              break;
                            }
                          }
                          if(secondLayerNavBar){
                            listDropDownWhole2nd[pageNumber][pageNumberSecondLayer][elementInList][1] = itemList[c];
                            listDropDownWhole2nd[pageNumber][pageNumberSecondLayer][elementInList][c+1] = itemList[0];

                            String modifyListDropDownWhole;
                            modifyListDropDownWhole = listDropDownWhole2nd[pageNumber][pageNumberSecondLayer][elementInList].toString();
                            modifyListDropDownWhole = modifyListDropDownWhole.substring(1,modifyListDropDownWhole.length-1);
                            modifyListDropDownWhole = "6," + modifyListDropDownWhole;

                            var navName = this.pages[_index]['navBarName'][pageNumberSecondLayer];
                            this.pages[_index][navName][arrangedInPage]['i'] = modifyListDropDownWhole;
                          }
                          else{
                            listDropDownWhole[pageNumber][elementInList][1] = itemList[c];
                            listDropDownWhole[pageNumber][elementInList][c+1] = itemList[0];

                            String modifyListDropDownWhole;
                            modifyListDropDownWhole = listDropDownWhole[pageNumber][elementInList].toString();
                            modifyListDropDownWhole = modifyListDropDownWhole.substring(1,modifyListDropDownWhole.length-1);
                            modifyListDropDownWhole = "6," + modifyListDropDownWhole;
                            this.pages[_index]['item'][arrangedInPage]['i'] = modifyListDropDownWhole;
                          }
                          counterDropDownItem = 0;
                        });

                      },
                      child: Stack(
                        children: <Widget>[
                          Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(item, textAlign: TextAlign.start,),
                            ),
                          )
                        ],
                      )
                  );
                }).toList(),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Dismiss'),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                });

              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: <Widget>[
            Text(appName, style: TextStyle(fontSize: 15),),
            Text(pageName, style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl),
                      radius: 50.0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${widget.username}",
                      style: TextStyle(
                        color: Colors.white, fontSize:20.0),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight + Alignment(0, .3),
                    child: Text(
                      "${widget.email}",
                      style: TextStyle(
                        color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Change initial JSON'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: dataIsLoading  ? CircularProgressIndicator() : GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
            chatPageActivateWithKeyboard = false;
          },
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: new ListView.builder(
                    scrollDirection: scrollDirection,
                    controller: controller,
                    itemCount: _qtyItem + 1,
                    itemBuilder: (context, i) {

                      if(i == _qtyItem){
                        if(chatPageActivate){
                          return SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom < 100 ? MediaQuery.of(context).size.height * 0.55 : MediaQuery.of(context).size.height * 0.8,
                          );
                        }
                        else{
                          return SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom < 100 ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 1,
                          );
                        }
                      }
                      var xxx;
                      if(chatPageActivate){
                        if(secondLayerNavBar){
                          xxx = this.pages[_index][navBarName][chatPageActivateIndex]['m'][i].toString();
                        }
                        else{
                          xxx = this.pages[_index]['item'][chatPageActivateIndex]['m'][i].toString();
                        }

                        if(xxx[1]=='p'){
                          var actualText = xxx.substring(4);
                          var ind = actualText.length;
                          actualText = actualText.substring(0,ind-12);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(actualText),
                                  ),
                                  color: Colors.green[300],
                                  width: (MediaQuery.of(context).size.width/3) * 2,
                                )
                              ],
                            ),
                          );
                        }
                        else{
                          var actualText = xxx.substring(4);
                          var ind = actualText.length;
                          actualText = actualText.substring(0,ind-12);
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(actualText),
                                  ),
                                  color: Colors.green[100],
                                  width: (MediaQuery.of(context).size.width/3) * 2,
                                )
                              ],
                            ),
                          );
                        }

                      }
                      else{
                        if(secondLayerNavBar){
                          xxx = this.pages[_index][navBarName][i]['i'].toString();
                        }
                        else{
                          xxx = this.pages[_index]['item'][i]['i'].toString();
                        }
                      }

                      if (xxx.split(',')[0] == '0') {
                        return RaisedButton(
                          elevation: 0,
                          child: Text(xxx.split(',')[2]),
                          onPressed: () {
                            if(xxx.split(',')[1] == "GET"){
                              dataIsLoading = true;
                              return fetchData(xxx.split(',')[3].toString());
                            }
                            else if(xxx.split(',')[1] == "POST"){
                              if(secondLayerNavBar){
                                print(this.pages[_index][navBarName]);
                              }
                              else{
                                print(this.pages[_index]['item']);
                              }
                              return sendData(xxx.split(',')[3].toString());
                            }
                            else if(xxx.split(',')[1] == "POPUP"){
                              return _popupQuery(xxx.split(',')[2],xxx.split(',')[3]);
                            }
                            else{
                              return null;
                            }
                          },
                        );
                      }  else if (xxx.split(',')[0] == '2') {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(xxx.split(',')[1], style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                            Divider(
                              color: Colors.black,
                              height: 1,
                            )
                          ],
                        );
                      } else if (xxx.split(',')[0] == '3') {
                        return Card(
                          elevation: 0,
                          child: Row(
                            children: <Widget>[
                              Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 100,
                                  child: Text('${xxx.split(',')[1]}')),
                              Text('${xxx.split(',')[2]}'),
                            ],
                          ),
                        );
                      } else if (xxx.split(',')[0] == '4') {
                        var value;
                        if(secondLayerNavBar){
                          value = this.pages[_index][navBarName][i]['i'].substring(this.pages[_index][navBarName][i]['i'].indexOf(',')+1);
                          value = value.substring(value.indexOf(',')+1);
                        }
                        else{
                          value = this.pages[_index]['item'][i]['i'].substring(this.pages[_index]['item'][i]['i'].indexOf(',')+1);
                          value = value.substring(value.indexOf(',')+1);
                        }

                        counterDropDownItem = 0;

                        return AutoScrollTag(
                          key: ValueKey(i),
                          controller: controller,
                          index: i,
                          child: Card(
                            color: Colors.green[300],
                            elevation: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('${xxx.split(',')[1]}'),
                                    )),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10, bottom: 5),
                                    child: Container(
                                      height: 30,
                                      child: TextField(
//                                        controller: TextEditingController(text: value,),
                                        controller: TextEditingController.fromValue(TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length))),
                                        onSubmitted: (newValue){
                                          checkBelonging(4, _index, xxx.split(',')[1], newValue, secondLayerNavBar, navBarName);
                                        },

                                        onTap: (){
                                          controller.scrollToIndex(i, preferPosition: AutoScrollPosition.begin);
                                        },

                                        style: TextStyle(
                                            fontSize: 14
                                        ),

                                        autofocus: false,
                                        //controller: _controllers[seq]..text = xxx.split(',')[2].toString().toUpperCase(),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      } else if (xxx.split(',')[0] == '5') {
                        var value;
                        if(secondLayerNavBar){
                          value = this.pages[_index][navBarName][i]['i'].substring(this.pages[_index][navBarName][i]['i'].indexOf(',')+1);
                          value = value.substring(value.indexOf(',')+1);
                        }
                        else{
                          value = this.pages[_index]['item'][i]['i'].substring(this.pages[_index]['item'][i]['i'].indexOf(',')+1);
                          value = value.substring(value.indexOf(',')+1);
                        }

                        return AutoScrollTag(
                          key: ValueKey(i),
                          controller: controller,
                          index: i,
                          child: Card(
                            color: Colors.green[300],
                            elevation: 0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('${xxx.split(',')[1]}'),
                                    )),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10, bottom: 5),
                                    child: Container(
                                      height: 30,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        onSubmitted: (newValue){
                                          checkBelonging(5 ,_index, xxx.split(',')[1], newValue, secondLayerNavBar, navBarName);
                                        },
                                        style: TextStyle(
                                            fontSize: 14
                                        ),
                                        onTap: (){
                                          controller.scrollToIndex(i, preferPosition: AutoScrollPosition.begin);
                                        },
                                        controller: TextEditingController.fromValue(TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length))),
                                        autofocus: false,
                                        //controller: _controllers[seq]..text = xxx.split(',')[2].toString().toUpperCase(),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }

                      else if(xxx.split(',')[0] == '6'){
                        var listTitle;
                        var listValueFirst;

                        listTitle = xxx.split(',')[1];
                        listValueFirst = xxx.split(',')[2];
                        counterDropDownItem++;

                        return Card(
                          color: Colors.green[300],
                          elevation: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(listTitle),
                                  )),
                              Expanded(
                                flex: 7,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Container(
                                    height: listValueFirst.length < 35 ? 30 : 60,
                                    child: RaisedButton(
                                      padding: const EdgeInsets.all(5),
                                      elevation: 0,
                                      onPressed: (){
                                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                                        FocusScope.of(context).unfocus();
                                        counterDropDownItem = 0;
                                        if(secondLayerNavBar){
                                          int qw = 0;
                                          for(qw = 0; qw < listDropDownWhole2nd[_index][_indexSecond].length; qw++){
                                            if(listDropDownWhole2nd[_index][_indexSecond][qw][0] == listTitle){
                                              break;
                                            }
                                          }

                                          var listDropDownWholeWithoutTitle = new List();
                                          for(int x = 1; x < listDropDownWhole2nd[_index][_indexSecond][qw].length; x ++){
                                            listDropDownWholeWithoutTitle.add(listDropDownWhole2nd[_index][_indexSecond][qw][x]);
                                          }
                                          _popupSelect(listTitle, listDropDownWholeWithoutTitle, qw, _index, i, _indexSecond);

                                        }
                                        else{
                                          int qw = 0;
                                          for(qw = 0; qw < listDropDownWhole[_index].length; qw++){
                                            if(listDropDownWhole[_index][qw][0] == listTitle){
                                              break;
                                            }
                                          }

                                          var listDropDownWholeWithoutTitle = new List();
                                          for(int x = 1; x < listDropDownWhole[_index][qw].length; x ++){
                                            listDropDownWholeWithoutTitle.add(listDropDownWhole[_index][qw][x]);
                                          }
                                          _popupSelect(listTitle, listDropDownWholeWithoutTitle, qw, _index, i, 0);
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(child: Text(
                                            listValueFirst,
                                            style: TextStyle(
                                                fontSize: 12.5
                                            ),
                                          )),
                                          Icon(Icons.arrow_drop_down),
                                        ],
                                      ),

                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      else if(xxx.split(',')[0] == '7'){

                        var hh = xxx.split(',')[2][0] + xxx.split(',')[2][1];
                        var mm = xxx.split(',')[2][3] + xxx.split(',')[2][4];
                        var ampm = xxx.split(',')[2][6] + xxx.split(',')[2][7];


                        return Card(
                          color: Colors.green[300],
                          elevation: 0,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex:3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('${xxx.split(',')[1]}'),
                                  )
                              ),
                              Expanded(
                                flex: 7,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child:
                                  RaisedButton(
                                      onPressed: () {
                                        DatePicker.showTime12hPicker(context, showTitleActions: true,
                                            onConfirm: (date) {
                                              var editDate = date.toString();
                                              hh = editDate[11] + editDate[12];
                                              mm = editDate[14] + editDate[15];
                                              int determineAMPM = int.parse(hh);
                                              ampm = "AM";
                                              if(determineAMPM >= 12){
                                                ampm = "PM";
                                                if(determineAMPM > 12){
                                                  determineAMPM = determineAMPM - 12;
                                                }
                                              }
                                              hh = determineAMPM.toString();
                                              if(hh.length == 1){
                                                hh = "0" + hh;
                                              }
                                              var newValue = "$hh:$mm $ampm";
                                              counterDropDownItem = 0;
                                              checkBelonging(7, _index, xxx.split(',')[1], newValue, secondLayerNavBar, navBarName);
                                            },

                                            currentTime: DateTime.utc(2020, 04, 1, int.parse(hh), int.parse(mm), 0));
                                      },
                                      child: Text(
                                        hh + ":" + mm + " " + ampm,
//                                      style: TextStyle(color: Colors.blue),
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      else if(xxx.split(',')[0] == '8'){

                        var DD = xxx.split(',')[2].split('/')[0];
                        var MM = xxx.split(',')[2].split('/')[1];
                        var YYYY = xxx.split(',')[2].split('/')[2];

                        return Card(
                            color: Colors.green[300],
                            elevation: 0,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex:3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('${xxx.split(',')[1]}'),
                                    )
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: RaisedButton(
                                      onPressed: (){
                                        DatePicker.showDatePicker(context,
                                            theme: DatePickerTheme(
                                                backgroundColor: Colors.white,
                                                itemStyle: TextStyle(
                                                    color: Colors.black
                                                )
                                            ),
                                            showTitleActions: true,
                                            minTime: DateTime(2020, 1, 1),
                                            maxTime: DateTime(2030, 12, 31),
                                            onConfirm: (date){
                                              var stringDate = date.toString();
                                              YYYY = stringDate[0] + stringDate[1] + stringDate[2] + stringDate[3];
                                              MM = stringDate[5] + stringDate[6];
                                              DD = stringDate[8] + stringDate[9];
                                              stringDate = "$DD/$MM/$YYYY";
                                              checkBelonging(8, _index, xxx.split(',')[1], stringDate, secondLayerNavBar, navBarName);
                                            },
                                            currentTime: DateTime.utc(int.parse(YYYY), int.parse(MM), int.parse(DD), 0,0,0)
                                        );
                                      },
                                      child: Text(DD + '/' + MM + '/' + YYYY),
                                    ),
                                  ),
                                )
                              ],
                            )

                        );
                      }
                      else if(xxx.split(',')[0] == '9'){
                        return Card(
                          color: Colors.green[300],
                          elevation: 0,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex:3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('${xxx.split(',')[1]}'),
                                  )
                              ),
                              Expanded(
                                flex: 7,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: RaisedButton(
                                    child: Text(tempGPS),
                                    onPressed: (){
                                      _getCurrentLocation();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      else if (xxx.split(',')[0] == '10') {
                        var value;

                        if(secondLayerNavBar){
                          value = this.pages[_index][navBarName][i]['i'].substring(this.pages[_index][navBarName][i]['i'].indexOf(',')+1);
                          value = value.substring(value.indexOf(',')+1);
                        }
                        else{
                          value = this.pages[_index]['item'][i]['i'].substring(this.pages[_index]['item'][i]['i'].indexOf(',')+1);
                          value = value.substring(value.indexOf(',')+1);
                        }

                        return AutoScrollTag(
                          key: ValueKey(i),
                          controller: controller,
                          index: i,
                          child: Card(
                            color: Colors.green[300],
                            elevation: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text('${xxx.split(',')[1]}'),
                                    )),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10, bottom: 5),
                                    child: Container(
                                      child: TextField(
//                                        controller: TextEditingController(text: value),
                                        controller: TextEditingController.fromValue(TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length))),
                                        onSubmitted: (newValue){
                                          checkBelonging(10, _index, xxx.split(',')[1], newValue, secondLayerNavBar, navBarName);
                                        },
                                        style: TextStyle(
                                            fontSize: 14
                                        ),
                                        onTap: (){
                                          controller.scrollToIndex(i, preferPosition: AutoScrollPosition.begin);
                                        },
                                        maxLines: null,
                                        autofocus: false,
                                        keyboardType: TextInputType.text,
                                        //controller: _controllers[seq]..text = xxx.split(',')[2].toString().toUpperCase(),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }

                      else if(xxx.split(',')[0] == '11'){
                        return Column(
                          children: <Widget>[
                            RaisedButton(
                              onPressed:(){
                                getImage(ImgSource.Both);
                              },
                              child: Text('Select File'),
                            ),
                            Container(
                              child: _image != null ? Image.file(_image) : Container(),
                            )
                          ],
                        );
                      }

                      else if(xxx.split(',')[0] == '12'){
                        var json = jsonDecode(jsonSample);
                        String eligibleToVote(value) {
                          if (value >= 18) {
                            return "Yes";
                          } else
                            return "No";
                        }

                        var columns = [
                          JsonTableColumn("name", label: "Name"),
                          JsonTableColumn("age", label: "Age"),
                          JsonTableColumn("DOB", label: "Date of Birth", ),
                          JsonTableColumn("age", label: "Eligible to Vote", valueBuilder: eligibleToVote),
                          JsonTableColumn("email", label: "E-mail", defaultValue: "NA"),
                        ];

                        return JsonTable(json,columns: columns);
                      }

                      else if(xxx.split(',')[0] == '13'){
                        if(_hasPermissions){
                          return Container(
                            height: 500,
                            child: Column(
                              children: <Widget>[
                                _buildManualReader(),
                                Expanded(child: _buildCompass()),
                              ],
                            ),
                          );
                        }
                        else{
                          return _buildPermissionSheet();
                        }
//                          return Container(
//                            height: 500,
//                            child: FlutterMap(
//                              options: new MapOptions(
//                                center: LatLng(3.082,101.545),
//                                minZoom: 15.0
//                              ),
//                              layers:[
//                                new TileLayerOptions(
//                                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                                    subdomains: ['a', 'b', 'c']
//                                ),
//                                new MarkerLayerOptions(
//                                  markers: [
//                                    Marker(
//                                      width: 20.0,
//                                      height: 20.0,
//                                      point: new LatLng(3.081, 101.543),
//                                      builder: (ctx) =>
//                                      new Container(
//                                        child: new FlutterLogo(),
//                                      ),
//                                    ),
//                                    Marker(
//                                      width: 20.0,
//                                      height: 50.0,
//                                      point: new LatLng(3.0846, 101.5464),
//                                      builder: (ctx) =>
//                                      new Container(
//                                        child: new FlutterLogo(),
//                                      ),
//                                    )
//                                  ]
//                                )
//                              ]
//                            ),
//                          );
                      }

                      else if(xxx.split(',')[0] == '15'){
                        var rrr;
                        if(secondLayerNavBar){
                          rrr = this.pages[_index][navBarName][i]['m'].toString();
                        }
                        else{
                          rrr = this.pages[_index]['item'][i]['m'].toString();
                        }
                        return Card(
                          color: Colors.green[300],
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text('${xxx.split(',')[1]}'),
                                  )),
                              Expanded(
                                flex: 7,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Container(
                                    height: 30,
                                    child: RaisedButton(
                                      padding: const EdgeInsets.all(5),
                                      elevation: 0,
                                      onPressed: (){
                                        chatPageActivate = true;
                                        chatPageActivateIndex = i;
                                        if(secondLayerNavBar){
                                          appName = appName.split('/')[0] + "/" + appName.split('/')[1] + "/" + navBarName;
                                          _qtyItem = this.pages[_index][navBarName][chatPageActivateIndex]['m'].length;
                                        }
                                        else{
                                          pageName = pageName.substring(0,1).toUpperCase() + pageName.substring(1).toLowerCase();
                                          appName = appName.split('/')[0] + "/" + pageName;
                                          _qtyItem = this.pages[_index]['item'][chatPageActivateIndex]['m'].length;
                                        }
                                        pageName = xxx.split(',')[1];
                                        setState(() {

                                          counterDropDownItem = 0;

                                        });
                                      },
                                      child: Text(
                                        xxx.split(',')[2],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }

                      else {
                        return Text(xxx);
                      }
                    },
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                child: Container(
                  height: 500,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Visibility(
                          visible: chatPageActivate,
                          child: Container(
                            color: Colors.green[300],
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                    flex: 17,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none
                                        ),
                                        onChanged: (value){
                                          chatString = value;
                                        },
                                        onTap: (){
                                          chatPageActivateWithKeyboard = true;
                                          print("chatPageActivateWithKeyboard true");
                                        },
                                        maxLines: 3,
                                        minLines: 1,
                                      ),
                                    )
                                ),
                                Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        icon: Icon(Icons.send),
                                        onPressed: (){
                                          print(chatString);
                                          FocusScope.of(context).unfocus();
                                          chatPageActivateWithKeyboard = false;
                                        })
                                )
                              ],
                            ),
                          )
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom < 100 ? 0 : !secondLayerNavBar ? MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).size.height * 0.05 : MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).size.height * 0.1,
                      ),
                      Visibility(
                        visible: secondLayerNavBar,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.05,
                          color: Colors.green,
                          child:
                          new ListView.builder(
                            itemCount: this.pages[_index]['navBarName'] != null ? this.pages[_index]['navBarName'].length : 0,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              var tabName = this.pages[_index]['navBarName'][i].toString().toUpperCase();
                              return SizedBox(
                                width: this.pages[_index]['navBarName'].length < 4 ? MediaQuery.of(context).size.width / this.pages[_index]['navBarName'].length : null,
                                height: double.infinity,
                                child: new FlatButton(
                                    onPressed: () {
                                      chatPageActivate = false;
                                      appName = appName.split('/')[0] + "/" + this.pages[_index]['pageName'];
                                      pageName = this.pages[_index]['navBarName'][i].toString().toUpperCase();
                                      navBarName = this.pages[_index]['navBarName'][i];
                                      _qtyItem = this.pages[_index][navBarName].length;
                                      _indexSecond = i;
                                      counterDropDownItem = 0;

                                      setState(() {
                                      });
                                    },
                                    child: new Text(tabName)),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.green,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: new ListView.builder(
                          itemCount: this.pages != null ? this.pages.length : 0,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            var pageNameTemp = this.pages[i]['pageName'].toString().toUpperCase();

                            return SizedBox(
                              width: this.pages.length < 4 ? MediaQuery.of(context).size.width / this.pages.length : null,
                              height: double.infinity,
                              child: new FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      chatPageActivate = false;
                                      counterDropDownItem = 0;
                                      _index = i;
                                      _qtyItem = 0;
                                      refresh = this.pages[i]['refresh'];
                                      item = this.pages[i]['item'];
                                      hiddenLevel = this.pages[i]['hiddenLevel'];
                                      headerIcon = this.pages[i]['headerIcon'];
                                      headerColor = this.pages[i]['headerColor'];
                                      if(this.pages[i]['secondLayerNavBar'] == "true"){
                                        secondLayerNavBar = true;
                                        appName = appName.split('/')[0] + "/" + this.pages[_index]['pageName'];
                                        pageName = this.pages[_index]['navBarName'][0].toString().toUpperCase();
                                        // pageName = 'ano';
                                        navBarName = this.pages[_index]['navBarName'][0];
                                        _qtyItem = this.pages[_index][navBarName].length;
                                      }
                                      else{
                                        pageName = this.pages[i]['pageName'].toString().toUpperCase();
                                        secondLayerNavBar = false;
                                        appName = appName.split('/')[0];
                                      }
                                      item.forEach((item) => _qtyItem++);
                                    });
                                  },
                                  child: new Text(pageNameTemp, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*
code mati
cara cari epoch
var timeActual = (DateTime.now().millisecondsSinceEpoch + (8 * 60 * 60 * 1000))/1000;
print(timeActual.toInt().toString());
return Text(timeActual.toString());
 */

/*
[[], [], [], [], [[], [[State, Selangor, Perlis]], [[Age, 20-24, 25-39, 40-44, 45-49]], [[State, Kedah, Johor]], [[Gender, Male, Female]]]]
ptutnya
[[], [], [], [], [[],[[State, Selangor, Perlis],[Age, 20-24, 25-39, 40-44, 45-49]],[[State, Kedah, Johor], [Gender, Male, Female]]]]
*/
//elementInList   = popupSelect yang ke berapa dalam page tu.
//pageNumber      = pageNumber. Untuk 2nd Array, kita akan buatkan [MainTab][SecondaryTab]
//arrangedInPage  = item yang ke berapa dalam page tu
//title           = value [0]. Contoh Cardinal latitude
//itemList        = baki selepas value[0]. Contoh [N, S]