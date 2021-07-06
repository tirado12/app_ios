import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/obra_admin.dart';
import 'package:flutter_app/Vistas/obra_contrato.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getwidget/components/accordian/gf_accordian.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Prodim extends StatefulWidget {
  @override
  _ProdimView createState() => _ProdimView();
  int id_cliente;
  int anio;
  bool prodimb;
  bool gib;
  int clave;
  Prodim({
    this.id_cliente,
    this.anio,
    this.prodimb,
    this.gib,
    this.clave,
  });
}

class _ProdimView extends State<Prodim> {
  String fecha_integracion = '';
  String fecha_priorizacion = '';
  String fecha_adendum = '';
  String url;
  bool inicio = false;
  int id_cliente;
  int anio;
  List<Widget> lista_obras = [];
  List<Widget> send = [];
  int firma_electronica;
  int convenio;
  int validado;
  int revisado;
  bool prodim;
  bool gi;
  int clave_municipio;
  List<Widget> gastos = [];
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
    final Prodim args = ModalRoute.of(context).settings.arguments;
    id_cliente = args.id_cliente;
    anio = args.anio;
    prodim = args.prodimb;
    gi = args.gib;
    clave_municipio = args.clave;

    if (!lista_obras.isEmpty && inicio) {
      _options();
    }
    if (send.isEmpty && !inicio) {
      _getListado(context);
      inicio = true;
    }
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
            centerTitle: true,
            title: Text("PRODIMDF"),
          ),
          bottomNavigationBar: _menuInferior(context),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Fondo06.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: NestedScrollView(
              // Setting floatHeaderSlivers to true is required in order to float
              // the outer slivers over the inner scrollable.
              floatHeaderSlivers: false,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    toolbarHeight: 1,
                    title: const Text(''),
                    floating: false,
                    centerTitle: true,
                    forceElevated: innerBoxIsScrolled,
                    backgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
                  ),
                ];
              },
              body: SmartRefresher(
                enablePullDown: false,
                enablePullUp: false,
                controller: _refreshController,
                child: ListView.builder(
                  itemBuilder: (c, i) => send[i],
                  itemCount: send.length,
                ),
              ), //menu(context), //menu(context),
            ),
          )),
    );
  }

  void _options() {
    send.clear();
    send.add(SizedBox(
      height: 20,
    ));
    if (gi) {
      send.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "GASTOS INDIRECTOS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      send.add(SizedBox(
        height: 10,
      ));
      send.add(Container(
        child: Column(
          children: gastos,
        ),
      ));
      Divider(
        height: 20,
        thickness: 5,
        indent: 20,
        endIndent: 20,
      );
      send.add(SizedBox(
        height: 30,
      ));
    }
    if (!prodim) {
      send.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Text(
              "PRODIMDF",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      send.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Text(
              "Programa de Desarrollo Institucional Municipal y de las demarcaciones territoriales del Distrito Federal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      send.add(
        SizedBox(
          height: 20,
        ),
      );
      send.add(
        Container(
          child: GFAccordion(
            titleBorderRadius: BorderRadius.circular(6),
            margin: EdgeInsets.only(top: 10, bottom: 8, left: 10, right: 10),
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
            titleChild:
                cards_comprometido(context, 'Comprometido', firma_electronica),
            expandedTitleBackgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
            collapsedTitleBackgroundColor:
                const Color.fromRGBO(9, 46, 116, 1.0),
            contentBackgroundColor: const Color.fromRGBO(4, 124, 188, 1.0),
            contentChild: Container(
              child: Column(
                children: lista_obras,
              ),
            ),
            collapsedIcon: Icon(
              Icons.arrow_drop_down_outlined,
              color: Colors.white,
            ),
            expandedIcon: Icon(
              Icons.arrow_drop_up,
              color: Colors.white,
            ),
          ),
        ),
      );
      send.add(cards(context, 'Presentado', firma_electronica));

      send.add(cards(context, 'Revisado', revisado));

      send.add(cards(context, 'Aprobado', validado));

      send.add(cards(context, 'Firma de convenio', convenio));
    }
  }

//menu inferior
  Widget _menuInferior(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // this will be set when a new tab is tapped
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
        if (index == 2) {}
        if (index == 3) {
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
          icon: Icon(Icons.auto_stories),
          label: 'PRODIM',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Salir',
        ),
      ],
    );
  }

  Widget cards_listado(BuildContext context, nombre, monto) {
    return Container(
        height: 65,
        child: InkWell(
          child: Card(
            // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            // margen para el Card
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 8,
            ),
            // La sombra que tiene el Card aumentará
            elevation: 10,
            //Colocamos una fila en dentro del card
            color: const Color.fromRGBO(9, 46, 116, 1.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(nombre,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                            )))),
                Expanded(
                  //columna fecha
                  flex: 1,
                  child: Text("\u0024 $monto",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      )),
                ),
              ],
            ),
          ),
        ));
  }

  Widget cards_desglose(BuildContext context, nombre, monto) {
    return Container(
      height: 65,
      child: Card(
        // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 30,
          right: 10,
          bottom: 8,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 10,
        //Colocamos una fila en dentro del card
        color: const Color.fromRGBO(9, 46, 116, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
              //columna fecha
              flex: 1,
              child: Text("\u0024 $monto",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget cards_comprometido(BuildContext context, nombre, estado) {
    IconData estado_icon;
    Color color;
    Color color_barra;
    if (estado == 1) {
      estado_icon = Icons.check_circle_rounded;
      color = Colors.green;
      color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    }
    if (estado == 2) {
      estado_icon = Icons.cancel /*check_circle_rounded*/;
      color = Colors.red;
      color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    }

    if (estado == 3) {
      estado_icon = Icons.remove_circle;
      color = Colors.yellow;
      color_barra = Colors.grey[500];
    }
    return Container(
      height: 65,
      child: Card(
        // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: 0,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 0,
        //Colocamos una fila en dentro del card
        color: color_barra,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 6,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
              flex: 1,
              child: Icon(
                estado_icon,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cards(BuildContext context, nombre, estado) {
    IconData estado_icon;
    Color color;
    Color color_barra;
    if (estado == 1) {
      estado_icon = Icons.check_circle_rounded;
      color = Colors.green;
      color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    }
    if (estado == 2) {
      estado_icon = Icons.cancel /*check_circle_rounded*/;
      color = Colors.red;
      color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    }

    if (estado == 3) {
      estado_icon = Icons.remove_circle;
      color = Colors.yellow;
      color_barra = Colors.grey[500];
    }
    return Container(
      height: 65,
      child: Card(
        // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 8,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 10,
        //Colocamos una fila en dentro del card
        color: color_barra,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
              flex: 1,
              child: Icon(
                estado_icon,
                color: color,
              ),
            ),
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
    send.clear();
    lista_obras.clear();
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
        "http://sistema.mrcorporativo.com/api/getDesgloseProdim/$id_cliente,$anio";
    print('$id_cliente $anio');
    try {
      final respuesta = await http.get(Uri.parse(url));
      print(respuesta.body);
      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";
        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          data.forEach((e) {
            final prodim = json.encode(e['prodim']);
            dynamic prodim_1 = json.decode(prodim);

            prodim_1.forEach((i) {
              firma_electronica = i['firma_electronica'];
              revisado = i['revisado'];
              validado = i['validado'];
              convenio = i['convenio'];
            });

            final comprometido = json.encode(e['comprometido']);
            dynamic comprometido_1 = json.decode(comprometido);

            comprometido_1.forEach((i) {
              lista_obras.add(cards_listado(
                  context, i['nombre'], numberFormat(i['monto'].toDouble())));
              final desglose = json.encode(e['desglose']);
              dynamic desglose_1 = json.decode(desglose);
              desglose_1.forEach((a) {
                if (i['nombre'] == a['nombre']) {
                  print(a['concepto']);
                  lista_obras.add(cards_desglose(context, a['concepto'],
                      numberFormat(a['monto'].toDouble())));
                }
              });
            });

            final gastos_indirectos = json.encode(e['gastos']);
            dynamic indirectos_1 = json.decode(gastos_indirectos);

            indirectos_1.forEach((i) {
              gastos.add(
                cards_listado(
                  context,
                  i['nombre'],
                  numberFormat(i['monto'].toDouble()),
                ),
              );
            });

            /*fecha_integracion = e['acta_integracion_consejo'];
            fecha_priorizacion = e['acta_priorizacion'];
            fecha_adendum = e['adendum_priorizacion'];
            double avance =
                int.parse(e['avance_tecnico'].toStringAsFixed(0)).toDouble();
            double monto_contratado = e['monto_contratado'].toDouble();
            String nombre = e['nombre_obra'];
            if (nombre.length > 48) {
              nombre = nombre.substring(0, 53) + '...';
            }
            lista_obras.add(cards_listado(
                context,
                nombre,
                numberFormat(monto_contratado),
                avance,
                e['id_obra'],
                e['modalidad_ejecucion']));*/
          });
          _onRefresh();
          _onLoading();
          return jsonDecode(respuesta.body);
        } else {
          return null;
        }
      } else {
        print("Error con la respusta");
      }
    } catch (e) {
      print(e);
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
}
