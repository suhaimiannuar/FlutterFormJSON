import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:april282020/src/loginPage.dart';
import 'package:april282020/src/Widget/bezierContainer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:april282020/src/errorHandler.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

int userId=0;

class _SignUpPageState extends State<SignUpPage> {


  TextEditingController user=new TextEditingController();
  TextEditingController pass=new TextEditingController();
  TextEditingController email=new TextEditingController();

  String msg='';

  checkTextFieldEmptyOrNot(){

    // Creating 3 String Variables.
    String userField,emailField,passField ;

    // Getting Value From Text Field and Store into String Variable
    userField = user.text ;
    emailField = email.text ;
    passField = pass.text ;

    // Checking all TextFields.
    if(userField == '' || emailField == '' || passField == '')
    {
      // Put your code here which you want to execute when Text Field is Empty.
      emptyField(context);

    }else{
      // Put your code here, which you want to execute when Text Field is NOT Empty.
      _signup();
    }
    
  }

  Future<List> _signup() async {
    try {
      final response = await http.post("https://api.onemango.my/auth/signup",headers: {"Content-Type": "application/json"}, body: json.encode({
        "username": user.text,
        "email": email.text,
        "password": pass.text,
        "roles": [
          "user"
        ]
      }));

      var datauser = json.decode(response.body);
      print(datauser);
      if(datauser.length==0){
        setState(() {
              msg="Registration Failed";
            });
      }else{
        if(datauser['message']=='User was registered successfully!'){
          Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
        }else if(datauser['message']=='Failed! Username is already in use!'){
          usernameExist(context);
          // Navigator.pushReplacementNamed(context, '/MemberPage');
        }else if(datauser['message']=='Failed! Email is already in use!'){
          emailExist(context);
        }

        setState(() {
              userId= datauser['userId'];
            });

      }
    } catch (err) {
      serverError(context);
    }

    // return datauser;
  }

  emptyField(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Empty Field"),
      content: Text("Please fill in all the field."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  usernameExist(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Username already existed"),
      content: Text("Please choose another username."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  emailExist(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () { },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Email address already existed"),
      content: Text("Please choose another email address."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  passwordInput(){
    return pass;
  }
  emailInput(){
    return email;
  }
  usernameInput(){
    return user;
  }
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, {bool isPassword = false, isUsername = false, isEmail = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              controller: (isPassword)?passwordInput():(isUsername)? usernameInput(): emailInput(),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {

    return InkWell(
      onTap: () {
        checkTextFieldEmptyOrNot();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xff00e676), Color(0xff00c853)])),
        child: Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _signupAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(
                  color: Color(0xff00c853),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'N',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xff00c853),
          ),
          children: [
            TextSpan(
              text: 'i',
              style: TextStyle(color: Color(0xff00c853), fontSize: 30),
            ),
            TextSpan(
              text: 'Ne 2.0',
              style: TextStyle(color: Color(0xff00c853), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username", isUsername: true),
        _entryField("Email id", isEmail: true),
        _entryField("Password", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          height: MediaQuery.of(context).size.height,
          child:Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _signupAccountLabel(),
              ),
              Positioned(top: 40, left: 0, child: _backButton()),
              Positioned(
                  top: -MediaQuery.of(context).size.height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer())
            ],
          ),
        )
      )
    );
  }
}
