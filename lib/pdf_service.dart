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
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            // --- EN-TÊTE ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('GP MANAGER', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Vos voyages, notre priorité.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('MANIFESTE', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Réf: $departReference', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.blue900, thickness: 2),
            pw.SizedBox(height: 12),

            // --- INFOS DEPART ---
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Trajet : $lieuDepart ➔ $lieuArrivee', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date du vol : ${dateDepart.length >= 10 ? dateDepart.substring(0, 10) : dateDepart}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // --- TABLEAU DES COLIS ---
            pw.Text('Liste des colis', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Client', 'Tél. Exp.', 'Tél. Dest.', 'Prix', 'Statut'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 9),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },
              data: colis.map((c) {
                return [
                  c['nom_client']?.toString() ?? '',
                  c['telephone_expediteur']?.toString() ?? '-',
                  c['telephone_destinataire']?.toString() ?? '-',
                  '${_formatMontant(c['prix_transport'])} ${c['devise']}',
                  c['statut_paiement']?.toString() ?? '',
                ];
              }).toList(),
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Généré par GP Manager', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    // Ouvre l'aperçu d'impression (permet d'enregistrer en PDF)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Manifeste_$departReference',
    );
  }
}
