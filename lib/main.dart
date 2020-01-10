import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loginscreen/Data/constants.dart';
import 'package:loginscreen/widgets/custom_button.dart';

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
  Pattern passPattern = r'^[A-Za-z]+.*[0-9]+$';
  RegExp passRegex;
  TextEditingController email = TextEditingController();

  TextEditingController pass = TextEditingController();

  final _signUpForm = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    passRegex = new RegExp(passPattern);
    onTap() {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          if (!value.contains('@') || !value.contains('.com')) {
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
            )
          ],
        ),
      ),
    );
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
