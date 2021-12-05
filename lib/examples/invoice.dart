// ignore_for_file: public_member_api_docs

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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data.dart';

String _precioBase = '';
String _iva = '';
String _precioTotal = '';

Future<Uint8List> generateInvoice(
    PdfPageFormat pageFormat, CustomData data) async {
  final lorem = pw.LoremText();

  print(data.precio);

  final products = <Product>[
    Product('19874', lorem.sentence(4), 3.99, 2),
    Product('98452', lorem.sentence(6), 15, 2),
    Product('28375', lorem.sentence(4), 6.95, 3),
    Product('95673', lorem.sentence(3), 49.99, 4),
    Product('23763', lorem.sentence(2), 560.03, 1),
    Product('55209', lorem.sentence(5), 26, 1),
    Product('09853', lorem.sentence(5), 26, 1),
    Product('23463', lorem.sentence(5), 34, 1),
    Product('56783', lorem.sentence(5), 7, 4),
    Product('78256', lorem.sentence(5), 23, 1),
    Product('23745', lorem.sentence(5), 94, 1),
    Product('07834', lorem.sentence(5), 12, 1),
    Product('23547', lorem.sentence(5), 34, 1),
    Product('98387', lorem.sentence(5), 7.99, 2),
  ];

  final invoice = Invoice(
    invoiceNumber: '982347',
    products: products,
    customerName: 'Angel Sandin Sanchez - CNAE: Autotaxi',
    customerAddress: 'Sant Cugat del valles',
    paymentInfo: 'Licencia 12592037',
    tax: .10,
    baseColor: PdfColors.teal,
    accentColor: PdfColors.white,
  );

  return await invoice.buildPdf(pageFormat, data);
}

class Invoice {
  Invoice({
    required this.products,
    required this.customerName,
    required this.customerAddress,
    required this.invoiceNumber,
    required this.tax,
    required this.paymentInfo,
    required this.baseColor,
    required this.accentColor,
  });

  final List<Product> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final String paymentInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;

  static const _darkColor = PdfColors.black;
  static const _lightColor = PdfColors.black;

  PdfColor get _baseTextColor => baseColor.isLight ? _lightColor : _darkColor;

  PdfColor get _accentTextColor => baseColor.isLight ? _lightColor : _darkColor;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat, CustomData data) async {
    // Create a PDF document.
    final doc = pw.Document();

    print(data.numRecibo);

    final qr = await rootBundle.loadString('assets/qr.svg');

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          await PdfGoogleFonts.robotoRegular(),
          await PdfGoogleFonts.robotoBold(),
          await PdfGoogleFonts.robotoItalic(),
        ),
        header: _buildHeader,
        //footer: _buildFooter,
        build: (context) => [
          prueba(context, data),
          imagen(context, qr),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget prueba(pw.Context context, CustomData data) {
    _formatCurrency(data.precio);
    final double _fontSize = 20;
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: accentColor,
      ),
      padding: const pw.EdgeInsets.only(left: 20, top: 0, bottom: 0, right: 20),
      alignment: pw.Alignment.center,
      height:
          500, // Modificar este datos para que aparezca mas margen entre lineas
      child: pw.DefaultTextStyle(
        style: pw.TextStyle(
          color: _accentTextColor,
          fontSize: 25,
        ),
        child: pw.GridView(
          crossAxisCount: 2,
          children: [
            pw.Text('ANGEL SANDIN SANCHEZ',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('CIF: 46711299-R',
                textAlign: pw.TextAlign.right,
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Divider(),
            pw.Text('RECIBO NUMERO:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(data.numRecibo.toString(),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('FECHA Y HORA:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(_formatDate(DateTime.now()),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('CNAE:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('721.2 - AUTOTAXI',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('LICENCIA:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('12592037',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('MATRICULA:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('3838-KLP',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('TELEFONO:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('93.100.11.00',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(''),
            pw.Text(''),
            pw.Divider(),
            pw.Divider(),
            pw.Text('DATOS SERVICIO',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Divider(),
            pw.Divider(),
            pw.Text(''),
            pw.Text(''),
            pw.Text('ORIGEN:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(data.origen,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 14)),
            pw.Text(''),
            pw.Text('',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('DESTINO:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(data.destino,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 14)),
            pw.Text(''),
            pw.Text('', textAlign: pw.TextAlign.right),
            pw.Divider(),
            pw.Divider(),
            pw.Text('IMPORTE',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Divider(),
            pw.Divider(),
            pw.Text(''),
            pw.Text(''),
            pw.Text('PRECIO BRUTO:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(_precioBase,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('10% IVA:', style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text(_iva,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: _fontSize)),
            pw.Text('PRECIO TOTAL:',
                style: pw.TextStyle(
                    fontSize: _fontSize, fontWeight: pw.FontWeight.bold)),
            pw.Text(_precioTotal,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                    fontSize: _fontSize, fontWeight: pw.FontWeight.bold)),
            pw.Text(''),
            pw.Text(''),
            pw.Divider(),
            pw.Divider(),
            pw.Text(''),
            pw.Text(''),
            pw.Text(''),
            pw.Text(''),
          ],
        ),
      ),
    );
  }

  pw.Widget imagen(pw.Context context, String qr) {
    return pw.Container(
        height: 400,
        padding: const pw.EdgeInsets.all(60),
        child: pw.SvgImage(svg: qr, fit: pw.BoxFit.fill, height: 200),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(20)));
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 80,
                    padding: const pw.EdgeInsets.only(left: 2),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'RECIBO VTC - GROC I NEGRE',
                      style: pw.TextStyle(
                        color: _baseTextColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          height: 20,
          width: 100,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.pdf417(),
            data: 'Invoice# $invoiceNumber',
            drawText: false,
          ),
        ),
        pw.Text(
          'Page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        //child: pw.SvgImage(svg: _bgShape!),
      ),
    );
  }
}

String _formatCurrency(String precio) {
  double? amount;

  try {
    amount = double.parse(precio);
  } catch (e) {
    amount = null;
  }
  if (amount == null) {
    return '0.00 €';
  } else {
    _precioTotal = '${amount.toStringAsFixed(2)} €';

    _precioBase = '${(amount / 1.1).toStringAsFixed(2)} €';
    _iva = '${(amount - (amount / 1.1)).toStringAsFixed(2)} €';

    return '';
  }
}

String _formatDate(DateTime date) {
  initializeDateFormatting('es');
  final format = DateFormat.yMd('es').add_jm();
  return format.format(date);
}

class Product {
  const Product(
    this.sku,
    this.productName,
    this.price,
    this.quantity,
  );

  final String sku;
  final String productName;
  final double price;
  final int quantity;
  double get total => price * quantity;
}
