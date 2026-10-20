class DetailDepense {
  final String devise;
  final String categorie;
  final num total;
  final int nombre;

  DetailDepense({
    required this.devise,
    required this.categorie,
    required this.total,
    required this.nombre,
  });

  factory DetailDepense.fromJson(Map<String, dynamic> json) {
    return DetailDepense(
      devise: json['devise']?.toString() ?? 'FCFA',
      categorie: json['categorie']?.toString() ?? 'Divers',
      total: json['total'] is num ? json['total'] as num : 0,
      nombre: json['nombre'] is num
          ? (json['nombre'] as num).toInt()
          : 0,
    );
  }
}

class FinanceDevise {
  final num recettes;
  final num depenses;
  final num benefice;

  FinanceDevise({
    required this.recettes,
    required this.depenses,
    required this.benefice,
  });

  factory FinanceDevise.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FinanceDevise(
        recettes: 0,
        depenses: 0,
        benefice: 0,
      );
    }

    return FinanceDevise(
      recettes: json['recettes'] is num
          ? json['recettes'] as num
          : 0,
      depenses: json['depenses'] is num
          ? json['depenses'] as num
          : 0,
      benefice: json['benefice'] is num
          ? json['benefice'] as num
          : 0,
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
