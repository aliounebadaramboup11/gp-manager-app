require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(cors({ origin: '*' }));
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://localhost:5432/gp_manager',
  ssl: false
});

// Création de la table notifications
pool.query(`
  CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    host_email VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    est_lu BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
`);

// INSCRIPTION
app.post('/api/register', async (req, res) => {
  const { nom, email, telephone, mot_de_passe } = req.body;
  try { 
    const codeInvitation = 'GP-' + nom.substring(0, 4).toUpperCase() + '-' + Math.floor(1000 + Math.random() * 9000);
    await pool.query('INSERT INTO users (nom, email, telephone, mot_de_passe, code_invitation) VALUES ($1, $2, $3, $4, $5)', [nom, email, telephone, mot_de_passe, codeInvitation]); 
    res.status(201).json({ message: "OK" }); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

// CONNEXION
app.post('/api/login', async (req, res) => {
  const { email, mot_de_passe } = req.body;
  try { 
    const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]); 
    if (user.rows.length === 0 || user.rows[0].mot_de_passe !== mot_de_passe) return res.status(401).json({ message: "Erreur" }); 
    res.status(200).json({ message: "OK", user: user.rows[0] }); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

// CONNEXION INVITÉ
app.post('/api/login-invite', async (req, res) => {
  const { code_invitation, nom_invite } = req.body;
  try { 
    const user = await pool.query('SELECT * FROM users WHERE code_invitation = $1', [code_invitation]); 
    if (user.rows.length === 0) return res.status(401).json({ message: "Code invalide" }); 
    res.status(200).json({ message: "OK", host_email: user.rows[0].email, host_nom: user.rows[0].nom, invite_nom: nom_invite, masquer_montants: user.rows[0].masquer_montants_invites }); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

// PROFIL & ÉQUIPE
app.get('/api/users/:email', async (req, res) => {
  try { const user = await pool.query('SELECT nom, email, photo_profil, code_invitation, masquer_montants_invites FROM users WHERE email = $1', [req.params.email]); if (user.rows.length === 0) return res.status(404).json({ message: "Non trouvé" }); res.status(200).json(user.rows[0]); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.put('/api/users/:email/profil', async (req, res) => {
  const { nom, photo_profil } = req.body;
  try { await pool.query('UPDATE users SET nom = $1, photo_profil = $2 WHERE email = $3', [nom, photo_profil, req.params.email]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.put('/api/users/:email/code-invitation', async (req, res) => {
  const { code_invitation } = req.body;
  try { await pool.query('UPDATE users SET code_invitation = $1 WHERE email = $2', [code_invitation, req.params.email]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.put('/api/users/:email/masquer-montants', async (req, res) => {
  const { masquer } = req.body;
  try { await pool.query('UPDATE users SET masquer_montants_invites = $1 WHERE email = $2', [masquer, req.params.email]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

// NOTIFICATIONS
app.get('/api/notifications/:email', async (req, res) => {
  try { const n = await pool.query('SELECT * FROM notifications WHERE host_email = $1 ORDER BY created_at DESC', [req.params.email]); res.status(200).json(n.rows); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.put('/api/notifications/:email/read', async (req, res) => {
  try { await pool.query('UPDATE notifications SET est_lu = TRUE WHERE host_email = $1', [req.params.email]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

// PAIEMENT (Simulation)
app.post('/api/paiement/creer', async (req, res) => { setTimeout(() => { res.status(200).json({ message: "OK" }); }, 2000); });

// DÉPARTS
app.post('/api/departures', async (req, res) => { 
  const { reference, date_depart, lieu_depart, lieu_arrivee, owner_email, created_by } = req.body; 
  try { await pool.query('INSERT INTO departures (reference, date_depart, lieu_depart, lieu_arrivee, owner_email, created_by) VALUES ($1, $2, $3, $4, $5, $6)', [reference, date_depart, lieu_depart, lieu_arrivee, owner_email, created_by]); res.status(201).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); } 
});

app.get('/api/departures/:email', async (req, res) => {
  try {
    const departs = await pool.query('SELECT * FROM departures WHERE owner_email = $1 ORDER BY created_at DESC', [req.params.email]);
    const departsAvecStatut = departs.rows.map(depart => {
      const dateCreation = new Date(depart.created_at);
      const dateActuelle = new Date();
      const differenceEnHeures = (dateActuelle - dateCreation) / (1000 * 60 * 60);
      const estClotureParTemps = differenceEnHeures >= 168;
      const estFermeManuellement = depart.est_ferme_manuellement === true;
      return { ...depart, est_cloture: estClotureParTemps || estFermeManuellement, peut_etre_rouvert: estFermeManuellement && !estClotureParTemps };
    });
    res.status(200).json(departsAvecStatut);
  } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.put('/api/departures/:id/close', async (req, res) => { try { await pool.query('UPDATE departures SET est_ferme_manuellement = TRUE WHERE id = $1', [req.params.id]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); } });
app.put('/api/departures/:id/open', async (req, res) => { try { await pool.query('UPDATE departures SET est_ferme_manuellement = FALSE WHERE id = $1', [req.params.id]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); } });
app.delete('/api/departures/:id', async (req, res) => { try { await pool.query('DELETE FROM departures WHERE id = $1', [req.params.id]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); } });

// COLIS
app.post('/api/packages', async (req, res) => { 
  const { departure_id, nom_client, telephone_expediteur, telephone_destinataire, prix_transport, devise, photo_recto, photo_verso, created_by, host_email } = req.body; 
  try { 
    await pool.query('INSERT INTO packages (departure_id, nom_client, telephone_expediteur, telephone_destinataire, prix_transport, devise, photo_recto, photo_verso, created_by) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)', [departure_id, nom_client, telephone_expediteur, telephone_destinataire, prix_transport, devise, photo_recto, photo_verso, created_by]); 
    if (created_by !== host_email) {
      await pool.query('INSERT INTO notifications (host_email, message) VALUES ($1, $2)', [host_email, `${created_by} a ajouté le colis "${nom_client}"`]);
    }
    res.status(201).json({ message: "OK" }); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); } 
});

app.get('/api/packages/:departure_id/:user_email', async (req, res) => { 
  try { 
    const { departure_id } = req.params;
    const p = await pool.query('SELECT * FROM packages WHERE departure_id = $1 ORDER BY created_at DESC', [departure_id]); 
    res.status(200).json(p.rows); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); } 
});

app.delete('/api/packages/:id/:user_email/:host_email', async (req, res) => { 
  try { 
    const { id, user_email, host_email } = req.params;
    await pool.query('DELETE FROM packages WHERE id = $1', [id]); 
    if (user_email !== host_email) {
      await pool.query('INSERT INTO notifications (host_email, message) VALUES ($1, $2)', [host_email, `${user_email} a supprimé un colis`]);
    }
    res.status(200).json({ message: "OK" }); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); } 
});

app.put('/api/packages/:id/pay', async (req, res) => { try { await pool.query("UPDATE packages SET statut_paiement = 'Payé' WHERE id = $1", [req.params.id]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); } });
app.put('/api/packages/:id/unpay', async (req, res) => { try { await pool.query("UPDATE packages SET statut_paiement = 'Non payé' WHERE id = $1", [req.params.id]); res.status(200).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); } });

app.put('/api/packages/:id', async (req, res) => { 
  const { nom_client, telephone_expediteur, telephone_destinataire, prix_transport, devise, user_email, host_email } = req.body; 
  try { 
    await pool.query('UPDATE packages SET nom_client = $1, telephone_expediteur = $2, telephone_destinataire = $3, prix_transport = $4, devise = $5 WHERE id = $6', [nom_client, telephone_expediteur, telephone_destinataire, prix_transport, devise, req.params.id]); 
    if (user_email !== host_email) {
      await pool.query('INSERT INTO notifications (host_email, message) VALUES ($1, $2)', [host_email, `${user_email} a modifié le colis "${nom_client}"`]);
    }
    res.status(200).json({ message: "OK" }); 
  } catch (err) { res.status(500).json({ message: "Erreur" }); } 
});

// STATS & FINANCES
app.get('/api/stats/:email', async (req, res) => { try { const result = await pool.query(`SELECT SUM(p.prix_transport) as total FROM packages p JOIN departures d ON p.departure_id = d.id WHERE d.owner_email = $1 AND p.devise = 'FCFA' AND p.statut_paiement = 'Payé'`, [req.params.email]); res.status(200).json({ total_encaisse: result.rows[0].total || 0 }); } catch (err) { res.status(500).json({ message: "Erreur" }); } });

app.post('/api/expenses', async (req, res) => {
  const { owner_email, montant, devise, description, departure_id } = req.body;
  try { await pool.query('INSERT INTO expenses (owner_email, montant, devise, description, departure_id) VALUES ($1, $2, $3, $4, $5)', [owner_email, montant, devise, description, departure_id]); res.status(201).json({ message: "OK" }); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.get('/api/expenses/:email', async (req, res) => {
  try { const e = await pool.query('SELECT * FROM expenses WHERE owner_email = $1 ORDER BY date_depense DESC', [req.params.email]); res.status(200).json(e.rows); } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.get('/api/stats-financieres/:email', async (req, res) => {
  const { departure_id } = req.query;
  try {
    let recettesQuery = `SELECT SUM(p.prix_transport) as total FROM packages p JOIN departures d ON p.departure_id = d.id WHERE d.owner_email = $1 AND p.devise = 'FCFA' AND p.statut_paiement = 'Payé'`;
    let depensesQuery = `SELECT SUM(montant) as total FROM expenses WHERE owner_email = $1 AND devise = 'FCFA'`;
    let params = [req.params.email];

    if (departure_id && departure_id !== 'null') {
      recettesQuery += ` AND d.id = $2`;
      depensesQuery += ` AND departure_id = $2`;
      params.push(departure_id);
    }

    const recettes = await pool.query(recettesQuery, params);
    const depenses = await pool.query(depensesQuery, params);
    
    const totalRecettes = recettes.rows[0].total || 0;
    const totalDepenses = depenses.rows[0].total || 0;
    
    res.status(200).json({ recettes: totalRecettes, depenses: totalDepenses, benefice: totalRecettes - totalDepenses });
  } catch (err) { res.status(500).json({ message: "Erreur" }); }
});

app.get('/api/finances/:email', async (req, res) => {
  try {
    const { email } = req.params;
    const { departure_id, month, day } = req.query;
    
    const departsList = await pool.query('SELECT id, lieu_depart, lieu_arrivee, date_depart FROM departures WHERE owner_email = $1 ORDER BY date_depart DESC', [email]);

    let recettesQueryText = `SELECT CASE
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('fcfa','cfa','xof') THEN 'FCFA'
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('euro','euros','eur') THEN 'EURO'
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dollar','dollars','usd') THEN 'Dollars'
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dirham','dirhams','mad') THEN 'Dirham'
      WHEN LOWER(TRIM(COALESCE(devise,''))) = 'autre' OR TRIM(COALESCE(devise,'')) = '' THEN 'Autre'
      ELSE TRIM(devise) END AS devise,
      COALESCE(SUM(prix_transport), 0) AS total
      FROM packages p JOIN departures d ON d.id = p.departure_id
      WHERE d.owner_email = $1 AND p.statut_paiement = 'Payé'`;
    let recettesParams = [email];
    if (departure_id) { recettesQueryText += ` AND d.id = $${recettesParams.length + 1}`; recettesParams.push(departure_id); }
    else if (day) { recettesQueryText += ` AND DATE(d.date_depart) = $${recettesParams.length + 1}`; recettesParams.push(day); }
    else if (month) { recettesQueryText += ` AND TO_CHAR(d.date_depart, 'YYYY-MM') = $${recettesParams.length + 1}`; recettesParams.push(month); }
    recettesQueryText += ` GROUP BY CASE WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('fcfa','cfa','xof') THEN 'FCFA' WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('euro','euros','eur') THEN 'EURO' WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dollar','dollars','usd') THEN 'Dollars' WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dirham','dirhams','mad') THEN 'Dirham' WHEN LOWER(TRIM(COALESCE(devise,''))) = 'autre' OR TRIM(COALESCE(devise,'')) = '' THEN 'Autre' ELSE TRIM(devise) END`;
    const recettesQuery = await pool.query(recettesQueryText, recettesParams);

    let depensesQueryText = `SELECT CASE
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('fcfa','cfa','xof') THEN 'FCFA'
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('euro','euros','eur') THEN 'EURO'
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dollar','dollars','usd') THEN 'Dollars'
      WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dirham','dirhams','mad') THEN 'Dirham'
      WHEN LOWER(TRIM(COALESCE(devise,''))) = 'autre' OR TRIM(COALESCE(devise,'')) = '' THEN 'Autre'
      ELSE TRIM(devise) END AS devise,
      categorie, COALESCE(SUM(montant), 0) AS total, COUNT(*) AS nombre
      FROM depenses WHERE owner_email = $1`;
    let depensesParams = [email];
    if (departure_id) { depensesQueryText += ` AND departure_id = $${depensesParams.length + 1}`; depensesParams.push(departure_id); }
    else if (day) { depensesQueryText += ` AND DATE(date_depense) = $${depensesParams.length + 1}`; depensesParams.push(day); }
    else if (month) { depensesQueryText += ` AND TO_CHAR(date_depense, 'YYYY-MM') = $${depensesParams.length + 1}`; depensesParams.push(month); }
    depensesQueryText += ` GROUP BY CASE WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('fcfa','cfa','xof') THEN 'FCFA' WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('euro','euros','eur') THEN 'EURO' WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dollar','dollars','usd') THEN 'Dollars' WHEN LOWER(TRIM(COALESCE(devise,''))) IN ('dirham','dirhams','mad') THEN 'Dirham' WHEN LOWER(TRIM(COALESCE(devise,''))) = 'autre' OR TRIM(COALESCE(devise,'')) = '' THEN 'Autre' ELSE TRIM(devise) END, categorie`;
    const depensesQuery = await pool.query(depensesQueryText, depensesParams);

    let finances = {}; 
    recettesQuery.rows.forEach(r => {
      if (!finances[r.devise]) finances[r.devise] = { recettes: 0, depenses: 0, benefice: 0 };
      finances[r.devise].recettes = Number(r.total);
    });

    let detailDepenses = [];
    depensesQuery.rows.forEach(d => {
      if (!finances[d.devise]) finances[d.devise] = { recettes: 0, depenses: 0, benefice: 0 };
      finances[d.devise].depenses += Number(d.total);
      detailDepenses.push({ devise: d.devise, categorie: d.categorie, total: Number(d.total), nombre: Number(d.nombre) });
    });

    Object.keys(finances).forEach(dev => {
      finances[dev].benefice = finances[dev].recettes - finances[dev].depenses;
    });

    res.status(200).json({ global: finances, detailDepenses: detailDepenses, departsDisponibles: departsList.rows });
  } catch (err) { res.status(500).json({ error: 'Erreur serveur' }); }
});

// 4. DEPENSES (Celle qu'on essayait d'ajouter)
app.post('/api/depenses', async (req, res) => {
  try {
    const { departure_id, owner_email, categorie, description, montant, devise, date_depense } = req.body;
    if (!owner_email || !categorie || !montant) return res.status(400).json({ error: 'Champs requis' });
    
    const result = await pool.query(
      "INSERT INTO depenses (departure_id, owner_email, categorie, description, montant, devise, date_depense) VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7, CURRENT_DATE)) RETURNING *",
      [departure_id || null, owner_email, categorie, description || null, Number(montant), devise || 'FCFA', date_depense]
    );
    res.status(201).json({ message: 'Dépense ajoutée', depense: result.rows[0] });
  } catch (err) { res.status(500).json({ error: 'Erreur serveur' }); }
});

// ... (Je te laisse remettre tes autres routes pour les colis, départs, etc. si besoin)

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => { console.log(`Serveur démarré sur le port ${PORT}`); });
