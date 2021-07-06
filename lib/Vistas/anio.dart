import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/fondos.dart';
import 'package:flutter_app/Vistas/login.dart';
import 'package:flutter_app/Vistas/obra_publica.dart';
import 'package:flutter_app/Vistas/plataformas.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_app/Vistas/prodim.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Anio extends StatefulWidget {
  int anio;
  int id_cliente;
  int clave;
  _AnioView createState() => _AnioView();

  Anio({
    this.anio,
    this.id_cliente,
    this.clave,
  });
}

class _AnioView extends State<Anio> {
  int anio;
  int id_cliente;
  String nombre_municipio = "Ejemplo 1";
  String nombre_distrito = "Ejemplo 1";
  String email = "Ejemplo 1";
  String direccion = "Ejemplo q";
  String rfc = "Ejemplo 1";
  int anio_inicio = 2020;
  int anio_fin = 2022;
  bool inicio = false;
  String texto = "";
  String logo =
      'https://raw.githubusercontent.com/tirado12/CMRInicio/master/logo_rojas.png';
  String prodim = '';
  Color c = const Color(0xFF42A5F5);
  String url;
  final formkey = GlobalKey<FormState>();
  bool prodimdf = false;
  bool gi = false;
  int clave_municipio;
  List<int> list_id_obras = [];
  List<String> list_nombre_obras = [];
  int currentIndex = 2;
  GlobalKey _bottomNavigationKey = GlobalKey();

  List<Widget> send = [];

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
    final Anio args = ModalRoute.of(context).settings.arguments;
    id_cliente = args.id_cliente;
    anio = args.anio;
    clave_municipio = args.clave;
    _returnValue(context);
    if (inicio) {
      _options();
    }
    if (send.isEmpty) {
      _getListado();
      inicio = true;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
          centerTitle: true,
          title: Text("EJERCICIO $anio"),
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

  Widget _menuInferior(BuildContext context) {
    return CurvedNavigationBar(
      key: _bottomNavigationKey,
      index: 1,
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
      },
      letIndexChange: (index) {
        if (index == 2) {
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
        });
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
  }*/

  void showHome(BuildContext context) {
    Navigator.pop(context);
  }

  void _options() {
    send.clear();

    send.add(
      Padding(
        padding: EdgeInsets.all(20.0),
      ),
    );
    send.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              height: 100,
              width: 260,
              child: ElevatedButton(
                child: Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on_rounded,
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          size: 30,
                        ),
                        Text(
                          "Fuentes de Financiamiento",
                          style: TextStyle(
                            color: Color.fromRGBO(9, 46, 116, 1.0),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  /*Navigator.pushNamed(context, '/fondos');*/

                  Navigator.pushNamed(context, '/fondos',
                      arguments: Fondos(
                        anio: anio,
                        id_cliente: id_cliente,
                        clave: clave_municipio,
                      ));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    //borde del boton
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    send.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              height: 100,
              width: 260,
              child: ElevatedButton(
                child: Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.construction,
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          size: 30,
                        ),
                        Text(
                          "Obra Pública",
                          style: TextStyle(
                            color: Color.fromRGBO(9, 46, 116, 1.0),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  print(clave_municipio);
                  Navigator.pushNamed(
                    context,
                    '/obras',
                    arguments: Obras(
                      anio: anio,
                      id_cliente: id_cliente,
                      clave: clave_municipio,
                      platform: Theme.of(context).platform,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    //borde del boton
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    /*if (prodimdf || gi) {
      send.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: SizedBox(
                height: 100,
                width: 260,
                child: ElevatedButton(
                  child: Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text(
                            texto,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  onPressed: () {
                    /*Navigator.pushNamed(context, '/fondos');*/

                    Navigator.pushNamed(context, '/prodim',
                        arguments: Prodim(
                          anio: anio,
                          id_cliente: id_cliente,
                          prodimb: prodimdf,
                          gib: gi,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(9, 46, 116, 1.0),
                    shape: RoundedRectangleBorder(
                      //borde del boton
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white),
                    ),
                    elevation: 8.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }*/
    send.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: SizedBox(
              height: 100,
              width: 260,
              child: ElevatedButton(
                child: Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.computer,
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          size: 30,
                        ),
                        Container(
                          child: Text(
                            'Plataformas Digitales',
                            style: TextStyle(
                              color: Color.fromRGBO(9, 46, 116, 1.0),
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  /*Navigator.pushNamed(context, '/fondos');*/

                  Navigator.pushNamed(context, '/plataformas',
                      arguments: Plataformas(
                        anio: anio,
                        id_cliente: id_cliente,
                        prodimb: prodimdf,
                        gib: gi,
                        clave: clave_municipio,
                        platform: Theme.of(context).platform,
                        id_obras_list: list_id_obras,
                        nombre_obras_list: list_nombre_obras,
                      ));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    //borde del boton
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSecondPage(BuildContext context) {
    _getListado();
  }

  List<Widget> listado(List<dynamic> info) {
    List<Widget> lista = [];
    info.forEach((elemento) {
      int elemento_cliente = elemento['id_cliente'];
      lista.add(Text("$elemento_cliente"));
    });
    return lista;
  }

  Future<dynamic> _getListado() async {
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
    url = "http://sistema.mrcorporativo.com/api/getProdim/$id_cliente,$anio";
    print(url);

    try {
      final respuesta = await http.get(Uri.parse(url));
      print(respuesta.body);
      if (respuesta.statusCode == 200) {
        print(respuesta.body);
        if (respuesta.body != "[]") {
          final data = json.decode(respuesta.body);
          data.forEach((e) {
            final prodim_1 = json.encode(e['prodim']);
            dynamic prodim_2 = json.decode(prodim_1);

            prodim_2.forEach((i) {
              if (i['gastos_indirectos'] == 1) {
                gi = true;
                texto = "Gastos Indirectos";
              }

              if (i['prodim'] == 1) {
                if (texto != "") {
                  texto = texto + "\n";
                }
                prodimdf = true;
                texto = texto + "PRODIMDF";
              }
            });
            final obras_1 = json.encode(e['obras']);
            dynamic obras_2 = json.decode(obras_1);

            obras_2.forEach((i) {
              print(i['id_obra']);
              list_id_obras.add(i['id_obra']);
              print(i['nombre_corto']);
              list_nombre_obras.add(i['nombre_corto']);
              print(i['nombre_corto']);
            });
            print(list_nombre_obras.length);
          });
          _onRefresh();
          _onLoading();
          return jsonDecode(respuesta.body);
        } else {
          EasyLoading.dismiss();
          return null;
        }
      } else {
        print("Error con la respusta");
        EasyLoading.dismiss();
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

  Future<String> _returnValue(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = await prefs.getString("token");
    return token;
  }

  void _fondos(
    BuildContext context,
    nombre_municipio,
    email,
    logo,
    monto_comprometido,
    monto_proyectado,
    nombre_corto,
    anio,
    id_cliente,
    direccion,
    rfc,
    nombre_distrito,
    anio_inicio,
    anio_fin,
  ) {
    print("datos correctos");
    if (email == null) {
      email = "Sin dato";
    }

    Navigator.pushReplacementNamed(context, '/fondos',
        arguments: Fondos(
          anio: anio,
          id_cliente: id_cliente,
        ));
  }
}
