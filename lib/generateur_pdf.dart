import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateurPdf {
  static Future<void> genererManifeste({
    required Map<String, dynamic> depart,
    required List<dynamic> colis,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GP MANAGER', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.amber)),
                  pw.Text('Manifeste de vol', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Infos du vol
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(5)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Départ : ${depart['lieu_depart']} ➔ ${depart['lieu_arrivee']}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Date du vol : ${depart['date_depart'].toString().substring(0, 10)}'),
                  pw.Text('Référence : ${depart['reference']}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tableau des colis
            pw.Text('Liste des colis (${colis.length})', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['N°', 'Nom du client', 'Prix', 'Devise', 'Statut'],
              data: List<List<String>>.generate(colis.length, (index) {
                final c = colis[index];
                return [
                  (index + 1).toString(),
                  c['nom_client'].toString(),
                  c['prix_transport'].toString(),
                  c['devise'].toString(),
                  c['statut_paiement'].toString(),
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            
            // Pied de page
            pw.Divider(),
            pw.Text('Document généré par GP Manager. Développé par ABNEXT Technologie.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ];
        },
      ),
    );

    // Cette ligne ouvre l'aperçu d'impression (ou téléchargement)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
