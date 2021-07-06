import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/login.dart';
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

class Obras_contrato extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;
  @override
  _ObrasContrato createState() => _ObrasContrato();
  int id_obra;
  int id_cliente;
  int anio;
  int clave;
  String nombre;
  String nombre_archivo;
  Obras_contrato({
    Key key,
    this.id_obra,
    this.id_cliente,
    this.anio,
    this.platform,
    this.clave,
    this.nombre,
    this.nombre_archivo,
  }) : super(key: key);
}

class Vehicle {
  final String title;
  List<String> contents = [];
  List<int> icons;

  Vehicle(this.title, this.contents, this.icons);
}

class _ObrasContrato extends State<Obras_contrato> {
  String nombre_obra = 'Ejemplo de nombre de obra';
  String nombre_corto = 'Ejemplo de nombre de obra';
  String monto = '10,000';
  double avance_fisico = 20.0;
  double avance_tecnico = 20.0;
  double avance_economico = 20.0;
  String url;
  bool inicio = false;
  int id_cliente;
  int anio;
  int modalidad = 2;
  int id_obra;
  List<Widget> lista_obras = [];
  List<Widget> send = [];
  List<int> exp = [];
  List<String> fondo = [];
  List<Widget> facturas = [];
  List<Widget> estimacion = [];
  List<Widget> arrendamientos = [];
  List<Widget> licitacion = [];
  String observaciones = '';
  String contrato;
  int fact_anticipo;
  int f_ant;
  int f_cumplimiento;
  int f_v_o;
  String tipo_contrato;
  bool visibility_obj = false;
  int clave_municipio;
  int obra;
  String nombre_archivo;

  //DOWNLOAD ARCHIVOS
  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();

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
    final Obras_contrato args = ModalRoute.of(context).settings.arguments;
    id_obra = args.id_obra;
    id_cliente = args.id_cliente;
    anio = args.anio;
    clave_municipio = args.clave;
    nombre_corto = args.nombre;
    nombre_archivo = args.nombre_archivo;
    /*_getListado(context);*/
    if (!exp.isEmpty && inicio) {
      _options();
    }
    if (send.isEmpty && !inicio) {
      _getListado(context);
      arrendamientos.add(
        Container(
          height: 30,
          child: Card(
            // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            // margen para el Card
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 8,
            ),
            // La sombra que tiene el Card aumentará
            elevation: 0,
            //Colocamos una fila en dentro del card
            color: const Color.fromRGBO(4, 124, 188, 1.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    flex: 3,
                    child: Text('FECHA DE INICIO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ))),
                Expanded(
                    flex: 3,
                    child: Text('FECHA DE FIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ))),
                Expanded(
                    flex: 3,
                    child: Text('MONTO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ))),
              ],
            ),
          ),
        ),
      );
      facturas.add(
        Container(
          height: 30,
          child: Card(
            // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            // margen para el Card
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 8,
            ),
            // La sombra que tiene el Card aumentará
            elevation: 0,
            //Colocamos una fila en dentro del card
            color: const Color.fromRGBO(4, 124, 188, 1.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    flex: 3,
                    child: Text('FOLIO FISCAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ))),
                Expanded(
                    flex: 1,
                    child: Text('MONTO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ))),
              ],
            ),
          ),
        ),
      );
      inicio = true;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(9, 46, 116, 1.0),
          centerTitle: true,
          title: Text("EXPEDIENTE TÉCNICO"),
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
  }

  void _options() {
    String n_moda = 'Licitación pública';
    int avance_fisico_1 = avance_fisico.toInt();
    int avance_economico_1 = avance_economico.toInt();
    int avance_tecnico_1 = avance_tecnico.toInt();
    bool nombre = nombre_corto == nombre_obra;
    print(modalidad);
    if (modalidad == 3) {
      print('hola');
      n_moda = 'Invitación a cuando menos tres contratistas';
    }
    if (modalidad == 4) {
      n_moda = 'Adjudicación directa';
    }
    send.clear();

    send.add(SizedBox(
      height: 30,
    ));

    send.add(
      visibility_obj
          ? new Container()
          : Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                nombre_corto.toUpperCase(),
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
    send.add(
      visibility_obj
          ? Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Text(
                nombre_obra.toUpperCase(),
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
            )
          : new Container(),
    );
    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: InkWell(
          onTap: () {
            _changed(visibility_obj);
          },
          child: Card(
            // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: Colors.transparent),
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
                  flex: nombre ? 0 : 5,
                  child: nombre
                      ? new Container()
                      : Container(
                          child: Text(
                            visibility_obj ? "Ver menos" : "Ver más",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: _items
                        .map(
                          (item) => item.task == null
                              ? _buildListSection(item.name)
                              : DownloadItem(
                                  data: item,
                                  onItemClick: (task) {
                                    _openDownloadedFile(task).then((success) {
                                      if (!success) {
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Cannot open this file')));
                                      }
                                    });
                                  },
                                  onActionClick: (task) {
                                    if (task.status ==
                                        DownloadTaskStatus.undefined) {
                                      _requestDownload(task);
                                    } else if (task.status ==
                                        DownloadTaskStatus.running) {
                                      _pauseDownload(task);
                                    } else if (task.status ==
                                        DownloadTaskStatus.paused) {
                                      _resumeDownload(task);
                                    } else if (task.status ==
                                        DownloadTaskStatus.complete) {
                                      _delete(task);
                                    } else if (task.status ==
                                        DownloadTaskStatus.failed) {
                                      _retryDownload(task);
                                    }
                                  },
                                ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Text(
          'Modalidad de ejecucion: Contrato',
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w400,
            fontSize: 17,
          ),
        ),
      ),
    );
    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Text(
          'Modalidad de asignación: $n_moda',
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w400,
            fontSize: 17,
          ),
        ),
      ),
    );

    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 20),
        child: Text(
          'Número de contrato: $contrato',
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
    );

    send.add(
      Container(
        margin: EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Text(
          '$tipo_contrato',
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w400,
            fontSize: 17,
          ),
        ),
      ),
    );

    send.add(SizedBox(
      height: 10,
    ));
    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Inversión',
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
            Expanded(
              //columna fecha
              flex: 5,
              child: Text(
                '\u0024 $monto',
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    for (var i = 0; i < fondo.length; i++) {
      String fondoT = fondo[i];
      i++;
      String montoT = fondo[i];
      send.add(
        Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 20, top: 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  flex: 3,
                  child: Text(fondoT,
                      style: TextStyle(
                        color: Color.fromRGBO(9, 46, 116, 1.0),
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                      ))),
              Expanded(
                //columna fecha
                flex: 5,
                child: Text(
                  '\u0024 $montoT',
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    send.add(SizedBox(
      height: 30,
    ));

    /*send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Text('Avance Fisico',
                    style: TextStyle(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                    ))),
            Expanded(
              //columna fecha
              flex: 5,
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineHeight: 20.0,
                percent: avance_fisico_1 * 0.01,
                center: Text(
                  "$avance_fisico_1%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: const Color.fromRGBO(0, 153, 51, 1.0),
                backgroundColor: const Color.fromRGBO(133, 138, 141, 1.0),
              ),
            ),
          ],
        ),
      ),
    );*/
    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Text(
          'Porcentaje de avance',
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
    send.add(SizedBox(
      height: 10,
    ));
    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            /*Expanded(
                flex: 3,
                child: Text('Avance Financiero',
                    style: TextStyle(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                      fontWeight: FontWeight.w300,
                      fontSize: 17,
                    ))),*/
            Expanded(
              //columna fecha
              flex: 5,
              child: CircularPercentIndicator(
                radius: 80.0,
                animation: true,
                animationDuration: 1000,
                percent: avance_fisico_1 * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "$avance_fisico_1%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 8,
                footer: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  height: 30,
                  child: Center(
                    child: Text(
                      "Fisico",
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 17.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              //columna fecha
              flex: 5,
              child: CircularPercentIndicator(
                radius: 80.0,
                animation: true,
                animationDuration: 1000,
                percent: avance_economico * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  "$avance_economico_1%",
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 8,
                footer: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  height: 30,
                  child: Center(
                    child: Text(
                      "Financiero",
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 17.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              //columna fecha
              flex: 5,
              child: CircularPercentIndicator(
                radius: 80.0,
                animation: true,
                animationDuration: 1000,
                percent: avance_tecnico_1 * 0.01,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '$avance_tecnico_1%',
                  style: TextStyle(
                    color: Color.fromRGBO(9, 46, 116, 1.0),
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey[350],
                lineWidth: 8,
                footer: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  height: 30,
                  child: Center(
                    child: Text(
                      'Expediente\nTécnico',
                      style: new TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 17.0),
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
    /*print("hola 12");
    send.add(
      Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Expediente Técnico',
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              //columna fecha
              flex: 5,
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineHeight: 20.0,
                percent: avance_tecnico_1 * 0.01,
                linearStrokeCap: LinearStrokeCap.roundAll,
                center: Text(
                  '$avance_tecnico_1%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                progressColor: const Color.fromRGBO(0, 153, 51, 1.0),
                backgroundColor: const Color.fromRGBO(133, 138, 141, 1.0),
              ),
            ),
          ],
        ),
      ),
    );*/
    send.add(SizedBox(
      height: 10,
    ));
    send.add(
      Container(
        child: GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Parte social',
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
                cards(
                    context,
                    "Acta de integración del consejo de desarrollo municipal",
                    exp[0]),
                cards(context, "Acta de selección de obras", exp[1]),
                cards(
                    context,
                    "Acta de priorización de obras, acciones sociales básicas e inversión",
                    exp[2]),
                cards(context, "Convenio celebrado para mezcla de recursos",
                    exp[3]),
                cards(
                    context, "Acta de integración del comité de obras", exp[4]),
                cards(context, "Convenio de concertación", exp[5]),
                cards(
                    context,
                    "Acta de aprobación y autorización de obras, acciones sociales e inversiones",
                    exp[6]),
                cards(
                    context,
                    "Acta de acuerdo excepción a la licitación pública",
                    exp[7]),
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
      ),
    );
    send.add(
      Container(
        child: GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Proyecto ejecutivo',
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
                cards(
                    context,
                    "Estudio de factibilidad técnica exonómica y exológica",
                    exp[8]),
                cards(
                    context,
                    "Oficio de notificación de aprobación y autorización de obras",
                    exp[9]),
                cards(context, "Anexo del oficio de notificación", exp[10]),
                cards(context, "Cédula de información básica", exp[11]),
                cards(context, "Generalidades de la inversión", exp[12]),
                cards(
                    context,
                    "Documentos que acrediten la tenecia de la tierra",
                    exp[13]),
                cards(context, "Dictamen de impacto ambiental", exp[14]),
                cards(context, "Presupuesto de obra", exp[15]),
                cards(context, "Catálogo de conceptos", exp[16]),
                cards(context, "Explosión de insumos", exp[17]),
                cards(context, "Generadores de obra programada", exp[18]),
                cards(context, "Planos del proyecto", exp[19]),
                cards(context, "Especificaciones generales y particulares",
                    exp[20]),
                cards(context, "Firma del director responsable de obra (DRO)",
                    exp[21]),
                cards(context, "Programa de obra e inversión", exp[22]),
                cards(context, "Croquis de macrolocalización", exp[23]),
                cards(context, "Croquis de microlocalización", exp[24]),
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
      ),
    );

    send.add(
      Container(
        child: GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Proceso de contratación',
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
              children: licitacion,
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
    );

    send.add(
      Container(
        child: GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Ejecución de obra',
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
                cards(context, "Asignación del superintendente (Contratista)",
                    exp[25]),
                cards(context, "Asignación del residente de obra (Municipio)",
                    exp[26]),
                cards(context, "Oficio para la disposición del inmueble",
                    exp[27]),
                cards(context, "Notificación de incio de obra", exp[28]),
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
      ),
    );
    print("hola 15");
    send.add(
      Container(
        child: GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Documentación comprobatoria',
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
                cards(context, "Factura de anticipo", fact_anticipo),
                cards(context, "Fianza de anticipo", f_ant),
                cards(context, "Fianza de cumplimiento", f_cumplimiento),
                cards(context, "Fianza de vicios ocultos", f_v_o),
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
      ),
    );
    for (var i = 0; i < estimacion.length; i++) {
      send.add(estimacion[i]);
    }
    send.add(
      Container(
        child: GFAccordion(
          titleBorder: Border.all(
            width: 1.0,
            color: Color.fromRGBO(9, 46, 116, 1.0),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
          titlePadding:
              EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          titleChild: Text(
            'Terminación de los trabajos',
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
                cards(context, "Aviso de terminación de obra", exp[29]),
                cards(
                    context,
                    "Acta de entrega-recepción contratista a municipio",
                    exp[30]),
                cards(
                    context,
                    "Acta de entrega-recepción municipio a beneficiarios",
                    exp[31]),
                cards(context, "Sabana de finiquito de obra", exp[32]),
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
      ),
    );
    print("hola 17");
    if (observaciones != '') {
      observaciones = observaciones.substring(0, observaciones.length - 2);
      send.add(
        Container(
          child: GFAccordion(
            titleBorder: Border.all(
              width: 1.0,
              color: Color.fromRGBO(9, 46, 116, 1.0),
            ),
            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
            titlePadding:
                EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            titleChild: Text(
              'Observaciones',
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
              child: Column(children: [
                Container(
                  width: MediaQuery.of(context).size.height,
                  child: Card(
                    // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: Color.fromRGBO(9, 46, 116, 1.0),
                      ),
                    ),
                    // margen para el Card
                    // La sombra que tiene el Card aumentará
                    elevation: 0,
                    //Colocamos una fila en dentro del card
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        observaciones,
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
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
      );
    }
    send.add(SizedBox(
      height: 35,
    ));
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
          CupertinoIcons.book,
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
          icon: CupertinoIcons.book,
          title: 'Expediente',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.book,
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

  void _changed(bool visibility) {
    setState(() {
      visibility_obj = !visibility;
      print(visibility_obj);
    });
  }

//-----------Cards de Actas preliminares------------
  Widget cards(BuildContext context, nombre, estado) {
    IconData estado_icon;
    Color color;
    Color color_barra;
    Widget ret;

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
    bool estado_2 = estado == 3;
    estado_2
        ? ret = new Container()
        : ret = new Container(
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
                          child: Text(nombre,
                              style: TextStyle(
                                color: Color.fromRGBO(9, 46, 116, 1.0),
                                fontWeight: FontWeight.w400,
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
    return ret;
  }

  Widget cards_facturas(BuildContext context, folio, monto) {
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
        color: const Color.fromRGBO(9, 46, 116, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(folio,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(monto,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
          ],
        ),
      ),
    );
  }

  Widget cards_lista(BuildContext context, fecha_inicio, fecha_fin, monto) {
    IconData estado_icon;
    Color color;
    Color color_barra;

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
        color: const Color.fromRGBO(9, 46, 116, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(fecha_inicio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(fecha_fin,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 30),
                    child: Text(monto,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
          ],
        ),
      ),
    );
  }
// ------------- Cards Listado de obras -------------------

  Widget cards_listado(
      BuildContext context, nombre, monto, avance, id_obra, modalidad) {
    send.clear();

    return Container(
        height: 70,
        child: InkWell(
          onTap: () {},
          child: Card(
            // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: Colors.white),
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
                  flex: 2,
                  child: Text("\u0024 $monto",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: LinearPercentIndicator(
                    width: 60.0,
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: avance * 0.01,
                    linearStrokeCap: LinearStrokeCap.butt,
                    center: Text("$avance%"),
                    progressColor: Colors.green,
                  ),
                )
              ],
            ),
          ),
        ));
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
    url = "https://sistema.mrcorporativo.com/api/getObraExpediente/$id_obra";
    try {
      final respuesta = await http.get(Uri.parse(url));
      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";
        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          /*final parte_social = json.encode(data['parte_social']);
          print(respuesta.body);
          final data1 = json.decode(parte_social);
          print(data);*/
          data.forEach((e) {
            final parte_social = json.encode(e['parte_social']);
            dynamic data1 = json.decode(parte_social);
            data1.forEach((i) {
              if (i != null) {
                exp.add(i['acta_integreacion_consejo']);
                exp.add(i['acta_seleccion_obras']);
                exp.add(i['acta_priorizacion_obras']);
                exp.add(i['convenio_mezcla']);
                exp.add(i['acta_integracion_comite']);
                exp.add(i['convenio_concertacion']);
                exp.add(i['acta_aprobacion_obra']);
                exp.add(i['acta_excep_licitacion']);
                exp.add(i['estudio_factibilidad']);
                exp.add(i['oficio_aprobacion_obra']);
                exp.add(i['anexos_oficio_notificacion']);
                exp.add(i['cedula_informacion_basica']);
                exp.add(i['generalidades_inversion']);
                exp.add(i['tenencia_tierra']);
                exp.add(i['dictamen_impacto_ambiental']);
                exp.add(i['presupuesto_obra']);
                exp.add(i['catalogo_conceptos']);
                exp.add(i['explosion_insumos']);
                exp.add(i['generadores_obra']);
                exp.add(i['planos_proyecto']);
                exp.add(i['especificaciones_generales_particulares']);
                exp.add(i['dro']);
                exp.add(i['programa_obra_inversion']);
                exp.add(i['croquis_macro']);
                exp.add(i['croquis_micro']);
              }
            });
            final parte_licitacion = json.encode(e['obra_licitacion']);
            data1 = json.decode(parte_licitacion);
            data1.forEach((i) {
              if (i != null) {
                licitacion.add(cards(
                    context,
                    "Padrón de contratistas de obra pública del municipio",
                    i['padron_contratistas']));
                licitacion.add(cards(
                    context, "Bases de licitación", i['bases_licitacion']));
                licitacion.add(cards(
                    context,
                    "Constancia de visita donde se ejecutará la obra",
                    i['constancia_visita']));
                licitacion.add(
                  cards(context, "Acta de la junta de aclaraciones",
                      i['acta_junta_aclaraciones']),
                );
                licitacion.add(
                  cards(context, "Acta de apertura técnica",
                      i['acta_apertura_tecnica']),
                );
                licitacion.add(
                  cards(context, "Dictamen técnico y análisis detallado",
                      i['dictamen_tecnico']),
                );
                licitacion.add(
                  cards(context, "Acta de apertura económica",
                      i['acta_apertura_economica']),
                );
                licitacion.add(
                  cards(context, "Dictamen económico y análisis detallado",
                      i['dictamen_economico']),
                );
                licitacion.add(
                  cards(context, "Dictamen", i['dictamen']),
                );
                licitacion.add(
                  cards(context, "Acta de fallo", i['acta_fallo']),
                );
                licitacion.add(
                  cards(context, "Propuesta de licitantes técnica",
                      i['propuesta_licitantes_tecnica']),
                );
                licitacion.add(
                  cards(context, "Propuesta de licitantes económica",
                      i['propuesta_licitantes_economica']),
                );
              }
            });
            final parte_obra = json.encode(e['obra']);
            data1 = json.decode('[' + parte_obra + ']');
            int anticipo = 3;
            data1.forEach((i) {
              if (i != null) {
                nombre_obra = i['nombre_obra'];
                nombre_corto = i['nombre_corto'];
                monto = numberFormat(i['monto_contratado'].toDouble());
                avance_fisico =
                    int.parse(i['avance_fisico'].toStringAsFixed(0)).toDouble();
                avance_economico =
                    int.parse(i['avance_economico'].toStringAsFixed(0))
                        .toDouble();
                avance_tecnico =
                    int.parse(i['avance_tecnico'].toStringAsFixed(0))
                        .toDouble();
                if (i['anticipo_porcentaje'] != 0) {
                  anticipo = 1;
                } else {
                  anticipo = 3;
                }
              }
            });
            final parte_admin = json.encode(e['obra_exp']);
            data1 = json.decode(parte_admin);
            data1.forEach((i) {
              if (i != null) {
                licitacion.add(
                  cards(
                      context,
                      "Oficio justificatorio para convenio modificatorio",
                      i['oficio_justificativo_convenio_modificatorio']),
                );
                licitacion.add(
                  cards(context, "Analísis de precios unitarios",
                      i['analisis_p_u']),
                );
                licitacion.add(
                  cards(context, "Catalogo de conceptos",
                      i['catalogo_conceptos']),
                );
                licitacion.add(
                  cards(context, "Montos mensuales ejecutados",
                      i['montos_mensuales_ejecutados']),
                );
                licitacion.add(
                  cards(context, "Calendario de los trabajos ejecutados",
                      i['calendario_trabajos_ejecutados']),
                );
                exp.add(i['oficio_superintendente']);
                exp.add(i['oficio_residente_obra']);
                exp.add(i['oficio_disposicion_inmueble']);
                exp.add(i['oficio_inicio_obra']);
                exp.add(i['aviso_terminacion_obra']);
                exp.add(i['acta_entrega_contratista']);
                exp.add(i['acta_entrega_municipio']);
                exp.add(i['saba_finiquito']);
                exp.add(i['notas_botacoras']);
                modalidad = i['modalidad_asignacion'];
                fact_anticipo = anticipo;
                f_ant = anticipo;
                if (anticipo == 1 && i['factura_anticipo'] == '') {
                  fact_anticipo = 2;
                  f_ant = 2;
                }
                /*fact_anticipo = i['factura_anticipo'];*/
                f_cumplimiento = 1;
                if (i['fianza_cumplimiento'] == "") {
                  f_cumplimiento = 2;
                }
                f_v_o = 1;
                if (i['fianza_v_o'] == "") {
                  f_v_o = 2;
                }
                contrato = i['contrato'];
                if (i['contrato_tipo'] == 1) {
                  tipo_contrato = 'Precios unitarios';
                } else {
                  tipo_contrato = 'Precios alzados';
                }
              }
            });

            final parte_fondo = json.encode(e['fondo']);
            data1 = json.decode(parte_fondo);
            data1.forEach((i) {
              if (i != null) {
                fondo.add(i['nombre_corto']);
                fondo.add(numberFormat(i['monto'].toDouble()));
              }
            });
            final parte_estimacion = json.encode(e['obra_estimacion']);
            data1 = json.decode(parte_estimacion);
            int p = 1;
            data1.forEach((i) {
              if (i != null) {
                estimacion.add(
                  Container(
                    child: GFAccordion(
                      titlePadding: EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      margin: EdgeInsets.only(top: 10, left: 20, right: 10),
                      titleChild: Text(
                        'ESTIMACION $p',
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                      expandedTitleBackgroundColor: Colors.transparent,
                      collapsedTitleBackgroundColor: Colors.transparent,
                      contentBackgroundColor:
                          Color.fromRGBO(204, 204, 204, 0.3),
                      titleBorder: Border.all(
                        width: 1.0,
                        color: Color.fromRGBO(9, 46, 116, 1.0),
                      ),
                      contentChild: Container(
                        child: Column(
                          children: [
                            cards_lista(
                                context,
                                i['fecha_inicio'],
                                i['fecha_final'],
                                numberFormat(i['total_estimacion'].toDouble())),
                            cards(context, "Caratula de la estimación",
                                i['caratula_estimacion']),
                            cards(context, "Presupuesto de la estimación",
                                i['presupuesto_estimacion']),
                            cards(context, "Cuerpo de la estimación",
                                i['cuerpo_estimacion']),
                            cards(context, "Número generados de la estimación",
                                i['numero_generadores_estimacion']),
                            cards(context, "Resumen de la estimación",
                                i['resumen_estimacion']),
                            cards(context, "Estado de cuenta de la estimación",
                                i['estado_cuenta_estimacion']),
                            cards(
                                context,
                                "Croquis ilustrativo de la estimación",
                                i['croquis_ilustrativo_estimacion']),
                            cards(
                                context,
                                "Reporte fotografico de la estimación",
                                i['reporte_fotografico_estimacion']),
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
                  ),
                );
                p++;
              }
            });

            final parte_obs = json.encode(e['observaciones']);
            data1 = json.decode(parte_obs);
            data1.forEach((i) {
              if (i != null) {
                observaciones =
                    observaciones + '* ' + i['observacion'] + '\n\n';
              }
            });
          });
          _onRefresh();
          _onLoading();
          return jsonDecode(respuesta.body);
        } else {
          return null;
        }
      } else {
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
          'ERROR DE CONEXIÓN',
          maskType: EasyLoadingMaskType.custom,
        );
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
    _tasks = [];
    _items = [];
    final _documents = [
      {
        'name': nombre_corto,
        'posicion': 1,
        'link':
            'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/obras/$id_obra/$nombre_archivo.pdf'
      },
    ];

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
        child: Text("Descargar checklist",
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
