import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static String _formatMontant(dynamic montant) {
    if (montant == null) return '0';
    final num = int.tryParse(montant.toString()) ?? 0;
    return num.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ');
  }

  static Future<void> genererManifeste({
    required String departReference,
    required String lieuDepart,
    required String lieuArrivee,
    required String dateDepart,
    required List<dynamic> colis,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('GP MANAGER', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Vos voyages, notre priorité.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('MANIFESTE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Réf: ${departReference}', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.blue900, thickness: 2),
            pw.SizedBox(height: 16),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Départ : ${lieuDepart.isNotEmpty ? lieuDepart : "Non renseigné"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Arrivée : ${lieuArrivee.isNotEmpty ? lieuArrivee : "Non renseigné"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Text('Date : ${dateDepart.length >= 10 ? dateDepart.substring(0, 10) : dateDepart}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            pw.Text('Liste des colis', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['N°', 'Client', 'Téléphone', 'Prix', 'Statut', 'Devise'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              data: colis.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final c = entry.value;
                return [
                  index.toString(),
                  c['nom_client']?.toString() ?? '',
                  c['telephone_expediteur']?.toString() ?? '',
                  _formatMontant(c['prix_transport']),
                  c['statut_paiement']?.toString() ?? '',
                  c['devise']?.toString() ?? 'FCFA',
                ];
              }).toList(),
            ),
            
            pw.SizedBox(height: 32),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Généré par GP Manager', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Manifeste_${departReference}',
    );
  }
}
