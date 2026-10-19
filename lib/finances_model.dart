class DetailDepense {
  final String devise;
  final String categorie;
  final num total;
  final int nombre;

  DetailDepense({required this.devise, required this.categorie, required this.total, required this.nombre});

  factory DetailDepense.fromJson(Map<String, dynamic> json) {
    return DetailDepense(
      devise: json['devise']?.toString() ?? 'FCFA',
      categorie: json['categorie']?.toString() ?? 'Divers',
      total: (json['total'] as num?) ?? 0,
      nombre: (json['nombre'] as num?)?.toInt() ?? 0,
    );
  }
}

class FinanceDevise {
  final num recettes;
  final num depenses;
  final num benefice;

  FinanceDevise({required this.recettes, required this.depenses, required this.benefice});

  factory FinanceDevise.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FinanceDevise(recettes: 0, depenses: 0, benefice: 0);
    return FinanceDevise(
      recettes: (json['recettes'] as num?) ?? 0,
      depenses: (json['depenses'] as num?) ?? 0,
      benefice: (json['benefice'] as num?) ?? 0,
    );
  }
}

class FinancesData {
  final FinanceDevise fcfa;
  final FinanceDevise eur;
  final List<DetailDepense> detailDepenses;

  FinancesData({required this.fcfa, required this.eur, required this.detailDepenses});

  factory FinancesData.fromJson(Map<String, dynamic> json) {
    final global = json['global'] as Map<String, dynamic>? ?? {};
    return FinancesData(
      fcfa: FinanceDevise.fromJson(global['FCFA'] as Map<String, dynamic>?),
      eur: FinanceDevise.fromJson(global['EUR'] as Map<String, dynamic>?),
      detailDepenses: (json['detailDepenses'] as List? ?? [])
          .map((e) => DetailDepense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
