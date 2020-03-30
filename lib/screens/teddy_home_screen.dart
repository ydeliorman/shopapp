import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/animation/signin_button.dart';
import 'package:shopapp/animation/teddy_controller.dart';
import 'package:shopapp/animation/tracking_text_input.dart';
import 'package:shopapp/models/http_exception.dart';
import 'package:shopapp/providers/auth.dart';

enum AuthMode { Signup, Login }

class TeddyHomePage extends StatefulWidget {
  const TeddyHomePage({
    Key key,
    @required TeddyController teddyController,
  })  : _teddyController = teddyController,
        super(key: key);

  final TeddyController _teddyController;

  @override
  _TeddyHomePageState createState() => _TeddyHomePageState();
}

class _TeddyHomePageState extends State<TeddyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occured'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).logIn(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already registered.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Your e-mail address is not valid.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is not strong enough.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = 'Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Color.fromRGBO(93, 142, 155, 1.0),
      body: Container(
          child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
              // Box decoration takes a gradient
              gradient: LinearGradient(
                // Where the linear gradient begins and ends
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                // Add one stop for each color. Stops should increase from 0 to 1
                stops: [0.0, 1.0],
                colors: [
                  Color.fromRGBO(170, 207, 211, 1.0),
                  Color.fromRGBO(93, 142, 155, 1.0),
                ],
              ),
            ),
          )),
          Positioned.fill(
            child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: 20.0, right: 20.0, top: devicePadding.top + 50.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          height: 200,
                          padding:
                              const EdgeInsets.only(left: 30.0, right: 30.0),
                          child: FlareActor(
                            "assets/Teddy.flr",
                            shouldClip: false,
                            alignment: Alignment.bottomCenter,
                            fit: BoxFit.contain,
                            controller: widget._teddyController,
                          )),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    TrackingTextInput(
                                      label: "Email",
                                      hint: "What's your email address?",
                                      onCaretMoved: (Offset caret) {
                                        widget._teddyController.lookAt(caret);
                                      },
                                      onSaved: (value) {
                                        _authData['email'] = value;
                                      },
                                    ),
                                    TrackingTextInput(
                                      label: "Password",
                                      hint: "Try 'bears'...",
                                      isObscured: true,
                                      onCaretMoved: (Offset caret) {
                                        widget._teddyController
                                            .coverEyes(caret != null);
                                        widget._teddyController.lookAt(null);
                                      },
                                      onTextChanged: (String value) {
                                        widget._teddyController
                                            .setPassword(value);
                                      },
                                      onSaved: (value) {
                                        _authData['password'] = value;
                                      },
                                    ),
                                    SigninButton(
                                        child: Text("Sign In",
                                            style: TextStyle(
                                                fontFamily: "RobotoMedium",
                                                fontSize: 16,
                                                color: Colors.white)),
                                        onPressed: () {
                                          _submit();
                                          widget._teddyController
                                              .submitPassword();
                                        })
                                  ],
                                )),
                          )),
                    ])),
          ),
        ],
      )),
    );
  }
}
