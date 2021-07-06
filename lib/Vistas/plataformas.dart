import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/login.dart';
import 'package:flutter_app/Vistas/obra_admin.dart';
import 'package:flutter_app/Vistas/obra_contrato.dart';
import 'package:flutter_app/Vistas/obra_publica.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:getwidget/components/accordian/gf_accordian.dart';
import 'package:page_transition/page_transition.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class Plataformas extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;
  @override
  _PlataformasView createState() => _PlataformasView();
  int id_cliente;
  int anio;
  int clave;
  bool prodimb;
  bool gib;
  List<int> id_obras_list;
  List<String> nombre_obras_list;
  Plataformas({
    Key key,
    this.id_cliente,
    this.platform,
    this.anio,
    this.clave,
    this.gib,
    this.prodimb,
    this.id_obras_list,
    this.nombre_obras_list,
  }) : super(key: key);
}

class _PlataformasView extends State<Plataformas> {
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
  List<Widget> mids = [];
  List<Widget> sisplade = [];
  List<Widget> rft = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Object> _documents = [];
  List<int> list_id_obras = [];
  List<String> list_nombre_obras = [];

  //DOWNLOAD ARCHIVOS
  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();
  var listObras = [];

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
    final Plataformas args = ModalRoute.of(context).settings.arguments;
    id_cliente = args.id_cliente;
    anio = args.anio;
    prodim = args.prodimb;
    gi = args.gib;
    clave_municipio = args.clave;
    list_id_obras = args.id_obras_list;
    list_nombre_obras = args.nombre_obras_list;
    if (!listObras.isEmpty && inicio) {
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
          title: Text("PLATAFORMAS DIGITALES"),
        ),
        bottomNavigationBar: _menuInferior(context),
        body: Builder(
            builder: (context) => _isLoading
                ? new Center(
                    child: new CircularProgressIndicator(),
                  )
                : _permissionReady
                    ? _buildDownloadList()
                    : _buildNoPermissionWarning()),
      ),
    );
    /*Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/Fondo03.png"),
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
          )*/
  }

  void _options() {
    send.clear();
    send.add(SizedBox(
      height: 20,
    ));

    send.add(
      Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: Text(
            "SISPLADE",
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
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
            "Sistema de Información para la Planeación del Desarrollo de Oaxaca",
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
              fontWeight: FontWeight.w400,
              fontSize: 17,
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
        children: sisplade,
      ),
    ));
    send.add(
      SizedBox(
        height: 30,
      ),
    );
    /*send.add(
      DownloadItem(
        data: _items[0],
        onItemClick: (task) {
          _openDownloadedFile(task).then((success) {
            if (!success) {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Cannot open this file')));
            }
          });
        },
        onActionClick: (task) {
          if (task.status == DownloadTaskStatus.undefined) {
            _requestDownload(task);
          } else if (task.status == DownloadTaskStatus.running) {
            _pauseDownload(task);
          } else if (task.status == DownloadTaskStatus.paused) {
            _resumeDownload(task);
          } else if (task.status == DownloadTaskStatus.complete) {
            _delete(task);
          } else if (task.status == DownloadTaskStatus.failed) {
            _retryDownload(task);
          }
        },
      ),
    );*/
    send.add(
      Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: Text(
            "MIDS / RFT",
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
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
            "Matriz de Inversión para el Desarrollo Social / Informe de Recursos Federales Transferidos",
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
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
        height: 10,
      ),
    );

    send.add(
      GFAccordion(
        titleBorder: Border.all(
          width: 1.0,
          color: Color.fromRGBO(9, 46, 116, 1.0),
        ),
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        titlePadding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
        titleChild: Text(
          'Obras Públicas',
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        ),
        expandedTitleBackgroundColor: Colors.transparent,
        collapsedTitleBackgroundColor: Colors.transparent,
        contentBackgroundColor: Color.fromRGBO(204, 204, 204, 0.3),
        contentChild: Container(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Card(
                // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                // margen para el Card
                margin: EdgeInsets.only(
                  left: 10,
                  right: 30,
                  bottom: 0,
                ),
                // La sombra que tiene el Card aumentará
                elevation: 0,
                //Colocamos una fila en dentro del card
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Text(
                              "Obra",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "MIDS",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color.fromRGBO(9, 46, 116, 1.0),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          //columna fecha
                          flex: 3,
                          child: Text(
                            "RFT",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color.fromRGBO(9, 46, 116, 1.0),
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                  children: listObras
                      .map<Widget>(
                        (i) =>
                            //Mostar items
                            Column(
                          children: [
                            /*Text((category['nombre_obra'] != null)
                                ? category['nombre_obra']
                                : ''),*/
                            cards_listado(
                                context,
                                i['nombre'],
                                i['primero'],
                                i['segundo'],
                                i['tercero'],
                                i['cuarto'],
                                i['planeado'],
                                i['fecha_planeado'],
                                i['validado'],
                                i['fecha_validado'],
                                i['firmado'],
                                i['fecha_firmado'],
                                i['id_obra'],
                                i['index']),
                          ],
                        ),
                      )
                      .toList()),
              Column(
                children: rft,
              ),
            ],
          ),
        ),
        collapsedIcon: Icon(
          Icons.arrow_drop_down_outlined,
          color: Color.fromRGBO(9, 46, 116, 1.0),
        ),
        expandedIcon: Icon(
          Icons.arrow_drop_up,
          color: Color.fromRGBO(9, 46, 116, 1.0),
        ),
      ),
    );

    if (gi) {
      send.add(
        GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Gastos Indirectos',
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          expandedTitleBackgroundColor: Colors.transparent,
          collapsedTitleBackgroundColor: Colors.transparent,
          contentBackgroundColor: Color.fromRGBO(204, 204, 204, 0.3),
          contentChild: Container(
            child: Column(
              children: gastos,
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
      );
    }

    if (prodim) {
      send.add(
        GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'PRODIM',
            style: TextStyle(
              color: Color.fromRGBO(9, 46, 116, 1.0),
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          expandedTitleBackgroundColor: Colors.transparent,
          collapsedTitleBackgroundColor: Colors.transparent,
          contentBackgroundColor: Color.fromRGBO(204, 204, 204, 0.3),
          contentChild: Container(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 8.0),
                    child: Text(
                      "Programa de Desarrollo Institucional Municipal y de las demarcaciones territoriales del Distrito Federal",
                      style: TextStyle(
                        color: Color.fromRGBO(9, 46, 116, 1.0),
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: DownloadItem(
                      data: _items[_items.length - 1],
                      onItemClick: (task) {
                        _openDownloadedFile(task).then((success) {
                          if (!success) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Cannot open this file')));
                          }
                        });
                      },
                      onActionClick: (task) {
                        if (task.status == DownloadTaskStatus.undefined) {
                          _requestDownload(task);
                        } else if (task.status == DownloadTaskStatus.running) {
                          _pauseDownload(task);
                        } else if (task.status == DownloadTaskStatus.paused) {
                          _resumeDownload(task);
                        } else if (task.status == DownloadTaskStatus.complete) {
                          _delete(task);
                        } else if (task.status == DownloadTaskStatus.failed) {
                          _retryDownload(task);
                        }
                      },
                    ),
                  ),
                ]),
                Container(
                  child: GFAccordion(
                    titleBorder: Border.all(
                      width: 1.0,
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                    ),
                    margin: EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 8),
                    titlePadding:
                        EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                    titleChild: cards_comprometido_prodim(
                        context, 'Comprometido', firma_electronica),
                    expandedTitleBackgroundColor: Colors.transparent,
                    collapsedTitleBackgroundColor: Colors.transparent,
                    contentBackgroundColor: Color.fromRGBO(204, 204, 204, 0.3),
                    titleBorderRadius: BorderRadius.circular(6),
                    contentChild: Container(
                      child: Column(
                        children: lista_obras,
                      ),
                    ),
                    collapsedIcon: Icon(
                      Icons.arrow_drop_down_outlined,
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                    ),
                    expandedIcon: Icon(
                      Icons.arrow_drop_up,
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                    ),
                  ),
                ),
                cards_prodim(context, 'Presentado', firma_electronica),
                cards_prodim(context, 'Revisado', revisado),
                cards_prodim(context, 'Aprobado', validado),
                cards_prodim(context, 'Firma de convenio', convenio),
              ],
            ),
          ),
          collapsedIcon: Icon(
            Icons.arrow_drop_down_outlined,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          expandedIcon: Icon(
            Icons.arrow_drop_up,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
        ),
      );
    }
    send.add(SizedBox(
      height: 20,
    ));

    /*send.add(
      Container(
        child: Column(
          children: rft,
        ),
      ),
    );*/
  }

//menu inferior
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
          CupertinoIcons.device_laptop,
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
          icon: CupertinoIcons.device_laptop,
          title: 'Plataformas',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.device_laptop,
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

  Widget cards_prodim(BuildContext context, nombre, estado) {
    IconData estado_icon;
    Color color;
    Color color_barra;
    if (estado == 1) {
      estado_icon = Icons.check_circle_rounded;
      color = Colors.blue;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
        ),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 8,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 0,
        //Colocamos una fila en dentro del card
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
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

  Widget cards_listado(
      BuildContext context,
      nombre,
      primero,
      segundo,
      tercero,
      cuarto,
      planeado,
      fecha_planeado,
      validado,
      fecha_validado,
      firmado,
      fecha_firmado,
      id_obra,
      index) {
    String estado_mid;
    String estado_rft;
    if (planeado == 0) estado_mid = "Sin información";
    if (planeado == 1 || validado == 1) estado_mid = "En proceso";
    if (firmado == 1) estado_mid = "Presentado";
    if (primero == 0) estado_rft = "Sin información";
    if (primero > 0) estado_rft = "En proceso";
    if (primero == 100) estado_rft = "Terminado";
    if (segundo > 0) estado_rft = "En proceso";
    if (segundo == 100) estado_rft = "Terminado";
    if (tercero > 0) estado_rft = "En proceso";
    if (tercero == 100) estado_rft = "Terminado";
    if (cuarto > 0) estado_rft = "En proceso";
    if (cuarto == 100) estado_rft = "Terminado";
    int index_mids = (index * 2) - 2;
    int index_rft = (index * 2) - 1;
    bool mid_final = false;
    bool rft_final = false;
    if (estado_mid == "Presentado") mid_final = true;
    if (estado_rft == "Terminado") rft_final = true;

    return Container(
      child: GFAccordion(
        titleBorder: Border.all(
          width: 1.0,
          color: Color.fromRGBO(9, 46, 116, 1.0),
        ),
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
        titleChild: cards_comprometido(context, nombre, estado_mid, estado_rft),
        expandedTitleBackgroundColor: Colors.transparent,
        collapsedTitleBackgroundColor: Colors.transparent,
        contentBackgroundColor: Color.fromRGBO(204, 204, 204, 0.3),
        contentChild: Container(
          child: Column(children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
                child: Text(
                  "MIDS - Matriz de Inversión para el Desarrollo Social",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            mid_final
                ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DownloadItem(
                        data: _items[index_mids],
                        onItemClick: (task) {
                          _openDownloadedFile(task).then((success) {
                            if (!success) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Cannot open this file')));
                            }
                          });
                        },
                        onActionClick: (task) {
                          if (task.status == DownloadTaskStatus.undefined) {
                            _requestDownload(task);
                          } else if (task.status ==
                              DownloadTaskStatus.running) {
                            _pauseDownload(task);
                          } else if (task.status == DownloadTaskStatus.paused) {
                            _resumeDownload(task);
                          } else if (task.status ==
                              DownloadTaskStatus.complete) {
                            _delete(task);
                          } else if (task.status == DownloadTaskStatus.failed) {
                            _retryDownload(task);
                          }
                        },
                      ),
                    ),
                  ])
                : new Container(),
            cards(context, "Planeado", fecha_planeado, planeado, 50.0),
            cards(context, "Validado", fecha_validado, validado, 50.0),
            cards(context, "Firmado", fecha_firmado, firmado, 50.0),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
                child: Text(
                  "RFT -Informe de Recursos Federales Transferidos",
                  style: TextStyle(
                    color: const Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            rft_final
                ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: DownloadItem(
                        data: _items[index_rft],
                        onItemClick: (task) {
                          _openDownloadedFile(task).then((success) {
                            if (!success) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Cannot open this file')));
                            }
                          });
                        },
                        onActionClick: (task) {
                          if (task.status == DownloadTaskStatus.undefined) {
                            _requestDownload(task);
                          } else if (task.status ==
                              DownloadTaskStatus.running) {
                            _pauseDownload(task);
                          } else if (task.status == DownloadTaskStatus.paused) {
                            _resumeDownload(task);
                          } else if (task.status ==
                              DownloadTaskStatus.complete) {
                            _delete(task);
                          } else if (task.status == DownloadTaskStatus.failed) {
                            _retryDownload(task);
                          }
                        },
                      ),
                    ),
                  ])
                : new Container(),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
                child: Text(
                  "Trimestre",
                  style: TextStyle(
                    color: const Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            cards__rft(context, primero, segundo, tercero, cuarto),
          ]),
        ),
        collapsedIcon: Icon(
          Icons.arrow_drop_down_outlined,
          color: const Color.fromRGBO(9, 46, 116, 1.0),
        ),
        expandedIcon: Icon(
          Icons.arrow_drop_up,
          color: const Color.fromRGBO(9, 46, 116, 1.0),
        ),
      ),
    );
  }

  Widget cards_listado_prodim(BuildContext context, nombre, monto) {
    return Container(
      height: 60,
      child: InkWell(
        child: Card(
          // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: Color.fromRGBO(9, 46, 116, 1.0),
            ),
          ),
          // margen para el Card
          margin: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 8,
          ),
          // La sombra que tiene el Card aumentará
          elevation: 0,
          //Colocamos una fila en dentro del card
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    nombre,
                    style: TextStyle(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Expanded(
                //columna fecha
                flex: 1,
                child: Text(
                  "\u0024 $monto",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cards_desglose(BuildContext context, nombre, monto) {
    return Container(
      height: 65,
      child: Card(
        // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: Color.fromRGBO(9, 46, 116, 0.5),
          ),
        ),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 30,
          right: 10,
          bottom: 8,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 0,
        //Colocamos una fila en dentro del card
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(nombre,
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        )))),
            Expanded(
              //columna fecha
              flex: 1,
              child: Text("\u0024 $monto",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  dynamic ex(bool f) {
    return true;
  }

  Widget cards_comprometido(
      BuildContext context, nombre, estado_mids, estado_rft) {
    IconData estado_icon;
    Color color;
    Color color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
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
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: const Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  estado_mids,
                  style: TextStyle(
                    color: const Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  estado_rft,
                  style: TextStyle(
                    color: const Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cards_comprometido_prodim(BuildContext context, nombre, estado) {
    IconData estado_icon;
    Color color;
    Color color_barra;
    if (estado == 1) {
      estado_icon = Icons.check_circle_rounded;
      color = Colors.blue;
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
      height: 55,
      child: Card(
        // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: 0,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 0,
        //Colocamos una fila en dentro del card
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
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

  Widget cards(BuildContext context, nombre, fecha, estado, tamanio) {
    IconData estado_icon;
    Color color;
    Color color_barra;
    int estado_1 = estado.toInt();

    if (estado_1 == 1) {
      estado_icon = Icons.check_circle_rounded;
      color = Colors.blue;
      color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    }
    if (estado_1 == 2) {
      estado_icon = Icons.cancel /*check_circle_rounded*/;
      color = Colors.red;
      color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    }

    if (estado_1 == 3) {
      estado_icon = Icons.remove_circle;
      color = Colors.yellow;
      color_barra = Colors.grey[500];
    }

    return Container(
      height: tamanio,
      child: Card(
        // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
        ),
        // margen para el Card
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 8,
        ),
        // La sombra que tiene el Card aumentará
        elevation: 0,
        //Colocamos una fila en dentro del card
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  nombre,
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                fecha,
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
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

  Widget cards__rft(BuildContext context, primero, segundo, tercero, cuarto) {
    IconData estado_icon;
    Color color;
    Color color_barra = const Color.fromRGBO(9, 46, 116, 1.0);
    return Container(
      height: 100,
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
        elevation: 0,
        //Colocamos una fila en dentro del card
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 50.0,
                animation: true,
                animationDuration: 1000,
                percent: primero * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "$primero%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 6,
                footer: Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  height: 15,
                  child: Center(
                    child: Text(
                      "1ro",
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 50.0,
                animation: true,
                animationDuration: 1000,
                percent: segundo * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "$segundo%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 6,
                footer: Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  height: 15,
                  child: Center(
                    child: Text(
                      "2do",
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 50.0,
                animation: true,
                animationDuration: 1000,
                percent: tercero * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "$tercero%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 6,
                footer: Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  height: 15,
                  child: Center(
                    child: Text(
                      "3ro",
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CircularPercentIndicator(
                radius: 50.0,
                animation: true,
                animationDuration: 1000,
                percent: cuarto * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "$cuarto%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 6,
                footer: Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  height: 15,
                  child: Center(
                    child: Text(
                      "4to",
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
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
    mids.clear();
    rft.clear();
    sisplade.clear();
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
    url = "http://sistema.mrcorporativo.com/api/getRFT/$id_cliente,$anio";
    try {
      final respuesta = await http.get(Uri.parse(url));
      //final tasks = await FlutterDownloader.loadTasks();
      //_permissionReady = await _checkPermission();
      if (_permissionReady) {
        await _prepareSaveDir();
      }
      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";
        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          data.forEach(
            (e) {
              final sisplade_1 = json.encode(e['sisplade']);
              dynamic sisplade_2 = json.decode(sisplade_1);

              sisplade_2.forEach((i) {
                sisplade.add(
                  cards(context, 'Capturado', i['fecha_capturado'],
                      i['capturado'], 65.0),
                );
                sisplade.add(
                  cards(context, 'Validado', i['fecha_validado'], i['validado'],
                      65.0),
                );
              });

              final comprometido = json.encode(e['rft']);
              dynamic comprometido_1 = json.decode(comprometido);
              /**/

              /*_tasks = [];
              int cont = 0;
              comprometido_1.forEach((i) {
                int id_obra = i["id_obra"];
                print(id_obra);
                _tasks.add(
                  _TaskInfo(
                      name: i['nombre_obra'],
                      posicion: id_obra,
                      link:
                          'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/obras/$id_obra/mids-$id_obra.pdf'),
                );
              });

              int count = 0;
              for (int i = count; i < _tasks.length; i++) {
                _items.add(_ItemHolder(
                    name: _tasks[i].name,
                    posicion: _tasks[i].posicion,
                    task: _tasks[i]));
                count++;
              }

              tasks.forEach((task) {
                for (_TaskInfo info in _tasks) {
                  if (info.link == task.url) {
                    info.taskId = task.taskId;
                    info.status = task.status;
                    info.progress = task.progress;
                  }
                }
              });

              setState(() {
                _isLoading = false;
              });*/
              int cont = 1;

              comprometido_1.forEach(
                (i) {
                  listObras.add(
                    {
                      'nombre': i['nombre_obra'],
                      'primero': i['primer_trimestre'],
                      'segundo': i['segundo_trimestre'],
                      'tercero': i['tercer_trimestre'],
                      'cuarto': i['cuarto_trimestre'],
                      'planeado': i['planeado'],
                      'fecha_planeado': i['fecha_planeado'],
                      'validado': i['validado'],
                      'fecha_validado': i['fecha_validado'],
                      'firmado': i['firmado'],
                      'fecha_firmado': i['fecha_firmado'],
                      'id_obra': i['id_obra'],
                      'index': cont,
                    },
                  );
                  cont++;
                },
              );
              final prodim = json.encode(e['prodim']);
              dynamic prodim_1 = json.decode(prodim);

              prodim_1.forEach((i) {
                firma_electronica = i['firma_electronica'];
                revisado = i['revisado'];
                validado = i['validado'];
                convenio = i['convenio'];
              });

              final comprometido_2 = json.encode(e['comprometido']);
              dynamic comprometido_3 = json.decode(comprometido_2);

              comprometido_3.forEach(
                (i) {
                  lista_obras.add(cards_listado_prodim(context, i['nombre'],
                      numberFormat(i['monto'].toDouble())));
                  final desglose = json.encode(e['desglose']);
                  dynamic desglose_1 = json.decode(desglose);
                  desglose_1.forEach(
                    (a) {
                      if (i['nombre'] == a['nombre']) {
                        lista_obras.add(cards_desglose(context, a['concepto'],
                            numberFormat(a['monto'].toDouble())));
                      }
                    },
                  );
                },
              );

              final gastos_indirectos = json.encode(e['gastos']);
              dynamic indirectos_1 = json.decode(gastos_indirectos);

              indirectos_1.forEach((i) {
                gastos.add(
                  cards_listado_prodim(
                    context,
                    i['nombre'],
                    numberFormat(i['monto'].toDouble()),
                  ),
                );
              });
            },
          );

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
    await prefs.setString('token', token);
  }

  @override
  void initState() {
    init();
    super.initState();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;

    _prepare();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (_tasks != null && _tasks.isNotEmpty) {
        final task = _tasks.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  Widget _buildDownloadList() => Container(
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
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
      ) /*,*/
      ;
  Widget _buildListSection(String title) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 17.0),
        ),
      );

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Please grant accessing storage permission to continue -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 17.0),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              FlatButton(
                  onPressed: () {
                    _retryRequestPermission();
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();

    if (hasGranted) {
      await _prepareSaveDir();
    }

    setState(() {
      _permissionReady = hasGranted;
    });
  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: debug);
  }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _cancelDownload(_TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void _pauseDownload(_TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> _openDownloadedFile(_TaskInfo task) {
    if (task != null) {
      return FlutterDownloader.open(taskId: task.taskId);
    } else {
      return Future.value(false);
    }
  }

  void _delete(_TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
    setState(() {});
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _items = [];
    _tasks = [];
    var _documents = [];
    for (int i = 0; i < list_id_obras.length; i++) {
      int id_obra = list_id_obras[i];
      _documents.add(
        {
          'name': list_nombre_obras[i],
          'posicion': id_obra,
          'link':
              'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/obras/$id_obra/mids-$id_obra.pdf'
        },
      );
      _documents.add(
        {
          'name': list_nombre_obras[i],
          'posicion': id_obra,
          'link':
              'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/obras/$id_obra/rft-$id_obra.pdf'
        },
      );
    }

    _documents.add(
      {
        'name': "Prodim $clave_municipio",
        'posicion': 19,
        'link':
            'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/prodim-$clave_municipio.pdf'
      },
    );

    _tasks.addAll(_documents.map((document) => _TaskInfo(
        name: document['name'],
        posicion: document['posicion'],
        link: document['link'])));

    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(
          name: _tasks[i].name, posicion: _tasks[i].posicion, task: _tasks[i]));
      count++;
    }

    tasks.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }
}

class _TaskInfo {
  final String name;
  final int posicion;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.posicion, this.link});
}

class _ItemHolder {
  final String name;
  final int posicion;
  final _TaskInfo task;

  _ItemHolder({this.name, this.posicion, this.task});
}

class DownloadItem extends StatelessWidget {
  final _ItemHolder data;
  final Function(_TaskInfo) onItemClick;
  final Function(_TaskInfo) onActionClick;

  DownloadItem({
    this.data,
    this.onItemClick,
    this.onActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: data.task.status == DownloadTaskStatus.complete
            ? () {
                onItemClick(data.task);
              }
            : null,
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildActionForTask(data.task),
                  )
                ],
              ),
            ),
            data.task.status == DownloadTaskStatus.running ||
                    data.task.status == DownloadTaskStatus.paused
                ? Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: LinearProgressIndicator(
                      value: data.task.progress / 100,
                    ),
                  )
                : Container()
          ].toList(),
        ),
      ),
    );
  }

  Widget _buildActionForTask(_TaskInfo task) {
    if (task.status == DownloadTaskStatus.undefined) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick(task);
        },
        child: Text("Descargar acuse",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w300,
              fontSize: 16,
            )),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 25.0, minWidth: 25.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick(task);
        },
        child: Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 25.0, minWidth: 25.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return RawMaterialButton(
        onPressed: () {
          onActionClick(task);
        },
        child: Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 25.0, minWidth: 25.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.remove_red_eye,
            color: Colors.green,
          ),
          RawMaterialButton(
            onPressed: () {
              onActionClick(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 25.0, minWidth: 25.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text('Calcelado', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Fallido', style: TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              onActionClick(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: CircleBorder(),
            constraints: BoxConstraints(minHeight: 25.0, minWidth: 25.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.enqueued) {
      return Text('Pendiente', style: TextStyle(color: Colors.orange));
    } else {
      return null;
    }
  }
}
