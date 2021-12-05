/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'examples.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int _tab = 0;
  TabController? _tabController;

  PrintingInfo? printingInfo;

  late SharedPreferences _prefs;
  late int _counter;

  var _data = const CustomData();
  var _hasData = false;
  var _pending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    _prefs = await SharedPreferences.getInstance();

    if (examples[_tab].needsData && !_hasData && !_pending) {
      _pending = true;
      askName(context).then((data) {
        if (_data != null) {
          setState(() {
            _data = CustomData(
                origen: _data.origen,
                destino: _data.destino,
                precio: _data.precio,
                numRecibo: _data.numRecibo);
            _hasData = true;
            _pending = false;
          });
        }
      });
      // Obtnemos el ultimo numero de recibo

      _counter = _prefs.getInt('counter') ?? 0;
    }

    _tabController = TabController(
      vsync: this,
      length: examples.length,
      initialIndex: _tab,
    );

    // SI HAY MAS DE UN TAB, HAY QUE ACTIVAR ESTO.
    // _tabController!.addListener(() {
    //   if (_tab != _tabController!.index) {
    //     setState(() {
    //       _tab = _tabController!.index;
    //     });
    //   }
    //   if (examples[_tab].needsData && !_hasData && !_pending) {
    //     print(_tab);
    //     _pending = true;
    //     askName(context).then((value) {
    //       if (value != null) {
    //         setState(() {
    //           _data = CustomData(name: value);
    //           _hasData = true;
    //           _pending = false;
    //         });
    //       }
    //     });
    //   }
    // });

    setState(() {
      printingInfo = info;
    });
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document shared successfully'),
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + 'document.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('VTC Recibos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: examples.map<Tab>((e) => Tab(text: e.name)).toList(),
          isScrollable: true,
        ),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (format) => examples[_tab].builder(format, _data),
        actions: actions,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
      // Boton Naranja
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () => Navigator.popAndPushNamed(context, 'inicio'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  void _showSources() {
    // return Navigator.pop(context);
  }

  Future<String?> askName(BuildContext context) {
    return showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final controllerOrigen = TextEditingController();
          final controllerDestino = TextEditingController();
          final controllerPrecio = TextEditingController();

          return AlertDialog(
            title: const Text('Datos del recibo:'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Direccion de origen'),
                  controller: controllerOrigen,
                ),
                TextField(
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Direccion de destino'),
                  controller: controllerDestino,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Precio'),
                  keyboardType: TextInputType.number,
                  controller: controllerPrecio,
                ),
                // TextField(
                //   decoration: const InputDecoration(hintText: 'Observaciones'),
                //   keyboardType: TextInputType.number,
                //   controller: controllerPrecio,
                // ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (controllerOrigen.text != '' &&
                      controllerDestino.text != '' &&
                      controllerPrecio.text != '') {
                    _counter = _counter + 1;
                    print(_counter);
                    _prefs.setInt('counter', _counter);
                    var data = CustomData(
                        origen: controllerOrigen.text,
                        destino: controllerDestino.text,
                        precio: controllerPrecio.text,
                        numRecibo: _counter);
                    _data = data;

                    Navigator.pop(context, '');
                  }
                },
                child: const Text('Nuevo Recibo'),
              ),
            ],
          );
        });
  }
}
