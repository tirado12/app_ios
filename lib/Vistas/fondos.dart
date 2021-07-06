import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/counter.dart';
import 'package:flutter_app/Vistas/login.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Fondos extends StatefulWidget {
  @override
  _FondosView createState() => _FondosView();
  int id_cliente;
  int anio;
  int clave;
  Fondos({
    this.id_cliente,
    this.anio,
    this.clave,
  });
}

class _FondosView extends State<Fondos> {
  String nombre_municipio;
  String email;
  String logo;
  List<double> monto_comprometido;
  List<double> monto_proyectado;
  List<String> nombre_corto;
  int id_cliente;
  int anio;
  String direccion;
  String rfc;
  String nombre_distrito;
  String anio_inicio;
  String anio_fin;
  bool entro = false;
  String url;
  int clave_municipio;
  bool inicio = false;
  List<Widget> send = [];
  List<Widget> fondos = [];

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    _returnValue(context);
    final Fondos args = ModalRoute.of(context).settings.arguments;
    anio = args.anio;
    id_cliente = args.id_cliente;
    clave_municipio = args.clave;
    if (inicio) {
      _options();
    }
    if (send.isEmpty) {
      _getListado(context);
      inicio = true;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
          centerTitle: true,
          title: Text("FUENTES DE FINANCIAMIENTO"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/Fondo06.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: false,
            controller: _refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => send[i],
              itemCount: send.length,
            ),
          ),
        ),
        bottomSheet: _menuInferior(context),
      ),
    );
  }

  Widget _menuInferior(BuildContext context) {
    return CurvedNavigationBar(
      key: GlobalKey(),
      index: 2,
      height: 50.0,
      items: <Widget>[
        Icon(
          CupertinoIcons.house,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          CupertinoIcons.calendar,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          CupertinoIcons.money_dollar,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          CupertinoIcons.square_arrow_left,
          size: 30,
          color: Colors.white,
        ),
      ],
      color: Color.fromRGBO(9, 46, 116, 1.0),
      buttonBackgroundColor: Color.fromRGBO(9, 46, 116, 1.0),
      backgroundColor: Colors.transparent,
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: Duration(milliseconds: 600),
      onTap: (i) {
        if (i == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/inicio', (Route<dynamic> route) => false,
              arguments: Welcome(
                id_cliente: id_cliente,
              ));
        }
        if (i == 1) {
          Navigator.pushNamed(
            context,
            '/anio',
            arguments: Anio(
              anio: anio,
              id_cliente: id_cliente,
              clave: clave_municipio,
            ),
          );
        }
      },
      letIndexChange: (index) {
        if (index == 3) {
          _showAlertDialog();
          return false;
        }
        return true;
      },
    );
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (buildcontext) {
        return AlertDialog(
          title: Text(
            "¿Está seguro de que desea salir?",
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: Color.fromRGBO(9, 46, 116, 1.0),
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text(
                "ACEPTAR",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              color: Colors.transparent,
              elevation: 0,
              highlightColor: Colors.transparent,
              highlightElevation: 0,
              onPressed: () {
                Navigator.of(context).pop();
                _saveValue(null);
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
              },
            ),
            RaisedButton(
              child: Text(
                "CERRAR",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              color: Colors.transparent,
              elevation: 0,
              highlightColor: Colors.transparent,
              highlightElevation: 0,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  /*Widget _menuInferior(BuildContext context) {
    return ConvexAppBar(
      backgroundColor: Color.fromRGBO(9, 46, 116, 1.0),
      style: TabStyle.react,
      disableDefaultTabController: false,
      items: [
        TabItem(
          icon: CupertinoIcons.house,
          title: 'Inio',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Icon(
              CupertinoIcons.house,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        TabItem(
          icon: CupertinoIcons.calendar,
          title: 'Ejercicio $anio',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.calendar,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        TabItem(
          icon: CupertinoIcons.money_dollar,
          title: 'Fuentes',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.money_dollar,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        TabItem(
          icon: CupertinoIcons.square_arrow_left,
          title: 'Cerrar Sesión ',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.square_arrow_left,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],

      initialActiveIndex: 2, //optional, default as 0
      onTap: (int i) {
        if (i == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/inicio', (Route<dynamic> route) => false,
              arguments: Welcome(
                id_cliente: id_cliente,
              ));
        }
        if (i == 1) {
          print("hola mundo");
          Navigator.pushNamed(
            context,
            '/anio',
            arguments: Anio(
              anio: anio,
              id_cliente: id_cliente,
              clave: clave_municipio,
            ),
          );
        }
        if (i == 3) {
          _saveValue(null);
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
      },
    );
  }*/

  void showHome(BuildContext context) {
    Navigator.pop(context);
  }

  void _options() {
    send.clear();
    send.add(
      SizedBox(
        height: 20,
      ),
    );
    send.add(
      Container(
        child: Column(
          children: fondos,
        ),
      ),
    );
    send.add(
      SizedBox(
        height: 70,
      ),
    );
    /*send.add(
      Card(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: new Text(
                "ramo",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: new Text(
                "Recibido:",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: new Text(
                "\u0024 20",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 40.0,
                animation: true,
                animationDuration: 1000,
                percent: 20 * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "20%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 4.5,
              ),
            ),
          ],
        ),
      ),
    );*/
    /*send.add(
      Container(
        width: 130.0,
        height: 130.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          image: new DecorationImage(
            fit: BoxFit.contain,
            image: new NetworkImage(logo),
          ),
        ),
      ),
    );
    send.add(
      SizedBox(
        height: 40,
      ),
    );
    send.add(
      Text(
        "H. Ayuntamiento Constitucional de",
        style: TextStyle(
          color: Color.fromRGBO(9, 46, 116, 1.0),
          fontWeight: FontWeight.w300,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
    send.add(
      Text(
        nombre_municipio,
        style: TextStyle(
          color: Color.fromRGBO(9, 46, 116, 1.0),
          fontWeight: FontWeight.w500,
          fontSize: 25,
        ),
        textAlign: TextAlign.center,
      ),
    );
    send.add(
      Text(
        "$nombre_distrito, Oaxaca.",
        style: TextStyle(
          color: Color.fromRGBO(9, 46, 116, 1.0),
          fontWeight: FontWeight.w300,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
    send.add(
      SizedBox(
        height: 30,
      ),
    );
    send.add(
      Text(
        "RFC: $rfc",
        style: TextStyle(
          color: Color.fromRGBO(9, 46, 116, 1.0),
          fontWeight: FontWeight.w300,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
    send.add(
      SizedBox(
        height: 30,
      ),
    );
    send.add(
      Container(
        child: Text(
          "$direccion",
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w300,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        margin: const EdgeInsets.only(left: 50, right: 50),
      ),
    );
    send.add(
      SizedBox(
        height: 60,
      ),
    );

    send.add(
      Text(
        "EJERCICIO",
        style: TextStyle(
          color: Color.fromRGBO(9, 46, 116, 1.0),
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
    send.add(
      SizedBox(
        height: 20,
      ),
    );*/
  }

  Widget cards(
    BuildContext context,
    ramo,
    proyectado,
    comprometido,
    pendiente,
    porcentaje_comprometido,
    porcentaje_pendiente,
  ) {
    int p_c = porcentaje_comprometido.toInt();
    int p_p = porcentaje_pendiente.toInt();
    return Card(
      // RoundedRectangleBorder para proporcionarle esquinas circulares al Card

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: Color.fromRGBO(9, 46, 116, 1.0),
        ),
      ),
      // margen para el Card
      margin: EdgeInsets.only(
        left: 30,
        right: 30,
        bottom: 10,
        top: 10,
      ),
      // La sombra que tiene el Card aumentará
      color: Colors.transparent,
      elevation: 0,

      //Colocamos una fila en dentro del card
      child: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: new Text(
                ramo,
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: new Text(
                "Recibido:",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: new Text(
                "\u0024 $proyectado",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CircularPercentIndicator(
                    radius: 80.0,
                    animation: true,
                    animationDuration: 1000,
                    percent: porcentaje_comprometido * 0.01,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Text(
                      "$p_c%",
                      style: TextStyle(
                        color: Color.fromRGBO(9, 46, 116, 1.0),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                    progressColor: Colors.blue,
                    backgroundColor: Colors.grey[350],
                    lineWidth: 7,
                    footer: new Container(
                      margin: EdgeInsets.only(top: 10, bottom: 20),
                      child: Column(
                        children: [
                          Text(
                            "Comprometido:",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0),
                          ),
                          Text(
                            "$comprometido",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CircularPercentIndicator(
                    radius: 80.0,
                    animation: true,
                    animationDuration: 1000,
                    percent: porcentaje_pendiente * 0.01,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Text(
                      "$p_p%",
                      style: TextStyle(
                        color: Color.fromRGBO(9, 46, 116, 1.0),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                    progressColor: Colors.blue,
                    backgroundColor: Colors.grey[350],
                    lineWidth: 7,
                    footer: new Container(
                      margin: EdgeInsets.only(top: 10, bottom: 20),
                      child: Column(
                        children: [
                          Text(
                            "Pendiente:",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0),
                          ),
                          Text(
                            "$pendiente",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            /*
             Text(
                ramo.toUpperCase(),
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(children: [
                        Text(
                          "Recibido:",
                          style: TextStyle(
                              color: Color.fromRGBO(9, 46, 116, 1.0),
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                      ]),
                      Row(children: [
                        Text("\u0024 $proyectado",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0)),
                      ]),
                    ],
                  )
                ],
              ), //titulo y barra contratado

              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text("Contratado:\n\u0024  $comprometido",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0)),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                //FILA DE BARRA
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearPercentIndicator(
                    width: 300.0,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: porcentaje_comprometido * 0.01,
                    center: Text("$porcentaje_comprometido%"),
                    progressColor: const Color.fromRGBO(0, 153, 51, 1.0),
                  ),
                ],
              ), //titulo y barra pendiente
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text("Pendiente:\n\u0024 $pendiente",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0)),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                //FILA DE BARRA
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearPercentIndicator(
                    width: 300.0,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: porcentaje_pendiente * 0.01,
                    center: Text("$porcentaje_pendiente%"),
                    progressColor: const Color.fromRGBO(0, 204, 255, 1.0),
                  ),
                ],
              ),
            ], */
          ],
        ),
      ),
    );
  }

  void _showSecondPage(BuildContext context) {
    _getListado(context);
  }

  List<Widget> listado(List<dynamic> info) {
    List<Widget> lista = [];
    info.forEach((elemento) {
      int elemento_cliente = elemento['id_cliente'];
      lista.add(Text("$elemento_cliente"));
    });
    return lista;
  }

  Future<dynamic> _getListado(BuildContext context) async {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = const Color.fromRGBO(9, 46, 116, 1.0)
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.88)
      ..userInteractions = false
      ..dismissOnTap = false;

    EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
    EasyLoading.show(
      status: 'CARGANDO',
      maskType: EasyLoadingMaskType.custom,
    );
    url =
        "http://sistema.mrcorporativo.com/api/getFuentesCliente/$id_cliente,$anio";
    send.clear();
    try {
      final respuesta = await http.get(Uri.parse(url));
      print(respuesta.body);
      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";
        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          data.forEach((e) {
            /*ramo, proyectado, comprometido, pendiente, porcentaje_comprometido, porcentaje_pendiente,*/
            String ramo = e['nombre_corto'];
            double comprometido =
                double.parse(e['monto_comprometido'].toString());
            double proyectado = double.parse(e['monto_proyectado'].toString());
            double pendiente = proyectado - comprometido;
            double porcentaje_comprometido = comprometido * 100 / proyectado;
            double porcentaje_pendiente = 100 - porcentaje_comprometido;
            fondos.add(cards(
              context,
              ramo,
              numberFormat(proyectado),
              numberFormat(comprometido),
              numberFormat(pendiente),
              int.parse(porcentaje_comprometido.toStringAsFixed(0)).toDouble(),
              int.parse(porcentaje_pendiente.toStringAsFixed(0)).toDouble(),
            ));
          });
          send.add(
            SizedBox(
              height: 20,
            ),
          );
          _onRefresh();
          _onLoading();
          return jsonDecode(respuesta.body);
        } else {
          return null;
        }
      } else {
        EasyLoading.dismiss();
        print("Error con la respusta");
      }
    } catch (e) {
      EasyLoading.instance
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
        'ERROR DE CONEXIÓN ',
        maskType: EasyLoadingMaskType.custom,
      );
    }
  }

  String numberFormat(double x) {
    List<String> parts = x.toString().split('.');
    RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');

    parts[0] = parts[0].replaceAll(re, ',');
    if (parts.length == 1) {
      parts.add('00');
    } else {
      parts[1] = parts[1].padRight(2, '0').substring(0, 2);
    }
    return parts.join('.');
  }

  _saveValue(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(token);
    await prefs.setString('token', token);
  }

  Future<String> _returnValue(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString("token");
    print(token);
    /*if (token != null) {
      Navigator.pushReplacementNamed(context, '/inicio',
          arguments: Welcome(
            id_cliente: 1,
          ));
    }*/
    return token;
  }
}


/*import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/login.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_app/Vistas/obra_publica.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Fondos extends StatefulWidget {
  @override
  _FondosView createState() => _FondosView();
  int id_cliente;
  int anio;
  int clave;
  Fondos({
    this.id_cliente,
    this.anio,
    this.clave,
  });
}

class _FondosView extends State<Fondos> {
  String nombre_municipio;
  String email;
  String logo;
  List<double> monto_comprometido;
  List<double> monto_proyectado;
  List<String> nombre_corto;
  int id_cliente;
  int anio;
  String direccion;
  String rfc;
  String nombre_distrito;
  String anio_inicio;
  String anio_fin;
  List<Widget> send = [];
  bool entro = false;
  String url;
  int clave_municipio;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
    print(logo);
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final Fondos args = ModalRoute.of(context).settings.arguments;
    anio = args.anio;
    id_cliente = args.id_cliente;
    clave_municipio = args.clave;
    if (send.isEmpty && !entro) {
      _getListado(context);
      entro = true;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
          centerTitle: true,
          title: Text("FUENTES DE FINANCIAMIENTO"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/Fondo06.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SmartRefresher(
            enablePullDown: false,
            enablePullUp: false,
            controller: _refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => send[i],
              itemCount: send.length,
            ),
          ),
        ),
        bottomNavigationBar: _menuInferior(context),
      ),
    );
  }

  void showHome(BuildContext context) {
    Navigator.pop(context);
  }

  Widget _contenedor(BuildContext context) {
    return Container(
      child: Scrollbar(
        child: ListView(children: listado(context)),
      ),
    );
  }

  Widget _menuInferior(BuildContext context) {
    return ConvexAppBar(
      backgroundColor: Color.fromRGBO(9, 46, 116, 1.0),
      style: TabStyle.react,
      disableDefaultTabController: false,
      items: [
        TabItem(
          icon: CupertinoIcons.house,
          title: 'Inio',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Icon(
              CupertinoIcons.house,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        TabItem(
          icon: CupertinoIcons.calendar,
          title: 'Ejercicio $anio',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.calendar,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        TabItem(
          icon: CupertinoIcons.square_arrow_left,
          title: 'Cerrar Sesión ',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.square_arrow_left,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],

      initialActiveIndex: 1, //optional, default as 0
      onTap: (int i) {
        if (i == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/inicio', (Route<dynamic> route) => false,
              arguments: Welcome(
                id_cliente: id_cliente,
              ));
        }
        if (i == 1) {
          Navigator.pushNamed(
            context,
            '/anio',
            arguments: Anio(
              anio: anio,
              id_cliente: id_cliente,
              clave: clave_municipio,
            ),
          );
        }
        if (i == 2) {
          _saveValue(null);
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
      },
    );
  }

  /*Widget _menuInferior(BuildContext context) {
    final Fondos args = ModalRoute.of(context).settings.arguments;
    return BottomNavigationBar(
      currentIndex: 0, // this will be set when a new tab is tapped

      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        if (index == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/inicio', (Route<dynamic> route) => false,
              arguments: Welcome(
                id_cliente: id_cliente,
              ));
        }

        if (index == 1) {
          Navigator.pushNamed(context, '/anio',
              arguments: Anio(
                anio: anio,
                id_cliente: id_cliente,
                clave: clave_municipio,
              ));
        }
        if (index == 3) {
          Navigator.pushNamed(context, '/obras',
              arguments: Obras(
                anio: anio,
                id_cliente: id_cliente,
                clave: clave_municipio,
              ));
        }
        if (index == 4) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (Route<dynamic> route) => false,
          );
          _saveValue(null);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: new Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.calendar_today),
          label: 'Año $anio',
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.attach_money),
          label: 'Fondos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.construction),
          label: 'Obra Pública',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Salir',
        ),
      ],
    );
  }*/

  Widget cards(
    BuildContext context,
    ramo,
    proyectado,
    comprometido,
    pendiente,
    porcentaje_comprometido,
    porcentaje_pendiente,
  ) {
    /*porcentaje_pendiente =
        int.parse(porcentaje_pendiente.toStringAsFixed(0)).toDouble();
    porcentaje_comprometido =
        int.parse(porcentaje_comprometido.toStringAsFixed(0)).toDouble();
    print('cards');*/
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
        ), //bordes redondeados
        margin: EdgeInsets.all(20),
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ramo.toUpperCase(),
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(children: [
                        Text(
                          "Recibido:",
                          style: TextStyle(
                              color: Color.fromRGBO(9, 46, 116, 1.0),
                              fontWeight: FontWeight.w400,
                              fontSize: 20.0),
                        ),
                      ]),
                      Row(children: [
                        Text("\u0024 $proyectado",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0)),
                      ]),
                    ],
                  )
                ],
              ), //titulo y barra contratado

              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text("Contratado:\n\u0024  $comprometido",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0)),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                //FILA DE BARRA
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearPercentIndicator(
                    width: 300.0,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: porcentaje_comprometido * 0.01,
                    center: Text("$porcentaje_comprometido%"),
                    progressColor: const Color.fromRGBO(0, 153, 51, 1.0),
                  ),
                ],
              ), //titulo y barra pendiente
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text("Pendiente:\n\u0024 $pendiente",
                            style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w300,
                                fontSize: 16.0)),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                //FILA DE BARRA
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearPercentIndicator(
                    width: 300.0,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: porcentaje_pendiente * 0.01,
                    center: Text("$porcentaje_pendiente%"),
                    progressColor: const Color.fromRGBO(0, 204, 255, 1.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> listado(BuildContext context) {
    List<Widget> lista = [];
    lista.add(
      Container(
        margin: const EdgeInsets.only(
          top: 30,
        ),
      ),
    );
    double pendiente;
    double p_c;
    double p_p;
    for (var i = 0; i < nombre_corto.length; i++) {
      pendiente = monto_proyectado[i] - monto_comprometido[i];
      p_c = monto_comprometido[i] * 100 / monto_proyectado[i];
      p_p = 100 - p_c;
      lista.add(cards(
        context,
        nombre_corto[i],
        numberFormat(monto_proyectado[i]),
        numberFormat(monto_comprometido[i]),
        numberFormat(pendiente),
        p_c,
        p_p,
      ));
    }
    return lista;
  }

  String numberFormat(double x) {
    List<String> parts = x.toString().split('.');
    RegExp re = RegExp(r'\B(?=(\d{3})+(?!\d))');

    parts[0] = parts[0].replaceAll(re, ',');
    if (parts.length == 1) {
      parts.add('00');
    } else {
      parts[1] = parts[1].padRight(2, '0').substring(0, 2);
    }
    return parts.join('.');
  }

  Future<dynamic> _getListado(BuildContext context) async {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = const Color.fromRGBO(9, 46, 116, 1.0)
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.88)
      ..userInteractions = false
      ..dismissOnTap = false;

    EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
    EasyLoading.show(
      status: 'CARGANDO',
      maskType: EasyLoadingMaskType.custom,
    );
    url =
        "http://sistema.mrcorporativo.com/api/getFuentesCliente/$id_cliente,$anio";
    send.clear();
    try {
      final respuesta = await http.get(Uri.parse(url));
      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";
        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          data.forEach((e) {
            /*ramo, proyectado, comprometido, pendiente, porcentaje_comprometido, porcentaje_pendiente,*/
            String ramo = e['nombre_corto'];
            double comprometido =
                double.parse(e['monto_comprometido'].toString());
            double proyectado = double.parse(e['monto_proyectado'].toString());
            double pendiente = proyectado - comprometido;
            double porcentaje_comprometido = comprometido * 100 / proyectado;
            double porcentaje_pendiente = 100 - porcentaje_comprometido;
            send.add(cards(
              context,
              ramo,
              numberFormat(proyectado),
              numberFormat(comprometido),
              numberFormat(pendiente),
              int.parse(porcentaje_comprometido.toStringAsFixed(0)).toDouble(),
              int.parse(porcentaje_pendiente.toStringAsFixed(0)).toDouble(),
            ));
          });
          send.add(
            SizedBox(
              height: 20,
            ),
          );
          _onRefresh();
          _onLoading();
          return jsonDecode(respuesta.body);
        } else {
          return null;
        }
      } else {
        EasyLoading.dismiss();
        print("Error con la respusta");
      }
    } catch (e) {
      EasyLoading.instance
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
        'ERROR DE CONEXIÓN ',
        maskType: EasyLoadingMaskType.custom,
      );
    }
  }

  _saveValue(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(token);
    await prefs.setString('token', token);
  }
}
*/