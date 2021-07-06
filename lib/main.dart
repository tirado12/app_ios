import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/bienvenida.dart';
import 'package:flutter_app/Vistas/download.dart';
import 'package:flutter_app/Vistas/notify.dart';
import 'package:flutter_app/Vistas/obra_admin.dart';
import 'package:flutter_app/Vistas/obra_contrato.dart';
import 'package:flutter_app/Vistas/plataformas.dart';
import 'package:flutter_app/Vistas/prodim.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/services.dart';

import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

//Codigo correcto
import 'Vistas/login.dart';
import 'Vistas/principal.dart';
import 'Vistas/obra_publica.dart';
import 'Vistas/fondos.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

const debug = true;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);
  runApp(MyApp());
  const SystemUiOverlayStyle light = SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF000000),
    systemNavigationBarDividerColor: const Color.fromRGBO(9, 46, 116, 1.0),
    statusBarColor: const Color.fromRGBO(9, 46, 116, 1.0),
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  SystemChrome.setSystemUIOverlayStyle(light);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CMR APP',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => Animacion(),
        '/': (context) => LoginForm(),
        '/inicio': (context) => Welcome(),
        '/obras': (context) => Obras(
              key: key,
              anio: 2020,
              id_cliente: 1,
              platform: Theme.of(context).platform,
            ),
        '/fondos': (context) => Fondos(),
        '/anio': (context) => Anio(),
        '/admin': (context) => Obras_admin(
              key: key,
              anio: 2020,
              id_cliente: 1,
              platform: Theme.of(context).platform,
            ),
        '/contrato': (context) => Obras_contrato(
              key: key,
              anio: 2020,
              id_cliente: 1,
              platform: Theme.of(context).platform,
            ),
        '/counter': (context) => Notify(),
        '/prodim': (context) => Prodim(),
        '/plataformas': (context) => Plataformas(
              key: key,
              anio: 2020,
              id_cliente: 1,
              platform: Theme.of(context).platform,
            ),
        '/MyHome': (context) =>
            MyHomePage(key, "hola", Theme.of(context).platform),
      },
      builder: EasyLoading.init(
        builder: (context, child) {
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: 0.85),
          );
        },
      ),
    );
  }
}

/*import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';





void main() async {
  runApp(AnimBgDemoPage());
}*/

/*import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void main() => runApp(MyApp());

///Example App
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/second':
            return PageTransition(
              child: SecondPage(),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: Duration(seconds: 3),
            );
            break;
          default:
            return null;
        }
      },
    );
  }
}

/// Example page
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Page Transition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Fade Second Page - Default'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Left To Right Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRight,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Left To Right with Fade Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.leftToRightWithFade,
                    alignment: Alignment.topCenter,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Right To Left Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Right To Left with Fade Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Top to Bottom Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.topToBottom,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Bottom to Top Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.bottomToTop,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Scale Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    curve: Curves.linear,
                    type: PageTransitionType.scale,
                    alignment: Alignment.topCenter,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Rotate Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    curve: Curves.bounceOut,
                    type: PageTransitionType.rotate,
                    alignment: Alignment.topCenter,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Size Transition Second Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    alignment: Alignment.bottomCenter,
                    curve: Curves.bounceOut,
                    type: PageTransitionType.size,
                    child: SecondPage(),
                  ),
                );
              },
            ),
            ElevatedButton(
              child: Text('Right to Left Joined'),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 600),
                        reverseDuration: Duration(milliseconds: 600),
                        type: PageTransitionType.rightToLeftJoined,
                        child: SecondPage(),
                        childCurrent: this));
              },
            ),
            ElevatedButton(
              child: Text('Left to Right Joined'),
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                      alignment: Alignment.bottomCenter,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 600),
                      reverseDuration: Duration(milliseconds: 600),
                      type: PageTransitionType.leftToRightJoined,
                      child: SecondPage(),
                      childCurrent: this),
                );
              },
            ),
            ElevatedButton(
              child: Text('PushNamed With arguments'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/second",
                  arguments: "with Arguments",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

///Example second page
class SecondPage extends StatelessWidget {
  /// Page Title
  final String title;

  /// second page constructor
  const SecondPage({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(args ?? "Page Transition Plugin"),
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

/// third page
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
*/
