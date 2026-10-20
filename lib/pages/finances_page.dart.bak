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
  String? _selectedMonth; // ex: '2026-10'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = ApiService().getFinances(widget.email, month: _selectedMonth);
    });
  }

  String _formatMontant(num montant, String devise) {
    final str = montant.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
    return '$str $devise';
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nouvelle Dépense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: categorie,
                decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                items: ['Douane', 'Transport', 'Divers']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => categorie = v!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: montantController,
                      decoration: const InputDecoration(labelText: 'Montant', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: devise,
                      decoration: const InputDecoration(labelText: 'Devise', border: OutlineInputBorder()),
                      items: ['FCFA', 'EUR']
                          .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => devise = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description (optionnel)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context); // Fermer le dialogue
                      final success = await ApiService().addDepense(
                        ownerEmail: widget.email,
                        categorie: categorie,
                        description: descController.text,
                        montant: int.parse(montantController.text),
                        devise: devise,
                      );
                      if (success) {
                        _loadData(); // Rafraîchir
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dépense ajoutée !')));
                      }
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
    );
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
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filtrer par mois',
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                helpText: 'Choisir un mois',
              );
              if (picked != null) {
                setState(() {
                  _selectedMonth = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
                });
                _loadData();
              }
            },
          ),
          if (_selectedMonth != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Effacer le filtre',
              onPressed: () {
                setState(() => _selectedMonth = null);
                _loadData();
              },
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
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final data = snapshot.data;
          if (data == null) return const Center(child: Text('Aucune donnée'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedMonth != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Chip(
                      label: Text('Filtre : $_selectedMonth'),
                      onDeleted: () {
                        setState(() => _selectedMonth = null);
                        _loadData();
                      },
                    ),
                  ),
                
                _buildDeviseSection('FCFA', data.fcfa),
                const SizedBox(height: 24),

                if (data.eur.recettes > 0 || data.eur.depenses > 0) ...[
                  _buildDeviseSection('EUR', data.eur),
                  const SizedBox(height: 24),
                ],

                const Text('Détail des dépenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (data.detailDepenses.isEmpty)
                  const Text('Aucune dépense enregistrée.')
                else
                  ...data.detailDepenses.map((d) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[100],
                        child: const Icon(Icons.arrow_downward, color: Colors.red),
                      ),
                      title: Text(d.categorie),
                      subtitle: Text('${d.nombre} opération(s)'),
                      trailing: Text(
                        '- ${_formatMontant(d.total, d.devise)}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDepenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Dépense'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDeviseSection(String devise, FinanceDevise finance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bilan en $devise', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCard('Recettes', finance.recettes, Colors.green, Icons.trending_up, devise),
            const SizedBox(width: 8),
            _buildCard('Dépenses', finance.depenses, Colors.red, Icons.trending_down, devise),
          ],
        ),
        const SizedBox(height: 8),
        _buildCard('Bénéfice Net', finance.benefice, finance.benefice >= 0 ? Colors.blue : Colors.orange, Icons.account_balance_wallet, devise, fullWidth: true),
      ],
    );
  }

  Widget _buildCard(String title, num amount, Color color, IconData icon, String devise, {bool fullWidth = false}) {
    return Expanded(
      flex: fullWidth ? 0 : 1,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
      ),
    );
  }
}
