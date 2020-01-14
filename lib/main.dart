import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loginscreen/Data/constants.dart';
import 'package:loginscreen/widgets/custom_button.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
void main(List<String> args) {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: LoginScreen(),
        key: scaffoldKey,
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with Functions {
  final dbref = Firestore.instance;
  final _signUpForm = GlobalKey<FormState>();
  final facebookLogin = FacebookLogin();
  Pattern passPattern = r'^[A-Za-z]+.*[0-9]+$';
  RegExp passRegex;
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool _isLoggedIn = false;
  bool _isLoading = false;
  Map userProfile;
  Function facebookLogOutFunction;
  @override
  void initState() {
    super.initState();
    passRegex = new RegExp(passPattern);
    facebookLogOutFunction = () {
      Navigator.of(context).pop();
      facebookLogin.logOut();
      setState(() {
        _isLoggedIn = false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
            child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Image(
                image: AssetImage('images/login_image.png'),
                height: 150,
                width: 150,
              )),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Center(
                  child: Form(
                    key: _signUpForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextFormField(
                          controller: email,
                          validator: (value) {
                            value = value.trim();
                            if (value.isEmpty) return 'Input email';
                            if (!value.contains('@') ||
                                !value.contains('.com')) {
                              return 'Input a valid email address';
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(
                              Icons.person,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: pass,
                          obscureText: true,
                          validator: (value) {
                            value = value.trim();
                            if (value.isEmpty) return 'Input password';
                            if (!passRegex.hasMatch(value)) {
                              return "Start with alphabet and end with number.";
                            }
                          },
                          decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.vpn_key,
                              )),
                        ),
                        /* RaisedButton(
                            onPressed: () async {
                              if (this._signUpForm.currentState.validate()) {
                                if (await auth(email.text, pass.text)) {
                                  scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text('Signed in Sucessfully!'),
                                  ));
                                } else {
                                  scaffoldKey.currentState.showSnackBar(SnackBar(
                                    content: Text('Sign in Failed!'),
                                  ));
                                }
                              }
                              pass.clear();
                              email.clear();
                            },
                            child: Text('Sign In'),
                          ) */
                        CustomButton(
                          ontap: () async {
                            if (this._signUpForm.currentState.validate()) {
                              if (await auth(email.text, pass.text)) {
                                scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text('Signed in Sucessfully!'),
                                ));
                              } else {
                                scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text('Sign in Failed!'),
                                ));
                              }
                            }
                            pass.clear();
                            email.clear();
                          },
                          buttonType: Constants.flatButton,
                          text: 'Sign In',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SignInButton(
                    Buttons.Facebook,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      _loginWithFB();
                    },
                  ),
                  SignInButton(
                    Buttons.Google,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        )),
        _isLoading
            ? Container(
                color: Colors.black87,
                height: double.infinity,
                width: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                height: 0,
                width: 0,
              )
      ],
    );
  }

  _loginWithFB() async {
    setState(() {
      _isLoading = !_isLoading;
    });
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = JSON.jsonDecode(graphResponse.body);
        print(profile);
        setState(() {
          userProfile = profile;
          _isLoggedIn = true;
          _isLoading = !_isLoading;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FacebookProfile(
                name: profile['name'],
                email: profile['email'],
                facebookLoginObj: facebookLogin,
                url: profile['picture']['data']['url'],
                facebookLogOutFunction: facebookLogOutFunction,
              ),
            ),
          );
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          _isLoggedIn = false;
          _isLoading = !_isLoading;
        });
        break;
      case FacebookLoginStatus.error:
        setState(() {
          _isLoggedIn = false;
          _isLoading = !_isLoading;
        });
        break;
    }
  }

  auth(paramUser, paramPass) async {
    bool check = false;
    QuerySnapshot snapshot = await dbref.collection("Users").getDocuments();
    snapshot.documents.forEach((f) {
      if (f.data['user'] == paramUser && f.data['password'] == paramPass) {
        check = true;
      }
    });
    return check;
  }
}

class FacebookProfile extends StatelessWidget {
  final name;
  final email;
  final url;
  final facebookLoginObj;
  final facebookLogOutFunction;
  static const placeholderimg =
      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png';
  FacebookProfile({
    Key key,
    this.name,
    this.email,
    this.url = placeholderimg,
    this.facebookLoginObj,
    this.facebookLogOutFunction,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    child: Image(
                      image: NetworkImage(url),
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    email,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Container(
              child: CustomButton(
                text: 'Log Out',
                ontap: facebookLogOutFunction,
                buttonType: Constants.raisedButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
