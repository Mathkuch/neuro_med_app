// examen_clinique_neuro.dart
// Widget inline — examen neurologique adapté à l'âge (pas de dialog)

import 'dart:collection' show LinkedHashMap;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Modèle de données
// ─────────────────────────────────────────────────────────────────────────────

enum EtatExamen { normal, anormal, nonFait }

class ItemExamen {
  final String label;
  EtatExamen etat;
  final TextEditingController detailCtrl;

  ItemExamen(this.label, {this.etat = EtatExamen.normal})
      : detailCtrl = TextEditingController();

  void dispose() => detailCtrl.dispose();

  String get detail => detailCtrl.text.trim();
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widget principal (embarqué dans l'onglet)
// ─────────────────────────────────────────────────────────────────────────────

class ExamenNeuroWidget extends StatefulWidget {
  /// Âge en années (ex. 1.5 = 18 mois).
  final double ageAns;

  /// Appelé à chaque modification — transmet le texte mis en forme.
  final ValueChanged<String> onChanged;

  const ExamenNeuroWidget({
    super.key,
    required this.ageAns,
    required this.onChanged,
  });

  @override
  State<ExamenNeuroWidget> createState() => _ExamenNeuroWidgetState();
}

class _ExamenNeuroWidgetState extends State<ExamenNeuroWidget> {
  int get _ageM => (widget.ageAns * 12).round();

  late Map<String, List<ItemExamen>> _sections;
  final Map<String, bool> _expanded = {};
  final TextEditingController _commentCtrl = TextEditingController();

  static const Color _blueCHRU = Color(0xFF00599A);

  // ── Cycle de vie ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _sections = _buildSections(_ageM);
    for (final k in _sections.keys) _expanded[k] = true;
    _commentCtrl.addListener(_notify);
  }

  @override
  void didUpdateWidget(ExamenNeuroWidget old) {
    super.didUpdateWidget(old);
    final int newAgeM = (widget.ageAns * 12).round();
    final int oldAgeM = (old.ageAns * 12).round();
    if (newAgeM != oldAgeM) {
      // L'âge a changé : on reconstruit les sections
      for (final items in _sections.values) {
        for (final item in items) item.dispose();
      }
      _sections = _buildSections(newAgeM);
      _expanded.clear();
      for (final k in _sections.keys) _expanded[k] = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
    }
  }

  @override
  void dispose() {
    for (final items in _sections.values) {
      for (final item in items) item.dispose();
    }
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── Notification parent ───────────────────────────────────────────────────────

  void _notify() => widget.onChanged(_buildTexte());

  void _setEtat(ItemExamen item, EtatExamen etat) {
    setState(() => item.etat = etat);
    _notify();
  }

  // ── Construction des sections selon l'âge ────────────────────────────────────

  static Map<String, List<ItemExamen>> _buildSections(int ageM) {
    final sections = LinkedHashMap<String, List<ItemExamen>>();

    // ── 1. NEUROLOGIQUE ──────────────────────────────────────────────────────
    final neuro = <ItemExamen>[];

    if (ageM < 18) {
      neuro.addAll([
        ItemExamen('Mobilité harmonieuse des 4 membres'),
        ItemExamen('Tonus passif et actif, central et périphérique sans particularité'),
      ]);
    }

    if (ageM <= 3) {
      neuro.addAll([
        ItemExamen('Tiré-assis : bonne tenue de tête'),
        ItemExamen(
            'Suspension ventrale adaptée (tête alignée plan dorsal (1-2 mois) /'
            ' au-dessus (3-4 mois), membres semi-fléchis)'),
        ItemExamen('Signe de Moro présent'),
        ItemExamen('Réflexe tonique asymétrique de la nuque présent'),
        ItemExamen('Fontanelle normotendue'),
        ItemExamen('Sutures sans anomalie (pas de souffle à la fontanelle)'),
      ]);
    } else if (ageM <= 8) {
      neuro.addAll([
        ItemExamen('Tiré-assis : bonne tenue de tête'),
        ItemExamen('Signe de Moro disparu'),
        ItemExamen('Réflexe tonique asymétrique de la nuque disparu'),
        ItemExamen('Parachutes antérieurs et latéraux présents'),
        ItemExamen('Signe du foulard : pas de résistance'),
        ItemExamen('Angle des adducteurs > 100° et symétrique'),
        ItemExamen('Angle poplité > 100°'),
        ItemExamen('Angle pied-jambe < 80°'),
        ItemExamen('Fontanelle normotendue'),
        ItemExamen('Sutures sans anomalie (pas de souffle à la fontanelle)'),
      ]);
    } else if (ageM <= 17) {
      neuro.addAll([
        ItemExamen('Parachutes antérieurs et latéraux présents'),
        ItemExamen('Signe du foulard : pas de résistance'),
        ItemExamen('Angle des adducteurs > 100° et symétrique'),
        ItemExamen('Angle poplité > 100°'),
        ItemExamen('Angle pied-jambe < 80°'),
        ItemExamen('Tonus axial : flexion = extension'),
        ItemExamen('Fontanelle normotendue'),
        ItemExamen('Sutures sans anomalie (pas de souffle à la fontanelle)'),
      ]);
    } else {
      neuro.addAll([
        ItemExamen('Mobilité harmonieuse des 4 membres'),
        ItemExamen('Tonus passif et actif, central et périphérique sans particularité'),
        ItemExamen("Pas d'hyperréflexie ni spasticité des suraux"),
        ItemExamen('Équilibre à la marche : pointes, talons, funiculaire sans trouble'),
        ItemExamen(
            'Pas de syndrome vestibulaire (pas de marche en étoile,'
            ' pas de déviation des index)'),
        ItemExamen('Manœuvre de Gowers négative'),
        ItemExamen('Pas de syncinésies'),
        ItemExamen('Sensibilité : graphesthésie / sens de position / tactile normaux'),
      ]);
    }

    if (neuro.isNotEmpty) sections['Neurologique'] = neuro;

    // ── 2. PAIRES CRÂNIENNES ─────────────────────────────────────────────────
    if (ageM < 18) {
      sections['Paires crâniennes'] = [
        ItemExamen('Fixation oculaire'),
        ItemExamen('Poursuite oculaire'),
        ItemExamen('Réactivité pupillaire à la lumière'),
        ItemExamen('Symétrie faciale aux pleurs'),
        ItemExamen('Réactivité sonore (auditif)'),
        ItemExamen('Mimique / motricité spontanée de la face'),
        ItemExamen('Réflexe de succion / déglutition'),
      ];
    } else {
      sections['Paires crâniennes'] = [
        ItemExamen('Vision / Champ visuel'),
        ItemExamen('Oculomotricité (versions, saccades) — III / IV / VI'),
        ItemExamen('Réflexes photomoteurs / consensuels'),
        ItemExamen('Sensibilité / motricité de la face — V / VII'),
        ItemExamen('Mimique faciale / asymétrie aux pleurs'),
        ItemExamen('Audition (épreuve chuchotée / Rinne-Weber) — VIII'),
        ItemExamen('Voile / luette — IX / X'),
        ItemExamen('Trapèzes / SCM — XI'),
        ItemExamen('Langue (déviation, fasciculations) — XII'),
      ];
    }

    // ── 3. SYNDROME PYRAMIDAL (≥ 12 mois) ───────────────────────────────────
    if (ageM >= 12) {
      sections['Syndrome pyramidal'] = [
        ItemExamen('ROT (réflexes ostéotendineux)'),
        ItemExamen('Réflexe cutané plantaire (Babinski)'),
        ItemExamen('Clonus rotulien'),
        ItemExamen('Spasticité des suraux'),
        ItemExamen('Signe de Hoffman'),
        ItemExamen('Signe de Rossolimo'),
        ItemExamen('Réflexes cutanés abdominaux'),
      ];
    }

    // ── 4. SYNDROME CÉRÉBELLEUX (≥ 5 ans) ───────────────────────────────────
    if (ageM >= 60) {
      sections['Syndrome cérébelleux'] = [
        ItemExamen('Adiadococinésie'),
        ItemExamen("Dysmétrie à l'épreuve doigt-nez"),
        ItemExamen('Danse des tendons'),
        ItemExamen('Asynergie'),
      ];
    }

    // ── 5. EXAMEN GÉNÉRAL ────────────────────────────────────────────────────
    sections['Examen général'] = [
      ItemExamen("Examen cutané : pas d'anomalie"),
      ItemExamen("Phénotype : pas d'aspect particulier"),
      ItemExamen('Abdomen souple, sans organomégalie'),
      ItemExamen('Auscultation cardio-pulmonaire normale'),
    ];

    return sections;
  }

  // ── Génération du texte compte-rendu ─────────────────────────────────────────

  String _buildTexte() {
    final sb = StringBuffer();
    final int ageM = _ageM;

    for (final entry in _sections.entries) {
      final String nom = entry.key;
      final List<ItemExamen> items = entry.value;

      final anormaux = items.where((i) => i.etat == EtatExamen.anormal).toList();
      final nonFaits = items.where((i) => i.etat == EtatExamen.nonFait).toList();

      if (anormaux.isEmpty && nonFaits.isEmpty) {
        switch (nom) {
          case 'Neurologique':
            if (ageM < 18) {
              sb.writeln(
                  "L'examen neurologique est sans anomalie pour l'âge : "
                  "mobilité des 4 membres harmonieuse, tonus adapté.");
            } else {
              sb.writeln(
                  "L'examen neurologique est sans anomalie : tonus, force musculaire, "
                  "équilibre, coordination et sensibilité sans particularité. "
                  "Manœuvre de Gowers négative, pas de syncinésies.");
            }
            break;
          case 'Paires crâniennes':
            if (ageM < 18) {
              sb.writeln(
                  "Les paires crâniennes sont adaptées à l'âge : fixation et poursuite "
                  "oculaires présentes, réactivité pupillaire normale, symétrie faciale "
                  "aux pleurs, réactivité sonore et succion-déglutition efficaces.");
            } else {
              sb.writeln(
                  "Les paires crâniennes sont sans anomalie (vision/champ visuel, "
                  "oculomotricité, réflexes photomoteurs/consensuels, sensibilité et "
                  "motricité de la face, voile/luette, trapèzes/SCM, langue).");
            }
            break;
          case 'Syndrome pyramidal':
            sb.writeln(
                "Il n'y a pas de syndrome pyramidal cliniquement (ROT présents aux 4 "
                "membres, pas de signe d'Hoffmann ni de Rossolimo, réflexes cutanés "
                "abdominaux présents, pas de clonus ni spasticité, plantaire en flexion).");
            break;
          case 'Syndrome cérébelleux':
            sb.writeln(
                "Il n'y a pas de syndrome cérébelleux cliniquement "
                "(pas d'adiadococinésie, épreuves doigt-nez et talon-genou sans dysmétrie).");
            break;
          case 'Examen général':
            sb.writeln(
                "L'examen général est sans particularité : pas d'anomalie cutanée, "
                "phénotype ordinaire, abdomen souple sans organomégalie, "
                "auscultation cardio-pulmonaire normale.");
            break;
        }
      } else {
        sb.writeln('[$nom]');
        for (final item in anormaux) {
          final det = item.detail.isNotEmpty ? ' (${item.detail})' : '';
          sb.writeln('• ANORMAL : ${item.label}$det');
        }
        for (final item in nonFaits) {
          sb.writeln('• NON FAIT : ${item.label}');
        }
        final normaux = items.where((i) => i.etat == EtatExamen.normal).toList();
        if (normaux.length == 1) {
          sb.writeln('  → ${normaux.first.label} : normal');
        } else if (normaux.length > 1 && normaux.length <= 3) {
          sb.writeln('  → Normaux : ${normaux.map((i) => i.label).join(', ')}');
        }
        sb.writeln();
      }
    }

    if (_commentCtrl.text.trim().isNotEmpty) {
      sb.writeln('Commentaire libre :');
      sb.writeln(_commentCtrl.text.trim());
    }

    return sb.toString().trim();
  }

  // ── Interface ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Légende
        _legendeRow(),
        const SizedBox(height: 10),

        // Sections
        for (final entry in _sections.entries) ...[
          _buildSection(entry.key, entry.value),
          const SizedBox(height: 6),
        ],

        // Commentaire libre
        _buildCommentaire(),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Légende ──────────────────────────────────────────────────────────────────

  Widget _legendeRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _legendeChip(EtatExamen.normal, 'Normal'),
        _legendeChip(EtatExamen.anormal, 'Anormal'),
        _legendeChip(EtatExamen.nonFait, 'Non fait'),
      ],
    );
  }

  Widget _legendeChip(EtatExamen etat, String label) {
    final Color c = _couleur(etat);
    final String letter = _lettre(etat);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
          alignment: Alignment.center,
          child: Text(letter,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: c, fontSize: 12)),
      ],
    );
  }

  // ── Section ──────────────────────────────────────────────────────────────────

  Widget _buildSection(String titre, List<ItemExamen> items) {
    final bool isExpanded = _expanded[titre] ?? true;
    final int nbAnorm = items.where((i) => i.etat == EtatExamen.anormal).length;
    final int nbNF    = items.where((i) => i.etat == EtatExamen.nonFait).length;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: nbAnorm > 0
              ? const Color(0xFFF44336)
              : nbNF > 0
                  ? const Color(0xFFFF9800)
                  : Colors.grey.shade300,
          width: (nbAnorm > 0 || nbNF > 0) ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // En-tête section (cliquable pour replier)
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            onTap: () => setState(() => _expanded[titre] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(_sectionIcon(titre), color: _blueCHRU, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  if (nbAnorm > 0) _badgeCount(nbAnorm, const Color(0xFFF44336)),
                  if (nbNF > 0) ...[
                    const SizedBox(width: 4),
                    _badgeCount(nbNF, const Color(0xFFFF9800)),
                  ],
                  const SizedBox(width: 6),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Items
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: items.map(_buildItemRow).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Ligne item ────────────────────────────────────────────────────────────────

  Widget _buildItemRow(ItemExamen item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: item.etat == EtatExamen.anormal
                          ? const Color(0xFFC62828)
                          : item.etat == EtatExamen.nonFait
                              ? Colors.grey.shade600
                              : Colors.black87,
                      fontStyle: item.etat == EtatExamen.nonFait
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _etatToggle(item),
            ],
          ),
        ),
        if (item.etat == EtatExamen.anormal)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: TextField(
              controller: item.detailCtrl,
              onChanged: (_) => _notify(),
              decoration: const InputDecoration(
                hintText: 'Préciser…',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              style: const TextStyle(fontSize: 12),
              minLines: 1,
              maxLines: 3,
            ),
          ),
      ],
    );
  }

  // ── Toggle N / A / ? ─────────────────────────────────────────────────────────

  Widget _etatToggle(ItemExamen item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toggleBtn(
          label: 'N',
          active: item.etat == EtatExamen.normal,
          activeColor: const Color(0xFF43A047),
          onTap: () => _setEtat(item, EtatExamen.normal),
          tooltip: 'Normal',
        ),
        const SizedBox(width: 3),
        _toggleBtn(
          label: 'A',
          active: item.etat == EtatExamen.anormal,
          activeColor: const Color(0xFFF44336),
          onTap: () => _setEtat(item, EtatExamen.anormal),
          tooltip: 'Anormal',
        ),
        const SizedBox(width: 3),
        _toggleBtn(
          label: '?',
          active: item.etat == EtatExamen.nonFait,
          activeColor: const Color(0xFF9E9E9E),
          onTap: () => _setEtat(item, EtatExamen.nonFait),
          tooltip: 'Non fait',
        ),
      ],
    );
  }

  Widget _toggleBtn({
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? activeColor : Colors.grey.shade400,
              width: active ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Commentaire libre ─────────────────────────────────────────────────────────

  Widget _buildCommentaire() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.notes, color: _blueCHRU, size: 18),
              const SizedBox(width: 8),
              const Text('Commentaire libre',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              decoration: const InputDecoration(
                hintText: 'Observations complémentaires…',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13),
              minLines: 2,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  static Color _couleur(EtatExamen e) {
    switch (e) {
      case EtatExamen.normal:   return const Color(0xFF43A047);
      case EtatExamen.anormal:  return const Color(0xFFF44336);
      case EtatExamen.nonFait:  return const Color(0xFF9E9E9E);
    }
  }

  static String _lettre(EtatExamen e) {
    switch (e) {
      case EtatExamen.normal:  return 'N';
      case EtatExamen.anormal: return 'A';
      case EtatExamen.nonFait: return '?';
    }
  }

  Widget _badgeCount(int n, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text('$n',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  static IconData _sectionIcon(String name) {
    switch (name) {
      case 'Neurologique':       return Icons.psychology;
      case 'Paires crâniennes':  return Icons.visibility;
      case 'Syndrome pyramidal': return Icons.bolt;
      case 'Syndrome cérébelleux': return Icons.balance;
      case 'Examen général':     return Icons.person_search;
      default:                   return Icons.checklist;
    }
  }
}
