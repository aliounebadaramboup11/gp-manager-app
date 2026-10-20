import 'package:flutter/material.dart';
import '../api_service.dart';
import '../finances_model.dart';

class FinancesPage extends StatefulWidget {
  final String email;

  const FinancesPage({super.key, required this.email});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  late Future<FinancesData> _future;
  String? _selectedMonth;
  String? _selectedDay;
  int? _selectedDepartureId;

  @override
  void initState() {
    super.initState();
    _future = _fetchData();
  }

  Future<FinancesData> _fetchData() {
    return ApiService().getFinances(
      widget.email,
      month: _selectedMonth,
      day: _selectedDay,
      departureId: _selectedDepartureId,
    );
  }

  void _loadData() {
    setState(() {
      _future = _fetchData();
    });
  }

  String _formatMontant(num montant, String devise) {
    final str = montant.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ' ',
    );
    return '$str $devise';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _departureLabel(Map<String, dynamic> d) {
    final from = d['lieu_depart']?.toString() ?? 'Départ';
    final to = d['lieu_arrivee']?.toString() ?? 'Arrivée';
    final rawDate = d['date_depart']?.toString();
    final date = rawDate == null ? null : DateTime.tryParse(rawDate);
    return '$from → $to${date == null ? '' : ' • ${_formatDate(date.toLocal())}'}';
  }

  Future<void> _chooseDate({required bool chooseDay}) async {
    final now = DateTime.now();
    final initial = _selectedDay != null
        ? DateTime.tryParse(_selectedDay!) ?? now
        : _selectedMonth != null
            ? DateTime.tryParse('$_selectedMonth-01') ?? now
            : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: chooseDay ? 'Choisir un jour' : 'Choisir un mois',
      cancelText: 'ANNULER',
      confirmText: 'CONFIRMER',
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDepartureId = null;
      if (chooseDay) {
        _selectedDay =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}';
        _selectedMonth = null;
      } else {
        _selectedMonth =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
        _selectedDay = null;
      }
      _future = _fetchData();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedMonth = null;
      _selectedDay = null;
      _selectedDepartureId = null;
      _future = _fetchData();
    });
  }

  void _showAddDepenseDialog() {
    final formKey = GlobalKey<FormState>();
    String categorie = 'Douane';
    String devise = 'FCFA';
    final descController = TextEditingController();
    final montantController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle Dépense',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: categorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Douane', 'Transport', 'Divers']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) categorie = v;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: montantController,
                        decoration: const InputDecoration(
                          labelText: 'Montant',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final montant = num.tryParse(v ?? '');
                          return montant == null || montant <= 0
                              ? 'Montant invalide'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: devise,
                        decoration: const InputDecoration(
                          labelText: 'Devise',
                          border: OutlineInputBorder(),
                        ),
                        items: ['FCFA', 'EUR', 'MAD', 'USD']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) devise = v;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final montant = num.parse(montantController.text).round();
                      Navigator.pop(sheetContext);

                      try {
                        final success = await ApiService().addDepense(
                          ownerEmail: widget.email,
                          categorie: categorie,
                          description: descController.text,
                          montant: montant,
                          devise: devise,
                        );

                        if (!mounted) return;

                        if (success) {
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dépense ajoutée !')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La dépense n’a pas été enregistrée.'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : $e')),
                        );
                      } finally {
                        descController.dispose();
                        montantController.dispose();
                      }
                    },
                    child: const Text('Enregistrer la dépense'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<dynamic> departs) {
    final items = <DropdownMenuItem<int>>[];
    final ids = <int>{};

    for (final item in departs) {
      if (item is! Map) continue;
      final d = Map<String, dynamic>.from(item);
      final id = int.tryParse(d['id']?.toString() ?? '');
      if (id == null || !ids.add(id)) continue;

      items.add(
        DropdownMenuItem<int>(
          value: id,
          child: Text(_departureLabel(d), overflow: TextOverflow.ellipsis),
        ),
      );
    }

    final validIds = items.map((e) => e.value).toSet();
    final selectedId = validIds.contains(_selectedDepartureId)
        ? _selectedDepartureId
        : null;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer les finances',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _chooseDate(chooseDay: false),
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_selectedMonth ?? 'Par mois'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _chooseDate(chooseDay: true),
                  icon: const Icon(Icons.event),
                  label: Text(
                    _selectedDay == null
                        ? 'Par jour'
                        : _formatDate(DateTime.parse(_selectedDay!)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Tout afficher'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Départ spécifique',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flight_takeoff),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Tous les départs'),
                ),
                ...items,
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDepartureId = value;
                  _selectedMonth = null;
                  _selectedDay = null;
                  _future = _fetchData();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviseSection(String devise, FinanceDevise finance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bilan en $devise',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCard('Recettes', finance.recettes, Colors.green, Icons.trending_up, devise),
            const SizedBox(width: 8),
            _buildCard('Dépenses', finance.depenses, Colors.red, Icons.trending_down, devise),
          ],
        ),
        const SizedBox(height: 8),
        _buildCard(
          'Bénéfice net',
          finance.benefice,
          finance.benefice >= 0 ? Colors.blue : Colors.orange,
          Icons.account_balance_wallet,
          devise,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    num amount,
    Color color,
    IconData icon,
    String devise, {
    bool fullWidth = false,
  }) {
    final card = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatMontant(amount, devise),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );

    return fullWidth ? card : Expanded(child: card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mes Finances', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<FinancesData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur : ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Aucune donnée disponible.'));
          }

          final devises = data.global.entries.toList()
            ..sort((a, b) {
              if (a.key == 'FCFA') return -1;
              if (b.key == 'FCFA') return 1;
              return a.key.compareTo(b.key);
            });

          return RefreshIndicator(
            onRefresh: () async {
              _loadData();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilters(data.departsDisponibles),
                const SizedBox(height: 20),
                if (devises.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aucun bilan disponible pour cette sélection.'),
                    ),
                  )
                else
                  ...devises.expand(
                    (entry) => [
                      _buildDeviseSection(entry.key, entry.value),
                      const SizedBox(height: 20),
                    ],
                  ),
                const Text(
                  'Détail des dépenses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.detailDepenses.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Aucune dépense enregistrée pour ce filtre.'),
                    ),
                  )
                else
                  ...data.detailDepenses.map(
                    (d) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: const Icon(Icons.arrow_downward, color: Colors.red),
                        ),
                        title: Text(d.categorie),
                        subtitle: Text('${d.nombre} opération(s) • ${d.devise}'),
                        trailing: Text(
                          '- ${_formatMontant(d.total, d.devise)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDepenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Dépense'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
    );
  }
}
