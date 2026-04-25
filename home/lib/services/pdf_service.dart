// lib/services/pdf_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateInvoicePDF(InvoiceModel invoice, BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'HOMEOPATHY CLINIC',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('123 Healthcare Avenue, Medical District'),
                pw.Text('Phone: +91 98765 43210 | Email: info@homeopathyclinic.com'),
                pw.SizedBox(height: 20),
                pw.Divider(),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Invoice #: ${invoice.id.substring(0, 8)}'),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(invoice.date)}'),
                ],
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Text(
                  invoice.status.toUpperCase(),
                  style: pw.TextStyle(
                    color: invoice.status == 'paid' ? PdfColors.green : PdfColors.orange,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Patient Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Name: ${invoice.patientName}'),
                pw.Text('Patient ID: ${invoice.patientId.substring(0, 8)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                ],
              ),
              ...invoice.items.map((item) => pw.TableRow(
                children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(item['name'])),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(item['quantity'].toString())),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('₹${item['price']}')),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}')),
                ],
              )),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    children: [
                      pw.Text('Subtotal: ', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('₹${invoice.amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Text('GST (0%): ', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('₹0.00', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Text('Total Amount: ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('₹${invoice.amount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text('Authorized Signature', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                  pw.SizedBox(height: 20),
                  pw.Text('_________________', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text('Payment Method: ${invoice.paymentMethod}', style: pw.TextStyle(fontSize: 10)),
                  pw.Text('Thank you for your visit!', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice_${invoice.id.substring(0, 8)}.pdf');
  }
}