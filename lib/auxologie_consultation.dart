// auxologie_consultation.dart
// Courbes de croissance AFPA/CRESS/Inserm-CGM 2018 (post-natales)
// Équations polynomiales extraites du fichier Consultations.xlsm (feuille Auxiologie)
//
// Variables Excel d'origine :
//   E16 = age en années  (→ paramètre `a`)
//   E17 = E16*12 = age en mois (→ paramètre `m`)
//
// Taille & PC  : DS = (mesure − P50) / σ  où σ = P84.1 − P50
// Poids        : bande percentile (P3/P10/P25/P50/P75/P90/P97) + DS via IQR
// IMC          : bande percentile + zone IOTF (AD30/AD35/AD40)

import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────
//  DTOs résultats
// ─────────────────────────────────────────────────────────

class ResultatConsult {
  final double? ds;
  final String percentileBand; // ex: "25-50e"
  final Color dsColor;

  const ResultatConsult({
    required this.ds,
    required this.percentileBand,
    required this.dsColor,
  });

  String get dsText {
    if (ds == null) return '';
    final sign = ds! >= 0 ? '+' : '';
    return '$sign${ds!.toStringAsFixed(2)} DS';
  }

  String get fullText {
    if (ds == null) return '';
    return '$dsText  (${percentileBand}e perc.)';
  }
}

class ResultatIMC {
  final double imc;
  final String percentileBand; // bande percentile, ex: "50-75e"
  final String zoneIOTF;       // ex: "Normopondéral", "Surpoids", "Obésité grade I"
  final Color couleur;

  const ResultatIMC({
    required this.imc,
    required this.percentileBand,
    required this.zoneIOTF,
    required this.couleur,
  });

  String get imcStr => '${imc.toStringAsFixed(1)} kg/m²';
}

// ─────────────────────────────────────────────────────────
//  Moteur de calcul
// ─────────────────────────────────────────────────────────

class AuxologieConsult {

  // ── Polynômes helpers ──────────────────────────────────

  /// Polynôme degré 6 : c[0]*x^6 + c[1]*x^5 + ... + c[6]
  static double _p6(List<double> c, double x) {
    return c[0]*pow(x,6) + c[1]*pow(x,5) + c[2]*pow(x,4)
         + c[3]*pow(x,3) + c[4]*pow(x,2) + c[5]*x + c[6];
  }

  /// Polynôme degré 5 : c[0]*x^5 + c[1]*x^4 + ... + c[5]
  static double _p5(List<double> c, double x) {
    return c[0]*pow(x,5) + c[1]*pow(x,4) + c[2]*pow(x,3)
         + c[3]*pow(x,2) + c[4]*x + c[5];
  }

  // ── Couleur selon |DS| ─────────────────────────────────

  static Color _dsColor(double ds) {
    final abs = ds.abs();
    if (abs < 1.0) return const Color(0xFF43A047); // vert
    if (abs < 2.0) return const Color(0xFFFF9800); // orange
    if (abs < 3.0) return const Color(0xFFF44336); // rouge
    return const Color(0xFF9C27B0);                // violet
  }

  /// Bande percentile estimée à partir d'un DS (approx Gaussienne)
  static String _dsToPercentileBand(double ds) {
    if (ds >  1.96) return '>97e';
    if (ds >  1.28) return '90-97e';
    if (ds >  0.67) return '75-90e';
    if (ds >  0.00) return '50-75e';
    if (ds > -0.67) return '25-50e';
    if (ds > -1.28) return '10-25e';
    if (ds > -1.96) return '3-10e';
    return '<3e';
  }

  /// Bande percentile à partir de seuils [P97, P90, P75, P50, P25, P10, P3]
  static String _bandFromThresholds(
      double val, double p97, double p90, double p75,
      double p50, double p25, double p10, double p3) {
    if (val > p97) return '>97e';
    if (val > p90) return '90-97e';
    if (val > p75) return '75-90e';
    if (val > p50) return '50-75e';
    if (val > p25) return '25-50e';
    if (val > p10) return '10-25e';
    if (val > p3)  return '3-10e';
    return '<3e';
  }

  // ═══════════════════════════════════════════════════════
  //  TAILLE — courbes AFPA/CRESS/Inserm
  //  Paramètre : m = âge en mois (< 3 ans), a = âge en années (≥ 3 ans)
  // ═══════════════════════════════════════════════════════

  // ── Fille < 3 ans (ligne 21, variable m) ──────────────

  static double _tailleF_lt3_P50(double m) => _p6([
    -0.00000008,  0.00001284,  -0.00079604,
     0.02432566, -0.39857811,   4.50538098,  48.98311668], m);

  static double _tailleF_lt3_P841(double m) => _p6([
    -0.0000001611,  0.0000214458, -0.0011326309,
     0.0302001099, -0.4401402303,  4.6040032006, 51.1447602848], m);

  // ── Garçon < 3 ans (ligne 22, variable m) ─────────────

  static double _tailleG_lt3_P50(double m) => _p6([
    -0.0000001285,  0.0000175614, -0.0009728264,
     0.0278567884, -0.4448846331,  4.888122873,  49.3099100748], m);

  static double _tailleG_lt3_P841(double m) => _p6([
    -0.0000001338,  0.0000193448, -0.001105157,
     0.0317644499, -0.49495153,    5.1813430272, 50.954294817], m);

  // ── Fille ≥ 3 ans (ligne 29, variable a) ──────────────

  static double _tailleF_gte3_P50(double a) {
    if (a >= 18) return 164.26696861622943;
    return _p6([
       0.0000936646, -0.0054358086,  0.1209721944,
      -1.3091951912,  7.0822205702, -11.1373836148, 91.746865394], a);
  }

  static double _tailleF_gte3_P841(double a) {
    if (a >= 18) return 170.97750664983272;
    return _p6([
       0.0000770676, -0.0042403415,  0.0876534537,
      -0.8539313567,  3.8750931675,  0.3175729084, 79.5337272136], a);
  }

  // ── Garçon ≥ 3 ans (ligne 30, variable a) ─────────────

  static double _tailleG_gte3_P50(double a) {
    if (a >= 18) return 176.07019453051899;
    return _p6([
      -0.000017161258,  0.000839035614, -0.017880157075,
       0.230648295459, -1.960919128312, 15.454877693382, 62.937996315237], a);
  }

  static double _tailleG_gte3_P841(double a) {
    if (a >= 18) return 183.313597462003;
    return _p6([
       0.000000452,  -0.000149828,   0.0025777644,
       0.0382788069, -1.1500790331, 14.6254131402, 65.6181059353], a);
  }

  // ═══════════════════════════════════════════════════════
  //  PC (PÉRIMÈTRE CRÂNIEN)
  //  < 3 ans → lignes 23/24, ≥ 3 ans → lignes 33/34
  //  Après 5 ans → polynôme étendu + valeurs adulte plateau
  // ═══════════════════════════════════════════════════════

  // ── Fille < 3 ans (ligne 23, variable m) ──────────────

  static double _pcF_lt3_P50(double m) => _p6([
    -0.0000000103,  0.0000020186, -0.0001578198,
     0.0063642358, -0.1440440701,  1.9247827218, 35.2495974692], m);

  static double _pcF_lt3_P841(double m) => _p6([
    -0.000000013,   0.0000023991, -0.0001781785,
     0.0068945635, -0.1517316978,  1.9958725654, 36.172698644], m);

  // ── Garçon < 3 ans (ligne 24, variable m) ─────────────

  static double _pcG_lt3_P50(double m) => _p6([
    -0.000000012,   0.0000023569, -0.0001848138,
     0.0074298596, -0.1654770719,  2.1221660142, 35.7370141359], m);

  static double _pcG_lt3_P841(double m) => _p6([
    -0.000000009914,  0.00000201577, -0.000163582693,
     0.006826626674, -0.158321609348, 2.110047570954, 36.880079698674], m);

  // ── Fille ≥ 3 ans (ligne 33, variable a, degré 5)
  //    P84.1 = (polynôme_brut − P50) / 2 + P50

  static double _pcF_gte3_P50(double a) {
    if (a >= 18) return 55.0061907524911;
    return _p5([
       0.000038761944, -0.002389684807,  0.054657495702,
      -0.576947025354,  3.180225745761, 43.546671908865], a);
  }

  static double _pcF_gte3_P841(double a) {
    if (a >= 18) return 56.520337153332;
    final p50  = _pcF_gte3_P50(a);
    final raw  = _p5([
       0.000088035146, -0.004724226926,  0.095090625983,
      -0.890499852735,  4.25970790354,  44.895213870585], a);
    return (raw - p50) / 2 + p50;
  }

  // ── Garçon ≥ 3 ans (ligne 34, variable a, degré 6)
  //    P84.1 = (polynôme_brut − P50) / 2 + P50

  static double _pcG_gte3_P50(double a) {
    if (a >= 18) return 55.8647773491;
    return _p6([
      -0.0000006751,  0.0000773864, -0.0031203525,
       0.0593879251, -0.5697652681,  2.964648442, 45.0515844615], a);
  }

  static double _pcG_gte3_P841(double a) {
    if (a >= 18) return 57.1839021410403;
    final p50 = _pcG_gte3_P50(a);
    final raw = _p6([
       0.000019498,  -0.0012985335,  0.0346800798,
      -0.4743409057,  3.496816548, -12.7742828157, 71.7523671705], a);
    return (raw - p50) / 2 + p50;
  }

  // ═══════════════════════════════════════════════════════
  //  POIDS — lignes 25/26 (< 3 ans, m), lignes 31/32 (≥ 3 ans, a)
  //  Colonnes : G=P97, H=P90, I=P75, J=P50, K=P25, L=P10, M=P3
  // ═══════════════════════════════════════════════════════

  // ── Fille < 3 ans ──────────────────────────────────────
  static double _poidsF_lt3_P97(double m) => _p6([-0.000000013799, 0.000002334212,-0.000160138875, 0.005664735545,-0.108954837423, 1.361741451436, 3.682822362414], m);
  static double _poidsF_lt3_P90(double m) => _p6([ 0.000000011284,-0.000000564145,-0.000029362619, 0.002744906121,-0.075590222461, 1.157223388206, 3.590911366275], m);
  static double _poidsF_lt3_P75(double m) => _p6([-0.000000006412, 0.000001477785,-0.000118138307, 0.004518424486,-0.091027604954, 1.16967256565,  3.28734467413 ], m);
  static double _poidsF_lt3_P50(double m) => _p6([-0.000000014603, 0.000002288902,-0.000146526521, 0.004901199205,-0.091377289776, 1.117236215287, 3.045595777639], m);
  static double _poidsF_lt3_P25(double m) => _p6([ 0.000000007648,-0.000000209324,-0.000037946637, 0.0025865498,  -0.065933895572, 0.96250250219,  2.915562088991], m);
  static double _poidsF_lt3_P10(double m) => _p6([-0.000000019976, 0.000002773793,-0.000159354753, 0.004861079649,-0.084548474274, 0.990478580238, 2.612825769611], m);
  static double _poidsF_lt3_P3 (double m) => _p6([-0.000000011318, 0.000001825689,-0.000118737629, 0.00397947855, -0.074118796817, 0.915382145567, 2.398892268167], m);

  // ── Garçon < 3 ans ─────────────────────────────────────
  static double _poidsG_lt3_P97(double m) => _p6([-0.000000024446, 0.000003573079,-0.000216279565, 0.006941490156,-0.125478926889, 1.482464958652, 4.004412663739], m);
  static double _poidsG_lt3_P90(double m) => _p6([-0.000000028765, 0.000004131648,-0.000242370856, 0.007451961424,-0.128390875742, 1.438699537948, 3.693307622442], m);
  static double _poidsG_lt3_P75(double m) => _p6([-0.000000033053, 0.000004507014,-0.00025145338,  0.007395285336,-0.123368326991, 1.357121807761, 3.458375809671], m);
  static double _poidsG_lt3_P50(double m) => _p6([-0.000000036029, 0.000004824898,-0.000262790871, 0.007515789916,-0.12206730919,  1.305885493966, 3.142711788303], m);
  static double _poidsG_lt3_P25(double m) => _p6([-0.000000033761, 0.000004515197,-0.000244586103, 0.006940324177,-0.112207585774, 1.207810056322, 2.930428157143], m);
  static double _poidsG_lt3_P10(double m) => _p6([-0.00000003519,  0.000004625921,-0.00024756778,  0.006971252234,-0.111924987428, 1.181068567737, 2.600337835048], m);
  static double _poidsG_lt3_P3 (double m) => _p6([-0.000000047771, 0.000006060795,-0.000307752877, 0.008088576082,-0.120254496891, 1.178674566117, 2.260675276419], m);

  // ── Fille ≥ 3 ans (variable a) ─────────────────────────
  static double _poidsF_gte3_P97(double a) => _p6([ 0.000052457196,-0.002668107476, 0.048618449763,-0.391989606618, 1.554411052836, 0.399430315367, 9.996811461399], a);
  static double _poidsF_gte3_P90(double a) => _p6([ 0.000040291524,-0.002037812419, 0.036449436125,-0.279738587796, 1.001421838324, 1.269113852685, 8.735480614219], a);
  static double _poidsF_gte3_P75(double a) => _p6([ 0.000034962731,-0.001831566871, 0.034131125015,-0.274387876929, 1.005359252995, 0.99051575869,  8.303184414783], a);
  static double _poidsF_gte3_P50(double a) => _p6([ 0.000037056832,-0.002071379171, 0.042151974268,-0.384719643288, 1.648472031349,-0.794059936024, 9.059313977327], a);
  static double _poidsF_gte3_P25(double a) => _p6([ 0.00002766906, -0.001640934925, 0.035261036487,-0.338022560232, 1.499996695351,-0.787125078243, 8.510202311643], a);
  static double _poidsF_gte3_P10(double a) => _p6([ 0.000023392182,-0.00143579111,  0.031953556789,-0.317657959028, 1.454459198208,-0.950933783048, 8.191843568701], a);
  static double _poidsF_gte3_P3 (double a) => _p6([ 0.000014507899,-0.00094704899,  0.021863504265,-0.218977716372, 0.969149501904,-0.015409896531, 7.054330569886], a);

  // ── Garçon ≥ 3 ans (variable a) ────────────────────────
  static double _poidsG_gte3_P97(double a) => _p6([ 0.00004957423, -0.002693419768, 0.053711441112,-0.488100447157, 2.236998124398,-1.637556304097,12.260507704058], a);
  static double _poidsG_gte3_P90(double a) => _p6([ 0.000033419507,-0.00188322611,  0.038376669636,-0.347568759644, 1.539132472659,-0.380841399394,10.70296146756 ], a);
  static double _poidsG_gte3_P75(double a) => _p6([ 0.000014047046,-0.000880968144, 0.019077234666,-0.17327757043,  0.738897047826, 1.047611259749, 9.113858533526], a);
  static double _poidsG_gte3_P50(double a) => _p6([-0.000003647457, 0.000060365243, 0.000503755513,-0.002506390929,-0.043217670199, 2.422110029783, 7.590908918716], a);
  static double _poidsG_gte3_P25(double a) => _p6([-0.000018228417, 0.000826916678,-0.014246748237, 0.125900586619,-0.573190547759, 3.180015318618, 6.516342919531], a);
  static double _poidsG_gte3_P10(double a) => _p6([-0.00002364609,  0.00114799109, -0.021221106329, 0.195424095966,-0.916263503893, 3.790821186161, 5.525588772342], a);
  static double _poidsG_gte3_P3 (double a) => _p6([-0.000036042239, 0.00184886243, -0.036141628159, 0.344386061659,-1.6400889954,   5.206652717524, 4.076161695705], a);

  // ═══════════════════════════════════════════════════════
  //  IMC — lignes 27/28 (< 3 ans, a), lignes 35/36 (≥ 3 ans, a)
  //  + seuils IOTF AD30/AD35/AD40 (colonnes O/P/Q)
  // ═══════════════════════════════════════════════════════

  // ── IMC Fille < 3 ans (variable a) ────────────────────
  static double _imcF_lt3_P97(double a) => _p6([-0.005999409043, 0.131242988446,-1.141582240479, 5.01122105392, -11.461748135149,11.870134488058,15.585869415867], a);
  static double _imcF_lt3_P90(double a) => _p6([-0.004676931086, 0.104435059931,-0.928840409244, 4.178350288908, -9.815196641811,10.433129086182,15.002534806057], a);
  static double _imcF_lt3_P75(double a) => _p6([-0.004323415352, 0.099382906268,-0.905493620373, 4.146113353204, -9.8387626888,  10.496556916619,14.141038235297], a);
  static double _imcF_lt3_P50(double a) => _p6([-0.005977648736, 0.129073226642,-1.105402316828, 4.761035096515,-10.658804270145,10.840542254184,13.259890225654], a);
  static double _imcF_lt3_P25(double a) => _p6([-0.004619080827, 0.101784063648,-0.88971003844,  3.913515416887, -8.955535606047, 9.288803402788,12.823584525823], a);
  static double _imcF_lt3_P10(double a) => _p6([-0.003464139557, 0.080945915613,-0.74608096671,  3.431672910757, -8.116153315044, 8.568712210132,12.302075978313], a);
  static double _imcF_lt3_P3 (double a) => _p6([-0.00576380088,  0.126877634441,-1.09798055974,  4.722236075291,-10.409730950409,10.333055137503,11.193919777352], a);

  // ── IMC Garçon < 3 ans (variable a) ───────────────────
  static double _imcG_lt3_P97(double a) => _p6([-0.0089922113, 0.1898624769,-1.5829395241, 6.5873178599,-14.0224431383,13.0642128526,16.1814220482], a);
  static double _imcG_lt3_P90(double a) => _p6([-0.0039878256, 0.095108597, -0.8975696446, 4.2259116628,-10.1226129613,10.4901752159,15.5007175839], a);
  static double _imcG_lt3_P75(double a) => _p6([-0.005676179,  0.1246310807,-1.0864227987, 4.7528392196,-10.6967169495,10.6374620822,14.644861636 ], a);
  static double _imcG_lt3_P50(double a) => _p6([-0.0089407655, 0.1865894919,-1.5364649998, 6.3099521813,-13.2963902753,12.5539546984,13.2616430423], a);
  static double _imcG_lt3_P25(double a) => _p6([-0.0078812681, 0.1591935832,-1.2810892951, 5.2063381938,-11.0235111275,10.6111036478,12.8550195591], a);
  static double _imcG_lt3_P10(double a) => _p6([-0.0057644937, 0.1259245768,-1.0850858572, 4.664964985, -10.3123413307,10.265084495, 12.1538101123], a);
  static double _imcG_lt3_P3 (double a) => _p6([-0.0073218095, 0.1536922007,-1.2763382243, 5.3082603737,-11.4218240565,11.2351188477,11.1536428372], a);

  // ── IMC Fille ≥ 3 ans (variable a) ────────────────────
  static double _imcF_gte3_P97(double a) => _p6([ 0.0000183043,-0.0012122231, 0.0319604588,-0.4361486294, 3.3618671071,-13.6995027525,40.2737497237], a);
  static double _imcF_gte3_P90(double a) => _p6([ 0.0000212278,-0.0014283246, 0.0384765926,-0.5368476796, 4.1879439772,-17.189183068, 45.4370228442], a);
  static double _imcF_gte3_P75(double a) => _p6([ 0.0000204097,-0.001333308,  0.0346827516,-0.463507267,  3.4384998104,-13.4100875426,37.2732812626], a);
  static double _imcF_gte3_P50(double a) => _p6([ 0.0000202128,-0.0013462396, 0.0357131194,-0.4856551412, 3.6395974548,-14.2690818902,37.8776524778], a);
  static double _imcF_gte3_P25(double a) => _p6([ 0.0000191266,-0.0013326542, 0.0372076494,-0.5357686531, 4.2600882844,-17.7479399046,44.4643393845], a);
  static double _imcF_gte3_P10(double a) => _p6([ 0.0000106041,-0.0006560215, 0.0154578322,-0.173469677,  0.9648708366, -2.3161227835,14.8346721958], a);
  static double _imcF_gte3_P3 (double a) => _p6([ 0.00001724,  -0.001185593,  0.0325074105,-0.456122392,  3.5032107775,-14.0468175372,36.03842939  ], a);

  // ── IMC Garçon ≥ 3 ans (variable a) ───────────────────
  static double _imcG_gte3_P97(double a) => _p6([ 0.0000139893,-0.0010185491, 0.0296983249,-0.4461609978, 3.6910002597,-15.5660064708,43.5685127394], a);
  static double _imcG_gte3_P90(double a) => _p6([ 0.0000015433,-0.0001730095, 0.0064485326,-0.1148766041, 1.112672834,  -5.3093060483,26.6112330197], a);
  static double _imcG_gte3_P75(double a) => _p6([-0.0000011526, 0.0000226038, 0.0006595558,-0.0256549391, 0.3612484468, -2.1425824897,20.7115659606], a);
  static double _imcG_gte3_P50(double a) => _p6([ 0.0000035735,-0.0002929105, 0.009095314, -0.140289408,  1.1882426795, -5.1879843087,24.4346099758], a);
  static double _imcG_gte3_P25(double a) => _p6([-0.0000005904,-0.0000152054, 0.0016389647,-0.0370664375, 0.4086755114, -2.1875875639,19.0975710596], a);
  static double _imcG_gte3_P10(double a) => _p6([ 0.0000065417,-0.0004930699, 0.0145758047,-0.2173784505, 1.7649374878, -7.411633978, 26.510169982 ], a);
  static double _imcG_gte3_P3 (double a) => _p6([-0.000001602,  0.0000620035,-0.000639034, -0.0035632782, 0.1459571052, -1.19941767,  16.5253754339], a);

  // ── Seuils IOTF fille (AD30/AD35/AD40, a > 2) ─────────
  static double _iotfF_AD30(double a) => a > 2 ? _p6([
     0.000000135975,  0.000083375397, -0.004119977861,
     0.06158907471,  -0.234934746517, -0.190035344997, 20.669252862021], a) : 50.0;
  static double _iotfF_AD35(double a) => a > 2 ? _p6([
     0.000009421519, -0.000543876293,  0.011606577193,
    -0.123185362969,  0.868349084567, -3.653288583882, 26.650368770188], a) : 50.0;
  static double _iotfF_AD40(double a) => a > 2 ? _p6([
    -0.000004060855,  0.000291879931, -0.00873918252,
     0.122073388689, -0.627934669238,  0.696804721417, 22.985511643174], a) : 50.0;

  // ── Seuils IOTF garçon (AD30/AD35/AD40, a > 2) ────────
  static double _iotfG_AD30(double a) => a > 2 ? _p6([
     0.0000101194, -0.0006455333,  0.0170543303,
    -0.2452244307,  2.0514731297, -8.3786213947, 31.6866435656], a) : 50.0;
  static double _iotfG_AD35(double a) => a > 2 ? _p6([
    -0.0000105553,  0.0006629569, -0.0163715989,
     0.1896129117, -0.8869069045,  1.0651135873, 22.5842296294], a) : 50.0;
  static double _iotfG_AD40(double a) => a > 2 ? _p6([
     0.0000144171, -0.0008686611,  0.0206142384,
    -0.2604936801,  2.0370021977, -8.2734377265, 35.1594691153], a) : 50.0;

  // ═══════════════════════════════════════════════════════
  //  MÉTHODES PUBLIQUES
  // ═══════════════════════════════════════════════════════

  /// Calcule le DS de la taille pour un enfant de [ageAns] années.
  static ResultatConsult? calculerDsTaille({
    required double tailleCm,
    required double ageAns,
    required bool garcon,
  }) {
    if (tailleCm <= 0 || ageAns < 0) return null;
    final m = ageAns * 12;

    double p50, p841;
    if (ageAns < 3) {
      p50  = garcon ? _tailleG_lt3_P50(m)  : _tailleF_lt3_P50(m);
      p841 = garcon ? _tailleG_lt3_P841(m) : _tailleF_lt3_P841(m);
    } else {
      p50  = garcon ? _tailleG_gte3_P50(ageAns)  : _tailleF_gte3_P50(ageAns);
      p841 = garcon ? _tailleG_gte3_P841(ageAns) : _tailleF_gte3_P841(ageAns);
    }

    final sigma = p841 - p50;
    if (sigma <= 0) return null;
    final ds = (tailleCm - p50) / sigma;

    return ResultatConsult(
      ds: ds,
      percentileBand: _dsToPercentileBand(ds),
      dsColor: _dsColor(ds),
    );
  }

  /// Calcule le DS du périmètre crânien pour un enfant de [ageAns] années.
  /// Après 5 ans, les courbes de référence adulte sont utilisées en plateau.
  static ResultatConsult? calculerDsPC({
    required double pcCm,
    required double ageAns,
    required bool garcon,
  }) {
    if (pcCm <= 0 || ageAns < 0) return null;
    final m = ageAns * 12;

    double p50, p841;
    if (ageAns < 3) {
      p50  = garcon ? _pcG_lt3_P50(m)  : _pcF_lt3_P50(m);
      p841 = garcon ? _pcG_lt3_P841(m) : _pcF_lt3_P841(m);
    } else {
      p50  = garcon ? _pcG_gte3_P50(ageAns)  : _pcF_gte3_P50(ageAns);
      p841 = garcon ? _pcG_gte3_P841(ageAns) : _pcF_gte3_P841(ageAns);
    }

    final sigma = p841 - p50;
    if (sigma <= 0) return null;
    final ds = (pcCm - p50) / sigma;

    return ResultatConsult(
      ds: ds,
      percentileBand: _dsToPercentileBand(ds),
      dsColor: _dsColor(ds),
    );
  }

  /// Calcule la bande percentile du poids (+ DS via IQR) pour un enfant de [ageAns] années.
  static ResultatConsult? calculerDsPoids({
    required double poidsKg,
    required double ageAns,
    required bool garcon,
  }) {
    if (poidsKg <= 0 || ageAns < 0) return null;
    final m = ageAns * 12;

    double p97, p90, p75, p50, p25, p10, p3;

    if (ageAns < 3) {
      p97 = garcon ? _poidsG_lt3_P97(m) : _poidsF_lt3_P97(m);
      p90 = garcon ? _poidsG_lt3_P90(m) : _poidsF_lt3_P90(m);
      p75 = garcon ? _poidsG_lt3_P75(m) : _poidsF_lt3_P75(m);
      p50 = garcon ? _poidsG_lt3_P50(m) : _poidsF_lt3_P50(m);
      p25 = garcon ? _poidsG_lt3_P25(m) : _poidsF_lt3_P25(m);
      p10 = garcon ? _poidsG_lt3_P10(m) : _poidsF_lt3_P10(m);
      p3  = garcon ? _poidsG_lt3_P3(m)  : _poidsF_lt3_P3(m);
    } else {
      p97 = garcon ? _poidsG_gte3_P97(ageAns) : _poidsF_gte3_P97(ageAns);
      p90 = garcon ? _poidsG_gte3_P90(ageAns) : _poidsF_gte3_P90(ageAns);
      p75 = garcon ? _poidsG_gte3_P75(ageAns) : _poidsF_gte3_P75(ageAns);
      p50 = garcon ? _poidsG_gte3_P50(ageAns) : _poidsF_gte3_P50(ageAns);
      p25 = garcon ? _poidsG_gte3_P25(ageAns) : _poidsF_gte3_P25(ageAns);
      p10 = garcon ? _poidsG_gte3_P10(ageAns) : _poidsF_gte3_P10(ageAns);
      p3  = garcon ? _poidsG_gte3_P3(ageAns)  : _poidsF_gte3_P3(ageAns);
    }

    final band = _bandFromThresholds(poidsKg, p97, p90, p75, p50, p25, p10, p3);

    // Estimation DS via IQR
    final sigma = (p75 - p25) / 1.349;
    final ds = sigma > 0 ? (poidsKg - p50) / sigma : null;

    return ResultatConsult(
      ds: ds,
      percentileBand: band,
      dsColor: ds != null ? _dsColor(ds) : Colors.grey,
    );
  }

  /// Calcule l'IMC et son interprétation IOTF pour un enfant de [ageAns] années.
  static ResultatIMC? calculerIMC({
    required double poidsKg,
    required double tailleCm,
    required double ageAns,
    required bool garcon,
  }) {
    if (poidsKg <= 0 || tailleCm <= 0 || ageAns < 0) return null;

    final imc = poidsKg / pow(tailleCm / 100, 2);

    double p97, p90, p75, p50, p25, p10, p3;
    double ad30, ad35, ad40;

    if (ageAns < 3) {
      p97 = garcon ? _imcG_lt3_P97(ageAns) : _imcF_lt3_P97(ageAns);
      p90 = garcon ? _imcG_lt3_P90(ageAns) : _imcF_lt3_P90(ageAns);
      p75 = garcon ? _imcG_lt3_P75(ageAns) : _imcF_lt3_P75(ageAns);
      p50 = garcon ? _imcG_lt3_P50(ageAns) : _imcF_lt3_P50(ageAns);
      p25 = garcon ? _imcG_lt3_P25(ageAns) : _imcF_lt3_P25(ageAns);
      p10 = garcon ? _imcG_lt3_P10(ageAns) : _imcF_lt3_P10(ageAns);
      p3  = garcon ? _imcG_lt3_P3(ageAns)  : _imcF_lt3_P3(ageAns);
    } else {
      p97 = garcon ? _imcG_gte3_P97(ageAns) : _imcF_gte3_P97(ageAns);
      p90 = garcon ? _imcG_gte3_P90(ageAns) : _imcF_gte3_P90(ageAns);
      p75 = garcon ? _imcG_gte3_P75(ageAns) : _imcF_gte3_P75(ageAns);
      p50 = garcon ? _imcG_gte3_P50(ageAns) : _imcF_gte3_P50(ageAns);
      p25 = garcon ? _imcG_gte3_P25(ageAns) : _imcF_gte3_P25(ageAns);
      p10 = garcon ? _imcG_gte3_P10(ageAns) : _imcF_gte3_P10(ageAns);
      p3  = garcon ? _imcG_gte3_P3(ageAns)  : _imcF_gte3_P3(ageAns);
    }

    ad30 = garcon ? _iotfG_AD30(ageAns) : _iotfF_AD30(ageAns);
    ad35 = garcon ? _iotfG_AD35(ageAns) : _iotfF_AD35(ageAns);
    ad40 = garcon ? _iotfG_AD40(ageAns) : _iotfF_AD40(ageAns);

    final band = _bandFromThresholds(imc, p97, p90, p75, p50, p25, p10, p3);

    // Zone IOTF
    String zoneIOTF;
    Color couleur;
    if (imc > ad40) {
      zoneIOTF = 'Obésité grade III (équiv. adulte > 40)';
      couleur  = const Color(0xFF4A148C); // violet foncé
    } else if (imc > ad35) {
      zoneIOTF = 'Obésité grade II (équiv. adulte 35-40)';
      couleur  = const Color(0xFF9C27B0); // violet
    } else if (imc > ad30) {
      zoneIOTF = 'Obésité grade I (équiv. adulte 30-35)';
      couleur  = const Color(0xFFF44336); // rouge
    } else if (imc > p97) {
      zoneIOTF = 'Surpoids (> 97e percentile)';
      couleur  = const Color(0xFFFF9800); // orange
    } else if (imc < p3) {
      zoneIOTF = 'Insuffisance pondérale (< 3e percentile)';
      couleur  = const Color(0xFF1565C0); // bleu foncé
    } else if (imc < p10) {
      zoneIOTF = 'Maigreur modérée (3-10e percentile)';
      couleur  = const Color(0xFF1976D2); // bleu
    } else {
      zoneIOTF = 'Corpulence normale';
      couleur  = const Color(0xFF43A047); // vert
    }

    return ResultatIMC(
      imc: imc,
      percentileBand: band,
      zoneIOTF: zoneIOTF,
      couleur: couleur,
    );
  }

  // ─────────────────────────────────────────────────────
  //  Texte résumé pour le courrier (balise {{ExamenClinique}})
  // ─────────────────────────────────────────────────────

  static String buildTexteConsult({
    required bool garcon,
    required double ageAns,
    required double? poidsKg,
    required double? tailleCm,
    required double? pcCm,
  }) {
    final String pronom  = garcon ? 'il'   : 'elle';
    final String ne      = garcon ? 'é'    : 'ée';
    final int    annees  = ageAns.floor();
    final int    moisRem = ((ageAns - annees) * 12).round();

    String ageStr;
    if (annees == 0) {
      ageStr = '$moisRem mois';
    } else if (moisRem == 0) {
      ageStr = '$annees an${annees > 1 ? "s" : ""}';
    } else {
      ageStr = '$annees an${annees > 1 ? "s" : ""} et $moisRem mois';
    }

    String buf = "À l'examen clinique, à l'âge de $ageStr, ";

    if (tailleCm != null && tailleCm > 0) {
      final r = calculerDsTaille(tailleCm: tailleCm, ageAns: ageAns, garcon: garcon);
      buf += '$pronom mesure ${tailleCm.toStringAsFixed(1)} cm';
      if (r != null && r.ds != null) {
        final sign = r.ds! >= 0 ? '+' : '';
        buf += ' ($sign${r.ds!.toStringAsFixed(2)} DS, ${r.percentileBand}e perc.)';
      }
      buf += ', ';
    }

    if (poidsKg != null && poidsKg > 0) {
      final r = calculerDsPoids(poidsKg: poidsKg, ageAns: ageAns, garcon: garcon);
      buf += '$pronom pèse ${poidsKg.toStringAsFixed(1)} kg';
      if (r != null) {
        buf += ' (${r.percentileBand}e perc.';
        if (r.ds != null) {
          final sign = r.ds! >= 0 ? '+' : '';
          buf += ', $sign${r.ds!.toStringAsFixed(2)} DS';
        }
        buf += ')';
      }
      buf += ', ';
    }

    if (pcCm != null && pcCm > 0) {
      final r = calculerDsPC(pcCm: pcCm, ageAns: ageAns, garcon: garcon);
      buf += 'et a un périmètre crânien de ${pcCm.toStringAsFixed(1)} cm';
      if (r != null && r.ds != null) {
        final sign = r.ds! >= 0 ? '+' : '';
        buf += ' ($sign${r.ds!.toStringAsFixed(2)} DS, ${r.percentileBand}e perc.)';
      }
      buf += '. ';
    }

    if (poidsKg != null && tailleCm != null && poidsKg > 0 && tailleCm > 0) {
      final r = calculerIMC(poidsKg: poidsKg, tailleCm: tailleCm, ageAns: ageAns, garcon: garcon);
      if (r != null) {
        buf += 'Son IMC est de ${r.imcStr} (${r.percentileBand}e perc., ${r.zoneIOTF}).';
      }
    }

    return buf.trim();
  }
}
