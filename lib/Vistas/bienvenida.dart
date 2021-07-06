import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/login.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum _ColorTween { color1, color2 }

class Animacion extends StatefulWidget {
  @override
  _AnimacionView createState() => _AnimacionView();
}

class _AnimacionView extends State<Animacion> {
  String url;
  int id_cliente = 0;
  String token_t;
  bool accedio = false;
  @override
  Widget build(BuildContext context) {
    if (!accedio) _returnValue(context).toString();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: AnimatedBackground()),
          onBottom(
            AnimatedWave(
              height: 180,
              speed: 1.0,
            ),
          ),
          onBottom(
            AnimatedWave(
              height: 120,
              speed: 0.9,
              offset: pi,
            ),
          ),
          onBottom(
            AnimatedWave(
              height: 220,
              speed: 1.2,
              offset: pi / 2,
            ),
          ),
          Positioned.fill(
            child: new Center(
              child: accedio
                  ? Container(
                      width: 250,
                      height: 100,
                      child: Image.asset(
                        'images/logo.png',
                      ),
                    )
                  : PlayAnimation<double>(
                      tween: 0.0.tweenTo(250.0),
                      duration: 1.5.seconds,
                      curve: Curves.easeOut,
                      builder: (context, child, value) {
                        return Container(
                          width: value,
                          height: value,
                          child: Image.asset(
                            'images/logo.png',
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );

  Future<String> _returnValue(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString("token");
    print("hola mundo");
    print(token);
    if (token != null) {
      Timer(Duration(seconds: 2), () {
        _showSecondToken(context, token);
      });
    } else {
      Timer(Duration(seconds: 2), () {
        if (!accedio) {
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              alignment: Alignment.bottomCenter,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 1000),
              reverseDuration: Duration(milliseconds: 1000),
              type: PageTransitionType.rightToLeftJoined,
              child: LoginForm(),
              childCurrent: new Container(),
            ),
            (Route<dynamic> route) => false,
          );
        }
        accedio = true;
        /*print("hola mundo");
        Navigator.pushReplacementNamed(
          context,
          '/',
          arguments: Welcome(
            id_cliente: id_cliente,
          ),
        );*/
      });
    }
    return token;
  }

  void cambiar_estado() {}

  void timeOutCallBack() {}

  void _showSecondToken(BuildContext context, token) {
    url = "https://sistema.mrcorporativo.com/api/getUsuarioToken/$token";
    _getListado(context);
  }

  _saveValue(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(token);
    await prefs.setString('token', token);
  }

  Future<dynamic> _getListado(BuildContext context) async {
    try {
      final respuesta = await http.get(Uri.parse(url));

      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";
        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          data.forEach((e) {
            print(e['id_cliente']);
            id_cliente = e['id_cliente'];
            token_t = e['remember_token'];
          });
          _saveValue(token_t);
          _login(id_cliente, context);
          return jsonDecode(respuesta.body);
        } else {
          Timer(Duration(seconds: 4), () {
            if (!accedio) {
              Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                  alignment: Alignment.bottomCenter,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 1000),
                  reverseDuration: Duration(milliseconds: 1000),
                  type: PageTransitionType.rightToLeftJoined,
                  child: LoginForm(),
                  childCurrent: new Container(),
                ),
                (Route<dynamic> route) => false,
              );
            }
            accedio = true;
          });
          return null;
        }
      } else {
        print("Error con la respusta");
      }
    } catch (e) {
      print("ERROR");
      print(e);
      /*EasyLoading.instance
        ..displayDuration = const Duration(milliseconds: 2000)
        ..indicatorType = EasyLoadingIndicatorType.fadingCircle
        ..loadingStyle = EasyLoadingStyle.dark
        ..indicatorSize = 45.0
        ..radius = 10.0
        ..progressColor = Colors.white
        ..backgroundColor = Colors.red[900]
        ..indicatorColor = Colors.white
        ..textColor = Colors.white
        ..maskColor = Colors.black.withOpacity(0.88)
        ..userInteractions = false
        ..dismissOnTap = true;
      EasyLoading.dismiss();
      EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
      EasyLoading.showError(
        'EJEMPLO DE MENSAJE',
        maskType: EasyLoadingMaskType.custom,
      );*/
      return null;
    }
  }

  void _login(id_cliente, context) {
    EasyLoading.dismiss();
    print("id_cliente");
    print(id_cliente);

    if (!accedio) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          alignment: Alignment.bottomCenter,
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 1000),
          reverseDuration: Duration(milliseconds: 1000),
          type: PageTransitionType.rightToLeftJoined,
          child: new Welcome(),
          childCurrent: new Container(),
          settings: RouteSettings(
            arguments: Welcome(
              id_cliente: id_cliente,
            ),
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
    accedio = true;
  }
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: LoopAnimation<double>(
            duration: (5000 / speed).round().milliseconds,
            tween: 0.0.tweenTo(2 * pi),
            builder: (context, child, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_ColorTween>()
      ..add(
        _ColorTween.color1,
        Color(0xff092E74).tweenTo(Colors.lightBlue.shade900),
        3.seconds,
      )
      ..add(
        _ColorTween.color2,
        Color(0xff092E74).tweenTo(Colors.blue.shade600),
        3.seconds,
      );

    return MirrorAnimation<MultiTweenValues<_ColorTween>>(
      tween: tween,
      duration: tween.duration,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                value.get<Color>(_ColorTween.color1),
                value.get<Color>(_ColorTween.color2)
              ])),
        );
      },
    );
  }
}

class SecondPage extends StatelessWidget {
  /// Page Title
  final String title;

  /// second page constructor
  const SecondPage({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final SecondPage args = ModalRoute.of(context).settings.arguments;
    print(args);
    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Second Page'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    duration: Duration(milliseconds: 300),
                    reverseDuration: Duration(milliseconds: 300),
                    type: PageTransitionType.topToBottom,
                    child: ThirdPage(),
                  ),
                );
              },
              child: Text('Go Third Page'),
            )
          ],
        ),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  /// Page Title
  final String title;

  /// second page constructor
  const ThirdPage({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Transition Plugin"),
      ),
      body: Center(
        child: Text('ThirdPage Page'),
      ),
    );
  }
}
