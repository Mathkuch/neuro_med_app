// ============================================================
// auxologie_naissance.dart
// Calcul des déviations standards (DS) à la naissance
// via les courbes AUDIPOG (poids, taille, périmètre crânien)
//
// Les équations polynomiales de degré 6 sont modélisées
// depuis les courbes de croissance AUDIPOG.
// Variable : h = terme gestationnel en semaines décimales
//            h = (termeSA * 7 + termeJours) / 7
// Plage valide : 24 ≤ h ≤ 43 semaines
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';

// ─── Résultat du calcul auxologique ─────────────────────────
class ResultatAuxo {
  final double? ds;            // Valeur en DS (null si données manquantes)
  final double? p50;           // Médiane à ce terme
  final String percentileBand; // Texte : "<3e" / "3-10e" / etc.
  final Color dsColor;         // Couleur clinique

  const ResultatAuxo({
    required this.ds,
    required this.p50,
    required this.percentileBand,
    required this.dsColor,
  });

  /// Texte formaté pour l'affichage (ex: "+0.45 DS")
  String get dsText {
    if (ds == null) return '';
    final sign = ds! >= 0 ? '+' : '';
    return '$sign${ds!.toStringAsFixed(2)} DS';
  }

  /// Texte complet : DS + percentile (ex: "+0.45 DS (50-75e)")
  String get fullText {
    if (ds == null) return '';
    return '${dsText}  ($percentileBand percentile)';
  }
}

// ─── Calculs auxologiques ────────────────────────────────────
class AuxologieNaissance {

  // ─── Polynôme degré 6 ──────────────────────────────────────
  // coeffs = [a6, a5, a4, a3, a2, a1, a0]
  static double _p6(List<double> c, double x) {
    return c[0] * pow(x, 6)
         + c[1] * pow(x, 5)
         + c[2] * pow(x, 4)
         + c[3] * pow(x, 3)
         + c[4] * pow(x, 2)
         + c[5] * x
         + c[6];
  }

  // ════════════════════════════════════════════════════════════
  // POIDS DE NAISSANCE (grammes)
  // Source : feuille Auxiologie, lignes 37-38
  // ════════════════════════════════════════════════════════════

  // ── Garçon ──────────────────────────────────────────────────
  static double _poidsG_P75(double h) => _p6([
     0.000156761747, -0.031265315528,  2.526211908558,
    -106.461476262205, 2486.78546423272, -30631.7841913141, 156113.213726403
  ], h);

  static double _poidsG_P50(double h) => _p6([
     0.000182104121, -0.037206294351,  3.081943788139,
    -133.210420046388, 3189.63046424488, -40256.507577461, 210068.014506313
  ], h);

  static double _poidsG_P25(double h) => _p6([
     0.000189140958, -0.038740410791,  3.21384654357,
    -138.936213969103, 3321.99995088129, -41817.8026377196, 217502.131516241
  ], h);

  static double _poidsG_P10(double h) => _p6([
     0.000163878517, -0.034553302395,  2.935487378824,
    -129.522679606148, 3154.31071363339, -40400.7409000213, 213747.461812299
  ], h);

  static double _poidsG_P3(double h) => _p6([
     0.000174415024, -0.036790475953,  3.125341225507,
    -137.768213504088, 3347.6263261975, -42731.8951342436, 225101.252533401
  ], h);

  // ── Fille ───────────────────────────────────────────────────
  static double _poidsF_P75(double h) => _p6([
     0.000086527125, -0.017152395711,  1.354293781307,
    -54.988976118504, 1225.42099978425, -14279.9877400919, 68445.9157359595
  ], h);

  static double _poidsF_P50(double h) => _p6([
     0.000186616891, -0.037527577994,  3.062980724822,
    -130.492173352628, 3079.35821914696, -38293.5720735955, 196819.854796382
  ], h);

  static double _poidsF_P3(double h) => _p6([
     0.000150263216, -0.032269878267,  2.781748025112,
    -124.172555145633, 3051.22231024702, -39340.1398896127, 209036.649318235
  ], h);

  // P25 fille = P50 − (P50 − P3) / 3  [formule Excel K38]
  static double _poidsF_P25(double h) =>
      _poidsF_P50(h) - (_poidsF_P50(h) - _poidsF_P3(h)) / 3.0;

  // P10 fille = P25 − (P25 − P3) / 2  [formule Excel L38]
  static double _poidsF_P10(double h) =>
      _poidsF_P25(h) - (_poidsF_P25(h) - _poidsF_P3(h)) / 2.0;

  // ════════════════════════════════════════════════════════════
  // TAILLE DE NAISSANCE (cm)
  // Source : feuille Auxiologie, lignes 39-40
  // Distribution symétrique : P25 = 2·P50 − P75
  // ════════════════════════════════════════════════════════════

  // ── Garçon ──────────────────────────────────────────────────
  static double _tailleG_P75(double h) => _p6([
     0.000000110456, -0.000023402778,  0.00204020171,
    -0.094894756623,  2.476843198758, -32.6868213977, 190.680414896869
  ], h);

  static double _tailleG_P50(double h) => _p6([
     0.000000185948, -0.00003628412,   0.002928682265,
    -0.127334954645,  3.175661456208, -41.819142517314, 248.135951821674
  ], h);

  static double _tailleG_P25(double h) => 2 * _tailleG_P50(h) - _tailleG_P75(h);
  static double _tailleG_P10(double h) => 3 * _tailleG_P50(h) - 2 * _tailleG_P75(h);
  static double _tailleG_P3(double h)  => 4 * _tailleG_P50(h) - 3 * _tailleG_P75(h);

  // ── Fille ───────────────────────────────────────────────────
  static double _tailleF_P75(double h) => _p6([
     0.000000214645, -0.000043450463,  0.003631313875,
    -0.161129526277,  3.983759626856, -50.073228831449, 266.132757798389
  ], h);

  static double _tailleF_P50(double h) => _p6([
     0.000000254799, -0.000049740374,  0.004014727729,
    -0.173252049111,  4.232469086628, -54.067919742638, 300.683980526303
  ], h);

  static double _tailleF_P25(double h) => 2 * _tailleF_P50(h) - _tailleF_P75(h);
  static double _tailleF_P10(double h) => 3 * _tailleF_P50(h) - 2 * _tailleF_P75(h);
  static double _tailleF_P3(double h)  => 4 * _tailleF_P50(h) - 3 * _tailleF_P75(h);

  // ════════════════════════════════════════════════════════════
  // PÉRIMÈTRE CRÂNIEN DE NAISSANCE (cm)
  // Source : feuille Auxiologie, lignes 41-42
  // Distribution symétrique : P25 = 2·P50 − P75
  // ════════════════════════════════════════════════════════════

  // ── Garçon ──────────────────────────────────────────────────
  static double _pcG_P75(double h) => _p6([
    -0.000000022927,  0.000003555796, -0.000210045661,
     0.005134896326, -0.039986119002,  1.196491406084, -9.056860274638
  ], h);

  static double _pcG_P50(double h) => _p6([
     0.000001615729, -0.00032488142,   0.027023078074,
    -1.19079836019,  29.306514747468, -380.530779216606, 2047.67482563382
  ], h);

  static double _pcG_P25(double h) => 2 * _pcG_P50(h) - _pcG_P75(h);
  static double _pcG_P10(double h) => 3 * _pcG_P50(h) - 2 * _pcG_P75(h);
  static double _pcG_P3(double h)  => 4 * _pcG_P50(h) - 3 * _pcG_P75(h);

  // ── Fille ───────────────────────────────────────────────────
  // Note : formule I42 sans terme constant
  static double _pcF_P75(double h) {
    return  0.000000016405 * pow(h, 6)
          - 0.000003418406 * pow(h, 5)
          + 0.000290163516 * pow(h, 4)
          - 0.013167952653 * pow(h, 3)
          + 0.309945382178 * pow(h, 2)
          - 1.945887327194 * h;
  }

  static double _pcF_P50(double h) => _p6([
     0.000000088562, -0.000016831479,  0.001326475502,
    -0.056390808987,  1.358267614008, -16.274483748959, 86.193789246172
  ], h);

  static double _pcF_P25(double h) => 2 * _pcF_P50(h) - _pcF_P75(h);
  static double _pcF_P10(double h) => 3 * _pcF_P50(h) - 2 * _pcF_P75(h);
  static double _pcF_P3(double h)  => 4 * _pcF_P50(h) - 3 * _pcF_P75(h);

  // ════════════════════════════════════════════════════════════
  // UTILITAIRES COMMUNS
  // ════════════════════════════════════════════════════════════

  // Sigma estimé via IQR : σ ≈ (P75 − P25) / 1.349  (hypothèse Gaussienne)
  static double _sigma(double p75, double p25) => (p75 - p25) / 1.349;

  static String _percentileBand({
    required double val,
    required double p3,  required double p10,
    required double p25, required double p50,
    required double p75, required double p90, required double p97,
  }) {
    if (val >= p97) return '>97e';
    if (val >= p90) return '90-97e';
    if (val >= p75) return '75-90e';
    if (val >= p50) return '50-75e';
    if (val >= p25) return '25-50e';
    if (val >= p10) return '10-25e';
    if (val >= p3)  return '3-10e';
    return '<3e';
  }

  static Color _dsColor(double ds) {
    final a = ds.abs();
    if (a < 1.0) return const Color(0xFF43A047); // vert foncé
    if (a < 2.0) return const Color(0xFFFF9800); // orange
    if (a < 3.0) return const Color(0xFFF44336); // rouge
    return const Color(0xFF9C27B0);              // violet (extrême)
  }

  // ════════════════════════════════════════════════════════════
  // API PUBLIQUE
  // ════════════════════════════════════════════════════════════

  /// Calcule le DS et le percentile du poids de naissance.
  /// [poidsG] en grammes. Retourne null si données invalides.
  static ResultatAuxo? calculerDsPoids({
    required double poidsG,
    required int termeSA,
    required int termeJours,
    required bool garcon,
  }) {
    final h = (termeSA * 7 + termeJours) / 7.0;
    if (h < 24 || h > 43 || poidsG <= 0) return null;

    final p50 = garcon ? _poidsG_P50(h) : _poidsF_P50(h);
    final p75 = garcon ? _poidsG_P75(h) : _poidsF_P75(h);
    final p25 = garcon ? _poidsG_P25(h) : _poidsF_P25(h);
    final p10 = garcon ? _poidsG_P10(h) : _poidsF_P10(h);
    final p3  = garcon ? _poidsG_P3(h)  : _poidsF_P3(h);
    final p90 = 2 * p50 - p10;
    final p97 = 2 * p50 - p3;

    final sig = _sigma(p75, p25);
    if (sig <= 0) return null;
    final ds = (poidsG - p50) / sig;

    return ResultatAuxo(
      ds: ds,
      p50: p50,
      percentileBand: _percentileBand(
        val: poidsG, p3: p3, p10: p10, p25: p25,
        p50: p50, p75: p75, p90: p90, p97: p97,
      ),
      dsColor: _dsColor(ds),
    );
  }

  /// Calcule le DS et le percentile de la taille de naissance.
  /// [tailleCm] en centimètres.
  static ResultatAuxo? calculerDsTaille({
    required double tailleCm,
    required int termeSA,
    required int termeJours,
    required bool garcon,
  }) {
    final h = (termeSA * 7 + termeJours) / 7.0;
    if (h < 24 || h > 43 || tailleCm <= 0) return null;

    final p50 = garcon ? _tailleG_P50(h) : _tailleF_P50(h);
    final p75 = garcon ? _tailleG_P75(h) : _tailleF_P75(h);
    final p25 = garcon ? _tailleG_P25(h) : _tailleF_P25(h);
    final p10 = garcon ? _tailleG_P10(h) : _tailleF_P10(h);
    final p3  = garcon ? _tailleG_P3(h)  : _tailleF_P3(h);
    final p90 = 2 * p50 - p10;
    final p97 = 2 * p50 - p3;

    final sig = _sigma(p75, p25);
    if (sig <= 0) return null;
    final ds = (tailleCm - p50) / sig;

    return ResultatAuxo(
      ds: ds,
      p50: p50,
      percentileBand: _percentileBand(
        val: tailleCm, p3: p3, p10: p10, p25: p25,
        p50: p50, p75: p75, p90: p90, p97: p97,
      ),
      dsColor: _dsColor(ds),
    );
  }

  /// Calcule le DS et le percentile du périmètre crânien de naissance.
  /// [pcCm] en centimètres.
  static ResultatAuxo? calculerDsPC({
    required double pcCm,
    required int termeSA,
    required int termeJours,
    required bool garcon,
  }) {
    final h = (termeSA * 7 + termeJours) / 7.0;
    if (h < 24 || h > 43 || pcCm <= 0) return null;

    final p50 = garcon ? _pcG_P50(h) : _pcF_P50(h);
    final p75 = garcon ? _pcG_P75(h) : _pcF_P75(h);
    final p25 = garcon ? _pcG_P25(h) : _pcF_P25(h);
    final p10 = garcon ? _pcG_P10(h) : _pcF_P10(h);
    final p3  = garcon ? _pcG_P3(h)  : _pcF_P3(h);
    final p90 = 2 * p50 - p10;
    final p97 = 2 * p50 - p3;

    final sig = _sigma(p75, p25);
    if (sig <= 0) return null;
    final ds = (pcCm - p50) / sig;

    return ResultatAuxo(
      ds: ds,
      p50: p50,
      percentileBand: _percentileBand(
        val: pcCm, p3: p3, p10: p10, p25: p25,
        p50: p50, p75: p75, p90: p90, p97: p97,
      ),
      dsColor: _dsColor(ds),
    );
  }
}
