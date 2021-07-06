import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Vistas/anio.dart';
import 'package:flutter_app/Vistas/login.dart';
import 'package:flutter_app/Vistas/obra_admin.dart';
import 'package:flutter_app/Vistas/obra_contrato.dart';
import 'package:flutter_app/Vistas/principal.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

const debug = true;

class Obras extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;
  @override
  int id_cliente;
  int anio;
  int clave;
  Obras({
    Key key,
    this.id_cliente,
    this.anio,
    this.platform,
    this.clave,
  }) : super(key: key);
  _ObrasView createState() => _ObrasView(
        id_cliente: id_cliente,
        anio: anio,
        clave_municipio: clave,
      );
}

class _ObrasView extends State<Obras> {
  String fecha_integracion = '';
  String fecha_priorizacion = '';
  String fecha_adendum = '';
  String url;
  bool inicio = false;
  int id_cliente;
  int anio;
  List<Widget> lista_obras = [];
  List<Widget> send = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> fechas = [];
  List<String> link = [];

  //DOWNLOAD ARCHIVOS
  List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  String _localPath;
  ReceivePort _port = ReceivePort();
  int clave_municipio = 0;

  _ObrasView({
    this.id_cliente,
    this.anio,
    this.clave_municipio,
  });

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

  @override
  Widget build(BuildContext context) {
    final Obras args = ModalRoute.of(context).settings.arguments;
    id_cliente = args.id_cliente;
    anio = args.anio;
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
          title: Text("OBRA PÚBLICA"),
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
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
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
                  'Por favor acepte el almacenamiento de archivos para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              FlatButton(
                onPressed: () {
                  _retryRequestPermission();
                },
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              )
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
        'name': 'Acta de Integración del Consejo de Desarrollo Municipal',
        'posicion': 1,
        'link':
            'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/acta_consejo.pdf'
      },
      {
        'name': 'Acta de Priorización de Obras',
        'posicion': 2,
        'link':
            'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/acta_priorizaicion.pdf'
      },
      {
        'name': 'Acta de Adendum a la Priorización de Obras',
        'posicion': 3,
        'link':
            'http://sistema.mrcorporativo.com/archivos/$clave_municipio/$anio/acta_adendum.pdf'
      },
    ];

    _tasks.addAll(_documents.map((document) => _TaskInfo(
        name: document['name'],
        posicion: document['posicion'],
        link: document['link'])));

    for (int i = count; i < _tasks.length; i++) {
      print(_tasks[i].link);
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

  void _options() {
    send.clear();

    send.add(SizedBox(
      height: 20,
    ));
    send.add(Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "ACTAS PRELIMINARES",
          style: TextStyle(
            color: Color.fromRGBO(9, 46, 116, 1.0),
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
    ));
    send.add(SizedBox(
      height: 10,
    ));
    send.add(Column(
      children: _items
          .map(
            (item) => item.task == null
                ? _buildListSection(item.name)
                : DownloadItem(
                    data: item,
                    fecha: fechas[item.posicion],
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
          )
          .toList(),
    ));

    send.add(Container(
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          SizedBox(
            child: Center(
                child: Text(
              "LISTADO DE OBRAS",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(9, 46, 116, 1.0),
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            )),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    ));
    send.add(Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                "Proyecto",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "Inversión",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Avance",
                style: TextStyle(
                  color: Color.fromRGBO(9, 46, 116, 1.0),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        )));
    send.add(SizedBox(
      height: 10,
    ));
    send.add(Container(
      child: Column(
        children: lista_obras,
      ),
    ));
    send.add(SizedBox(
      height: 30,
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
          CupertinoIcons.hammer,
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
          icon: CupertinoIcons.hammer,
          title: 'Obras',
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 1000),
            child: Icon(
              CupertinoIcons.hammer,
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

//-----------Cards de Actas preliminares------------
  Widget cards(BuildContext context, nombre, fecha) {
    return Container(
      height: 70,
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
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 3,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color.fromRGBO(9, 46, 116, 1.0),
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                        )))),
            Expanded(
              //columna fecha
              flex: 2,
              child: Text(fecha,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  )),
            ),
            Expanded(
              flex: 1,
              child: Icon(
                Icons.get_app_rounded,
                color: Colors.green,
              ),
            )
          ],
        ),
      ),
    );
  }
// ------------- Cards Listado de obras -------------------

  Widget cards_listado(BuildContext context, nombre, monto, avance, id_obra,
      modalidad, nombre_archivo) {
    int avance_1 = avance.toInt();
    return Container(
      height: 70,
      child: InkWell(
        onTap: () {
          if (modalidad == 1) {
            Navigator.pushNamed(context, '/admin',
                arguments: Obras_admin(
                  id_obra: id_obra,
                  id_cliente: id_cliente,
                  anio: anio,
                  clave: clave_municipio,
                  nombre: nombre,
                  nombre_archivo: nombre_archivo,
                ));
          }
          if (modalidad > 1) {
            Navigator.pushNamed(context, '/contrato',
                arguments: Obras_contrato(
                  id_obra: id_obra,
                  id_cliente: id_cliente,
                  anio: anio,
                  clave: clave_municipio,
                  nombre: nombre,
                  nombre_archivo: nombre_archivo,
                ));
          }
        },
        child: Card(
          // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Color.fromRGBO(9, 46, 116, 1.0)),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color.fromRGBO(9, 46, 116, 1.0),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          )))),
              Expanded(
                //columna fecha
                flex: 2,
                child: Text("\u0024 $monto",
                    style: TextStyle(
                      color: Color.fromRGBO(9, 46, 116, 1.0),
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    )),
              ),
              Expanded(
                flex: 1,
                child: CircularPercentIndicator(
                  radius: 40.0,
                  animation: true,
                  animationDuration: 1000,
                  percent: avance * 0.01,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Text(
                    "$avance_1%",
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
              )
            ],
          ),
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
        "http://sistema.mrcorporativo.com/api/getObrasCliente/$id_cliente,$anio";
    print('$id_cliente $anio');
    try {
      final respuesta = await http.get(Uri.parse(url));
      if (respuesta.statusCode == 200) {
        bool resp = respuesta.body == "";

        if (respuesta.body != "") {
          final data = json.decode(respuesta.body);
          data.forEach((e) {
            fechas.add(e['acta_integracion_consejo']);
            fechas.add(e['acta_priorizacion']);
            fechas.add(e['adendum_priorizacion']);
            double avance = int.parse(e['avance_tecnico']).toDouble();
            double monto_contratado = e['monto_contratado'].toDouble();
            String nombre = e['nombre_obra'];
            if (nombre.length > 52) {
              nombre = nombre.substring(0, 53) + '...';
            }

            lista_obras.add(cards_listado(
                context,
                nombre,
                numberFormat(monto_contratado),
                avance,
                e['id_obra'],
                e['modalidad_ejecucion'],
                e['nombre_archivo']));
          });
          _onRefresh();
          _onLoading();
          return jsonDecode(respuesta.body);
        } else {
          return null;
        }
      } else {
        print("Error con la respuesta");
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
  final String fecha;

  DownloadItem({
    this.data,
    this.onItemClick,
    this.onActionClick,
    this.fecha,
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
              height: 70,
              child: Card(
                // RoundedRectangleBorder para proporcionarle esquinas circulares al Card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: Color.fromRGBO(9, 46, 116, 1.0)),
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
                            child: Text(data.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color.fromRGBO(9, 46, 116, 1.0),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                )))),
                    Expanded(
                      //columna fecha
                      flex: 2,
                      child: Text(fecha.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(9, 46, 116, 1.0),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          )),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildActionForTask(data.task),
                    )
                  ],
                ),
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
        child: Icon(
          Icons.file_download,
          color: Colors.blue,
        ),
        shape: CircleBorder(),
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
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
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
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
        constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
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
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return Text('Calcelado', style: TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
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
            constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
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
