
class DetailDepense {
  final int? id;
  final int? departureId;
  final String devise;
  final String categorie;
  final String? description;
  final String? dateDepense;
  final num montant;
  final num total;
  final int nombre;

  DetailDepense({
    this.id,
    this.departureId,
    required this.devise,
    required this.categorie,
    this.description,
    this.dateDepense,
    num? montant,
    required this.total,
    required this.nombre,
  }) : montant = montant ?? total;

  factory DetailDepense.fromJson(Map<String, dynamic> json) {
    num lireMontant(dynamic v) {
      if (v is num) return v;
      return num.tryParse(v?.toString() ?? '') ?? 0;
    }

    return DetailDepense(
      id: int.tryParse(json['id']?.toString() ?? ''),
      departureId: int.tryParse(json['departure_id']?.toString() ?? ''),
      devise: json['devise']?.toString() ?? 'FCFA',
      categorie: json['categorie']?.toString() ?? 'Divers',
      description: json['description']?.toString(),
      dateDepense: json['date_depense']?.toString(),
      montant: lireMontant(json['montant'] ?? json['total']),
      total: lireMontant(json['total'] ?? json['montant']),
      nombre: json['nombre'] is num
          ? (json['nombre'] as num).toInt()
          : 1,
    );
  }
}

class FinanceDevise {
  final num recettes;
  final num depenses;
  final num benefice;
  final num totalColis;
  final num montantEncaisse;
  final num resteAEncaisser;
  final int nombreColis;
  final int nombreColisPayes;
  final int nombreColisNonPayes;

  FinanceDevise({
    required this.recettes,
    required this.depenses,
    required this.benefice,
    this.totalColis = 0,
    this.montantEncaisse = 0,
    this.resteAEncaisser = 0,
    this.nombreColis = 0,
    this.nombreColisPayes = 0,
    this.nombreColisNonPayes = 0,
  });

  factory FinanceDevise.fromJson(Map<String, dynamic>? json) {
    num lireNombre(String cle) {
      final valeur = json?[cle];
      if (valeur is num) return valeur;
      return num.tryParse(valeur?.toString() ?? '') ?? 0;
    }

    return FinanceDevise(
      recettes: lireNombre('recettes'),
      depenses: lireNombre('depenses'),
      benefice: lireNombre('benefice'),
      totalColis: lireNombre('totalColis'),
      montantEncaisse: lireNombre('montantEncaisse'),
      resteAEncaisser: lireNombre('resteAEncaisser'),
      nombreColis: lireNombre('nombreColis').toInt(),
      nombreColisPayes: lireNombre('nombreColisPayes').toInt(),
      nombreColisNonPayes: lireNombre('nombreColisNonPayes').toInt(),
    );
  }
}

class FinancesData {
  final Map<String, FinanceDevise> global;
  final List<DetailDepense> detailDepenses;
  final List<dynamic> departsDisponibles;

  FinancesData({
    required this.global,
    required this.detailDepenses,
    required this.departsDisponibles,
  });

  factory FinancesData.fromJson(Map<String, dynamic> json) {
    final rawGlobal = json['global'];
    final parsedGlobal = <String, FinanceDevise>{};

    if (rawGlobal is Map) {
      rawGlobal.forEach((key, value) {
        if (value is Map) {
          parsedGlobal[key.toString()] = FinanceDevise.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    final rawDepenses = json['detailDepenses'];
    final rawDeparts = json['departsDisponibles'];

    return FinancesData(
      global: parsedGlobal,
      detailDepenses: rawDepenses is List
          ? rawDepenses
              .whereType<Map>()
              .map(
                (e) => DetailDepense.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : <DetailDepense>[],
      departsDisponibles: rawDeparts is List
          ? rawDeparts
          : <dynamic>[],
    );
  }
}

