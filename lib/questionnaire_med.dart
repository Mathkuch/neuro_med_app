import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'auxologie_naissance.dart';
import 'auxologie_consultation.dart';
import 'examen_clinique_neuro.dart';




class QuestionnairePatient extends StatefulWidget {
  const QuestionnairePatient({super.key});

  @override
  State<QuestionnairePatient> createState() => _QuestionnairePatientState();
}

class _QuestionnairePatientState extends State<QuestionnairePatient> {
    final Color blueCHRU = const Color(0xFF00599A);
    final Color lightBlueBG = const Color.fromARGB(255, 186, 217, 252);
    String? _modeAccouchement;
    // --- 1. IDENTITÉ ENFANT & CONSULTATION ---
    final TextEditingController _nomEnfantController = TextEditingController();
    final TextEditingController _prenomEnfantController = TextEditingController();
    final TextEditingController _motifController = TextEditingController();
    DateTime? ddnEnfant;
    String sexe = 'Masculin';
    String lateralite = 'droitier';
    // --- 2. PARENTS ---
    final TextEditingController _nomPereController = TextEditingController();
    final TextEditingController _prenomPereController = TextEditingController();
    final TextEditingController _metierPereController = TextEditingController();
    final TextEditingController _originePereController = TextEditingController(text: 'européenne');
    final TextEditingController _atcdPereController = TextEditingController();
    final TextEditingController _atcdFamPereController = TextEditingController();
    DateTime? ddnPere;
    int _ongletSauvegarde = 0;
    final TextEditingController _nomMereController = TextEditingController();
    final TextEditingController _prenomMereController = TextEditingController();
    final TextEditingController _metierMereController = TextEditingController();
    final TextEditingController _origineMereController = TextEditingController(text: 'européenne');
    final TextEditingController _atcdMereController = TextEditingController();
    final TextEditingController _atcdFamMereController = TextEditingController();
    DateTime? ddnMere;
    final TextEditingController _precisionConsanguiniteCtrl = TextEditingController();
        // --- 3. FRATRIE ---
    final TextEditingController _rangController = TextEditingController();
    final TextEditingController _nbEnfantsController = TextEditingController();
    final TextEditingController _atcdFratrieController = TextEditingController();
    final TextEditingController _demiFreresPatController = TextEditingController();
    final TextEditingController _demiFreresMatController = TextEditingController();
    // --- 4. NAISSANCE ET SCOLARITÉ ---
    final TextEditingController _grossesseController = TextEditingController(text: "La grossesse était spontanée, de déroulement normal. Les échographies fœtales étaient sans particularité. Il n'y avait pas d'anomalie des sérologies maternelles, ni de prise de toxique ou de médicament pendant la grossesse.");
    final TextEditingController _termeSAController = TextEditingController();
    final TextEditingController _termeJoursController = TextEditingController();
    final TextEditingController _poidsController = TextEditingController();
    final TextEditingController _tailleController = TextEditingController();
    final TextEditingController _pcController = TextEditingController();
    final TextEditingController _apgar1Controller = TextEditingController();
    final TextEditingController _apgar5Controller = TextEditingController();
    final TextEditingController _scolariteCtrl = TextEditingController(text: "Actuellement, l'enfant est en classe de . Il est gardé par ");
    final TextEditingController _detailAccouchementController = TextEditingController();
    // --- 5. Antécédents et Allergies
    final TextEditingController _atcdMedCtrl = TextEditingController();
    final TextEditingController _atcdChirCtrl = TextEditingController();
    final TextEditingController _allergiesController = TextEditingController();
    final TextEditingController _traitements = TextEditingController();
    final TextEditingController _vaccinsController = TextEditingController();
    // --- 6. HISTOIRE DE LA MALADIE ---
    final TextEditingController _cliniqueCtrl = TextEditingController();
    final TextEditingController _imagerieCtrl = TextEditingController();
    final TextEditingController _eegCtrl = TextEditingController();
    final TextEditingController _traitEssayesCtrl = TextEditingController();
    final TextEditingController _suiviCtrl = TextEditingController();
    // Traitements en cours (liste structurée : nom, dose, répartition)
    List<Map<String, String>> _traitementsEnCours = [];

    // --- 7. EXAMEN CLINIQUE CONSULTATION ---
    DateTime? dateConsultation;                           // null = aujourd'hui
    final TextEditingController _poidsConsultCtrl   = TextEditingController();
    final TextEditingController _tailleConsultCtrl  = TextEditingController();
    final TextEditingController _pcConsultCtrl      = TextEditingController();
    String _examNeuroTexte = '';                          // résultat UserForm6

    // --- 8. CAT (Conduite À Tenir) ---
    bool _catPAI_Absences          = false;
    bool _catPAI_CGTC              = false;
    bool _catPAI_CCH               = false;
    bool _catPAI_Migraine          = false;
    bool _catDEM_IRM_AG            = false;
    bool _catDEM_IRM_Premed        = false;
    bool _catDEM_IRM_SansPremed    = false;
    bool _catDEM_EEG_Veille        = false;
    bool _catDEM_EEG_VeilleSommeil = false;
    bool _catDEM_Genetique         = false;
    bool _catIRM_Premed100         = false; // true = bizone (ALD), false = simple
    bool _catDEM_TEP               = false;
    bool _catDEM_BilanHDJ          = false;
    Set<String>   _bilanSelected       = {};
    final TextEditingController _catConclusionCtrl = TextEditingController();
    String _catTexte = '';
    bool _catEstSuivi = false;
    bool _isOHS       = false;  // false = CHRU de Nancy, true = OHS Flavigny
    List<String> _brochuresRemises = [];  // noms des brochures remises au patient

    // Étapes de développement
    final TextEditingController _assisCtrl = TextEditingController();
    final TextEditingController _marcheCtrl = TextEditingController();
    final TextEditingController _motsCtrl = TextEditingController();
    final TextEditingController _propreteCtrl = TextEditingController();
    final TextEditingController _sommeilCtrl = TextEditingController();
    final TextEditingController _alimCtrl = TextEditingController();

    // Contrôleurs additionnels sommeil pour les 6 mois - 4 ans
    // Stockage pour le développement et le sommeil
    final Map<String, bool> _devChecklist = {};
    final List<int?> _sdscResponses = List.filled(26, null);

    // Contrôleurs Sommeil (6 mois - 4 ans)
    final TextEditingController _heureCoucher = TextEditingController();
    final TextEditingController _heureLever = TextEditingController();
    final TextEditingController _dureeSieste = TextEditingController();
    final TextEditingController _dureeEveilNuit = TextEditingController();
    final TextEditingController _nbReveilNuit = TextEditingController();
    final TextEditingController _actionReveil = TextEditingController();

    // Contrôleurs Génétique — anomalie familiale connue
    final TextEditingController _genGeneConnu        = TextEditingController();
    final TextEditingController _genLaboratoire      = TextEditingController(text: 'CHRU Nancy');
    bool _genAnoFamiliale = false;
   
    // Données du développement psychomoteur (4 domaines)
    final Map<double, Map<String, List<String>>> _milestonesData = {
      0.167: {
        'Motricité Globale': ["A une tenue de tête", "Bouge vigoureusement les 4 membres de manière symétrique", "Passe du côté vers le dos", "Soulève la tête et les épaules sur le ventre", "Donne des coups avec ses mains et ses pieds pour s’amuser quand il est couché sur le dos", "A une préhension involontaire au contact"],
        'Motricité Fine': ["Ouvre les mains", "Joue avec ses mains", "Porte ses mains à sa bouche", "Peut secouer un objet pendant quelques secondes sans l’échapper"],
        'Langage oral': ["Vocalise", "Emet une réponse vocale à une sollicitation"],
        'Socialisation': ["A un sourire réponse", "Réagit quand votre voix ou votre ton change pour exprimer différentes émotions", "Observe les yeux et la bouche de la personne qui lui parle", "Cesse de téter pour écouter les sons qui l’entourent", "Rit aux éclats"],
      },
      0.333: {
        'Motricité Globale': ["Bouge vigoureusement les 4 membres de manière symétrique", "Tient sa tête droite maintenu assis", "Soulève la tête et les épaules sur le ventre", "Attrape des objets en soulevant un bras et en s’appuyant sur l’autre lorsqu’il est sur le ventre", "Passe sur le dos lorsqu’il est couché sur le ventre"],
        'Motricité Fine': ["A une préhension grossière, utilises toute la main", "Attrape un objet qui lui est tendu", "Porte les objets à sa bouche", "Regarde ses doigts", "Laisse tomber des objets et les ramasse"],
        'Langage oral': ["Vocalise ou gazouille", "Joue avec les sons en modifiant l’intensité (bas ou fort) et le débit de sa voix", "Émet des sons lorsqu’il regarde les gens ou ses jouets", "Produit des consonnes suivies de voyelle"],
        'Socialisation': ["Pleure pour attirer l’attention", "Reconnaît les personnes qui s’occupent le plus souvent de lui", "S’intéresse à son parent lorsque celui-ci varie le rythme de sa voix", "Rit aux éclats", "A un sourire sélectif à partir de 3 à 6 mois", "Fixe son regard dans le vôtre", "Lève les bras pour se faire prendre", "Rit aux éclats lorsqu’on le chatouille, lorsqu’on joue à faire « coucou » avec lui", "Peut se montrer triste ou en colère", "Repousse quelqu’un qui lui fait quelque chose qu’il n’aime pas"],
      },
      0.5: {
        'Motricité Globale': ["Tient sa tête stable sans osciller", "Tient assis en tripode, avec appui sur ses mains", "Passe sur le ventre lorsqu’il est couché sur le dos", "Peut se tourner vers la gauche et vers la droite lorsqu’il est couché sur le ventre", "Veut avancer sur le ventre"],
        'Motricité Fine': ["Attrape l’objet tenu à distance", "Utilise une main ou l’autre, sans préférence", "Porte à la bouche, passe un cube d’une main à l’autre", "Tourne son poignet pour faire pivoter et examiner des objets", "Utilise ses mains pour agripper, frapper et renverser des objets qu’il voit", "Commence à tenir un objet d’une main et à en prendre un autre avec l’autre main"],
        'Langage oral': ["Tourne la tête pour regarder la personne qui parle", "Vocalise des monosyllabes", "Babille (consonnes)", "Produit des consonnes suivies de voyelle", "Imite certains de vos sons et de vos intonations", "A tendance à se taire quand l’adulte parle et à produire des sons quand l’adulte se tait"],
        'Socialisation': ["Sourit en réponse au sourire de l’adulte", "Sollicite le regard de l’autre", "Distingue les visages familiers", "Demande les bras", "Réagit parfois au timbre émotif de la voix de ses parents", "Montre une préférence pour un jouet ou un objet particulier", "Sourit aux enfants qu’il ne connaît pas et veut les toucher", "Tourne la tête lorsqu’il l’appelle", "Porte attention à ce qu’il regarde"],
      },
      0.75: {
        'Motricité Globale': ["Rampe", "Tient assis sans appui", "marche à 4 pattes", "Tient debout avec appui", "Passe debout lorsqu’il est assis et que vous le tirez par les mains", "Avance en roulant du dos au ventre et du ventre au dos"],
        'Motricité Fine': ["A une pince inférieure (pouce-auriculaire)", "A une pince supérieure (opposition pouce-index)", "Fait tomber des objets par mégarde, puis les cherche du regard", "Examine des objets en les saisissant, en les secouant, en les glissant et en les frappant", "Transfère un objet de grosseur moyenne d’une main à l’autre", "Met son index dans des trous ou à l’intérieur d’autres objets qui l’intéressent", "Tient seul un biberon"],
        'Langage oral': ["A un babillage canonique", "Reconnaît certains mots dans des situations familières"],
        'Socialisation': ["Répond à son prénom à 7-8 mois", "Peur de l’étranger, détresse au départ de la mère", "Fait les marionnettes, bravo et au revoir", "Va chercher un objet caché", "Montre intentionnellement du doigt les objets qu’il veut"],
      },
      1.0: {
        'Motricité Globale': ["Passe tout seul de la position couchée à la position assise", "Tient assis seul sans appui et sans aide, dos bien droit", "Avance seul au sol", "Met ses mains lorsqu’il tombe en avant, sur les côtés ou vers l’arrière", "Marche lorsque vous le tenez par les deux mains", "Commence à marcher seul"],
        'Motricité Fine': ["Cherche l’objet que l’on vient de cacher", "Prend les petits objets entre le pouce et l’index (pince pulpaire)", "Donne un objet sur ordre", "Utilise son index pour pointer, pousser, toucher et explorer", "Empile de gros objets", "Utilise un objet pour frapper sur un autre objet, comme un outil", "Tient un gros crayon", "Boit au verre"],
        'Langage oral': ["Réagit à son prénom", "Comprend le « non » (un interdit)", "Prononce des syllabes redoublées", "Dit « Papa, maman », jargon de 3 à 5 mots compréhensibles par les parents", "Comprend les ordres simples"],
        'Socialisation': ["Regarde ce que l’adulte lui montre avec le doigt (attention conjointe)", "Fait des gestes sociaux (au revoir, bravo)", "Capable de se montrer triste, joyeux, fâché", "Montre son affection avec des câlins, des bisous, des caresses et des sourires", "Imite la personne qui tape des mains", "Peut se montrer impatient et réagir s’il n’obtient pas rapidement ce qu’il veut"],
      },
      1.5: {
        'Motricité Globale': ["Passe debout seul à partir du sol (transfert assis-debout sans aide)", "Marche sans aide (plus de cinq pas)", "Marche en fonçant sur un ballon pour le frapper vers l’âge de 19 mois et il le frappe du pied vers 24 mois", "Peut transporter un gros jouet en marchant"],
        'Motricité Fine': ["Empile deux cubes (sur modèle)", "Introduit un petit objet dans un petit récipient", "Enlève quelques vêtements", "Déballe un objet caché dans du papier", "Commence à utiliser des outils simples", "Boit dans une tasse en la soulevant"],
        'Langage oral': ["Désigne un objet ou une image sur consigne orale", "Comprend les consignes simples (chercher un objet connu, etc.)", "Dit spontanément cinq mots"],
        'Socialisation': ["Est capable d’exprimer un refus", "Montre avec le doigt ce qui l’intéresse pour attirer l’attention de l’adulte", "Est possessif avec ses jouets et les personnes de son entourage", "A des changements d’humeur rapides et manifester son désaccord", "Dit « non »"],
      },
      2.0: {
        'Motricité Globale': ["Court avec des mouvements coordonnés des bras", "Monte les escaliers marche par marche (seul ou avec aide)", "Shoote dans un ballon", "Saute sur place, les deux pieds ensemble", "Se met à cheval sur des jouets à roues et les fait avancer en bougeant les deux pieds en même temps"],
        'Motricité Fine': ["Empile cinq cubes (sur modèle)", "Utilise seul la cuillère (même si peu efficace)", "Encastre des formes géométriques simples", "Tourne les pages d’un livre", "Imite une ligne verticale", "Tour de 6 à 8 cubes", "Gribouille en tenant son crayon à pleine main"],
        'Langage oral': ["Dit spontanément plus de dix mots usuels", "Associe deux mots (bébé dodo, maman partie)", "Utilise un vocabulaire de 50 mots", "Dit son prénom", "Obéit aux ordres simples, « oui, non »", "Commence à compter"],
        'Socialisation': ["Participe à des jeux de faire semblant, d’imitation (dînette, garage)", "Est capable de s’opposer à vos demandes, de dire « non » et de décider de certaines choses par lui-même", "A de l'interêt pour les autres enfants (crèche, fratrie, etc.)", "Joue à faire semblant", "Peut attribuer des sentiments et des intentions aux objets comme à son toutou"],
      },
      3.0: {
        'Motricité Globale': ["Descend l’escalier seul en alternant les pieds (avec la rampe)", "Saute d’une marche", "Tient debout sur 1 pied sans appui pendant plus de 3 secondes", "Passe de la position assise à debout sans appui", "Monte les escaliers en alternant les pieds", "Pédale au tricycle", "S’accroupit et se relève sans aide", "Grimpe, glisse, monte une échelle et se balance sur le matériel d’un terrain de jeux"],
        'Motricité Fine': ["Empile huit cubes (sur modèle)", "Copie un cercle sur modèle visuel (non dessiné devant lui)", "Enfile seul un vêtement (bonnet, pantalon, tee-shirt)", "Dévisse/revisse le bouchon d’un flacon", "Recopie un cercle fermé – un trait vertical – un trait horizontal", "A une pince tripode du crayon", "Reproduit un pont de 3 cubes – une tour de 8 cubes – un mur de 4 cubes", "Manipule des ciseaux", "Dessine des maisons et des personnages avec deux ou quatre membres attachés à la tête", "Peut boutonner de gros boutons", "Est capable de se laver et sécher les mains"],
        'Langage oral': ["Dit des phrases de trois mots (avec sujet et verbe, objet)", "Utilise son prénom ou le « je » quand il parle de lui", "Comprend une consigne orale simple (sans geste de l’adulte)", "Dit son prénom", "Dit « je » et « oui »", "Nomme 3 couleurs", "Comprend le langage quotidien, « haut-bas » et « devant-derrière »", "Emploie des articles", "Conjugue des verbes", "A un vocabulaire diversifié (Verbe, adjectif, mots outils, mots fonctionnels, prépositions, pronoms… parfois mal prononcés)", "Peut compter environ jusqu’à 10"],
        'Socialisation': ["Prend plaisir à jouer avec des enfants de son âge", "Sait prendre son tour dans un jeu à deux ou à plusieurs", "Mange seul au repas", "Est capable de s'habiller avec aide (chaussons et chaussettes seul)", "A acquis la propreté diurne/nocturne", "Joue à faire semblant", "Joue à plusieurs", "Est capable de se sépare plus ou moins facilement de sa mère", "Peut anticiper les situations", "A des peurs comme celle des fantômes, des loups et des orages", "Peut exprimer de la jalousie et de l’agressivité envers les autres enfants"],
      },
      4.0: {
        'Motricité Globale': ["Saute à pieds joints (au minimum sur place)", "Monte les marches non tenues et en alternant", "Lance un ballon de façon dirigée", "Sait pédaler (tricycle ou vélo avec stabilisateur)", "Saute sur 1 pied en plus de l’appui monopodal", "Lance, attrape et fait rebondir un ballon"],
        'Motricité Fine': ["Dessine un bonhomme têtard", "Copie une croix orientée selon le modèle (non dessiné devant lui)", "Fait un pont avec trois cubes (sur démonstration)", "Enfile son manteau tout seul", "Est capable de s’habiller sans aide", "Dessine un bonhomme en 3 parties", "Utilise des ciseaux, des gommettes, de la pâte à modeler", "Joue aux puzzles et jeux de construction", "Peint au grand pinceau sur une grande feuille", "Colorie l’intérieur d’une forme simple"],
        'Langage oral': ["Utilise le « je » pour se désigner (ou équivalent dans sa langue natale)", "A un langage intelligible par une personne étrangère à la famille", "Conjugue des verbes au présent", "Pose la question « Pourquoi ? »", "Peut répondre à des consignes avec deux variables", "Compte quatre objets", "Comprend les phrases longues complexes et un récit simple", "Articule tous les sons"],
        'Socialisation': ["A des jeux imaginatifs avec des scénarios", "Sait trier des objets par catégories (couleurs, formes, etc.)", "Accepte de participer à une activité en groupe", "Cherche à jouer ou interagir avec des enfants de son âge"],
      },
      5.0: {
        'Motricité Globale': ["Tient en équilibre sur un pied au moins cinq secondes sans appui", "Marche sur une ligne (en mettant un pied devant l’autre)", "Attrape un ballon avec les mains", "Marche en ligne en arrière"],
        'Motricité Fine': ["Dessine un bonhomme en deux à quatre parties", "Copie son prénom en lettres majuscules (sur modèle)", "Copie un carré (avec quatre coins distincts)", "Dessine un bonhomme en 6 parties (4 membres, tronc, tête)", "Connaît sa main droite, pianotage digital", "Fait claquer sa langue, fait un clin d’œil, gonfle les joues", "Utilise des ciseaux, des gommettes, de la pâte à modeler"],
        'Langage oral': ["Fait des phrases de six mots avec une grammaire correcte", "Comprend des éléments de topologie (dans/sur/derrière)", "Nomme au moins trois couleurs", "Décrit une scène sur une image (personnages, objets, actions)", "Compte jusqu’à dix (comptine numérique)", "Comprend/construit un récit", "A acquis les règles du langage", "Parle sans déformer les mots"],
        'Socialisation': ["Connaît les prénoms de plusieurs de ses camarades", "Participe à des jeux collectifs en respectant les règles"],
      },
      6.0: {
        'Motricité Globale': ["Saute à cloche pied trois à cinq fois (sur place ou en avançant)", "Court de manière fluide et sait s’arrêter net", "Marche sur les pointes et les talons", "Fait du vélo sans les petites roues (casqué)"],
        'Motricité Fine': ["Ferme seul son vêtement (boutons ou fermeture éclair)", "Touche avec son pouce chacun des doigts de la même main après démonstration", "Copie un triangle", "Est capable de se laver et/ou s’essuier les mains sans assistance", "Dessine un bonhomme en 6 parties (4 membres, tronc, tête)"],
        'Langage oral': ["Peut raconter une petite histoire de manière structurée", "Peut dialoguer en respectant le tour de parole", "Fait des phrases construites (grammaticalement correctes)", "Joue aux contraires par analogie", "Compte jusqu’à 13", "Dénombre treize objets présentés (crayons, jetons, etc.)", "Peut répéter dans l’ordre trois chiffres non sériés (5, 2, 9)", "Reconnaît tous les chiffres (de 0 à 9)"],
        'Socialisation': ["Reconnaît l’état émotionnel d’autrui et réagit de manière ajustée (sait consoler son/sa camarade)", "Maintient son attention environ dix minutes sur une activité qui l’intéresse, sans recadrage"],
      },
    };
    // États pour les cases à cocher
    bool pasAtcdMed = true;
    bool pasAtcdChir = true;
    bool pasAllergie = true;
    bool vaccinsAJour = true;
    bool traitements = true;
    bool pasAtcdPersoPere = true, pasAtcdFamPere = true;
    bool pasAtcdPersoMere = true, pasAtcdFamMere = true;
    bool pasConsanguinite = true;
    bool hasDemiFreres = false, pasDemiMat = true, pasDemiPat = true;
    bool pasAtcdFratrie = true, grossesseNormale = true, accouchementNormal = true, dvpNormal = true;
    bool imagerieNonFaite = true;
    bool eegNonFait = true;
    bool pasTraitementEssaye = true;
    bool pasSuivi = true;
    bool pasTroubleSommeil = true;
    bool pasTroubleAlim = true; // Par défaut, l'onglet Sommeil est caché   // Pour l'affichage conditionnel de l'onglet Sommeil
    @override
    void initState() {
      super.initState();
      _nomEnfantController.addListener(() {
        _nomPereController.text = _nomEnfantController.text;
      });
      // Recalcul des DS naissance à chaque modification
      void _refreshDS() => setState(() {});
      _termeSAController.addListener(_refreshDS);
      _termeJoursController.addListener(_refreshDS);
      _poidsController.addListener(_refreshDS);
      _tailleController.addListener(_refreshDS);
      _pcController.addListener(_refreshDS);
      // Recalcul DS consultation
      _poidsConsultCtrl.addListener(_refreshDS);
      _tailleConsultCtrl.addListener(_refreshDS);
      _pcConsultCtrl.addListener(_refreshDS);
    }
  // Remplace l'ancienne logique par votre calcul A4 (moyenne)
  List<double> _getAgesAAfficher() {
    if (ddnEnfant == null) return [];
    
    double a = _calculerAgeMois() / 12.0; // Âge réel en années
    List<double> table = [0.167, 0.333, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0];
    
    // Trouver A2 (l'âge de la table juste en dessous ou égal)
    int indexA2 = table.lastIndexWhere((age) => age <= a);
    
    // Cas où l'enfant est plus jeune que le premier palier ou plus vieux que le dernier
    if (indexA2 == -1) return [0.167, 0.333];
    if (indexA2 >= table.length - 1) return [5.0, 6.0];

    double a2 = table[indexA2];
    double a3 = table[indexA2 + 1];
    double a4 = (a3 + a2) / 2.0;
    return (a >= a4) ? [a2, a3] : [ (indexA2 > 0 ? table[indexA2 - 1] : 0.167), a2 ];
  }

  // Transforme les chiffres en texte lisible pour l'utilisateur
  String _getAgeLabel(double age) {
    if (age < 1.0) return "${(age * 12).round()} mois";
    if (age == 1.5) return "18 mois";
    return "${age.toInt()} ans";
  }
  
 @override
  Widget build(BuildContext context) {
    int ageMois = _calculerAgeMois();
    
    // 1. Définition des conditions de visibilité
    bool afficherSommeil = !pasTroubleSommeil;
    bool afficherDev = ddnEnfant != null && ageMois < 78; // Moins de 6.5 ans

    // 2. Initialisation des listes avec les 4 onglets de base
    List<Tab> mesTabs = [
      const Tab(text: 'Généralités'),
      const Tab(text: 'Antécédents'),
      const Tab(text: 'Histoire'),
      const Tab(text: 'Examen Clinique'),
      const Tab(text: 'CAT'),
    ];

    List<Widget> mesVues = [
      _buildTabGeneral(),
      _buildTabSante(),
      _buildTabHistoire(),
      _buildTabExamenClinique(),
      _buildTabCAT(),
    ];

    // 1. On calcule le nombre d'onglets actifs
    int nbOnglets = 5; // Généralités, Antécédents, Histoire, Examen Clinique, CAT
    if (ddnEnfant != null && _calculerAgeMois() < 78) nbOnglets++;
    if (!pasTroubleSommeil) nbOnglets++;

    // 3. Ajout SYNCHRONISÉ des onglets optionnels
    if (afficherDev) {
      // On ajoute le titre ET la vue au même moment
      mesTabs.add(const Tab(text: 'Développement'));
      mesVues.add(_buildTabDeveloppement());
    }

    if (afficherSommeil) {
      // On ajoute le titre ET la vue au même moment
      mesTabs.add(const Tab(text: 'Sommeil'));
      mesVues.add(_buildTabSDSC());
    }

    // 4. Rendu de l'interface
    return DefaultTabController(
      key: ValueKey(nbOnglets), 
      length: nbOnglets, // Maintenant la longueur est garantie correcte
      initialIndex: _ongletSauvegarde,
      child: Scaffold(
        backgroundColor: lightBlueBG,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            actions: const [],
            toolbarHeight: 140,
            title: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  'lib/assets/images/logo_chru.png', 
                  height: 60,
                  errorBuilder: (c, e, s) => Icon(Icons.local_hospital, color: blueCHRU, size: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  "Consultation de neurologie pédiatrique-version medecin",
                  style: TextStyle(color: blueCHRU, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: blueCHRU,
              unselectedLabelColor: Colors.grey,
              indicatorColor: blueCHRU,
              tabs: [
                const Tab(text: "Généralités"),
                const Tab(text: "Antécédents"),
                const Tab(text: "Histoire"),
                const Tab(text: "Examen Clinique"),
                const Tab(text: "CAT"),
                if (ddnEnfant != null && _calculerAgeMois() < 78) const Tab(text: "Développement"),
                if (!pasTroubleSommeil) const Tab(text: "Sommeil"),
              ],
            ),
          ),
        // Colonne de FABs
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bouton 1 : Charger un patient
            FloatingActionButton.extended(
              heroTag: "btn_load",
              onPressed: _chargerDonneesPatient,
              label: const Text('Charger un patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.person_search, color: Colors.white),
              backgroundColor: Colors.teal,
            ),

            const SizedBox(height: 15),

            // Bouton 2 : Générer Word (1ère CS ou suivi selon _catEstSuivi)
            FloatingActionButton.extended(
              heroTag: "btn_word",
              onPressed: () async {
                if (_catEstSuivi) {
                  await _genererCourrierSuivi();
                } else {
                  await genererCompteRenduPrincipal();
                }
              },
              icon: Icon(_catEstSuivi
                  ? Icons.repeat_outlined
                  : Icons.description),
              label: Text(
                _catEstSuivi ? "Courrier Suivi" : "Générer Word",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: _catEstSuivi
                  ? const Color(0xFF2E7D32)
                  : blueCHRU,
              foregroundColor: Colors.white,
            ),
          ],
        ),
        body: TabBarView(
          children: mesVues,
        ),
      ),
    );
  }
  
  int _calculerAgeMois() {
    if (ddnEnfant == null) return 0;
    final maintenant = DateTime.now();
    return (maintenant.year - ddnEnfant!.year) * 12 + maintenant.month - ddnEnfant!.month;
  }
  // ────────────────────────────────────────────────────────
  // Construit le texte de naissance pour le Word/CR
  // Ex: "Il est né à 39 SA+4j. Poids : 3 250 g (-0,45 DS, 25-50e perc.),
  //      Taille : 49 cm (-0,80 DS, 25-50e perc.), PC : 34 cm (-0,20 DS, 50-75e perc.)"
  // ────────────────────────────────────────────────────────
  // Construit le texte des traitements en cours (liste structurée + texte libre)
  // ────────────────────────────────────────────────────────
  String _buildTraitementsText() {
    final parts = <String>[];
    // 1. Liste structurée (nouveau bloc Histoire)
    for (final t in _traitementsEnCours) {
      final nom    = (t['nom']         ?? '').trim();
      final dose   = (t['dose']        ?? '').trim();
      final rep    = (t['repartition'] ?? '').trim();
      if (nom.isNotEmpty) {
        String ligne = '• $nom';
        if (dose.isNotEmpty) ligne += ' $dose';
        if (rep.isNotEmpty)  ligne += ' — $rep';
        parts.add(ligne);
      }
    }
    // 2. Texte libre legacy (onglet Antécédents)
    final legacy = _traitements.text.trim();
    if (legacy.isNotEmpty) parts.add(legacy);
    return parts.join('\n');
  }

  // ────────────────────────────────────────────────────────
  String _buildNaissanceText() {
    final int sa     = int.tryParse(_termeSAController.text.trim()) ?? 0;
    final int jours  = int.tryParse(_termeJoursController.text.trim()) ?? 0;
    final double pdg = double.tryParse(_poidsController.text.trim()) ?? 0;
    final double tll = double.tryParse(_tailleController.text.trim()) ?? 0;
    final double pcv = double.tryParse(_pcController.text.trim()) ?? 0;
    final bool garcon = sexe == 'Masculin';

    String texte = '';
    if (sa > 0) {
      texte += 'Terme : $sa SA';
      if (jours > 0) texte += '+${jours}j';
      texte += '.';
    }

    String _dsStr(ResultatAuxo? r, double val, String unite) {
      if (val <= 0) return '';
      String t = '$val $unite';
      if (r != null) {
        final sign = (r.ds ?? 0) >= 0 ? '+' : '';
        final dsFormatted = '$sign${(r.ds!).toStringAsFixed(2)} DS';
        t += ' ($dsFormatted, ${r.percentileBand} perc.)';
      }
      return t;
    }

    final bool termeOk = sa >= 24 && sa <= 43;
    final rP = termeOk && pdg > 0
        ? AuxologieNaissance.calculerDsPoids(poidsG: pdg, termeSA: sa, termeJours: jours, garcon: garcon) : null;
    final rT = termeOk && tll > 0
        ? AuxologieNaissance.calculerDsTaille(tailleCm: tll, termeSA: sa, termeJours: jours, garcon: garcon) : null;
    final rC = termeOk && pcv > 0
        ? AuxologieNaissance.calculerDsPC(pcCm: pcv, termeSA: sa, termeJours: jours, garcon: garcon) : null;

    final List<String> mesures = [];
    final pStr = _dsStr(rP, pdg, 'g');
    final tStr = _dsStr(rT, tll, 'cm');
    final cStr = _dsStr(rC, pcv, 'cm');
    if (pStr.isNotEmpty) mesures.add('Poids : $pStr');
    if (tStr.isNotEmpty) mesures.add('Taille : $tStr');
    if (cStr.isNotEmpty) mesures.add('PC : $cStr');
    if (mesures.isNotEmpty) {
      if (texte.isNotEmpty) texte += ' ';
      texte += mesures.join(', ');
    }
    return texte.isEmpty ? 'Non renseigné' : texte;
  }

  // ─────────────────────────────────────────────────────────
  //  Âge à la consultation (utilise dateConsultation ou today)
  // ─────────────────────────────────────────────────────────
  double _calculerAgeAnsConsult() {
    if (ddnEnfant == null) return 0;
    final ref = dateConsultation ?? DateTime.now();
    return ref.difference(ddnEnfant!).inDays / 365.25;
  }

  /// Âge en mois entier — utilisé comme ValueKey pour ExamenNeuroWidget.
  int get _ageM => (_calculerAgeAnsConsult() * 12).round();

  String _ageConsultLabel() {
    if (ddnEnfant == null) return 'Âge inconnu (DDN manquante)';
    final a = _calculerAgeAnsConsult();
    final ans    = a.floor();
    final moisRem = ((a - ans) * 12).round();
    if (ans == 0) return '$moisRem mois';
    if (moisRem == 0) return '$ans an${ans > 1 ? "s" : ""}';
    return '$ans an${ans > 1 ? "s" : ""} et $moisRem mois';
  }

  // ─────────────────────────────────────────────────────────
  //  Mensurations format compact pour le courrier
  //  Taille + DS  |  Poids + percentile IOTF  |  PC + DS
  // ─────────────────────────────────────────────────────────
  String _mensurationsCompactes({
    required double? poidsKg,
    required double? tailleCm,
    required double? pcCm,
    required double  ageAns,
    required bool    garcon,
  }) {
    String _ds(double? ds) {
      if (ds == null) return '';
      final sign = ds >= 0 ? '+' : '';
      return '$sign${ds.toStringAsFixed(2)} DS';
    }

    final parts = <String>[];

    if (tailleCm != null && tailleCm > 0) {
      final r = AuxologieConsult.calculerDsTaille(
          tailleCm: tailleCm, ageAns: ageAns, garcon: garcon);
      final dsStr = (r != null && r.ds != null) ? ' (${_ds(r.ds)})' : '';
      parts.add('Taille : ${tailleCm.toStringAsFixed(1)} cm$dsStr');
    }

    if (poidsKg != null && poidsKg > 0) {
      final r = AuxologieConsult.calculerDsPoids(
          poidsKg: poidsKg, ageAns: ageAns, garcon: garcon);
      final percStr = r != null ? ' (${r.percentileBand}e perc.)' : '';
      parts.add('Poids : ${poidsKg.toStringAsFixed(1)} kg$percStr');
    }

    if (pcCm != null && pcCm > 0) {
      final r = AuxologieConsult.calculerDsPC(
          pcCm: pcCm, ageAns: ageAns, garcon: garcon);
      final dsStr = (r != null && r.ds != null) ? ' (${_ds(r.ds)})' : '';
      parts.add('PC : ${pcCm.toStringAsFixed(1)} cm$dsStr');
    }

    return parts.join('  —  ');
  }

  // ─────────────────────────────────────────────────────────
  //  Texte examen clinique pour le courrier Word
  // ─────────────────────────────────────────────────────────
  String _buildExamenCliniqueText() {
    final double? p = double.tryParse(_poidsConsultCtrl.text.trim());
    final double? t = double.tryParse(_tailleConsultCtrl.text.trim());
    final double? c = double.tryParse(_pcConsultCtrl.text.trim());
    final double ageAns = _calculerAgeAnsConsult();
    final bool garcon = sexe == 'Masculin';
    final String il = garcon ? 'il' : 'elle';

    String _dsStr(double? ds) {
      if (ds == null) return '';
      final sign = ds >= 0 ? '+' : '';
      return '$sign${ds.toStringAsFixed(2)} DS';
    }

    final sb = StringBuffer();

    // Phrase auxologie complète
    final bool hasMensurations =
        (p != null && p > 0) || (t != null && t > 0) || (c != null && c > 0);
    if (hasMensurations) {
      // Âge en texte
      final int ans    = ageAns.floor();
      final int moisR  = ((ageAns - ans) * 12).round();
      final String ageStr = ans == 0
          ? '$moisR mois'
          : (moisR == 0
              ? '$ans an${ans > 1 ? "s" : ""}'
              : '$ans an${ans > 1 ? "s" : ""} et $moisR mois');

      final parts = <String>[];

      if (t != null && t > 0) {
        final r = AuxologieConsult.calculerDsTaille(
            tailleCm: t, ageAns: ageAns, garcon: garcon);
        final ds = (r != null && r.ds != null) ? ' (${_dsStr(r.ds)})' : '';
        parts.add('mesure ${t.toStringAsFixed(1)} cm$ds');
      }

      if (p != null && p > 0) {
        final rP = AuxologieConsult.calculerDsPoids(
            poidsKg: p, ageAns: ageAns, garcon: garcon);
        final band = rP != null ? ' (${rP.percentileBand} perc.)' : '';
        String poidsPhrase = 'pèse ${p.toStringAsFixed(1)} kg$band';
        if (t != null && t > 0) {
          final rIMC = AuxologieConsult.calculerIMC(
              poidsKg: p, tailleCm: t, ageAns: ageAns, garcon: garcon);
          if (rIMC != null) {
            poidsPhrase += ' soit un IMC de ${rIMC.imcStr} kg/m² (${rIMC.percentileBand} percentile)';
          }
        }
        parts.add(poidsPhrase);
      }

      if (c != null && c > 0) {
        final rC = AuxologieConsult.calculerDsPC(
            pcCm: c, ageAns: ageAns, garcon: garcon);
        final ds = (rC != null && rC.ds != null) ? ' (${_dsStr(rC.ds)})' : '';
        parts.add('un périmètre crânien de ${c.toStringAsFixed(1)} cm$ds');
      }

      if (parts.isNotEmpty) {
        final String verbPhrase = parts.length == 1
            ? '$il ${parts.first}'
            : parts.length == 2
                ? '$il ${parts[0]} et ${parts[1]}'
                : '$il ${parts.sublist(0, parts.length - 1).join(', ')} et ${parts.last}';
        sb.writeln("A l'examen clinique, à l'âge de $ageStr, $verbPhrase.");
      }
    }

    // Examen neurologique
    if (_examNeuroTexte.isNotEmpty) {
      if (sb.isNotEmpty) sb.writeln();
      sb.write(_examNeuroTexte);
    }

    return sb.isEmpty ? 'Non renseigné' : sb.toString().trim();
  }

  // ─────────────────────────────────────────────────────────
  //  ONGLET EXAMEN CLINIQUE
  // ─────────────────────────────────────────────────────────
  Widget _buildTabExamenClinique() {
    final bool garcon   = sexe == 'Masculin';
    final double ageAns = _calculerAgeAnsConsult();
    final double? p = double.tryParse(_poidsConsultCtrl.text.trim());
    final double? t = double.tryParse(_tailleConsultCtrl.text.trim());
    final double? c = double.tryParse(_pcConsultCtrl.text.trim());
    final bool ageOk = ddnEnfant != null;

    // Calculs DS / percentiles
    final ResultatConsult? rPoids  = (ageOk && p != null && p > 0)
        ? AuxologieConsult.calculerDsPoids(poidsKg: p, ageAns: ageAns, garcon: garcon) : null;
    final ResultatConsult? rTaille = (ageOk && t != null && t > 0)
        ? AuxologieConsult.calculerDsTaille(tailleCm: t, ageAns: ageAns, garcon: garcon) : null;
    final ResultatConsult? rPC     = (ageOk && c != null && c > 0)
        ? AuxologieConsult.calculerDsPC(pcCm: c, ageAns: ageAns, garcon: garcon) : null;
    final ResultatIMC? rIMC        = (ageOk && p != null && p > 0 && t != null && t > 0)
        ? AuxologieConsult.calculerIMC(poidsKg: p, tailleCm: t, ageAns: ageAns, garcon: garcon) : null;

    return SingleChildScrollView(
      key: const PageStorageKey('tab_examen'),
      padding: const EdgeInsets.all(16),
      child: Column(children: [

        // ── 1. DATE & ÂGE ───────────────────────────────
        _card('Date & Âge de la consultation', Icons.calendar_today, Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dateTileFutur(
              'Date de la consultation',
              dateConsultation,
              (d) => setState(() => dateConsultation = d),
            ),
            if (ddnEnfant == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                    'Entrez la DDN dans l\'onglet "Généralités" pour calculer les DS',
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  )),
                ]),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Icon(Icons.cake_outlined, color: blueCHRU, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Âge : ${_ageConsultLabel()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: blueCHRU,
                    ),
                  ),
                ]),
              ),
          ],
        )),

        const SizedBox(height: 8),

        // ── 2. MENSURATIONS ──────────────────────────────
        _card('Mensurations', Icons.straighten, Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Poids ─────────────────────────────────
            _mensurationRow(
              label: 'Poids (kg)',
              controller: _poidsConsultCtrl,
              resultat: rPoids,
              ageOk: ageOk,
            ),

            const SizedBox(height: 4),

            // ── Taille ────────────────────────────────
            _mensurationRow(
              label: 'Taille (cm)',
              controller: _tailleConsultCtrl,
              resultat: rTaille,
              ageOk: ageOk,
            ),

            const SizedBox(height: 4),

            // ── PC ────────────────────────────────────
            _mensurationRow(
              label: 'Périmètre crânien (cm)',
              controller: _pcConsultCtrl,
              resultat: rPC,
              ageOk: ageOk,
              noteApres5ans: ageOk && ageAns >= 5,
            ),

            // ── Légende ───────────────────────────────
            if (ageOk && (rPoids != null || rTaille != null || rPC != null)) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _legendeChip(const Color(0xFF43A047), '< 1 DS  (normal)'),
                  _legendeChip(const Color(0xFFFF9800), '1-2 DS'),
                  _legendeChip(const Color(0xFFF44336), '2-3 DS'),
                  _legendeChip(const Color(0xFF9C27B0), '> 3 DS'),
                ],
              ),
            ],
          ],
        )),

        const SizedBox(height: 8),

        // ── 3. IMC ───────────────────────────────────────
        if (rIMC != null)
          _cardIMC(rIMC),

        const SizedBox(height: 8),

        // ── 4. EXAMEN NEUROLOGIQUE ───────────────────────
        _card('Examen neurologique', Icons.psychology,
          ageOk
            ? ExamenNeuroWidget(
                key: ValueKey(_ageM),
                ageAns: ageAns,
                onChanged: (text) => setState(() => _examNeuroTexte = text),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Entrez la date de naissance pour activer l\'examen.',
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ]),
              ),
        ),

        const SizedBox(height: 24),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Widget : ligne mensuration + badge DS
  // ─────────────────────────────────────────────────────────
  Widget _mensurationRow({
    required String label,
    required TextEditingController controller,
    required ResultatConsult? resultat,
    required bool ageOk,
    bool noteApres5ans = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _input(label,
                controller: controller,
                keyboardType: TextInputType.number,
              ),
            ),
            if (ageOk && resultat != null) ...[
              const SizedBox(width: 8),
              _dsBadgeConsult(resultat),
            ],
          ],
        ),
        if (noteApres5ans)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 13, color: Colors.blueGrey),
              const SizedBox(width: 4),
              const Text(
                'PC > 5 ans : référence adulte (courbe Adulte Head Circumference)',
                style: TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
            ]),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Badge DS consultation (légèrement plus grand que naissance)
  // ─────────────────────────────────────────────────────────
  Widget _dsBadgeConsult(ResultatConsult r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 88),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: r.dsColor.withAlpha(28),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: r.dsColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              r.ds != null ? r.dsText : '—',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: r.dsColor),
            ),
            Text(
              '${r.percentileBand} perc.',
              style: TextStyle(fontSize: 10, color: r.dsColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Carte IMC + IOTF
  // ─────────────────────────────────────────────────────────
  Widget _cardIMC(ResultatIMC r) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.monitor_weight_outlined, color: blueCHRU, size: 22),
              const SizedBox(width: 8),
              Text('IMC', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: blueCHRU,
              )),
            ]),
            const SizedBox(height: 12),

            // Valeur IMC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.imcStr,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: r.couleur)),
                    Text('kg/m²', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
                // Badge percentile
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(children: [
                    const Text('Percentile AFPA', style: TextStyle(fontSize: 10, color: Colors.black54)),
                    Text('${r.percentileBand}e',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Zone IOTF
            Row(children: [
              const Text('Classification IOTF : ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: r.couleur.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: r.couleur, width: 1.5),
              ),
              child: Row(children: [
                Icon(_imcIcon(r.zoneIOTF), color: r.couleur, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(r.zoneIOTF,
                    style: TextStyle(color: r.couleur, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ]),
            ),

            const SizedBox(height: 10),
            // Note de bas
            Text(
              'Référence : courbes AFPA/CRESS/Inserm-CGM 2018 — seuils IOTF (Cole & Lobstein)',
              style: const TextStyle(fontSize: 10, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  IconData _imcIcon(String zone) {
    if (zone.contains('Obésité')) return Icons.warning_amber_rounded;
    if (zone.contains('Surpoids')) return Icons.trending_up;
    if (zone.contains('Insuffisance') || zone.contains('Maigreur')) return Icons.trending_down;
    return Icons.check_circle_outline;
  }

  // ─────────────────────────────────────────────────────────
  //  Date picker autorisant les dates futures (pour consultation)
  // ─────────────────────────────────────────────────────────
  Widget _dateTileFutur(String l, DateTime? d, Function(DateTime) onP) => ListTile(
    title: Text(d == null
      ? '$l : Aujourd\'hui'
      : '$l : ${DateFormat('dd/MM/yyyy', 'fr_FR').format(d)}'),
    subtitle: d != null
      ? TextButton(
          onPressed: () => setState(() => dateConsultation = null),
          child: const Text("Réinitialiser à aujourd'hui",
            style: TextStyle(fontSize: 12)),
        )
      : null,
    trailing: Icon(Icons.calendar_month, color: blueCHRU),
    onTap: () async {
      DateTime? p = await showDatePicker(
        context: context,
        initialDate: d ?? DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('fr', 'FR'),
      );
      if (p != null) onP(p);
    },
  );

  Widget _buildTabGeneral() {
    return SingleChildScrollView(
      key: const PageStorageKey('tab_general'), // Recommandé pour garder la position du scroll
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // --- CARTE ENFANT ---
        _card('Enfant', Icons.child_care, Column(children: [
          _input('Nom', controller: _nomEnfantController),
          _input('Prénom', controller: _prenomEnfantController),
          _genderRadio(),
          _dateTile('Date de naissance de l\'enfant', ddnEnfant, (d) => setState(() => ddnEnfant = d)),
          _input('Motif de la consultation (raison de la consultation sans détailler)', 
            controller: _motifController, 
            maxLines: 3, 
            hint: 'Ex: retard de developpement, autisme, crise d\'épilepsie...'),
        ])),

        // --- CARTE PÈRE ---
        _card('Père', Icons.person, _parentBlock(
          'Père',
          nomCtrl: _nomPereController,
          prenomCtrl: _prenomPereController,
          metierCtrl: _metierPereController,
          origineCtrl: _originePereController,
          atcdPersoCtrl: _atcdPereController,
          atcdFamCtrl: _atcdFamPereController,
          date: ddnPere,
          onDateChanged: (d) => setState(() => ddnPere = d),
          pasAtcdPerso: pasAtcdPersoPere,
          onAtcdPersoChanged: (v) => setState(() => pasAtcdPersoPere = v!),
          pasAtcdFam: pasAtcdFamPere,
          onAtcdFamChanged: (v) => setState(() => pasAtcdFamPere = v!),
        )),

        // --- CARTE MÈRE ---
        _card('Mère', Icons.person_3, _parentBlock(
          'Mère',
          nomCtrl: _nomMereController,
          prenomCtrl: _prenomMereController,
          metierCtrl: _metierMereController,
          origineCtrl: _origineMereController,
          atcdPersoCtrl: _atcdMereController,
          atcdFamCtrl: _atcdFamMereController,
          date: ddnMere,
          onDateChanged: (d) => setState(() => ddnMere = d),
          pasAtcdPerso: pasAtcdPersoMere,
          onAtcdPersoChanged: (v) => setState(() => pasAtcdPersoMere = v!),
          pasAtcdFam: pasAtcdFamMere,
          onAtcdFamChanged: (v) => setState(() => pasAtcdFamMere = v!),
        )),

        // --- CARTE FAMILLE ---
        _card('Famille', Icons.family_restroom, Column(children: [
          // Utilisation de Transform.scale pour réduire la taille du bouton
          Transform.scale(
            scale: 0.85, // Réduit la taille de 15%
            child: _toggle(
              pasConsanguinite ? 'Pas de lien de parenté entre les parents' : 'Présence d\'un lien de parenté entre les parents',
              pasConsanguinite,
              (v) => setState(() => pasConsanguinite = v!),
            ),
          ),
          // Affichage conditionnel du champ de précision si un lien existe [cite: 67]
          if (!pasConsanguinite) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _input(
                'Précisez le lien (ex: cousins, grand-mères du couple soeurs...)', 
                controller: _precisionConsanguiniteCtrl
              ),
            ),
          const Divider(),
          _fratrieBlock(), 
          const SizedBox(height: 80), // Sécurité pour que le QR Code ne cache pas le contenu 
        ])),
      ]),
    );
  }
  // Fonction qui ouvre l'horloge de Flutter
  Future<void> _choisirHeure(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? heureChoisie = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0), // Heure par défaut
      builder: (context, child) {
        // Force l'affichage au format 24h (évite le format AM/PM américain)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (heureChoisie != null) {
      setState(() {
        // Formate l'heure proprement avec un "h" (ex: 07h30)
        String heures = heureChoisie.hour.toString().padLeft(2, '0');
        String minutes = heureChoisie.minute.toString().padLeft(2, '0');
        controller.text = "${heures}h$minutes";
      });
    }
  }

  // Le widget de champ texte cliquable
  Widget _timeInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Empêche l'ouverture du clavier normal
        onTap: () => _choisirHeure(context, controller), // Ouvre l'horloge au clic
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(Icons.access_time, color: blueCHRU), // Ajoute une icône d'horloge
        ),
      ),
    );
  }
  Widget _buildTabDeveloppement() {
    double ageExact = _calculerAgeMois() / 12.0;
    int anneePrincipale = ageExact.floor();
    int anneeSecondaire = (ageExact - anneePrincipale < 0.5) ? anneePrincipale - 1 : anneePrincipale + 1;

    List<int> anneesAffichage = [anneePrincipale, anneeSecondaire]..sort();
    anneesAffichage = anneesAffichage.where((a) => a >= 2 && a <= 6).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Évaluation du Développement", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blueCHRU)),
          const SizedBox(height: 8),
          const Text("Veuillez cocher les acquisitions maîtrisées par l'enfant.",
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
          const SizedBox(height: 16),

          if (anneesAffichage.isEmpty)
            const Text("L'évaluation détaillée par domaines est disponible pour les enfants de 2 à 6 ans."),

          // Appel dynamique des blocs de questions selon l'âge
          ..._getAgesAAfficher().map((double age) => _buildYearSection(age)),
        ],
      ),
    );
  }

Widget _buildYearSection(double age) {
    // On utilise le helper pour transformer 0.167 en "2 mois" ou 3.0 en "3 ans"
    final String labelAge = _getAgeLabel(age);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête de la section (ex: Acquisitions attendues à 6 mois)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: blueCHRU,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Text(
              "Acquisitions attendues à $labelAge", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          
          // Parcours des domaines (Motricité, Langage, etc.) pour cet âge
          ...(_milestonesData[age] ?? {}).entries.map((domaine) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sous-titre du domaine (ex: Motricité Fine)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  // Utilisation de withOpacity pour la compatibilité ou withValues selon votre version
                  color: blueCHRU.withValues(alpha: 0.05), 
                  child: Text(
                    domaine.key, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: blueCHRU)
                  ),
                ),
                
                // Liste des items avec Checkbox
                ...domaine.value.map((item) => CheckboxListTile(
                  title: Text(item, style: const TextStyle(fontSize: 13)),
                  // La clé de stockage utilise l'âge (double) pour rester unique
                  value: _devChecklist["$age-$item"] ?? false,
                  onChanged: (v) => setState(() => _devChecklist["$age-$item"] = v!),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true, // Pour réduire la taille comme demandé
                  activeColor: blueCHRU,
                )),
              ],
            );
          }),
        ],
      ),
    );
  }
  Widget _buildTabSDSC() {
    int ageMois = _calculerAgeMois();
    
    // Sécurité si la date de naissance n'est pas saisie
    if (ddnEnfant == null) {
      return const Center(
        child: Text("Veuillez saisir la date de naissance dans l'onglet Généralités."),
      );
    }

    bool estPetit = ageMois < 48; // Moins de 4 ans
    int totalQuestions = estPetit ? 22 : 25;

    return CustomScrollView(
      slivers: [
        // --- PARTIE 1 : TOUT CE QUI DÉFILE NORMALEMENT AU-DESSUS ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de l'échelle
                Text(
                  estPetit 
                    ? "Échelle des troubles du sommeil (6 mois à 4 ans)" 
                    : "Échelle des troubles du sommeil (4 à 16 ans)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: blueCHRU),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Basez-vous sur les observations des 6 derniers mois.",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // SECTION 1 : Infos spécifiques pour les 6 mois - 4 ans
                if (estPetit) _card(
                  'Habitudes de sommeil', 
                  Icons.access_time, 
                  Column(children: [
                    _timeInput("Heure habituelle de coucher", _heureCoucher), // Vérifiez vos noms de variables ici
                    _timeInput("Heure habituelle de lever matinal", _heureLever),
                    _timeInput("Durée approximative des siestes", _dureeSieste),
                    _timeInput("Temps passé éveillé la nuit", _dureeEveilNuit),
                    _input("Nombre de réveils par nuit", controller: _nbReveilNuit),
                    _input("Que faites-vous lors des réveils ?", controller: _actionReveil, maxLines: 2),
                  ])
                ),

                const SizedBox(height: 10),

                // SECTION 2 : Questions 1 et 2 (Durée et Latence)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        _buildSpecialLikert(
                          "Combien d'heures l'enfant dort-il la plupart des nuits ?",
                          1,
                          ["Plus de 9h", "8h à 9h", "7h à 8h", "5h à 7h", "Moins de 5h"],
                        ),
                        _buildSpecialLikert(
                          "Combien de temps après sa mise au lit l'enfant met-il habituellement pour s'endormir ?",
                          2,
                          ["< 15 min", "15-30 min", "30-45 min", "45-60 min", "> 60 min"],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10), // Espace avant l'entête collant
              ],
            ),
          ),
        ),

        // --- PARTIE 2 : L'ENTÊTE QUI SE COLLE EN HAUT (STICKY) ---
        SliverAppBar(
          pinned: true, // Magie : il reste collé en haut !
          floating: false,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Prend la couleur du fond de l'app
          elevation: 2, // Ajoute une petite ombre quand ça défile en dessous
          toolbarHeight: 70, // Hauteur de votre entête (ajustez si besoin)
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Pour s'aligner avec les cartes
            child: _buildFrequencyHeader(),
          ),
        ),

        // --- PARTIE 3 : LES QUESTIONS QUI DÉFILENT ---
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              _genererQuestionsFrequence(estPetit, totalQuestions),
            ),
          ),
        ),

        // --- PARTIE 4 : LE FOOTER (ET LA PROTECTION QR CODE) ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 100.0), // Padding de 100 pour le QR code !
            child: Text(
              "Note : Assurez-vous d'avoir répondu à toutes les lignes pour permettre le calcul du score.",
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }


   Widget _buildTabHistoire() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Section Clinique : Histoire de la maladie
        _card(
          'Histoire de la maladie', 
          Icons.visibility, 
          _input(
            "Détaillez les faits qui font que vous consultez en neurologie pédiatrique en commençant par la date de début", 
            controller: _cliniqueCtrl, 
            maxLines: 5
          )
        ),
        
        // Section Traitement en cours
        _card('Traitement(s) en cours', Icons.medication, Column(children: [
          if (_traitementsEnCours.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Aucun traitement en cours — appuyez sur + pour en ajouter.',
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ),
          ...List.generate(_traitementsEnCours.length, (i) {
            final t = _traitementsEnCours[i];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 6),
              color: const Color(0xFFE3F2FD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: blueCHRU.withValues(alpha: 0.25)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFF00599A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: t['nom'],
                                  decoration: const InputDecoration(
                                    labelText: 'Médicament',
                                    isDense: true,
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  onChanged: (v) => setState(() => _traitementsEnCours[i]['nom'] = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: t['dose'],
                                  decoration: const InputDecoration(
                                    labelText: 'Dose',
                                    isDense: true,
                                    border: InputBorder.none,
                                    labelStyle: TextStyle(fontSize: 13),
                                  ),
                                  onChanged: (v) => setState(() => _traitementsEnCours[i]['dose'] = v),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            initialValue: t['repartition'],
                            decoration: const InputDecoration(
                              labelText: 'Répartition (ex : matin et soir, 3x/j...)',
                              isDense: true,
                              border: InputBorder.none,
                              labelStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (v) => setState(() => _traitementsEnCours[i]['repartition'] = v),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      tooltip: 'Supprimer ce traitement',
                      onPressed: () => setState(() => _traitementsEnCours.removeAt(i)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => setState(() => _traitementsEnCours.add({
              'nom': '',
              'dose': '',
              'repartition': '',
            })),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Ajouter un traitement'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF00599A)),
          ),
        ])),

        // Section Examens & Traitements
        _card('Prise en charge déjà réalisée', Icons.analytics, Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IMAGERIE AVEC PUCES ---
              Expanded(
                child: _toggle(
                  imagerieNonFaite ? "Imagerie non faite" : "Résultats Imagerie", 
                  imagerieNonFaite, 
                  (v) => setState(() {
                    imagerieNonFaite = v!;
                    if (!v && _imagerieCtrl.text.trim().isEmpty) _imagerieCtrl.text = "• ";
                  }), 
                  controller: _imagerieCtrl, 
                  isBulletList: true, // Activé ici
                  hint: "Date, type d'imagerie, résultats (par exemple: 2024: IRM cérébrale : séquelles de prématurité ou normale...)"),
              ),
              const SizedBox(width: 8),
              // --- EEG AVEC PUCES ---
              Expanded(
                child: _toggle(
                  eegNonFait ? "EEG non fait" : "Résultats EEG", 
                  eegNonFait, 
                  (v) => setState(() {
                    eegNonFait = v!;
                    if (!v && _eegCtrl.text.trim().isEmpty) _eegCtrl.text = "• ";
                  }), 
                  controller: _eegCtrl, 
                  isBulletList: true, // Activé ici
                  hint: "Date, type d'EEG, résultats (par exemple: 2024: EEG de sommeil : pointes centrales droites ou normale...)"
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // --- TRAITEMENTS ESSAYÉS AVEC PUCES ---
          _toggle(
            pasTraitementEssaye ? "Aucun traitement essayé" : "Traitements essayés", 
            pasTraitementEssaye, 
            (v) => setState(() {
              pasTraitementEssaye = v!; 
              if (!v && _traitEssayesCtrl.text.trim().isEmpty) _traitEssayesCtrl.text = "• "; 
            }), 
            controller: _traitEssayesCtrl, 
            isBulletList: true, // Déjà activé
            hint: "Détaillez les traitements essayés, leur efficacité et les éventuels effets secondaires"
          ),
        ])),

        // Section Vie Quotidienne
        _card('Scolarité & Suivi', Icons.home, Column(children: [
          _input('Scolarité (classe, présence d\'une aide, niveau dans la classe...)/ mode de garde (à domicile, crèche, école maternelle...))', controller: _scolariteCtrl, maxLines: 2),
          const Divider(),
          _toggle(
            pasSuivi ? "Pas de suivi particulier (orthophonie, CAMSP, CMP...)" : "Suivi(s) en cours orthophonie, CAMSP, CMP...", 
            pasSuivi, 
            (v) => setState(() => pasSuivi = v!), 
            controller: _suiviCtrl, 
            hint: "Précisez l'intervenant et la fréquence des interventions, par exemple: Orthophonie 2 fois par semaine, CAMSP 1 fois par mois..."
          ),
          _toggle(
            pasTroubleSommeil ? "Pas de trouble du sommeil" : "Trouble(s) du sommeil", 
            pasTroubleSommeil, 
            (v) {
              setState(() {
                pasTroubleSommeil = v!;
                _ongletSauvegarde = 2; // <-- ON MÉMORISE : "Je suis sur l'onglet Histoire (index 2)"
              });
            }, 
            controller: _sommeilCtrl, 
            hint: "Précisez (ex: endormissement tardif, réveils...)"
          ),
          _toggle(
            pasTroubleAlim ? "Pas de trouble de l'alimentation" : "Trouble(s) de l'alimentation", 
            pasTroubleAlim, 
            (v) => setState(() => pasTroubleAlim = v!), 
            controller: _alimCtrl, 
            hint: "Précisez (ex: sélectivité, reflux , ne prend pas de morceaux...)"
          ),
        ])),
      ]),
    );
  }
  Widget _buildTabSante() {
    return SingleChildScrollView(
      key: const PageStorageKey('tab_sante'),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // --- BLOC NAISSANCE ---
        _card('Naissance (carnet de santé recommandé)', Icons.pregnant_woman, Column(children: [
          _toggle(
            grossesseNormale ? 'Grossesse normale' : 'Anomalie(s) grossesse',
            grossesseNormale,
            (v) => setState(() => grossesseNormale = v!),
            controller: _grossesseController,
            hint: 'Précisez (ex: diabète gestationnel, menace d\'accouchement prématuré...)',
          ),
          const Divider(),
          CheckboxListTile(
            title: Text(accouchementNormal ? 'Accouchement normal (voie basse, sans aide)' : 'Anomalie(s) accouchement'),
            value: accouchementNormal,
            activeColor: blueCHRU,
            onChanged: (v) => setState(() {
              accouchementNormal = v!;
              if (v) _modeAccouchement = null;
            }),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
          ),
          if (!accouchementNormal) 
            Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _modeAccouchementRadio("Naissance par césarienne programmée pour"),
                  _modeAccouchementRadio("Naissance par césarienne en urgence pour"),
                  _modeAccouchementRadio("Naissance déclenchée par voie basse pour"),
                  _modeAccouchementRadio("Naissance spontanée par voie basse avec manœuvres instrumentales pour"),
                  if (_modeAccouchement != null) ...[
                    const SizedBox(height: 10),
                    _input(
                      "Précisez le motif", 
                      controller: _detailAccouchementController,
                    ),
                  ],
                ],
              ),
            ),
          const Divider(),
          _birthGrid(), // Appel de la grille (Terme, Poids, Taille, PC, Apgar)
        ])),

        // --- BLOC ANTÉCÉDENTS ---
        _card('Antécédents & Traitements', Icons.medical_services, Column(children: [
          _toggle(
            pasAtcdMed ? "Aucun antécédent médical" : "Antécédent(s) médicaux", 
            pasAtcdMed, 
            (v) => setState(() {
              pasAtcdMed = v!;
              if (!v && _atcdMedCtrl.text.isEmpty) _atcdMedCtrl.text = "• ";
            }), 
            controller: _atcdMedCtrl, 
            isBulletList: true
          ),
          _toggle(
            pasAtcdChir ? "Aucun antécédent chirurgical" : "Antécédent(s) chirurgicaux", 
            pasAtcdChir, 
            (v) => setState(() {
              pasAtcdChir = v!;
              if (!v && _atcdChirCtrl.text.isEmpty) _atcdChirCtrl.text = "• ";
            }), 
            controller: _atcdChirCtrl, 
            isBulletList: true
          ),
          _toggle(
            pasAllergie ? "Aucune allergie connue" : "Allergie(s) identifiée(s)", 
            pasAllergie, 
            (v) => setState(() => pasAllergie = v!), 
            controller: _allergiesController,
            hint: "Précisez l'allergie et la réaction"
          ),
          _toggle(
            vaccinsAJour ? "Vaccinations à jour" : "Vaccinations non à jour", 
            vaccinsAJour, 
            (v) => setState(() => vaccinsAJour = v!), 
            controller: _vaccinsController,
            hint: "Précisez les vaccins manquants",
          ),
        ])),

        // --- BLOC DÉVELOPPEMENT ---
        _card('Développement', Icons.trending_up, Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toggle(dvpNormal ? 'Développement psychomoteur normal' : 'Développement anormal / retardé', 
              dvpNormal, (v) => setState(() => dvpNormal = v!)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("Âge d'acquisition (laissez vide si non acquis) :", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildChampsDeveloppement(), // Liaison des étapes clés
            const Divider(),
            const Text('Latéralité', style: TextStyle(fontWeight: FontWeight.bold)),
            _lateralityRadio(),
          ],
        )),
      ]),
    );
  }

  // --- LOGIQUE PARENTS ---
Widget _parentBlock(
  String label, {
  required TextEditingController nomCtrl,
  required TextEditingController prenomCtrl,
  required TextEditingController metierCtrl,
  required TextEditingController origineCtrl,
  required TextEditingController atcdPersoCtrl,
  required TextEditingController atcdFamCtrl,
  required DateTime? date,
  required Function(DateTime) onDateChanged,
  required bool pasAtcdPerso,
  required Function(bool?) onAtcdPersoChanged,
  required bool pasAtcdFam,
  required Function(bool?) onAtcdFamChanged,
}) {
  return Column(
    children: [
      _input('Nom ($label)', controller: nomCtrl),
      _input('Prénom ($label)', controller: prenomCtrl),
      _dateTile('Date de naissance ($label)', date, onDateChanged),
      _input('Métier ($label)', controller: metierCtrl),
      _input('Origine géographique', controller: origineCtrl),
      const Divider(),
      _toggle(
        pasAtcdPerso ? 'Pas d\'antécédents personnels ($label)' : 'Présence d\'antécédents personnels ($label)',
        pasAtcdPerso,
        onAtcdPersoChanged,
        controller: atcdPersoCtrl,
        hint: 'Précisez les antécédents (ex: épilepsie, retard...)'
      ),
      _toggle(
        pasAtcdFam ? 'Pas d\'antécédents familiaux ($label)' : 'Présence d\'antécédents familiaux ($label)',
        pasAtcdFam,
        onAtcdFamChanged,
        controller: atcdFamCtrl,
        hint: 'Précisez les antécédents familiaux du côté du $label'
      ),
    ],
  );
}

  Widget _fratrieBlock() {
    return Column(children: [
      // --- RANG ET NOMBRE D'ENFANTS ---
      Row(children: [
        Expanded(
          child: _input('Rang de l\'enfant', controller: _rangController)
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8), 
          child: Text('sur')
        ),
        Expanded(
          child: _input('Nombre total d\'enfants du couple', controller: _nbEnfantsController)
        ),
      ]),

      // --- DEMI-FRÈRES / SŒURS ---
      CheckboxListTile(
        title: const Text('Présence de demi-frères ou sœurs'),
        value: hasDemiFreres,
        activeColor: blueCHRU,
        onChanged: (v) => setState(() => hasDemiFreres = v!),
        controlAffinity: ListTileControlAffinity.leading,
      ),

      if (hasDemiFreres) 
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Column(children: [
            _toggle(
              pasDemiMat ? 'Pas de demi-frère/sœur maternel' : 'Demi-frère(s) et/ou soeur(s) Maternel(s)', 
              pasDemiMat, 
              (v) => setState(() => pasDemiMat = v!), 
              controller: _demiFreresMatController, // Liaison au contrôleur
              hint: 'Précisez (ex: une petite demi-soeur de 2 ans...)'
            ),
            _toggle(
              pasDemiPat ? 'Pas de demi-frère/sœur paternel' : 'Demi-frère(s) et/ou soeur(s) Paternel(s)', 
              pasDemiPat, 
              (v) => setState(() => pasDemiPat = v!), 
              controller: _demiFreresPatController, // Liaison au contrôleur
              hint: 'Précisez (ex: un grand demi-frère...)'
            ),
          ]),
        ),

      // --- ANTÉCÉDENTS FRATRIE ---
      _toggle(
        pasAtcdFratrie ? 'Pas d\'ATCD dans la fratrie' : 'Antécédent(s) dans la fratrie', 
        pasAtcdFratrie, 
        (v) => setState(() => pasAtcdFratrie = v!), 
        controller: _atcdFratrieController, // Liaison au contrôleur
        hint: 'Précisez (ex: grand frère a un autisme léger, épilepsie...)'
      ),
    ]);
  }

  // --- HELPERS UI ---
  Widget _card(String t, IconData i, Widget c) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: blueCHRU.withValues(alpha:0.1))),
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(i, color: blueCHRU), const SizedBox(width: 8), Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: blueCHRU))]),
      const SizedBox(height: 12),
      c,
    ])),
  );

  Widget _modeAccouchementRadio(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: title,
      groupValue: _modeAccouchement,
      activeColor: blueCHRU,
      onChanged: (v) => setState(() => _modeAccouchement = v),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _input(
    String label, {
    TextEditingController? controller,
    int maxLines = 1, // <-- Le "= 1" est CRUCIAL ici pour éviter l'erreur Null
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _dateTile(String l, DateTime? d, Function(DateTime) onP) => ListTile(
    title: Text(d == null ? l : '$l : ${DateFormat('dd/MM/yyyy', 'fr_FR').format(d)}'), // Formatage FR
    trailing: Icon(Icons.calendar_month, color: blueCHRU),
    onTap: () async {
      DateTime? p = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        locale: const Locale('fr', 'FR'), // Calendrier en français
      );
      if (p != null) onP(p);
    },
  );

  Widget _toggle(
    String label,
    bool value,
    Function(bool?) onChanged, {
    TextEditingController? controller,
    String? hint,
    bool isBulletList = false, // <-- Ajout de ce paramètre
  }) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(label, style: const TextStyle(fontSize: 14)),
          value: value,
          onChanged: onChanged,
          activeThumbColor: blueCHRU,
        ),
        // On affiche le champ de texte si la condition est remplie (ex: "Présence d'ATCD")
        if (!value && controller != null) 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _input(
              hint ?? "Précisez...",
              controller: controller,
              maxLines: 3, // Correction de l'erreur int : on donne une valeur fixe
            ),
          ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // Grille de naissance avec DS AUDIPOG en temps réel
  // ──────────────────────────────────────────────────────────
  Widget _birthGrid() {
    // ── Lecture des valeurs ──────────────────────────────────
    final int termeSA    = int.tryParse(_termeSAController.text.trim()) ?? 0;
    final int termeJours = int.tryParse(_termeJoursController.text.trim()) ?? 0;
    final double poids   = double.tryParse(_poidsController.text.trim()) ?? 0;
    final double taille  = double.tryParse(_tailleController.text.trim()) ?? 0;
    final double pc      = double.tryParse(_pcController.text.trim()) ?? 0;
    final bool garcon    = sexe == 'Masculin';
    final bool termeOk   = termeSA >= 24 && termeSA <= 43;

    // ── Calculs DS ───────────────────────────────────────────
    final ResultatAuxo? rPoids  = (termeOk && poids  > 0)
        ? AuxologieNaissance.calculerDsPoids(
            poidsG: poids, termeSA: termeSA, termeJours: termeJours, garcon: garcon)
        : null;
    final ResultatAuxo? rTaille = (termeOk && taille > 0)
        ? AuxologieNaissance.calculerDsTaille(
            tailleCm: taille, termeSA: termeSA, termeJours: termeJours, garcon: garcon)
        : null;
    final ResultatAuxo? rPC     = (termeOk && pc     > 0)
        ? AuxologieNaissance.calculerDsPC(
            pcCm: pc, termeSA: termeSA, termeJours: termeJours, garcon: garcon)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Terme ─────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: _input('Terme (SA)',
                  controller: _termeSAController,
                  keyboardType: TextInputType.number),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _input('+ jours (0-6)',
                  controller: _termeJoursController,
                  keyboardType: TextInputType.number),
            ),
          ],
        ),

        // ── Poids ─────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _input('Poids de naissance (g)',
                  controller: _poidsController,
                  keyboardType: TextInputType.number),
            ),
            if (rPoids != null) ...[
              const SizedBox(width: 8),
              _dsBadge(rPoids),
            ],
          ],
        ),

        // ── Taille ────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _input('Taille de naissance (cm)',
                  controller: _tailleController,
                  keyboardType: TextInputType.number),
            ),
            if (rTaille != null) ...[
              const SizedBox(width: 8),
              _dsBadge(rTaille),
            ],
          ],
        ),

        // ── PC ────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _input('PC de naissance (cm)',
                  controller: _pcController,
                  keyboardType: TextInputType.number),
            ),
            if (rPC != null) ...[
              const SizedBox(width: 8),
              _dsBadge(rPC),
            ],
          ],
        ),

        // ── Apgar ─────────────────────────────────────────────
        Row(children: [
          Expanded(child: _input('Apgar 1 min',
              controller: _apgar1Controller,
              keyboardType: TextInputType.number)),
          const SizedBox(width: 10),
          Expanded(child: _input('Apgar 5 min',
              controller: _apgar5Controller,
              keyboardType: TextInputType.number)),
        ]),

        // ── Légende DS ────────────────────────────────────────
        if (termeOk && (poids > 0 || taille > 0 || pc > 0))
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Wrap(
              spacing: 12,
              children: [
                _legendeChip(const Color(0xFF43A047), '< 1 DS  (normal)'),
                _legendeChip(const Color(0xFFFF9800), '1-2 DS  (surveillance)'),
                _legendeChip(const Color(0xFFF44336), '2-3 DS  (anormal)'),
                _legendeChip(const Color(0xFF9C27B0), '> 3 DS  (très anormal)'),
              ],
            ),
          ),
      ],
    );
  }

  /// Badge coloré affichant DS + percentile
  Widget _dsBadge(ResultatAuxo r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: r.dsColor.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: r.dsColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              r.dsText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: r.dsColor,
              ),
            ),
            Text(
              '${r.percentileBand} perc.',
              style: TextStyle(fontSize: 10, color: r.dsColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Petite pastille de légende
  Widget _legendeChip(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
  Widget _genderRadio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        const Text('Sexe : ', style: TextStyle(fontWeight: FontWeight.bold)),
        // ignore: deprecated_member_use
        Expanded(child: RadioListTile(title: const Text('Masculin'), value: 'Masculin', groupValue: sexe, activeColor: blueCHRU, onChanged: (v) => setState(() => sexe = v.toString()))),
        // ignore: deprecated_member_use
        Expanded(child: RadioListTile(title: const Text('Féminin'), value: 'Féminin', groupValue: sexe, activeColor: blueCHRU, onChanged: (v) => setState(() => sexe = v.toString()))),
      ]),
    );
  }

  Widget _lateralityRadio() => Wrap(children: ['droitier', 'gaucher', 'ambidextre', 'inconnue'].map((v) => Row(mainAxisSize: MainAxisSize.min, children: [Radio(value: v, activeColor: blueCHRU, groupValue: lateralite, onChanged: (val) => setState(() => lateralite = val.toString())), Text(v)])).toList());

  Widget _buildChampsDeveloppement() {
    int ageMois = _calculerAgeMois();
    if (ddnEnfant == null) return const Text("Veuillez saisir la date de naissance de l'enfant.");

    return Column(children: [
      if (ageMois >= 8) _input("Tenue assise sans appui (en mois)", controller: _assisCtrl),
      if (ageMois >= 15) _input("Âge de la marche (en mois)", controller: _marcheCtrl),
      if (ageMois >= 18) _input("Premiers mots (en mois)", controller: _motsCtrl),
      if (ageMois >= 30) ...[
        _input("Propreté acquise à (en mois/ans)", controller: _propreteCtrl),
      ],
    ]);
  }

  Widget _buildFrequencyHeader() {
    List<String> headers = ["Jamais", "Rarement", "Parfois", "Souvent", "Toujours"];
    List<String> subHeaders = ["", "1-3 f/mois", "1-2 f/sem", "3-5 f/sem", "Tous les j."];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: blueCHRU.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Expanded(flex: 5, child: SizedBox()),
          ...List.generate(5, (i) => Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(headers[i], textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: blueCHRU)),
                Text(subHeaders[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLikertRow(String question, int index) {
    bool isEven = index % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : lightBlueBG.withValues(alpha:0.3),
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha:0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text("$index. $question", style: const TextStyle(fontSize: 13, color: Colors.black87))
          ),
          ...List.generate(5, (i) => Expanded(
            flex: 2,
            child: Center(
              child: Radio<int>(
                value: i + 1,
                groupValue: _sdscResponses[index],
                activeColor: blueCHRU,
                onChanged: (v) => setState(() => _sdscResponses[index] = v),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSpecialLikert(String question, int index, List<String> labels) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          children: [
            const Expanded(flex: 5, child: SizedBox()),
            ...labels.map((l) => Expanded(
              flex: 2,
              child: Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: blueCHRU.withValues(alpha:0.8))),
            )),
          ],
        ),
        _buildLikertRow(question, index),
      ],
    );
  }

  List<Widget> _genererQuestionsFrequence(bool estPetit, int total) {
    final List<String> labelsGrands = [
      "", "", // Q1 et Q2 gérées par _buildSpecialLikert
      "L'enfant va au lit avec réticence",
      "L'enfant a des difficultés à s'endormir",
      "L'enfant ressent de l'anxiété ou des peurs au moment de s'endormir",
      "Lorsque l'enfant s'endort, il semble vivre ses rêves",
      "L'enfant transpire excessivement à l'endormissement",
      "L'enfant se réveille plus de 2 fois par nuit",
      "L'enfant a des difficultés à s'endormir à nouveau après s'être réveillé dans la nuit",
      "Dans son sommeil, l'enfant a des mouvements brusques ou des secousses des jambes ou il change souvent de position durant la nuit ou encore il jette les couvertures au pied de son lit",
      "L'enfant a des difficultés à respirer durant la nuit",
      "L'enfant fait des pauses respiratoires ou cherche sa respiration pendant son sommeil",
      "L'enfant ronfle",
      "L'enfant transpire excessivement pendant la nuit",
      "Vous avez assisté à un épisode de somnambulisme de l'enfant (il se lève et déambule pendant son sommeil)",
      "Vous avez déjà entendu l'enfant parler dans son sommeil",
      "L'enfant grince des dents pendant son sommeil",
      "L'enfant se réveille en hurlant ou est confus au point qu'il est impossible de l'approcher, mais il n'a aucun souvenir de ces événements le matin suivant",
      "L'enfant fait des cauchemars dont il ne se rappelle pas le matin venu",
      "L'enfant est difficile à réveiller le matin",
      "L'enfant se réveille le matin en se sentant fatigué",
      "L'enfant se sent incapable de bouger quand il se réveille le matin",
      "L'enfant est somnolent durant la journée",
      "L'enfant s'endort brutalement, de façon inattendue, à l'école ou lors de ses activités",
      "Lorsque l'enfant rit, il a une perte de tonus musculaire qui peut entraîner un affaissement du corps ou une chute"
    ];

    final List<String> labelsPetits = [
      "", "", // Q1 et Q2
      "L'enfant va au lit avec réticence",
      "L'enfant a des difficultés à s'endormir",
      "L'enfant ressent de l'anxiété ou des peurs au moment de s'endormir",
      "Lorsque l'enfant s'endort, il semble vivre ses rêves",
      "L'enfant transpire excessivement à l'endormissement",
      "L'enfant se réveille plus de 2 fois par nuit",
      "L'enfant a des difficultés à s'endormir à nouveau après s'être réveillé dans la nuit",
      "Dans son sommeil, l'enfant a des mouvements brusques ou des secousses des jambes ou il change souvent de position durant la nuit ou encore il jette les couvertures au pied de son lit",
      "L'enfant a des difficultés à respirer durant la nuit",
      "L'enfant fait des pauses respiratoires ou cherche sa respiration pendant son sommeil",
      "L'enfant ronfle",
      "L'enfant transpire excessivement pendant la nuit",
      "Vous avez déjà entendu l'enfant parler dans son sommeil",
      "L'enfant se réveille en hurlant ou est confus au point qu'il est impossible de l'approcher, mais il n'a aucun souvenir de ces événements le matin suivant",
      "L'enfant fait des cauchemars dont il ne se rappelle pas le matin venu",
      "L'enfant est difficile à réveiller le matin",
      "L'enfant se réveille le matin en se sentant fatigué",
      "L'enfant se sent incapable de bouger quand il se réveille le matin",
      "L'enfant est somnolent durant la journée",
      "L'enfant s'endort brutalement, de façon inattendue, à l'école ou lors de ses activités"
    ];

    final List<String> currentLabels = estPetit ? labelsPetits : labelsGrands;

    return List.generate(total - 2, (i) {
      int idx = i + 3;
      return _buildLikertRow(currentLabels[idx - 1], idx);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Génération du courrier de suivi (Word_template_cs_suivi.docm)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _genererCourrierSuivi() async {
    try {
      final String nom    = _nomEnfantController.text.trim().toUpperCase();
      final String prenom = _prenomEnfantController.text.trim();
      final String ddnStr = ddnEnfant != null
          ? DateFormat('dd/MM/yyyy').format(ddnEnfant!)
          : '';
      final double ageAns    = _calculerAgeAnsConsult();
      final int ageAnsFull   = ageAns.floor();
      final int ageMoisReste = _ageM - ageAnsFull * 12;
      final String ageStr = ageAnsFull > 0
          ? '$ageAnsFull an${ageAnsFull > 1 ? "s" : ""} et $ageMoisReste mois'
          : '$_ageM mois';
      final DateTime dateRef = dateConsultation ?? DateTime.now();
      final String dateStr   = DateFormat('dd/MM/yyyy').format(dateRef);
      final String dateFich  = DateFormat('yyyy-MM-dd').format(dateRef);
      final String patientStr = sexe == 'Masculin'
          ? '$prenom $nom, petit garçon âgé de $ageStr'
          : '$prenom $nom, petite fille âgée de $ageStr';
      final String neStr = sexe == 'Masculin' ? 'né' : 'née';
      final String atcdFam = [
        if (_atcdPereController.text.trim().isNotEmpty)
          'Père : ${_atcdPereController.text.trim()}',
        if (_atcdMereController.text.trim().isNotEmpty)
          'Mère : ${_atcdMereController.text.trim()}',
        if (_atcdFratrieController.text.trim().isNotEmpty)
          'Fratrie : ${_atcdFratrieController.text.trim()}',
      ].join(' — ');
      final String autreStr = [
        if (_suiviCtrl.text.trim().isNotEmpty) _suiviCtrl.text.trim(),
        if (_catTexte.isNotEmpty) _catTexte,
      ].join('\n\n');

      final folderPath   = await getDirectoryPath(nom, prenom);
      final tempDir      = await getTemporaryDirectory();
      final templatePath = await _getTemplatePath(
          _isOHS ? 'Word_template_cs_COCEE_suivi.docm' : 'Word_template_cs_suivi.docm');
      final String outputPath = '$folderPath\\${dateFich}_Courrier de suivi_${nom}_${prenom}.docx';

      // Script PowerShell — remplissage par signets Word
      final sb = StringBuffer();
      sb.writeln('\$word = New-Object -ComObject Word.Application');
      sb.writeln('\$word.Visible = \$false');
      sb.writeln("\$doc = \$word.Documents.Open('$templatePath')");

      void bm(String name, String value) =>
          sb.write(_psSetBookmark(name, value));

      bm('Nom',          nom);
      bm('Prénom',       prenom);
      bm('Ddn',          ddnStr);
      bm('Age',          ageStr);
      bm('Patient',      patientStr);
      bm('Né',           neStr);
      bm('CS',           dateStr);
      bm('Motif',        _motifController.text.trim());
      bm('HDM',          _cliniqueCtrl.text.trim());
      bm('Clinique',     _buildExamenCliniqueText());
      bm('Clinique_old', '');
      bm('General',      _buildExamenCliniqueText());
      bm('ATCDfam',      atcdFam);
      bm('ATCD_perso',   _atcdMedCtrl.text.trim());
      bm('Allergie',     _allergiesController.text.trim());
      bm('Vaccin',       _vaccinsController.text.trim());
      bm('TTT',          _buildTraitementsText());
      bm('ttt_old',      '');
      bm('Grossesse',    _grossesseController.text.trim());
      bm('Naissance',    _buildNaissanceText());
      bm('Lateralite',   lateralite);
      bm('EEG',          _eegCtrl.text.trim());
      bm('Imagerie',     _imagerieCtrl.text.trim());
      bm('Autre',        autreStr);
      bm('dvt',
          'Assis : ${_assisCtrl.text} — '
          'Marche : ${_marcheCtrl.text} — '
          'Mots : ${_motsCtrl.text}');
      bm('Dev_mot_glob', _marcheCtrl.text.trim());
      bm('Dev_mot_fine', '');
      bm('Dev_langage',  _motsCtrl.text.trim());
      bm('Dev_Soc',      '');

      sb.writeln("\$doc.SaveAs2('$outputPath', 16)");
      sb.writeln('\$doc.Close()');
      sb.writeln('\$word.Quit()');

      final psFile = File('${tempDir.path}/gen_suivi.ps1');
      final List<int> bom = [0xEF, 0xBB, 0xBF];
      await psFile.writeAsBytes([...bom, ...utf8.encode(sb.toString())]);

      final result = await Process.run('powershell.exe', [
        '-ExecutionPolicy', 'Bypass',
        '-NoProfile',
        '-File', psFile.path,
      ]);
      if (result.exitCode != 0) throw Exception(result.stderr);

      await _sauvegarderDonneesCryptes(folderPath, nom, prenom);
      await Process.run('explorer', [outputPath]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Courrier de suivi généré'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur suivi : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Échec suivi : $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }


  // ══════════════════════════════════════════════════════════════
  //  HELPERS — construction des paragraphes médicaux pour le CR
  // ══════════════════════════════════════════════════════════════

  /// Calcule l'âge en texte à partir d'une date (ex: "75 ans")
  String _ageDepuisDDN(DateTime ddn, DateTime ref) {
    final ans   = ref.year - ddn.year - ((ref.month < ddn.month || (ref.month == ddn.month && ref.day < ddn.day)) ? 1 : 0);
    final moisR = ((ref.difference(ddn).inDays / 365.25 - ans.floor()) * 12).round();
    if (ans == 0) return '$moisR mois';
    if (moisR == 0) return '$ans an${ans > 1 ? "s" : ""}';
    return '$ans an${ans > 1 ? "s" : ""} et $moisR mois';
  }

  /// Paragraphe père (style VBA complet)
  String _buildPereParagraphe(DateTime ref, bool garcon) {
    final nomP    = _nomPereController.text.trim();
    final prenomP = _prenomPereController.text.trim();
    final metier  = _metierPereController.text.trim();
    final origine = _originePereController.text.trim();
    final atcdP   = _atcdPereController.text.trim();
    final atcdFam = _atcdFamPereController.text.trim();

    String intro = 'Le père';
    if (prenomP.isNotEmpty || nomP.isNotEmpty) {
      final id = [if (prenomP.isNotEmpty) prenomP, if (nomP.isNotEmpty) nomP].join(' ');
      intro += ', Monsieur $id';
    }
    if (ddnPere != null) intro += ', né le ${DateFormat('dd/MM/yyyy').format(ddnPere!)} (${_ageDepuisDDN(ddnPere!, ref)})';
    if (origine.isNotEmpty) intro += ", d'origine $origine";
    if (metier.isNotEmpty) intro += ', $metier';

    String atcdPhrase;
    if (pasAtcdPersoPere || atcdP.isEmpty) {
      atcdPhrase = ", n'a pas d'antécédent particulier.";
    } else {
      atcdPhrase = ', est suivi pour $atcdP.';
    }

    String famPhrase;
    if (pasAtcdFamPere || atcdFam.isEmpty) {
      final il = garcon ? 'Il' : 'Elle';
      famPhrase = " $il n'a pas dans sa famille d'antécédent d'épilepsie, de maladie rare, de pathologie neurologique, psychiatrique ou de notion de retard de développement psychomoteur.";
    } else {
      famPhrase = ' Antécédents familiaux paternels : $atcdFam.';
    }
    return intro + atcdPhrase + famPhrase;
  }

  /// Paragraphe mère (style VBA complet)
  String _buildMereParagraphe(DateTime ref, bool garcon) {
    final nomM    = _nomMereController.text.trim();
    final prenomM = _prenomMereController.text.trim();
    final metier  = _metierMereController.text.trim();
    final origine = _origineMereController.text.trim();
    final atcdP   = _atcdMereController.text.trim();
    final atcdFam = _atcdFamMereController.text.trim();

    String intro = 'La mère';
    if (prenomM.isNotEmpty || nomM.isNotEmpty) {
      final id = [if (prenomM.isNotEmpty) prenomM, if (nomM.isNotEmpty) nomM].join(' ');
      intro += ', Madame $id';
    }
    if (ddnMere != null) intro += ', née le ${DateFormat('dd/MM/yyyy').format(ddnMere!)} (${_ageDepuisDDN(ddnMere!, ref)})';
    if (origine.isNotEmpty) intro += ", d'origine $origine";
    if (metier.isNotEmpty) intro += ', $metier';

    String atcdPhrase;
    if (pasAtcdPersoMere || atcdP.isEmpty) {
      atcdPhrase = ", n'a pas d'antécédent particulier.";
    } else {
      atcdPhrase = ', est suivie pour $atcdP.';
    }

    String famPhrase;
    if (pasAtcdFamMere || atcdFam.isEmpty) {
      famPhrase = " Elle n'a pas dans sa famille d'antécédent d'épilepsie, de maladie rare, de pathologie neurologique, psychiatrique ou de notion de retard de développement psychomoteur.";
    } else {
      famPhrase = ' Antécédents familiaux maternels : $atcdFam.';
    }
    return intro + atcdPhrase + famPhrase;
  }

  /// Phrase fratrie
  String _buildFratrieParagraphe(String prenom, bool garcon) {
    final rang   = int.tryParse(_rangController.text.trim()) ?? 0;
    final total  = int.tryParse(_nbEnfantsController.text.trim()) ?? 0;
    final atcdFr = _atcdFratrieController.text.trim();

    String rangStr = '';
    if (rang > 0 && total > 0) {
      const ordinals = ['', '1er', '2ème', '3ème', '4ème', '5ème', '6ème', '7ème', '8ème'];
      final o = rang < ordinals.length ? ordinals[rang] : '${rang}ème';
      rangStr = 'le $o enfant d\'une fratrie de $total.';
    } else if (total == 0) {
      rangStr = 'enfant unique.';
    } else {
      rangStr = 'un des $total enfants du couple.';
    }

    String atcdStr;
    if (pasAtcdFratrie || atcdFr.isEmpty) {
      atcdStr = " Il n'y a pas d'antécédent particulier dans cette fratrie.";
    } else {
      atcdStr = ' Antécédents dans la fratrie : $atcdFr.';
    }
    return rangStr + atcdStr;
  }

  /// Phrase naissance complète en langage médical (style VBA)
  String _buildNaissancePhraseComplete(bool garcon) {
    final sa    = int.tryParse(_termeSAController.text.trim()) ?? 0;
    final jours = int.tryParse(_termeJoursController.text.trim()) ?? 0;
    final pdg   = double.tryParse(_poidsController.text.trim()) ?? 0;
    final tll   = double.tryParse(_tailleController.text.trim()) ?? 0;
    final pcv   = double.tryParse(_pcController.text.trim()) ?? 0;

    final parts = <String>[];

    if (sa > 0) {
      String termeStr = 'Il est né à $sa semaine${sa > 1 ? "s" : ""} d\'aménorrhée';
      if (jours > 0) termeStr += ' et $jours jour${jours > 1 ? "s" : ""}';
      parts.add('$termeStr.');
    }

    // Mensurations avec DS/percentiles
    String _dsPerc(double val, ResultatAuxo? r, String unite) {
      if (val <= 0) return '';
      String t = '${val % 1 == 0 ? val.toInt() : val} $unite';
      if (r != null && r.percentileBand.isNotEmpty) {
        t += ' (${r.percentileBand} percentile)';
      }
      return t;
    }

    final bool termeOk = sa >= 24 && sa <= 43;
    final rP = termeOk && pdg > 0 ? AuxologieNaissance.calculerDsPoids(poidsG: pdg, termeSA: sa, termeJours: jours, garcon: garcon) : null;
    final rT = termeOk && tll > 0 ? AuxologieNaissance.calculerDsTaille(tailleCm: tll, termeSA: sa, termeJours: jours, garcon: garcon) : null;
    final rC = termeOk && pcv > 0 ? AuxologieNaissance.calculerDsPC(pcCm: pcv, termeSA: sa, termeJours: jours, garcon: garcon) : null;

    final pStr = _dsPerc(pdg, rP, 'g');
    final tStr = _dsPerc(tll, rT, 'cm');
    final cStr = _dsPerc(pcv, rC, 'cm');

    if (pStr.isNotEmpty || tStr.isNotEmpty || cStr.isNotEmpty) {
      final mesures = <String>[];
      if (pStr.isNotEmpty) mesures.add('son poids de naissance était de $pStr');
      if (tStr.isNotEmpty) mesures.add('sa taille de $tStr');
      if (cStr.isNotEmpty) mesures.add('son périmètre crânien de $cStr');
      parts.add('${mesures.join(', ')}.'.replaceFirst(mesures[0][0], mesures[0][0].toUpperCase()));
    }

    return parts.join(' ');
  }

  /// Phrase développement psychomoteur à la naissance (Dvt bookmark, antécédents)
  String _buildDvtNaissance(bool garcon) {
    final parts = <String>[];
    if (_assisCtrl.text.trim().isNotEmpty)    parts.add('tenue assise à ${_assisCtrl.text.trim()} mois');
    if (_marcheCtrl.text.trim().isNotEmpty)   parts.add('marche à ${_marcheCtrl.text.trim()} mois');
    if (_motsCtrl.text.trim().isNotEmpty)     parts.add('premiers mots à ${_motsCtrl.text.trim()} mois');
    if (_propreteCtrl.text.trim().isNotEmpty) parts.add('propreté à ${_propreteCtrl.text.trim()}');

    if (dvpNormal) {
      final base = 'Son développement psychomoteur a été sans anomalie.';
      if (parts.isEmpty) return base;
      return '$base\n${parts.join(', ')}.';
    }
    if (parts.isEmpty) return 'Développement psychomoteur à préciser.';
    return 'Développement psychomoteur retardé : ${parts.join(', ')}.';
  }

  /// HDM clinique uniquement (sans scolarité/suivi/sommeil/alimentation)
  String _buildHDMComplet() {
    return _cliniqueCtrl.text.trim();
  }

  /// Scolarité + suivi + sommeil + alimentation — section post-développement
  /// Affiché après "Développement psychomoteur actuel" dans le CR
  String _buildSuiviPost() {
    final parts = <String>[];

    // Scolarité / mode de garde
    final scol = _scolariteCtrl.text.trim();
    if (scol.isNotEmpty && scol != "Actuellement, l'enfant est en classe de . Il est gardé par ") {
      parts.add(scol);
    }

    // Suivi + sommeil + alimentation sur une même phrase
    final suiviParts = <String>[];
    if (pasSuivi) {
      suiviParts.add('pas de suivi particulier');
    } else if (_suiviCtrl.text.trim().isNotEmpty) {
      suiviParts.add(_suiviCtrl.text.trim());
    }
    if (pasTroubleSommeil) suiviParts.add('pas de trouble du sommeil');
    else if (_sommeilCtrl.text.trim().isNotEmpty) suiviParts.add(_sommeilCtrl.text.trim());
    if (pasTroubleAlim) suiviParts.add('ni de trouble de l\'alimentation');

    if (suiviParts.isNotEmpty) {
      parts.add(suiviParts.join(', ') + '.');
    }

    return parts.join('\n');
  }

  /// Section développement psychomoteur ACTUEL pour le corps du CR
  /// Retourne une map {glob, fine, langage, soc} ou null si rien à mettre.
  /// null = section entièrement absente du CR (aucune case cochée, aucun texte).
  Map<String, String>? _buildDvtActuelMap() {
    final assis  = _assisCtrl.text.trim();
    final marche = _marcheCtrl.text.trim();
    final mots   = _motsCtrl.text.trim();
    final prop   = _propreteCtrl.text.trim();

    // Aucune case cochée dans le questionnaire ET aucun texte → section absente
    final hasMilestones = _devChecklist.values.any((v) => v);
    final hasText = assis.isNotEmpty || marche.isNotEmpty
                 || mots.isNotEmpty  || prop.isNotEmpty;
    if (!hasMilestones && !hasText) return null;

    // Construit la liste des items cochés pour un domaine donné
    List<String> _itemsCoches(String domain) {
      final items = <String>[];
      for (final ageEntry in _milestonesData.entries) {
        final domainItems = ageEntry.value[domain];
        if (domainItems == null) continue;
        for (final item in domainItems) {
          if (_devChecklist['${ageEntry.key}-$item'] == true) {
            items.add(item);
          }
        }
      }
      return items;
    }

    // ── Motricité globale ───────────────────────────────────────────────────
    final itemsGlob = _itemsCoches('Motricité Globale');
    final partsGlob = <String>[];
    if (assis.isNotEmpty)   partsGlob.add('tenue assise à $assis mois');
    if (marche.isNotEmpty)  partsGlob.add('marche acquise à $marche mois');
    if (prop.isNotEmpty)    partsGlob.add('propreté à $prop');
    String glob;
    if (itemsGlob.isNotEmpty && partsGlob.isNotEmpty) {
      glob = '${partsGlob.join(", ")}. ${itemsGlob.join(". ")}.';
    } else if (itemsGlob.isNotEmpty) {
      glob = '${itemsGlob.join(". ")}.';
    } else if (partsGlob.isNotEmpty) {
      glob = '${partsGlob.join(", ")}.';
    } else {
      glob = dvpNormal ? '' : 'À préciser.';
    }

    // ── Motricité fine ──────────────────────────────────────────────────────
    final itemsFine = _itemsCoches('Motricité Fine');
    final fine = itemsFine.isNotEmpty
        ? '${itemsFine.join(". ")}.'
        : (dvpNormal ? '' : 'À préciser.');

    // ── Langage ─────────────────────────────────────────────────────────────
    final itemsLang = _itemsCoches('Langage oral');
    final partsLang = <String>[];
    if (mots.isNotEmpty) partsLang.add('premiers mots à $mots mois');
    String lang;
    if (itemsLang.isNotEmpty && partsLang.isNotEmpty) {
      lang = '${partsLang.join(", ")}. ${itemsLang.join(". ")}.';
    } else if (itemsLang.isNotEmpty) {
      lang = '${itemsLang.join(". ")}.';
    } else if (partsLang.isNotEmpty) {
      lang = '${partsLang.join(", ")}.';
    } else {
      lang = dvpNormal ? '' : 'À préciser.';
    }

    // ── Socialisation ────────────────────────────────────────────────────────
    final itemsSoc = _itemsCoches('Socialisation');
    final soc = itemsSoc.isNotEmpty
        ? '${itemsSoc.join(". ")}.'
        : (dvpNormal ? '' : 'À préciser.');

    return {
      'glob':    glob,
      'fine':    fine,
      'langage': lang,
      'soc':     soc,
    };
  }

  // ══════════════════════════════════════════════════════════════

  Future<void> genererCompteRenduPrincipal() async {
    try {
      // ── 0. Reconstruire le texte CAT (toujours à jour) ───────
      _catTexte = _buildCATTexte();

      // ── 1. Données de base ───────────────────────────────────
      final String nom    = _nomEnfantController.text.trim().toUpperCase();
      final String prenom = _prenomEnfantController.text.trim();
      final dateRef       = dateConsultation ?? DateTime.now();
      final String ddnStr = ddnEnfant != null
          ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : 'non précisée';
      final String dateStr   = DateFormat('dd/MM/yyyy').format(dateRef);
      final String dateFich  = DateFormat('yyyy-MM-dd').format(dateRef);

      // Âge
      final double ageAns = ddnEnfant != null
          ? dateRef.difference(ddnEnfant!).inDays / 365.25 : 0;
      final int ans    = ageAns.floor();
      final int moisRem = ((ageAns - ans) * 12).round();
      final String ageStr = ans == 0
          ? '$moisRem mois'
          : (moisRem == 0 ? '$ans an${ans > 1 ? "s" : ""}' : '$ans an${ans > 1 ? "s" : ""} et $moisRem mois');

      // Genre
      final bool garcon = sexe == 'Masculin';
      final String patientMot = garcon ? 'patient' : 'patiente';
      final String neStr      = garcon ? 'né' : 'née';
      final il                = garcon ? 'il' : 'elle';

      // ── 2. Construction des paragraphes médicaux ─────────────
      // Antécédents familiaux : paragraphes complets style VBA
      final String pereStr     = _buildPereParagraphe(dateRef, garcon);
      final String mereStr     = _buildMereParagraphe(dateRef, garcon);
      final String fratrieStr  = _buildFratrieParagraphe(prenom, garcon);

      // Naissance — phrase complète en langage médical
      final String naissanceStr = _buildNaissancePhraseComplete(garcon);

      // Grossesse
      final String grossesseStr = grossesseNormale
          ? 'La grossesse était physiologique (spontanée, de déroulement normal. Les échographies fœtales étaient sans particularité. Il n\'y avait pas d\'anomalie des sérologies maternelles, ni de prise de toxique ou de médicament pendant la grossesse).'
          : _grossesseController.text.trim();

      // Accouchement
      final String accStr = accouchementNormal
          ? 'Accouchement eutocique spontané.'
          : _detailAccouchementController.text.trim().isEmpty
              ? 'Accouchement eutocique.' : _detailAccouchementController.text.trim();

      // Dvt naissance
      final String dvtNaissStr = _buildDvtNaissance(garcon);

      // Antécédents personnels
      final String atcdMed  = _atcdMedCtrl.text.trim();
      final String atcdChir = _atcdChirCtrl.text.trim();
      String atcdPersoStr;
      if (pasAtcdMed && pasAtcdChir) {
        atcdPersoStr = '$il n\'a pas d\'antécédent personnel contributif.'.replaceFirst('il', il == 'il' ? 'Il' : 'Elle');
      } else {
        final p = <String>[];
        if (!pasAtcdMed  && atcdMed.isNotEmpty)  p.add(atcdMed);
        if (!pasAtcdChir && atcdChir.isNotEmpty) p.add('Chirurgical : $atcdChir.');
        atcdPersoStr = p.join('\n');
      }

      // Allergie
      final String allergieStr = pasAllergie
          ? (garcon ? 'Il n\'y a pas d\'allergie connue.' : 'Il n\'y a pas d\'allergie connue.')
          : (_allergiesController.text.trim().isEmpty ? '' : _allergiesController.text.trim());

      // Vaccins
      final String vaccinStr = vaccinsAJour
          ? 'Les vaccins sont à jour.'
          : (_vaccinsController.text.trim().isEmpty
              ? 'Les vaccins ne sont pas à jour.'
              : 'Les vaccins ne sont pas à jour : ${_vaccinsController.text.trim()}');

      // Traitement en cours
      final String tttStr = _buildTraitementsText().isEmpty ? 'Aucun' : _buildTraitementsText();

      // Traitement antérieur essayé
      final String tttAntStr = pasTraitementEssaye ? '' : _traitEssayesCtrl.text.trim();

      // HDM : clinique uniquement
      final String hdmStr = _buildHDMComplet();

      // Section post-développement : scolarité + suivi + sommeil + alimentation
      final String suiviPostStr = _buildSuiviPost();

      // Développement psychomoteur actuel (conditionnel)
      final Map<String, String>? dvtActuel = _buildDvtActuelMap();

      // Examen clinique — tout dans General, CS et Clinique vidés
      final String examGenStr     = _buildExamenCliniqueText();
      final String examCliniqueStr = '';

      // ── 3. Chemins ──────────────────────────────────────────
      final templatePath = await _getTemplatePath(
          _isOHS ? 'Word_template_cs_COCEE.docm' : 'Word_template_cs.docm');
      final folderPath   = await getDirectoryPath(nom, prenom);
      final String outputPath = '$folderPath\\${dateFich}_CR de consultation_${nom}_${prenom}.docx';
      final tempDir = await getTemporaryDirectory();

      // ── 4. Script PowerShell (signets) ──────────────────────
      final sb = StringBuffer();
      sb.writeln('\$word = New-Object -ComObject Word.Application');
      sb.writeln('\$word.Visible = \$false');
      sb.writeln("\$doc = \$word.Documents.Open('$templatePath')");

      void bm(String name, String value) => sb.write(_psSetBookmark(name, value));

      // Identité
      bm('Patient',       patientMot);
      bm('Prénom',        prenom);
      bm('Prénom2',       prenom);
      bm('Nom',           nom);
      bm('Né',            neStr);
      bm('Ddn',           ddnStr);
      bm('Age',           ageStr);
      bm('CS',            '');
      bm('Motif',         _motifController.text.trim());

      // Antécédents familiaux — paragraphes complets
      bm('Père',          pereStr);
      bm('Mère',          mereStr);
      bm('Nb_eft',        fratrieStr);
      bm('ATCD_fraterie', '');  // inclus dans fratrieStr

      // Antécédents personnels
      bm('Grossesse',     grossesseStr);
      bm('Accouchement',  accStr);
      bm('Naissance',     naissanceStr);
      bm('min1_Apgar',    _apgar1Controller.text.trim().isEmpty ? '?' : _apgar1Controller.text.trim());
      bm('min5_Apgar',    _apgar5Controller.text.trim().isEmpty ? '?' : _apgar5Controller.text.trim());
      bm('Dvt',           dvtNaissStr);
      bm('ATCD_perso',    atcdPersoStr);
      bm('Allergie',      allergieStr);
      bm('Vaccin',        vaccinStr);
      bm('Lateralité',    'Latéralité : $lateralite.');

      // Traitement en cours
      bm('TTT', tttStr);

      // Histoire de la maladie complète
      bm('HDM',      hdmStr);
      bm('EEG',      _eegCtrl.text.trim());
      bm('Imagerie', _imagerieCtrl.text.trim());
      bm('Autre',    '');
      bm('ttt_ant',  tttAntStr);

      // Examen clinique
      bm('General',  examGenStr);
      bm('Clinique', examCliniqueStr);

      // Développement psychomoteur actuel
      if (dvtActuel == null) {
        // Aucune case cochée → supprimer la section entière du document Word
        sb.writeln(r"$searchRng = $doc.Content.Duplicate");
        sb.writeln(r"$searchRng.Find.ClearFormatting()");
        sb.writeln(r"$searchRng.Find.MatchCase = $false");
        sb.writeln(r"$searchRng.Find.Forward = $true");
        sb.writeln(r"$searchRng.Find.Wrap = 0");
        sb.writeln(r"$searchRng.Find.Text = 'veloppement psychomoteur actuel'");
        sb.writeln(r"if ($searchRng.Find.Execute()) {");
        sb.writeln(r"    $pStart = $searchRng.Paragraphs.Item(1).Range.Start");
        sb.writeln(r"    $pEnd   = $doc.Bookmarks.Item('Dev_Soc').Range.End");
        sb.writeln(r"    $delRng = $doc.Range($pStart, $pEnd)");
        sb.writeln(r"    $delRng.MoveEnd(4, 2)");
        sb.writeln(r"    $delRng.Delete()");
        sb.writeln(r"}");
        bm('Dev_mot_glob', '');
        bm('Dev_mot_fine', '');
        bm('Dev_langage',  '');
        bm('Dev_Soc',      '');
      } else {
        bm('Dev_mot_glob', dvtActuel['glob']    ?? '');
        bm('Dev_mot_fine', dvtActuel['fine']    ?? '');
        bm('Dev_langage',  dvtActuel['langage'] ?? '');
        // Dev_Soc : socialisation + scolarité/suivi
        final String socStr = dvtActuel['soc'] ?? '';
        final String socAvecSuivi = [
          if (socStr.isNotEmpty) socStr,
          if (suiviPostStr.isNotEmpty) suiviPostStr,
        ].join('\n\n');
        bm('Dev_Soc', socAvecSuivi);
      }

      // CAT
      bm('CAT', _catTexte);

      sb.writeln("\$doc.SaveAs2('$outputPath', 16)");
      sb.writeln('\$doc.Close()');
      sb.writeln('\$word.Quit()');

      // ── 5. Exécution ────────────────────────────────────────
      await _runPsScript(tempDir, 'gen_cr.ps1', sb.toString());
      await _sauvegarderDonneesCryptes(folderPath, nom, prenom);
      await Process.run('explorer', [outputPath]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte-rendu généré'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur CR : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec CR : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  /// Extrait un template Word de assets/templates/ vers un dossier temp et
  /// retourne son chemin absolu (utilisable par PowerShell / Word.Application).
  /// Le fichier est réutilisé d'une session à l'autre tant que le temp existe.
  Future<String> _getTemplatePath(String filename) async {
    final tempDir = await getTemporaryDirectory();
    final dest = File('${tempDir.path}\\neuro_templates\\$filename');
    // Toujours réécrire depuis les assets pour utiliser la dernière version
    await dest.parent.create(recursive: true);
    final data = await rootBundle.load('assets/templates/$filename');
    await dest.writeAsBytes(data.buffer.asUint8List());
    return dest.path;
  }

  /// Dossier central unique pour tous les fichiers .crypt patients
  String get _centralPatientStoragePath =>
      "${Platform.environment['USERPROFILE']}\\Documents\\NeuroPed_Patients";

  Future<String> getDirectoryPath(String nom, String prenom) async {
    final desktopPath = "${Platform.environment['USERPROFILE']}\\Desktop";
    final maintenant = DateTime.now();
    final annee = DateFormat('yyyy').format(maintenant);
    final mois = DateFormat('MM').format(maintenant);
    
    final fullPath = "$desktopPath\\comptes-rendus_patients\\$annee\\$mois\\${nom}_$prenom";
    final directory = Directory(fullPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return fullPath;
  }
  Future<void> _sauvegarderDonneesCryptes(String folderPath, String nom, String prenom) async {
    try {
      // 1. Création du dictionnaire de données (COMPLET)
      Map<String, dynamic> patientData = {
        // --- Identité enfant ---
        'nomEnfant':    _nomEnfantController.text,
        'prenomEnfant': _prenomEnfantController.text,
        'ddn':          ddnEnfant?.toIso8601String(),
        'sexe':         sexe,
        'lateralite':   lateralite,
        'motif':        _motifController.text,
        // --- Père ---
        'nomPere':         _nomPereController.text,
        'prenomPere':      _prenomPereController.text,
        'metierPere':      _metierPereController.text,
        'originePere':     _originePereController.text,
        'atcdPere':        _atcdPereController.text,
        'atcdFamPere':     _atcdFamPereController.text,
        'ddnPere':         ddnPere?.toIso8601String(),
        'pasAtcdPersoPere': pasAtcdPersoPere,
        'pasAtcdFamPere':   pasAtcdFamPere,
        // --- Mère ---
        'nomMere':         _nomMereController.text,
        'prenomMere':      _prenomMereController.text,
        'metierMere':      _metierMereController.text,
        'origineMere':     _origineMereController.text,
        'atcdMere':        _atcdMereController.text,
        'atcdFamMere':     _atcdFamMereController.text,
        'ddnMere':         ddnMere?.toIso8601String(),
        'pasAtcdPersoMere': pasAtcdPersoMere,
        'pasAtcdFamMere':   pasAtcdFamMere,
        // --- Famille ---
        'pasConsanguinite':          pasConsanguinite,
        'precisionConsanguinite':    _precisionConsanguiniteCtrl.text,
        'hasDemiFreres':             hasDemiFreres,
        'pasDemiPat':                pasDemiPat,
        'pasDemiMat':                pasDemiMat,
        'demiFreresPat':             _demiFreresPatController.text,
        'demiFreresMat':             _demiFreresMatController.text,
        'rang':                      _rangController.text,
        'nbEft':                     _nbEnfantsController.text,
        'pasAtcdFratrie':            pasAtcdFratrie,
        'atcdFratrie':               _atcdFratrieController.text,
        // --- Naissance ---
        'grossesseNormale':          grossesseNormale,
        'grossesse':                 _grossesseController.text,
        'accouchementNormal':        accouchementNormal,
        'modeAccouchement':          _modeAccouchement,
        'accouchement':              _detailAccouchementController.text,
        'terme':                     _termeSAController.text,
        'termeJours':                _termeJoursController.text,
        'poids':                     _poidsController.text,
        'taille':                    _tailleController.text,
        'pc':                        _pcController.text,
        'apgar1':                    _apgar1Controller.text,
        'apgar5':                    _apgar5Controller.text,
        // --- Antécédents ---
        'pasAtcdMed':    pasAtcdMed,
        'pasAtcdChir':   pasAtcdChir,
        'pasAllergie':   pasAllergie,
        'vaccinsAJour':  vaccinsAJour,
        'traitements_bool': traitements,
        'atcdMed':       _atcdMedCtrl.text,
        'atcdChir':      _atcdChirCtrl.text,
        'allergies':     _allergiesController.text,
        'vaccins':       _vaccinsController.text,
        'traitements':   _traitements.text,
        // --- Traitements en cours structurés ---
        'traitementsEnCours': _traitementsEnCours,
        // --- Développement ---
        'dvpNormal': dvpNormal,
        'assis':     _assisCtrl.text,
        'marche':    _marcheCtrl.text,
        'mots':      _motsCtrl.text,
        'proprete':  _propreteCtrl.text,
        // --- Histoire ---
        'imagerieNonFaite':    imagerieNonFaite,
        'eegNonFait':          eegNonFait,
        'pasTraitementEssaye': pasTraitementEssaye,
        'pasSuivi':            pasSuivi,
        'pasTroubleSommeil':   pasTroubleSommeil,
        'pasTroubleAlim':      pasTroubleAlim,
        'clinique':            _cliniqueCtrl.text,
        'imagerie':            _imagerieCtrl.text,
        'eeg':                 _eegCtrl.text,
        'traitEssayes':        _traitEssayesCtrl.text,
        'scolarite':           _scolariteCtrl.text,
        'suivi':               _suiviCtrl.text,
        'sommeilTexte':        _sommeilCtrl.text,
        'alimTexte':           _alimCtrl.text,
        // --- Examen clinique consultation ---
        'dateConsultation': dateConsultation?.toIso8601String(),
        'poidsConsult':     _poidsConsultCtrl.text,
        'tailleConsult':    _tailleConsultCtrl.text,
        'pcConsult':        _pcConsultCtrl.text,
        'examNeuroTexte':   _examNeuroTexte,
        // --- CAT ---
        'catPAI_Absences':          _catPAI_Absences,
        'catPAI_CGTC':              _catPAI_CGTC,
        'catPAI_CCH':               _catPAI_CCH,
        'catPAI_Migraine':          _catPAI_Migraine,
        'catDEM_IRM_AG':            _catDEM_IRM_AG,
        'catDEM_IRM_Premed':        _catDEM_IRM_Premed,
        'catDEM_IRM_SansPremed':    _catDEM_IRM_SansPremed,
        'catDEM_EEG_Veille':        _catDEM_EEG_Veille,
        'catDEM_EEG_VeilleSommeil': _catDEM_EEG_VeilleSommeil,
        'catDEM_Genetique':         _catDEM_Genetique,
        'brochuresRemises':          _brochuresRemises,
        'bilanSelected':            _bilanSelected.toList(),
        'catDEM_TEP':               _catDEM_TEP,
        'catDEM_BilanHDJ':          _catDEM_BilanHDJ,
        'catConclusion':            _catConclusionCtrl.text,
        'catTexte':                 _catTexte,
        'catEstSuivi':              _catEstSuivi,
        'isOHS':                    _isOHS,
        'catIRM_Premed100':         _catIRM_Premed100,
        // --- Génétique anomalie familiale connue ---
        'genAnoFamiliale':   _genAnoFamiliale,
        'genGeneConnu':      _genGeneConnu.text,
        'genLaboratoire':    _genLaboratoire.text,
        'dateSauvegarde': DateTime.now().toIso8601String(),
      };

      // 2. Conversion en texte JSON
      String jsonString = jsonEncode(patientData);

      // 3. Chiffrement (Même clé/IV que vos QR codes)
      final key = enc.Key.fromUtf8('ChruNeuroPed2026_ClefSecrete_32c');
      final iv = enc.IV.fromUtf8('ChruNeuroPedIV16');
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

      final encrypted = encrypter.encrypt(jsonString, iv: iv);

      // 4. Écriture dans le dossier du CR (archivage)
      final file = File("$folderPath\\data_${nom}_${prenom}.crypt");
      await file.writeAsString(encrypted.base64);

      // 5. Copie dans le dossier central patients (pour chargement rapide)
      final centralDir = Directory(_centralPatientStoragePath);
      if (!await centralDir.exists()) await centralDir.create(recursive: true);
      final centralFile = File("${centralDir.path}\\${nom}_${prenom}.crypt");
      await centralFile.writeAsString(encrypted.base64);

      debugPrint("Données patient sauvegardées (CR + dossier central).");
    } catch (e) {
      debugPrint("Erreur lors de la sauvegarde cryptée : $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Charger un patient — dossier central avec recherche
  // ─────────────────────────────────────────────────────────────────────────

  /// Décrypte un fichier .crypt et retourne le Map de données, ou null si erreur.
  Map<String, dynamic>? _decrypterFichier(File file) {
    try {
      final content = file.readAsStringSync();
      final key = enc.Key.fromUtf8('ChruNeuroPed2026_ClefSecrete_32c');
      final iv  = enc.IV.fromUtf8('ChruNeuroPedIV16');
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt64(content, iv: iv);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Remplit tous les champs de l'application depuis un Map JSON décrypté.
  void _appliquerDonnees(Map<String, dynamic> data) {
    setState(() {
      // --- Identité enfant ---
      _nomEnfantController.text    = data['nomEnfant']    ?? "";
      _prenomEnfantController.text = data['prenomEnfant'] ?? "";
      if (data['ddn'] != null) ddnEnfant = DateTime.tryParse(data['ddn']);
      sexe       = data['sexe']       ?? "Masculin";
      lateralite = data['lateralite'] ?? "droitier";
      _motifController.text = data['motif'] ?? "";

      // --- Père ---
      _nomPereController.text      = data['nomPere']      ?? "";
      _prenomPereController.text   = data['prenomPere']   ?? "";
      _metierPereController.text   = data['metierPere']   ?? "";
      _originePereController.text  = data['originePere']  ?? "européenne";
      _atcdPereController.text     = data['atcdPere']     ?? "";
      _atcdFamPereController.text  = data['atcdFamPere']  ?? "";
      if (data['ddnPere'] != null) ddnPere = DateTime.tryParse(data['ddnPere']);
      pasAtcdPersoPere = data['pasAtcdPersoPere'] ?? true;
      pasAtcdFamPere   = data['pasAtcdFamPere']   ?? true;

      // --- Mère ---
      _nomMereController.text      = data['nomMere']      ?? "";
      _prenomMereController.text   = data['prenomMere']   ?? "";
      _metierMereController.text   = data['metierMere']   ?? "";
      _origineMereController.text  = data['origineMere']  ?? "européenne";
      _atcdMereController.text     = data['atcdMere']     ?? "";
      _atcdFamMereController.text  = data['atcdFamMere']  ?? "";
      if (data['ddnMere'] != null) ddnMere = DateTime.tryParse(data['ddnMere']);
      pasAtcdPersoMere = data['pasAtcdPersoMere'] ?? true;
      pasAtcdFamMere   = data['pasAtcdFamMere']   ?? true;

      // --- Famille ---
      pasConsanguinite             = data['pasConsanguinite'] ?? true;
      _precisionConsanguiniteCtrl.text = data['precisionConsanguinite'] ?? "";
      hasDemiFreres                = data['hasDemiFreres'] ?? false;
      pasDemiPat                   = data['pasDemiPat']    ?? true;
      pasDemiMat                   = data['pasDemiMat']    ?? true;
      _demiFreresPatController.text = data['demiFreresPat'] ?? "";
      _demiFreresMatController.text = data['demiFreresMat'] ?? "";
      _rangController.text         = data['rang']          ?? "";
      _nbEnfantsController.text    = data['nbEft']          ?? "";
      pasAtcdFratrie               = data['pasAtcdFratrie'] ?? true;
      _atcdFratrieController.text  = data['atcdFratrie']    ?? "";

      // --- Naissance ---
      grossesseNormale             = data['grossesseNormale']  ?? true;
      _grossesseController.text    = data['grossesse']         ?? "";
      accouchementNormal           = data['accouchementNormal'] ?? true;
      _modeAccouchement            = data['modeAccouchement'];
      _detailAccouchementController.text = data['accouchement'] ?? "";
      _termeSAController.text      = data['terme']             ?? "";
      _termeJoursController.text   = data['termeJours']        ?? "";
      _poidsController.text        = data['poids']             ?? "";
      _tailleController.text       = data['taille']            ?? "";
      _pcController.text           = data['pc']                ?? "";
      _apgar1Controller.text       = data['apgar1']            ?? "";
      _apgar5Controller.text       = data['apgar5']            ?? "";

      // --- Antécédents & traitements ---
      pasAtcdMed   = data['pasAtcdMed']   ?? true;
      pasAtcdChir  = data['pasAtcdChir']  ?? true;
      pasAllergie  = data['pasAllergie']  ?? true;
      vaccinsAJour = data['vaccinsAJour'] ?? true;
      traitements  = data['traitements_bool'] ?? true;
      _atcdMedCtrl.text      = data['atcdMed']      ?? "";
      _atcdChirCtrl.text     = data['atcdChir']     ?? "";
      _allergiesController.text = data['allergies'] ?? "";
      _vaccinsController.text   = data['vaccins']   ?? "";
      _traitements.text         = data['traitements'] ?? "";
      // Traitements en cours structurés
      if (data['traitementsEnCours'] != null) {
        _traitementsEnCours = List<Map<String, String>>.from(
          (data['traitementsEnCours'] as List).map((e) =>
            Map<String, String>.from(e as Map)
          )
        );
      } else {
        _traitementsEnCours = [];
      }

      // --- Développement ---
      dvpNormal = data['dvpNormal'] ?? true;
      _assisCtrl.text    = data['assis']    ?? "";
      _marcheCtrl.text   = data['marche']   ?? "";
      _motsCtrl.text     = data['mots']     ?? "";
      _propreteCtrl.text = data['proprete'] ?? "";

      // --- Histoire ---
      imagerieNonFaite    = data['imagerieNonFaite']    ?? true;
      eegNonFait          = data['eegNonFait']          ?? false;
      pasTraitementEssaye = data['pasTraitementEssaye'] ?? true;
      pasSuivi            = data['pasSuivi']            ?? true;
      pasTroubleSommeil   = data['pasTroubleSommeil']   ?? true;
      pasTroubleAlim      = data['pasTroubleAlim']      ?? true;
      _cliniqueCtrl.text       = data['clinique']      ?? "";
      _imagerieCtrl.text       = data['imagerie']      ?? "";
      _eegCtrl.text            = data['eeg']           ?? "";
      _traitEssayesCtrl.text   = data['traitEssayes']  ?? "";
      _scolariteCtrl.text      = data['scolarite']     ?? "";
      _suiviCtrl.text          = data['suivi']         ?? "";
      _sommeilCtrl.text        = data['sommeilTexte']  ?? "";
      _alimCtrl.text           = data['alimTexte']     ?? "";

      // --- Examen clinique consultation ---
      if (data['dateConsultation'] != null) {
        dateConsultation = DateTime.tryParse(data['dateConsultation']);
      }
      _poidsConsultCtrl.text  = data['poidsConsult']   ?? "";
      _tailleConsultCtrl.text = data['tailleConsult']  ?? "";
      _pcConsultCtrl.text     = data['pcConsult']      ?? "";
      _examNeuroTexte         = data['examNeuroTexte'] ?? "";

      // --- CAT ---
      _catPAI_Absences          = data['catPAI_Absences']          ?? false;
      _catPAI_CGTC              = data['catPAI_CGTC']              ?? false;
      _catPAI_CCH               = data['catPAI_CCH']               ?? false;
      _catPAI_Migraine          = data['catPAI_Migraine']          ?? false;
      _catDEM_IRM_AG            = data['catDEM_IRM_AG']            ?? false;
      _catDEM_IRM_Premed        = data['catDEM_IRM_Premed']        ?? false;
      _catDEM_IRM_SansPremed    = data['catDEM_IRM_SansPremed']    ?? false;
      _catDEM_EEG_Veille        = data['catDEM_EEG_Veille']        ?? false;
      _catDEM_EEG_VeilleSommeil = data['catDEM_EEG_VeilleSommeil'] ?? false;
      _catDEM_Genetique         = data['catDEM_Genetique']         ?? false;
      _brochuresRemises = List<String>.from(
          (data['brochuresRemises'] as List?)?.map((e) => e.toString()) ?? []);
      _bilanSelected = Set<String>.from(
          (data['bilanSelected'] as List?)?.map((e) => e.toString()) ?? []);
      _catDEM_TEP               = data['catDEM_TEP']               ?? false;
      _catDEM_BilanHDJ          = data['catDEM_BilanHDJ']          ?? false;
      _catConclusionCtrl.text   = data['catConclusion']            ?? "";
      _catTexte                 = data['catTexte']                 ?? "";
      _catEstSuivi              = data['catEstSuivi']              ?? false;
      _isOHS                    = data['isOHS']                    ?? false;
      _catIRM_Premed100         = data['catIRM_Premed100']         ?? false;
      // --- Génétique anomalie familiale connue ---
      _genAnoFamiliale        = data['genAnoFamiliale']   ?? false;
      _genGeneConnu.text      = data['genGeneConnu']      ?? "";
      _genLaboratoire.text    = data['genLaboratoire']    ?? 'CHRU Nancy';
    });
  }

  Future<void> _chargerDonneesPatient() async {
    try {
      // 1. Scanner le dossier central automatiquement
      final centralDir = Directory(_centralPatientStoragePath);
      if (!await centralDir.exists()) {
        await centralDir.create(recursive: true);
      }

      final cryptFiles = centralDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.crypt'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Si aucun patient, proposer de parcourir manuellement
      if (cryptFiles.isEmpty) {
        if (!mounted) return;
        final bool? browse = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Aucun patient'),
            content: Text(
              'Le dossier central $_centralPatientStoragePath ne contient aucun patient.\n\n'
              'Voulez-vous parcourir manuellement un dossier ?',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Annuler')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Parcourir')),
            ],
          ),
        );
        if (browse != true || !mounted) return;
        final String? dir = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Choisissez un dossier contenant des fichiers .crypt');
        if (dir == null || !mounted) return;
        return _chargerDepuisDossier(dir);
      }

      // 2. Décrypter chaque fichier pour extraire nom/prénom/date
      final List<Map<String, dynamic>> patients = [];
      for (final file in cryptFiles) {
        final data = _decrypterFichier(file);
        if (data != null) {
          patients.add({
            'file': file,
            'data': data,
            'nom':    data['nomEnfant']    ?? '',
            'prenom': data['prenomEnfant'] ?? '',
            'date': data['dateSauvegarde'] != null
                ? DateFormat('dd/MM/yyyy HH:mm')
                    .format(DateTime.parse(data['dateSauvegarde']))
                : '—',
          });
        }
      }

      if (patients.isEmpty || !mounted) return;

      // 3. Dialogue avec champ de recherche
      final Map<String, dynamic>? selectedData = await showDialog(
        context: context,
        builder: (ctx) => _PatientPickerDialog(patients: patients),
      );

      if (selectedData != null && mounted) {
        _appliquerDonnees(selectedData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Dossier de ${selectedData['prenomEnfant']} ${selectedData['nomEnfant']} chargé !"),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur chargement patient : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Chargement depuis un dossier quelconque (fallback manuel)
  Future<void> _chargerDepuisDossier(String dirPath) async {
    final files = Directory(dirPath)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.crypt'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    final List<Map<String, dynamic>> patients = [];
    for (final file in files) {
      final data = _decrypterFichier(file);
      if (data != null) {
        patients.add({
          'file': file,
          'data': data,
          'nom':    data['nomEnfant']    ?? '',
          'prenom': data['prenomEnfant'] ?? '',
          'date': data['dateSauvegarde'] != null
              ? DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(data['dateSauvegarde']))
              : '—',
        });
      }
    }
    if (patients.isEmpty || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Aucun fichier patient trouvé dans ce dossier.'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    final Map<String, dynamic>? selectedData = await showDialog(
      context: context,
      builder: (ctx) => _PatientPickerDialog(patients: patients),
    );
    if (selectedData != null && mounted) {
      _appliquerDonnees(selectedData);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ONGLET CAT — Conduite À Tenir
  // ═══════════════════════════════════════════════════════════════════════════

  /// Génère le texte CAT pour le compte-rendu.
  String _buildCATTexte() {
    final sb = StringBuffer();

    // ── PAI ──────────────────────────────────────────────────────────────────
    final paiTypes = <String>[];
    if (_catPAI_Absences) paiTypes.add('absences épileptiques');
    if (_catPAI_CGTC)    paiTypes.add('crises généralisées tonico-cloniques');
    if (_catPAI_CCH)     paiTypes.add('crises fébriles complexes');
    if (_catPAI_Migraine) paiTypes.add('crises de migraines');

    if (paiTypes.isNotEmpty) {
      if (paiTypes.length == 1) {
        sb.writeln('Un PAI est mis en place pour les ${paiTypes.first}.');
      } else {
        final last = paiTypes.removeLast();
        sb.writeln('Un PAI est mis en place pour les ${paiTypes.join(', ')} et les $last.');
      }
    }

    // ── Demandes ─────────────────────────────────────────────────────────────
    final demandes = <String>[];
    if (_catDEM_IRM_AG)            demandes.add('une IRM cérébrale sous anesthésie générale');
    if (_catDEM_IRM_Premed)        demandes.add('une IRM cérébrale sous prémédication');
    if (_catDEM_IRM_SansPremed)    demandes.add('une IRM cérébrale sans prémédication');
    if (_catDEM_EEG_Veille)        demandes.add('un EEG de veille');
    if (_catDEM_EEG_VeilleSommeil) demandes.add('un EEG de veille et de sommeil');
    if (_catDEM_Genetique)         demandes.add('un bilan d\'analyses génétiques');
    if (_catDEM_TEP)               demandes.add('un TEP-scan');
    if (_catDEM_BilanHDJ)          demandes.add('un bilan en hôpital de jour');

    if (demandes.isNotEmpty) {
      if (demandes.length == 1) {
        sb.writeln('J\'ai fait une demande pour ${demandes.first}.');
      } else {
        final last = demandes.removeLast();
        sb.writeln('J\'ai fait des demandes pour ${demandes.join(', ')} et $last.');
      }
    }

    // ── Bilan paraclinique ───────────────────────────────────────────────────
    if (_bilanSelected.isNotEmpty) {
      // Séparer consultations vs examens
      const _consultList = [
        'Neuropédiatrie', 'Génétique', 'Métabolique', 'Ophtalmologie',
        'ORL', 'Neuropsychologique', 'Kinésithérapeutique',
        'Ergothérapeutique', 'Orthophonique', 'Cardiopédiatrique',
        'Pédopsychiatrique', 'Diététique',
      ];
      final consults = _bilanSelected
          .where((e) => _consultList.contains(e))
          .toList();
      final examens = _bilanSelected
          .where((e) => !_consultList.contains(e))
          .toList();

      if (consults.isNotEmpty) {
        if (sb.isNotEmpty) sb.writeln();
        sb.write('Je propose les consultations spécialisées suivantes : '
            '${consults.join(', ')}.');
      }
      if (examens.isNotEmpty) {
        if (sb.isNotEmpty) sb.writeln();
        sb.write('Les examens complémentaires proposés sont les suivants : '
            '${examens.join(', ')}.');
      }
    }

    // ── Conclusion libre ──────────────────────────────────────────────────────
    final concl = _catConclusionCtrl.text.trim();
    if (concl.isNotEmpty) {
      if (sb.isNotEmpty) sb.writeln();
      sb.write(concl);
    }

    // ── Informations remises au patient (brochures) ───────────────────────
    if (_brochuresRemises.isNotEmpty) {
      if (sb.isNotEmpty) sb.writeln();
      sb.write(
          "J'ai profité de cette consultation pour fournir une information orale et écrite sur "
          "« ${_brochuresRemises.join(', ')} ».");
    }

    return sb.toString().trim();
  }

  Widget _buildTabCAT() {
    const Color blue = Color(0xFF00599A);

    Widget _sectionCard(String title, IconData icon, List<Widget> children) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: blue.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: blue, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blue,
                        fontSize: 14)),
              ]),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      );
    }

    Widget _check(String label, bool value, ValueChanged<bool?> onChanged) {
      return InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: blue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13.5)),
            ),
          ]),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Type de consultation ───────────────────────────────────────────
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: _catEstSuivi
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFE3F2FD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: _catEstSuivi
                      ? const Color(0xFF81C784)
                      : blue.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Icon(
                  _catEstSuivi
                      ? Icons.repeat_outlined
                      : Icons.fiber_new_outlined,
                  color: _catEstSuivi
                      ? const Color(0xFF388E3C)
                      : blue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _catEstSuivi
                            ? 'Consultation de suivi'
                            : 'Première consultation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _catEstSuivi
                              ? const Color(0xFF2E7D32)
                              : blue,
                        ),
                      ),
                      Text(
                        _catEstSuivi
                            ? 'Le courrier utilisera le template de suivi'
                            : 'Le courrier utilisera le template 1ère consultation',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _catEstSuivi,
                  onChanged: (v) => setState(() => _catEstSuivi = v),
                  activeColor: const Color(0xFF388E3C),
                ),
              ]),
            ),
          ),

          // ── Lieu de consultation ───────────────────────────────────────────
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: _isOHS
                ? const Color(0xFFFFF3E0)   // orange clair OHS
                : const Color(0xFFE3F2FD),  // bleu CHRU
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: _isOHS
                      ? const Color(0xFFFFB300)
                      : blue.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Icon(
                  Icons.location_on_outlined,
                  color: _isOHS ? const Color(0xFFE65100) : blue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOHS ? 'OHS Flavigny' : 'CHRU de Nancy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _isOHS ? const Color(0xFFE65100) : blue,
                        ),
                      ),
                      Text(
                        _isOHS
                            ? 'Template COCEE utilisé pour le courrier'
                            : 'Template CHRU utilisé pour le courrier',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: _isOHS
                                ? const Color(0xFFBF360C)
                                : Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOHS,
                  onChanged: (v) => setState(() => _isOHS = v),
                  activeColor: const Color(0xFFE65100),
                ),
              ]),
            ),
          ),

          // ── Section PAI ────────────────────────────────────────────────────
          _sectionCard('PAI — Projet d\'Accueil Individualisé', Icons.school, [
            _check('Absences épileptiques', _catPAI_Absences,
                (v) => setState(() => _catPAI_Absences = v ?? false)),
            _check('Crises généralisées tonico-cloniques (CGTC)', _catPAI_CGTC,
                (v) => setState(() => _catPAI_CGTC = v ?? false)),
            _check('Crises fébriles (CCH)', _catPAI_CCH,
                (v) => setState(() => _catPAI_CCH = v ?? false)),
            _check('Crises de migraines', _catPAI_Migraine,
                (v) => setState(() => _catPAI_Migraine = v ?? false)),
          ]),

          // ── Section Demandes ───────────────────────────────────────────────
          _sectionCard('Demandes complémentaires', Icons.assignment_add, [
            // IRM
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: Text('IRM cérébrale',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
            ),
            _check('IRM cérébrale sous anesthésie générale', _catDEM_IRM_AG,
                (v) => setState(() {
                      _catDEM_IRM_AG = v ?? false;
                      if (v == true) {
                        _catDEM_IRM_Premed = false;
                        _catDEM_IRM_SansPremed = false;
                      }
                    })),
            _check('IRM cérébrale sous prémédication', _catDEM_IRM_Premed,
                (v) => setState(() {
                      _catDEM_IRM_Premed = v ?? false;
                      if (v == true) {
                        _catDEM_IRM_AG = false;
                        _catDEM_IRM_SansPremed = false;
                      }
                    })),
            // ── Choix type d'ordonnance prémédication ──────────────────────────
            if (_catDEM_IRM_Premed)
              Padding(
                padding: const EdgeInsets.only(left: 36, bottom: 6, top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 15, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    const Text('Ordonnance :', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Normale', style: TextStyle(fontSize: 12)),
                      selected: !_catIRM_Premed100,
                      onSelected: (_) => setState(() => _catIRM_Premed100 = false),
                      selectedColor: const Color(0xFFBBDEFB),
                      labelStyle: TextStyle(
                        color: !_catIRM_Premed100 ? const Color(0xFF00599A) : Colors.grey,
                        fontWeight: !_catIRM_Premed100 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('100% ALD', style: TextStyle(fontSize: 12)),
                      selected: _catIRM_Premed100,
                      onSelected: (_) => setState(() => _catIRM_Premed100 = true),
                      selectedColor: const Color(0xFFC8E6C9),
                      labelStyle: TextStyle(
                        color: _catIRM_Premed100 ? const Color(0xFF2E7D32) : Colors.grey,
                        fontWeight: _catIRM_Premed100 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            _check('IRM cérébrale sans prémédication', _catDEM_IRM_SansPremed,
                (v) => setState(() {
                      _catDEM_IRM_SansPremed = v ?? false;
                      if (v == true) {
                        _catDEM_IRM_AG = false;
                        _catDEM_IRM_Premed = false;
                      }
                    })),
            const SizedBox(height: 6),
            // EEG
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('EEG',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
            ),
            _check('EEG de veille', _catDEM_EEG_Veille,
                (v) => setState(() {
                      _catDEM_EEG_Veille = v ?? false;
                      if (v == true) _catDEM_EEG_VeilleSommeil = false;
                    })),
            _check('EEG de veille et de sommeil', _catDEM_EEG_VeilleSommeil,
                (v) => setState(() {
                      _catDEM_EEG_VeilleSommeil = v ?? false;
                      if (v == true) _catDEM_EEG_Veille = false;
                    })),
            const SizedBox(height: 6),
            // Autres
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('Autres demandes',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
            ),
            Row(
              children: [
                Expanded(
                  child: _check('Analyses génétiques', _catDEM_Genetique,
                      (v) => setState(() => _catDEM_Genetique = v ?? false)),
                ),
                if (_catDEM_Genetique)
                  Tooltip(
                    message: 'Configurer les analyses génétiques',
                    child: InkWell(
                      onTap: _ouvrirGenetique,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.biotech_outlined,
                            size: 18, color: Colors.purple.shade700),
                      ),
                    ),
                  ),
              ],
            ),
            _check('Demande de TEP', _catDEM_TEP,
                (v) => setState(() => _catDEM_TEP = v ?? false)),
            Row(children: [
              Expanded(
                child: _check('Bilan en hôpital de jour', _catDEM_BilanHDJ,
                    (v) => setState(() => _catDEM_BilanHDJ = v ?? false)),
              ),
              if (_catDEM_BilanHDJ)
                Tooltip(
                  message: 'Programmer l\'HDJ',
                  child: InkWell(
                    onTap: () { _ouvrirHDJ(context); },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.calendar_month_outlined,
                          size: 18, color: Colors.teal.shade700),
                    ),
                  ),
                ),
            ]),
          ]),

          // ── Section Bilan paraclinique ────────────────────────────────────────
          _sectionCard('Bilan paraclinique', Icons.science_outlined, [
            Row(children: [
              Expanded(
                child: Text(
                  _bilanSelected.isEmpty
                      ? 'Aucun examen sélectionné'
                      : '${_bilanSelected.length} examen(s) sélectionné(s)',
                  style: TextStyle(
                      fontSize: 13,
                      color: _bilanSelected.isEmpty
                          ? Colors.grey.shade500
                          : blue,
                      fontStyle: _bilanSelected.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal),
                ),
              ),
              Tooltip(
                message: 'Configurer le bilan paraclinique',
                child: InkWell(
                  onTap: () => _ouvrirBilan(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.biotech_outlined,
                        size: 20, color: Colors.indigo.shade700),
                  ),
                ),
              ),
            ]),
            if (_bilanSelected.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _bilanSelected.map((item) => Chip(
                  label: Text(item, style: const TextStyle(fontSize: 11)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() => _bilanSelected.remove(item)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.indigo.shade50,
                  side: BorderSide(color: Colors.indigo.shade200),
                )).toList(),
              ),
            ],
          ]),

          // ── Conclusion libre ───────────────────────────────────────────────
          _sectionCard('Conclusion / remarques', Icons.edit_note, [
            TextField(
              controller: _catConclusionCtrl,
              decoration: const InputDecoration(
                hintText: 'Texte libre de conclusion…',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13),
              minLines: 3,
              maxLines: 8,
            ),
          ]),

          // ── Boutons ────────────────────────────────────────────────────────
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: blue,
                  side: BorderSide(color: blue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(_brochuresRemises.isEmpty
                    ? 'Brochures'
                    : 'Brochures (${_brochuresRemises.length})'),
                onPressed: () { _ouvrirBrochures(context); },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Générer les docs'),
                onPressed: () => _genererTousDocuments(),
              ),
            ),
          ]),

          // ── Brochures remises ──────────────────────────────────────────────
          if (_brochuresRemises.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00599A).withOpacity(0.05),
                border: Border.all(
                    color: const Color(0xFF00599A).withOpacity(0.25)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.info_outline,
                        size: 13, color: Colors.blue.shade700),
                    const SizedBox(width: 5),
                    Text('Informations remises au patient',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade700)),
                    const Spacer(),
                    InkWell(
                      onTap: () =>
                          setState(() => _brochuresRemises.clear()),
                      child: Icon(Icons.clear_all,
                          size: 15, color: Colors.grey.shade500),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: _brochuresRemises.map((name) {
                      return Chip(
                        label: Text(name,
                            style: const TextStyle(fontSize: 11)),
                        deleteIcon: const Icon(Icons.close, size: 13),
                        onDeleted: () =>
                            setState(() => _brochuresRemises.remove(name)),
                        backgroundColor:
                            const Color(0xFF00599A).withOpacity(0.1),
                        side: BorderSide(
                            color: const Color(0xFF00599A).withOpacity(0.3)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // ── Aperçu texte généré ────────────────────────────────────────────
          if (_catTexte.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.check_circle_outline,
                        color: Color(0xFF388E3C), size: 16),
                    const SizedBox(width: 6),
                    Text('Texte CAT inclus dans le CR',
                        style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _catTexte = ''),
                      child: const Icon(Icons.close,
                          color: Colors.grey, size: 18),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(_catTexte,
                      style: const TextStyle(fontSize: 12.5, height: 1.5)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Génération des documents Word PAI
  // ─────────────────────────────────────────────────────────────────────────

  /// Échappe les apostrophes et les sauts de ligne pour PowerShell
  /// (single-quoted strings : on les transforme en concaténation avec [char]13).
  // ─────────────────────────────────────────────────────────────────────────
  //  Fenêtre Génétique
  // ─────────────────────────────────────────────────────────────────────────

  void _ouvrirGenetique() {
    String genType        = 'DI';
    bool   genIncludePere = false;
    bool   genIncludeMere = false;
    // Tubes pour prélèvements externes : '' | 'EDTA' | 'Hep' | 'Les deux'
    String genTubePere    = '';
    String genTubeMere    = '';
    // Prélèvements internes avec consentement rempli
    bool   genInternalPere     = false;
    String genTubeInternPere   = 'EDTA';
    bool   genInternalMere     = false;
    String genTubeInternMere   = 'EDTA';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlg) {
          final nomEnf    = _nomEnfantController.text.trim().toUpperCase();
          final prenomEnf = _prenomEnfantController.text.trim();
          final ddnEnfStr = ddnEnfant != null
              ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : 'DDN inconnue';

          final nomPere    = _nomPereController.text.trim().toUpperCase();
          final prenomPere = _prenomPereController.text.trim();
          final ddnPereStr = ddnPere != null
              ? DateFormat('dd/MM/yyyy').format(ddnPere!) : 'DDN inconnue';
          final hasPere    = nomPere.isNotEmpty || prenomPere.isNotEmpty;

          final nomMere    = _nomMereController.text.trim().toUpperCase();
          final prenomMere = _prenomMereController.text.trim();
          final ddnMereStr = ddnMere != null
              ? DateFormat('dd/MM/yyyy').format(ddnMere!) : 'DDN inconnue';
          final hasMere    = nomMere.isNotEmpty || prenomMere.isNotEmpty;

          // ── Chip de sélection de type d'analyse ───────────────────────
          Widget typeChip(String label, String value) => Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 12)),
              selected: genType == value,
              selectedColor: Colors.purple.shade100,
              labelStyle: TextStyle(
                  color: genType == value
                      ? Colors.purple.shade800 : Colors.black87),
              onSelected: (_) => setDlg(() {
                genType = value;
                // Panel = toujours trio : auto-inclure les deux parents
                if (value == 'Panel') {
                  genIncludePere = hasPere;
                  genIncludeMere = hasMere;
                }
              }),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              visualDensity: VisualDensity.compact,
            ),
          );

          // ── Sélecteur de tubes ─────────────────────────────────────────
          Widget tubeSelector({
            required String value,
            required ValueChanged<String> onChanged,
            bool showAucun = true,
          }) {
            final opts = [
              if (showAucun) const ('Aucun',    ''),
              const ('EDTA',     'EDTA'),
              const ('Hépariné', 'Hep'),
              const ('Les deux', 'Les deux'),
            ];
            return Wrap(
              spacing: 4,
              children: opts.map((opt) {
                final (label, val) = opt;
                final sel = value == val;
                return GestureDetector(
                  onTap: () => onChanged(val),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sel ? Colors.orange.shade100 : Colors.grey.shade100,
                      border: Border.all(
                          color: sel
                              ? Colors.orange.shade400
                              : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: sel
                                ? FontWeight.w700 : FontWeight.normal,
                            color: sel
                                ? Colors.orange.shade800 : Colors.black54)),
                  ),
                );
              }).toList(),
            );
          }

          // ── Carte d'une personne ───────────────────────────────────────
          Widget personCard({
            required IconData icon,
            required Color color,
            required String title,
            required String nom,
            required String prenom,
            required String ddnStr,
            bool? checked,
            ValueChanged<bool>? onChecked,
            bool showType = false,
            String? tubeValue,
            ValueChanged<String>? onTubeChanged,
            // Prélèvement interne (avec consentement)
            bool? internalToggle,
            ValueChanged<bool>? onInternalToggle,
            String? internalTubeValue,
            ValueChanged<String>? onInternalTubeChanged,
          }) {
            final isActive = checked == null || checked == true;
            return AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isActive
                          ? color.withOpacity(0.5)
                          : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: isActive
                      ? color.withOpacity(0.04)
                      : Colors.grey.shade50,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête
                      Row(children: [
                        if (onChecked != null)
                          SizedBox(
                            width: 24, height: 24,
                            child: Checkbox(
                              value: checked,
                              onChanged: (v) => onChecked(v ?? false),
                              visualDensity: VisualDensity.compact,
                              activeColor: color,
                            ),
                          ),
                        if (onChecked != null) const SizedBox(width: 6),
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(title,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.5)),
                      ]),
                      const SizedBox(height: 6),
                      // Identité
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prenom.isNotEmpty || nom.isNotEmpty
                                  ? '$prenom $nom'.trim()
                                  : 'Non renseigné',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: (prenom.isEmpty && nom.isEmpty)
                                      ? Colors.grey : Colors.black87),
                            ),
                            Text(ddnStr,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      // Type d'analyse (enfant)
                      if (showType) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          typeChip('DI', 'DI'),
                          typeChip('TSA', 'TSA'),
                          typeChip('Exome / Panel', 'Panel'),
                        ]),
                        const SizedBox(height: 2),
                        Text(
                          genType == 'DI'
                              ? 'Cytogénétique DI — fiche + consentement'
                              : genType == 'TSA'
                                  ? 'Cytogénétique TSA — fiche + consentement'
                                  : 'Panel de gènes — trio obligatoire',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.purple.shade400,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                      // Fiche index label (parent)
                      if (!showType && isActive) ...[
                        const SizedBox(height: 3),
                        Text(
                          genType == 'Panel'
                              ? 'Fiche index parent (Panel)'
                              : 'Fiche cytogénétique parent',
                          style: TextStyle(
                              fontSize: 11,
                              color: color.withOpacity(0.7),
                              fontStyle: FontStyle.italic)),
                      ],
                      // ── Tube externe (parent coché uniquement) ─────────
                      if (!showType && isActive &&
                          tubeValue != null && onTubeChanged != null) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.science_outlined,
                              size: 13,
                              color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text('Prélèvement externe :',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade800)),
                        ]),
                        const SizedBox(height: 4),
                        tubeSelector(
                          value: tubeValue,
                          onChanged: onTubeChanged,
                        ),
                        if (tubeValue.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Ordonnance de prélèvement externe générée',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade600,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                      // ── Prélèvement interne (avec consentement) ───────────
                      if (isActive && onInternalToggle != null) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.bloodtype_outlined,
                              size: 13, color: Colors.red.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Prélèvement interne :',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700)),
                          ),
                          Transform.scale(
                            scale: 0.75,
                            child: Switch(
                              value: internalToggle ?? false,
                              onChanged: onInternalToggle,
                              activeColor: Colors.red.shade600,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ]),
                        if (internalToggle == true) ...[
                          const SizedBox(height: 4),
                          tubeSelector(
                            value: internalTubeValue ?? 'EDTA',
                            onChanged: onInternalTubeChanged!,
                            showAucun: false,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Consentement génétique rempli généré',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red.shade500,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            title: Row(children: [
              Icon(Icons.biotech_outlined,
                  color: Colors.purple.shade700, size: 22),
              const SizedBox(width: 8),
              const Text('Analyses génétiques',
                  style: TextStyle(fontSize: 16)),
            ]),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enfant
                    personCard(
                      icon: Icons.child_care,
                      color: Colors.purple.shade700,
                      title: 'ENFANT',
                      nom: nomEnf,
                      prenom: prenomEnf,
                      ddnStr: ddnEnfStr,
                      showType: true,

                    ),
                    // Père
                    GestureDetector(
                      onTap: () =>
                          setDlg(() => genIncludePere = !genIncludePere),
                      child: personCard(
                        icon: Icons.man_outlined,
                        color: Colors.blue.shade700,
                        title: 'PÈRE',
                        nom: hasPere ? nomPere : '',
                        prenom: hasPere ? prenomPere : '',
                        ddnStr: hasPere ? ddnPereStr : 'Non renseigné',
                        checked: genIncludePere,
                        onChecked: (v) =>
                            setDlg(() => genIncludePere = v),
                        tubeValue: genIncludePere ? genTubePere : null,
                        onTubeChanged: genIncludePere
                            ? (v) => setDlg(() => genTubePere = v)
                            : null,
                        internalToggle:
                            genIncludePere ? genInternalPere : null,
                        onInternalToggle: genIncludePere
                            ? (v) => setDlg(() => genInternalPere = v)
                            : null,
                        internalTubeValue: genInternalPere
                            ? genTubeInternPere : null,
                        onInternalTubeChanged: genInternalPere
                            ? (v) => setDlg(() => genTubeInternPere = v)
                            : null,
                      ),
                    ),
                    // Mère
                    GestureDetector(
                      onTap: () =>
                          setDlg(() => genIncludeMere = !genIncludeMere),
                      child: personCard(
                        icon: Icons.woman_outlined,
                        color: Colors.pink.shade600,
                        title: 'MÈRE',
                        nom: hasMere ? nomMere : '',
                        prenom: hasMere ? prenomMere : '',
                        ddnStr: hasMere ? ddnMereStr : 'Non renseigné',
                        checked: genIncludeMere,
                        onChecked: (v) =>
                            setDlg(() => genIncludeMere = v),
                        tubeValue: genIncludeMere ? genTubeMere : null,
                        onTubeChanged: genIncludeMere
                            ? (v) => setDlg(() => genTubeMere = v)
                            : null,
                        internalToggle:
                            genIncludeMere ? genInternalMere : null,
                        onInternalToggle: genIncludeMere
                            ? (v) => setDlg(() => genInternalMere = v)
                            : null,
                        internalTubeValue: genInternalMere
                            ? genTubeInternMere : null,
                        onInternalTubeChanged: genInternalMere
                            ? (v) => setDlg(() => genTubeInternMere = v)
                            : null,
                      ),
                    ),
                    // ── Anomalie familiale connue ─────────────────────
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.family_restroom,
                          size: 14, color: Colors.teal.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Anomalie familiale connue',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade700)),
                      ),
                      Transform.scale(
                        scale: 0.78,
                        child: Switch(
                          value: _genAnoFamiliale,
                          onChanged: (v) => setDlg(
                              () => setState(() => _genAnoFamiliale = v)),
                          activeColor: Colors.teal.shade600,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ]),
                    if (_genAnoFamiliale) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 6),
                        child: Text(
                          'Cas index : enfant (auto)  ·  Lien : Père / Mère (auto)',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.teal.shade400,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      TextField(
                        controller: _genGeneConnu,
                        decoration: InputDecoration(
                          labelText: 'Anomalie familiale / gène connu',
                          labelStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _genLaboratoire,
                        decoration: InputDecoration(
                          labelText: 'Laboratoire',
                          labelStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 4),
                      child: Row(children: [
                        Icon(Icons.info_outline,
                            size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Le consentement est généré avec identité et case cochée selon le prélèvement.',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx2),
                child: const Text('Annuler'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.description_outlined, size: 16),
                label: const Text('Générer les documents'),
                onPressed: () {
                  Navigator.pop(ctx2);
                  _genererDocumentsGenetique(
                    type: genType,
                    includePere: genIncludePere,
                    includeMere: genIncludeMere,
                    tubePere: genIncludePere ? genTubePere : '',
                    tubeMere: genIncludeMere ? genTubeMere : '',
                    internalPere:     genIncludePere && genInternalPere,
                    tubeInternPere:   genTubeInternPere,
                    internalMere:     genIncludeMere  && genInternalMere,
                    tubeInternMere:   genTubeInternMere,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _genererDocumentsGenetique({
    required String type,
    required bool includePere,
    required bool includeMere,
    required String tubePere,
    required String tubeMere,
    bool   internalPere     = false,
    String tubeInternPere   = 'EDTA',
    bool   internalMere     = false,
    String tubeInternMere   = 'EDTA',
  }) async {
    final nom    = _nomEnfantController.text.trim().toUpperCase();
    final prenom = _prenomEnfantController.text.trim();
    final ddnStr = ddnEnfant != null
        ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : '';
    final sexeCode = sexe == 'Masculin' ? 'M' : 'F';
    final ddj      = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final dateFile  = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Dossier patient (Desktop\comptes-rendus_patients\YYYY\MM\NOM_Prenom)
    final folderPath = await getDirectoryPath(nom, prenom);
    final tempDir = await getTemporaryDirectory();
    final List<String> generated = [];

    // ── Helper générique PS ────────────────────────────────────────────────
    Future<void> genDoc({
      required String templateAsset,
      required String outputName,
      required List<List<String>> bookmarks,
      List<List<String>> findReplace     = const [],
      List<int>          checkboxIndexes = const [],
      required String psFilename,
    }) async {
      final templatePath = await _getTemplatePath(templateAsset);
      final tpEsc  = templatePath.replaceAll("'", "''");
      final outPath = '$folderPath\\$outputName';
      final opEsc  = outPath.replaceAll("'", "''");

      final sb = StringBuffer();
      sb.writeln('\$word = New-Object -ComObject Word.Application');
      sb.writeln('\$word.Visible = \$false');
      sb.writeln("\$doc = \$word.Documents.Open('$tpEsc')");
      for (final bm in bookmarks) {
        sb.write(_psSetBookmark(bm[0], bm[1]));
      }
      // Cocher les cases à cocher (ContentControls)
      for (final idx in checkboxIndexes) {
        sb.writeln('\$doc.ContentControls.Item($idx).Checked = \$true');
      }
      if (findReplace.isNotEmpty) {
        sb.writeln('\$sel = \$word.Selection');
        for (final fr in findReplace) {
          final ef = _psEscape(fr[0]);
          final er = _psEscape(fr[1]);
          sb.writeln("\$sel.Find.Execute('$ef', \$false, \$false, \$false, \$false, \$false, \$true, 1, \$false, '$er', 2)");
        }
      }
      sb.writeln('\$doc.Fields.Update()');
      sb.writeln("\$doc.SaveAs2('$opEsc', 16)");
      sb.writeln('\$doc.Close()');
      sb.writeln('\$word.Quit()');
      await _runPsScript(tempDir, psFilename, sb.toString());
      await Process.run('explorer', [outPath]);
    }

    // ── Helper ordonnance prélèvement externe ──────────────────────────────
    Future<void> genOrdoPrelevement({
      required String nomP,
      required String prenomP,
      required DateTime? ddnP,
      required String genreCode,   // 'M.' ou 'Mme'
      required String tubes,       // 'EDTA' | 'Hep' | 'Les deux'
      required String lien,        // 'Père' | 'Mère'
      required String psFilename,
      required String outputName,
    }) async {
      final ddnPStr = ddnP != null
          ? DateFormat('dd/MM/yyyy').format(ddnP) : '';
      final ageAns  = ddnP != null
          ? ((DateTime.now().difference(ddnP).inDays) / 365.25).floor()
          : 0;

      final String tubeTexte;
      switch (tubes) {
        case 'EDTA':
          tubeTexte = '1 tube EDTA (5 mL) — analyse génétique moléculaire';
          break;
        case 'Hep':
          tubeTexte = '1 tube hépariné (5 mL) — analyse cytogénétique';
          break;
        default:
          tubeTexte = '1 tube EDTA (5 mL) + 1 tube hépariné (5 mL)\n'
              '— analyse génétique moléculaire et cytogénétique';
      }

      final String prescription =
          'Prélèvement sanguin ($lien de $prenom $nom)\n'
          '$tubeTexte\n'
          'Indication : analyses génétiques — à adresser au\n'
          'Laboratoire de Génétique du CHRU de Nancy\n'
          '(Hôpitaux de Brabois — Vandœuvre-lès-Nancy)';

      await genDoc(
        templateAsset: 'Ordo simple MK.docx',
        outputName:    outputName,
        bookmarks: [
          ['Genre',  genreCode],
          ['Nom',    nomP],
          ['Prenom', prenomP],
          ['DDN',    ddnPStr],
          ['Age',    ageAns > 0 ? '$ageAns ans' : ''],
          ['Poids',  ''],
          ['Taille', ''],
        ],
        findReplace: [
          // Remplace le texte de prémédication par la prescription génétique
          ['Mélatonine', prescription],
        ],
        psFilename: psFilename,
      );
    }

    try {
      // ── 1. Fiche enfant ────────────────────────────────────────────────
      final ficheLabel = type == 'TSA' ? 'TSA'
          : type == 'Panel' ? 'Panel' : 'DI';

      if (type == 'Panel') {
        // Panel de gènes : fiche spécifique Panel enfant
        await genDoc(
          templateAsset: 'Fiche_renseignements_cliniques_Panel.docx',
          outputName:    '${dateFile}_Fiche génétique Panel_${nom}_${prenom}.docx',
          bookmarks: [
            ['Nom',    nom],
            ['Prenom', prenom],
            ['ddn',    ddnStr],
            ['Sexe',   sexeCode],
            ['ddj',    ddj],
          ],
          psFilename: 'gen_fiche_enf.ps1',
        );
      } else {
        // Cytogénétique (DI / TSA) : fiche génétique avec champs anomalie familiale
        await genDoc(
          templateAsset: 'Fiche_renseignements_cliniques_genetique.docx',
          outputName:    '${dateFile}_Fiche génétique ${ficheLabel}_${nom}_${prenom}.docx',
          bookmarks: [
            ['Nom',    nom],
            ['Prenom', prenom],
            ['ddn',    ddnStr],
            ['Sexe',   sexeCode],
            ['ddj',    ddj],
            if (_genAnoFamiliale && _genGeneConnu.text.trim().isNotEmpty)
              ['Gène',   _genGeneConnu.text.trim()],
            if (_genAnoFamiliale && _genLaboratoire.text.trim().isNotEmpty)
              ['Labo',   _genLaboratoire.text.trim()],
          ],
          psFilename: 'gen_fiche_enf.ps1',
        );
      }
      generated.add('Fiche $ficheLabel enfant');

      // ── 2. Fiches parents + ordonnances tubes ──────────────────────────
      if (includePere) {
        final nomP    = _nomPereController.text.trim().toUpperCase();
        final prenomP = _prenomPereController.text.trim();
        final ddnPStr = ddnPere != null
            ? DateFormat('dd/MM/yyyy').format(ddnPere!) : '';
        if (type == 'Panel') {
          // Panel : fiche index avec identité de l'enfant
          await genDoc(
            templateAsset: 'Fiche_renseignements_cliniques_Panel_index.docx',
            outputName:    '${dateFile}_Fiche génétique Panel index Père_${nomP}_${prenomP}.docx',
            bookmarks: [
              ['Nom_parent',    nomP],
              ['Prenom_parent', prenomP],
              ['ddn_parent',    ddnPStr],
              ['Sexe',          'M'],
              ['ddj',           ddj],
              ['Nom',           nom],
              ['Prenom',        prenom],
              ['ddn',           ddnStr],
              ['Lien',          'Père'],
            ],
            psFilename: 'gen_fiche_pere.ps1',
          );
          generated.add('Fiche Panel index Père');
        } else {
          // Cytogénétique : fiche génétique standard pour le père
          await genDoc(
            templateAsset: 'Fiche_renseignements_cliniques_genetique.docx',
            outputName:    '${dateFile}_Fiche génétique ${ficheLabel} Père_${nomP}_${prenomP}.docx',
            bookmarks: [
              ['Nom',    nomP],
              ['Prenom', prenomP],
              ['ddn',    ddnPStr],
              ['Sexe',   'M'],
              ['ddj',    ddj],
              if (_genAnoFamiliale) ...[
                ['Parent', '$prenom $nom'.trim()],
                ['Lien',   'Père'],
                if (_genGeneConnu.text.trim().isNotEmpty)
                  ['Gène', _genGeneConnu.text.trim()],
                if (_genLaboratoire.text.trim().isNotEmpty)
                  ['Labo', _genLaboratoire.text.trim()],
              ],
            ],
            psFilename: 'gen_fiche_pere.ps1',
          );
          generated.add('Fiche cytogénétique Père');
        }

        if (tubePere.isNotEmpty) {
          await genOrdoPrelevement(
            nomP:       _nomPereController.text.trim().toUpperCase(),
            prenomP:    _prenomPereController.text.trim(),
            ddnP:       ddnPere,
            genreCode:  'M.',
            tubes:      tubePere,
            lien:       'Père',
            psFilename: 'ordo_prelev_pere.ps1',
            outputName: '${dateFile}_Ordo prélèvement Père_${_nomPereController.text.trim().toUpperCase()}.docx',
          );
          final tubeLabel = tubePere == 'Les deux' ? 'EDTA+Hép' : tubePere;
          generated.add('Ordo prélèvement Père ($tubeLabel)');
        }
      }

      if (includeMere) {
        final nomM    = _nomMereController.text.trim().toUpperCase();
        final prenomM = _prenomMereController.text.trim();
        final ddnMStr = ddnMere != null
            ? DateFormat('dd/MM/yyyy').format(ddnMere!) : '';
        if (type == 'Panel') {
          // Panel : fiche index avec identité de l'enfant
          await genDoc(
            templateAsset: 'Fiche_renseignements_cliniques_Panel_index.docx',
            outputName:    '${dateFile}_Fiche génétique Panel index Mère_${nomM}_${prenomM}.docx',
            bookmarks: [
              ['Nom_parent',    nomM],
              ['Prenom_parent', prenomM],
              ['ddn_parent',    ddnMStr],
              ['Sexe',          'F'],
              ['ddj',           ddj],
              ['Nom',           nom],
              ['Prenom',        prenom],
              ['ddn',           ddnStr],
              ['Lien',          'Mère'],
            ],
            psFilename: 'gen_fiche_mere.ps1',
          );
          generated.add('Fiche Panel index Mère');
        } else {
          // Cytogénétique : fiche génétique standard pour la mère
          await genDoc(
            templateAsset: 'Fiche_renseignements_cliniques_genetique.docx',
            outputName:    '${dateFile}_Fiche génétique ${ficheLabel} Mère_${nomM}_${prenomM}.docx',
            bookmarks: [
              ['Nom',    nomM],
              ['Prenom', prenomM],
              ['ddn',    ddnMStr],
              ['Sexe',   'F'],
              ['ddj',    ddj],
              if (_genAnoFamiliale) ...[
                ['Parent', '$prenom $nom'.trim()],
                ['Lien',   'Mère'],
                if (_genGeneConnu.text.trim().isNotEmpty)
                  ['Gène', _genGeneConnu.text.trim()],
                if (_genLaboratoire.text.trim().isNotEmpty)
                  ['Labo', _genLaboratoire.text.trim()],
              ],
            ],
            psFilename: 'gen_fiche_mere.ps1',
          );
          generated.add('Fiche cytogénétique Mère');
        }

        if (tubeMere.isNotEmpty) {
          await genOrdoPrelevement(
            nomP:       _nomMereController.text.trim().toUpperCase(),
            prenomP:    _prenomMereController.text.trim(),
            ddnP:       ddnMere,
            genreCode:  'Mme',
            tubes:      tubeMere,
            lien:       'Mère',
            psFilename: 'ordo_prelev_mere.ps1',
            outputName: '${dateFile}_Ordo prélèvement Mère_${_nomMereController.text.trim().toUpperCase()}.docx',
          );
          final tubeLabel = tubeMere == 'Les deux' ? 'EDTA+Hép' : tubeMere;
          generated.add('Ordo prélèvement Mère ($tubeLabel)');
        }
      }

      // ── 3. Consentement(s) génétique(s) ───────────────────────────────
      // Motif du consentement = motif de la consultation + type génétique
      final motifConsent = _motifController.text.trim();

      // Helper local pour consentements remplis
      Future<void> genConsent({
        required String suffix,
        required String psFile,
        required int    cbIdx,        // 1 = sur moi-même, 2 = sur mon enfant
        required String patNomPren,
        required String patDDN,
        String r1NomPren = '',
        String r1DDN     = '',
        String r1Lien    = '',
        String r2NomPren = '',
        String r2DDN     = '',
        String r2Lien    = '',
      }) async {
        final bms = <List<String>>[
          ['Motif',       motifConsent],
          ['PatNomPrenom', patNomPren],
          ['PatDDN',       patDDN],
          if (r1NomPren.isNotEmpty) ['Rep1NomPrenom', r1NomPren],
          if (r1DDN.isNotEmpty)     ['Rep1DDN',       r1DDN],
          if (r1Lien.isNotEmpty)    ['Rep1Lien',      r1Lien],
          if (r2NomPren.isNotEmpty) ['Rep2NomPrenom', r2NomPren],
          if (r2DDN.isNotEmpty)     ['Rep2DDN',       r2DDN],
          if (r2Lien.isNotEmpty)    ['Rep2Lien',      r2Lien],
        ];
        await genDoc(
          templateAsset:   'Consentement_genetique.docx',
          outputName:      '${dateFile}_Consentement génétique_${nom}_${prenom}.docx',
          checkboxIndexes: [cbIdx],
          bookmarks:       bms,
          psFilename:      psFile,
        );
      }

      // Identités des parents (utilisées dans le consentement enfant)
      final nomPere2    = _nomPereController.text.trim().toUpperCase();
      final prenomPere2 = _prenomPereController.text.trim();
      final ddnPere2Str = ddnPere != null
          ? DateFormat('dd/MM/yyyy').format(ddnPere!) : '';
      final nomMere2    = _nomMereController.text.trim().toUpperCase();
      final prenomMere2 = _prenomMereController.text.trim();
      final ddnMere2Str = ddnMere != null
          ? DateFormat('dd/MM/yyyy').format(ddnMere!) : '';

      // a) Consentement pour l'enfant (toujours) — "sur mon enfant" (SDT 2)
      await genConsent(
        suffix:     '${nom}_$prenom',
        psFile:     'gen_consent_enf.ps1',
        cbIdx:      2,
        patNomPren: '$prenom $nom'.trim(),
        patDDN:     ddnStr,
        r1NomPren:  '$prenomPere2 $nomPere2'.trim(),
        r1DDN:      ddnPere2Str,
        r1Lien:     'Père',
        r2NomPren:  '$prenomMere2 $nomMere2'.trim(),
        r2DDN:      ddnMere2Str,
        r2Lien:     'Mère',
      );
      generated.add('Consentement (enfant)');

      // b) Consent père si prélèvement interne OU externe — "sur moi-même" (SDT 1)
      if (internalPere || tubePere.isNotEmpty) {
        final nomP2    = nomPere2;
        final prenomP2 = prenomPere2;
        final ddnPStr2 = ddnPere2Str;
        await genConsent(
          suffix:     '${nomP2}_${prenomP2}_moi-meme',
          psFile:     'gen_consent_pere.ps1',
          cbIdx:      1,
          patNomPren: '$prenomP2 $nomP2'.trim(),
          patDDN:     ddnPStr2,
        );
        generated.add('Consentement Père');
      }

      // c) Consent mère si prélèvement interne OU externe — "sur moi-même" (SDT 1)
      if (internalMere || tubeMere.isNotEmpty) {
        final nomM2    = nomMere2;
        final prenomM2 = prenomMere2;
        final ddnMStr2 = ddnMere2Str;
        await genConsent(
          suffix:     '${nomM2}_${prenomM2}_moi-meme',
          psFile:     'gen_consent_mere.ps1',
          cbIdx:      1,
          patNomPren: '$prenomM2 $nomM2'.trim(),
          patDDN:     ddnMStr2,
        );
        generated.add('Consentement Mère');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Génétique : ${generated.join(' · ')} générés'),
          backgroundColor: Colors.purple.shade700,
          duration: const Duration(seconds: 5),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur génétique : $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
        ));
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Dialog HDJ — Programmer une Hospitalisation de Jour
  // ─────────────────────────────────────────────────────────────────────────


  // ── Profils diagnostiques HDJ (source : feuille Save_bilan du VBA) ────────
  static const _kHdjProfilLabels = [
    'DI',                    // 0  Retard psychomoteur / DI
    'DI + microcéphalie',    // 1
    'DI + surcharge',        // 2
    'TSA',                   // 3  Trouble du spectre autistique
    'Sd. cérébelleux',       // 4
    'Dystonie',              // 5
    'Convulsion',            // 6
    'Malaise',               // 7
    'Inflammatoire',         // 8
    'Œdème papillaire',      // 9
    'Paraplégie spastique',  // 10
    'STB',                   // 11 Sclérose tubéreuse de Bourneville
  ];

  // Sang : liste des tests cochés pour chaque profil (index = profil)
  static const _kHdjSangParProfil = <List<String>>[
    // 0 — DI
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
     'CPK', 'LDH', 'TQ-TCA-Fibrinogène',
     'Bilan énergetique pré & postprandial', 'Ac méthylmalonique',
     'Ac. pristanique, phytanique et pipécolique', 'Plasmalogènes érythrocytaires',
     'Profil des acylcarnitines', 'Acides gras à très longues chaînes',
     'Ammoniémie', 'Chromatographie des acides aminés (sang)',
     'Isoforme de la transferrine', 'Bilan lipidique', 'Frottis sanguins',
     'Homocystéine', 'FRM1 (Fragile X)', 'Étude du locus 15q11-q13',
     'ACPA', 'Purines, pyramidines & ac. orotique'],
    // 1 — DI + microcéphalie
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
     'CPK', 'TQ-TCA-Fibrinogène',
     'Bilan énergetique pré & postprandial', 'Ac méthylmalonique',
     'Ac. pristanique, phytanique et pipécolique', 'Plasmalogènes érythrocytaires',
     'Profil des acylcarnitines', 'Acides gras à très longues chaînes',
     'Ammoniémie', 'Chromatographie des acides aminés (sang)',
     'Isoforme de la transferrine', 'Chitotriosidase & kératan sulfate',
     'Bilan lipidique', 'Cholestanol', 'Frottis sanguins', 'Homocystéine',
     'FRM1 (Fragile X)', 'Étude du locus 15q11-q13', 'ACPA', 'DNAthèque',
     'Hexosaminidase A et B (GM2)', 'Sérologie CMV', 'Sérologie HSV',
     'Sérologie syphilis', 'Purines, pyramidines & ac. orotique'],
    // 2 — DI + surcharge
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
     'CPK', 'TQ-TCA-Fibrinogène',
     'Bilan énergetique pré & postprandial', 'Ac méthylmalonique',
     'Ac. pristanique, phytanique et pipécolique', 'Plasmalogènes érythrocytaires',
     'Profil des acylcarnitines', 'Acides gras à très longues chaînes',
     'Ammoniémie', 'Chromatographie des acides aminés (sang)',
     'Isoforme de la transferrine', 'Chitotriosidase & kératan sulfate',
     'Bilan lipidique', 'Cholestanol', 'Frottis sanguins', 'Homocystéine',
     'FRM1 (Fragile X)', 'Étude du locus 15q11-q13', 'ACPA', 'DNAthèque',
     'Hexosaminidase A et B (GM2)', 'Sérologie CMV', 'Sérologie HSV',
     'Sérologie syphilis', 'Purines, pyramidines & ac. orotique'],
    // 3 — TSA
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
     'CPK', 'Bilan énergetique pré & postprandial', 'Ac méthylmalonique',
     'Profil des acylcarnitines', 'Ammoniémie',
     'Chromatographie des acides aminés (sang)', 'Glycosylation des protéines',
     '25-OH-vitamine D', 'Vitamines B1, B6, B9 et B12', 'Frottis sanguins',
     'Homocystéine', 'FRM1 (Fragile X)', 'Étude du locus 15q11-q13', 'ACPA'],
    // 4 — Sd. cérébelleux
    ['NFS-plaquettes', 'Bilan énergetique pré & postprandial',
     'Ac. pristanique, phytanique et pipécolique',
     'Acides gras à très longues chaînes', 'Ammoniémie',
     'Chromatographie des acides aminés (sang)',
     'Bilan lipidique', 'Cholestanol', 'Vitamines B1, B6, B9 et B12',
     'Frottis sanguins', 'Cuivre, céruloplasmine', 'Homocystéine',
     'Étude du locus 15q11-q13', 'ACPA', 'DNAthèque',
     'Hexosaminidase A et B (GM2)',
     'Mannosidase A et B', 'Galactocérébrosidase (Krabbe)',
     'Arylsulfatase A (LDM)', 'Vitamine E', 'Alphafœtoprotéine', 'Lyso SM509'],
    // 5 — Dystonie
    [],
    // 6 — Convulsion
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Bilan énergetique pré & postprandial',
     'Ammoniémie', 'Chromatographie des acides aminés (sang)', 'DNAthèque'],
    // 7 — Malaise
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Bilan énergetique pré & postprandial',
     'Ammoniémie', 'Chromatographie des acides aminés (sang)'],
    // 8 — Inflammatoire
    ['NFS-plaquettes', 'ASAT, ALAT, Ph. alc., Gamma GT', 'T4, TSH, T3',
     'CRP', '25-OH-vitamine D', 'Vitamines B1, B6, B9 et B12', 'Vitamine E',
     'Ac anti-nucléaires', 'Ac anti-DNA natifs', 'Ac anti-neuronaux',
     'Ac anti-phospholipides', 'ANCA', 'ASCA', 'C3, C4, CH50', 'ECA',
     'Ac anti-MOG & anti-NMO', 'Ac anti-TPO & anti-thyroglobuline'],
    // 9 — Œdème papillaire
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie', 'T4, TSH, T3',
     'Magnésémie', 'Sérologie EBV', 'Sérologie bartonella henselae',
     'Sérologie Lyme', 'Vitamine A', 'Toxoplasmose', 'Sérologie VZV',
     'Ferritine', 'Ac anti-MOG & anti-NMO'],
    // 10 — Paraplégie spastique
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
     'CPK', 'Bilan énergetique pré & postprandial',
     'Ac. pristanique, phytanique et pipécolique',
     'Acides gras à très longues chaînes', 'Ammoniémie',
     'Chromatographie des acides aminés (sang)',
     'Isoforme de la transferrine', 'Biotinidase', 'Bilan lipidique',
     'Cholestanol', 'Vitamines B1, B6, B9 et B12', 'Frottis sanguins',
     'Cuivre, céruloplasmine', 'Homocystéine', 'ACPA',
     'Vitamine E', 'Purines, pyramidines & ac. orotique'],
    // 11 — STB
    ['NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
     'ASAT, ALAT, Ph. alc., Gamma GT', 'T4, TSH, T3', 'CRP',
     'Bilan énergetique pré & postprandial', 'Ammoniémie',
     'Chromatographie des acides aminés (sang)', 'DNAthèque'],
  ];

  static const _kHdjUrinesParProfil = <List<String>>[
    // 0 — DI
    ['Bandelette urinaire', 'Chromatographie des acides aminés (urines)',
     'Chromatographie des acides organiques (urines)',
     'AICAR/SAICAR', 'Guanidino-acétate urinaire',
     'Créatine urinaire', 'Créatinine urinaire'],
    // 1 — DI + microcéphalie
    ['Chromatographie des acides aminés (urines)',
     'Chromatographie des acides organiques (urines)',
     'Acide sialique', 'Oligo & mucopolysaccharides',
     'Guanidino-acétate urinaire', 'Créatine urinaire', 'Créatinine urinaire'],
    // 2 — DI + surcharge
    ['Chromatographie des acides aminés (urines)',
     'Chromatographie des acides organiques (urines)',
     'Acide sialique', 'Oligo & mucopolysaccharides',
     'AICAR/SAICAR', 'Guanidino-acétate urinaire',
     'Créatine urinaire', 'Créatinine urinaire'],
    // 3 — TSA
    ['Bandelette urinaire', 'Chromatographie des acides aminés (urines)',
     'Chromatographie des acides organiques (urines)', 'AICAR/SAICAR'],
    // 4 — Sd. cérébelleux
    ['Oligo & mucopolysaccharides'],
    // 5 — Dystonie
    [],
    // 6 — Convulsion
    [],
    // 7 — Malaise
    [],
    // 8 — Inflammatoire
    [],
    // 9 — Œdème papillaire
    [],
    // 10 — Paraplégie spastique
    ['Bandelette urinaire', 'Chromatographie des acides aminés (urines)',
     'Chromatographie des acides organiques (urines)'],
    // 11 — STB
    [],
  ];

  static const _kHdjLCRParProfil = <List<String>>[
    // 0 — DI
    [],
    // 1 — DI + microcéphalie
    [],
    // 2 — DI + surcharge
    ['Albumine/Préalbumine'],
    // 3 — TSA
    [],
    // 4 — Sd. cérébelleux
    [],
    // 5 — Dystonie
    [],
    // 6 — Convulsion
    [],
    // 7 — Malaise
    [],
    // 8 — Inflammatoire
    ['Chimie + glycorrachie (glycémie capillaire en parallèle)',
     'Cytologie', 'Bactériologie', 'Synthèse intrathécale'],
    // 9 — Œdème papillaire
    ['Chimie + glycorrachie (glycémie capillaire en parallèle)',
     'Cytologie', 'Bactériologie', 'PCR multiplex', 'Synthèse intrathécale'],
    // 10 — Paraplégie spastique
    ['Chimie + glycorrachie (glycémie capillaire en parallèle)',
     'Cytologie', 'Neurotransmetteurs',
     'Chromatographie des acides aminés (LCR)',
     'Interféron'],
    // 11 — STB
    [],
  ];

  // EEG suggéré par profil (null = aucun, 'VS' = Veille-Sommeil)
  static const _kHdjEEGParProfil = <String?>[
    null, 'VS', 'VS', null, null, null, 'VS', 'VS', null, null, null, null,
  ];

  /// Dose de mélatonine pour prémédication EEG selon l'âge (en mg).
  String _doseMelatonineEEG() {
    final age = ddnEnfant != null
        ? (DateTime.now().difference(ddnEnfant!).inDays / 365.25)
        : 0.0;
    if (age < 2)  return '1';
    if (age < 6)  return '2';
    if (age < 12) return '3';
    return '5';
  }

  void _ouvrirHDJ(BuildContext context) {
    // ── État local du dialog ───────────────────────────────────────────────
    final motifCtrl = TextEditingController();
    final eegMotifCtrl = TextEditingController();

    String hdjDelai    = '3 mois';
    bool   hasEEG      = false;
    String eegType     = 'Veille';       // Veille | Veille-Sommeil | Longue durée | ENMG
    bool   hasBio      = false;

    // ── Profil sélectionné ──────────────────────────────────────────────────
    int? hdjProfil;

    // ── Tests sang ───────────────────────────────────────────────────────────
    final Map<String, bool> bioSang = {
      'NFS-plaquettes':                                    false,
      'Ionogramme-Calcémie-phosphorémie':                  false,
      'ASAT, ALAT, Ph. alc., Gamma GT':                   false,
      'Acide urique':                                      false,
      'T4, TSH, T3':                                       false,
      'CPK':                                               false,
      'LDH':                                               false,
      'CRP':                                               false,
      'TQ-TCA-Fibrinogène':                                false,
      'Bilan énergetique pré & postprandial':              false,
      'Ac méthylmalonique':                                false,
      'Ac. pristanique, phytanique et pipécolique':        false,
      'Plasmalogènes érythrocytaires':                     false,
      'Profil des acylcarnitines':                         false,
      'Acides gras à très longues chaînes':                false,
      'Ammoniémie':                                        false,
      'Chromatographie des acides aminés (sang)':          false,
      'Glycosylation des protéines':                       false,
      'Isoforme de la transferrine':                       false,
      'Biotinidase':                                       false,
      'Chitotriosidase & kératan sulfate':                 false,
      'Bilan lipidique':                                   false,
      'Magnésémie':                                        false,
      '25-OH-vitamine D':                                  false,
      'Cholestanol':                                       false,
      'Vitamines B1, B6, B9 et B12':                      false,
      'Frottis sanguins':                                  false,
      'Cuivre, céruloplasmine':                            false,
      'Homocystéine':                                      false,
      'FRM1 (Fragile X)':                                  false,
      'Étude du locus 15q11-q13':                         false,
      'ACPA':                                              false,
      'DNAthèque':                                         false,
      'Hexosaminidase A et B (GM2)':                       false,
      'Sérologie CMV':                                     false,
      'Sérologie HSV':                                     false,
      'Sérologie syphilis':                                false,
      'Mannosidase A et B':                                false,
      'Galactocérébrosidase (Krabbe)':                     false,
      'Arylsulfatase A (LDM)':                             false,
      'Vitamine E':                                        false,
      'Alphafœtoprotéine':                                 false,
      'Lyso SM509':                                        false,
      'Ac anti-nucléaires':                                false,
      'Ac anti-DNA natifs':                                false,
      'Ac anti-neuronaux':                                 false,
      'Ac anti-phospholipides':                            false,
      'ANCA':                                              false,
      'ASCA':                                              false,
      'C3, C4, CH50':                                      false,
      'ECA':                                               false,
      'Sérologie EBV':                                     false,
      'Sérologie bartonella henselae':                     false,
      'Sérologie Lyme':                                    false,
      'Vitamine A':                                        false,
      'Toxoplasmose':                                      false,
      'Sérologie VZV':                                     false,
      'Ferritine':                                         false,
      'Ac anti-MOG & anti-NMO':                            false,
      'Ac anti-TPO & anti-thyroglobuline':                 false,
      'Purines, pyramidines & ac. orotique':               false,
    };

    // ── Tests urines ─────────────────────────────────────────────────────────
    final Map<String, bool> bioUrines = {
      'Bandelette urinaire':                               false,
      'Chromatographie des acides aminés (urines)':        false,
      'Chromatographie des acides organiques (urines)':    false,
      'Acide sialique':                                    false,
      'Oligo & mucopolysaccharides':                       false,
      'AICAR/SAICAR':                                      false,
      'Guanidino-acétate urinaire':                        false,
      'Créatine urinaire':                                 false,
      'Créatinine urinaire':                               false,
    };

    // ── Tests LCR ────────────────────────────────────────────────────────────
    final Map<String, bool> bioLCR = {
      'Chimie + glycorrachie (glycémie capillaire en parallèle)': false,
      'Cytologie':                                         false,
      'Bactériologie':                                     false,
      'PCR multiplex':                                     false,
      'Neurotransmetteurs':                                false,
      'Chromatographie des acides aminés (LCR)':          false,
      'Interféron':                                        false,
      'Synthèse intrathécale':                             false,
      'Albumine/Préalbumine':                              false,
    };

    final bioAutreCtrl = TextEditingController();

    const Color teal = Color(0xFF00695C);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlg) {
          final doseMela = _doseMelatonineEEG();
          final premedText = eegType == 'Veille-Sommeil'
              ? 'Mélatonine $doseMela mg à donner 30 min avant l\'examen'
              : '';

          // ── Sélecteur de délai ─────────────────────────────────────────
          Widget delaiChip(String label) => Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 4),
            child: ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 12)),
              selected: hdjDelai == label,
              selectedColor: teal.withOpacity(0.18),
              labelStyle: TextStyle(
                  color: hdjDelai == label ? teal : Colors.black87,
                  fontWeight: hdjDelai == label
                      ? FontWeight.w700 : FontWeight.normal),
              onSelected: (_) => setDlg(() => hdjDelai = label),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          );

          // ── Groupe de checkboxes bio ────────────────────────────────────
          Widget bioGroup(String title, Map<String, bool> tests) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700)),
              ),
              ...tests.keys.map((test) => SizedBox(
                height: 26,
                child: InkWell(
                  onTap: () =>
                      setDlg(() => tests[test] = !(tests[test] ?? false)),
                  child: Row(children: [
                    Checkbox(
                      value: tests[test] ?? false,
                      onChanged: (v) =>
                          setDlg(() => tests[test] = v ?? false),
                      activeColor: teal,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(test, style: const TextStyle(fontSize: 12)),
                  ]),
                ),
              )),
            ],
          );

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── En-tête ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                  decoration: const BoxDecoration(
                    color: teal,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.local_hospital_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Programmer une HDJ',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    Text(
                      '${_prenomEnfantController.text.trim()} '
                      '${_nomEnfantController.text.trim()}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx2),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ]),
                ),

                // ── Corps ─────────────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Motif ──────────────────────────────────────────
                        const Text('Motif de l\'HDJ',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13, color: teal)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: motifCtrl,
                          decoration: const InputDecoration(
                            hintText:
                                'Ex : Bilan épilepsie, bilan métabolique…',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                          ),
                          style: const TextStyle(fontSize: 13),
                          minLines: 2, maxLines: 4,
                        ),
                        const SizedBox(height: 12),

                        // ── Délai ──────────────────────────────────────────
                        const Text('Délai souhaité',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13, color: teal)),
                        const SizedBox(height: 6),
                        Wrap(children: [
                          for (final d in [
                            '3 semaines', '1 mois', '2 mois',
                            '3 mois', '6 mois', '1 an',
                            'Dès que possible'
                          ]) delaiChip(d),
                        ]),
                        const SizedBox(height: 12),
                        const Divider(),

                        // ── EEG ───────────────────────────────────────────
                        InkWell(
                          onTap: () => setDlg(() => hasEEG = !hasEEG),
                          borderRadius: BorderRadius.circular(6),
                          child: Row(children: [
                            Checkbox(
                              value: hasEEG,
                              onChanged: (v) =>
                                  setDlg(() => hasEEG = v ?? false),
                              activeColor: teal,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('EEG',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13, color: teal)),
                          ]),
                        ),
                        if (hasEEG) ...[
                          const SizedBox(height: 6),
                          // Type EEG
                          Wrap(spacing: 5, children: [
                            for (final t in [
                              'Veille',
                              'Veille-Sommeil',
                              'Longue durée',
                              'ENMG'
                            ])
                              ChoiceChip(
                                label: Text(t,
                                    style:
                                        const TextStyle(fontSize: 12)),
                                selected: eegType == t,
                                selectedColor: Colors.blue.shade100,
                                labelStyle: TextStyle(
                                    color: eegType == t
                                        ? Colors.blue.shade800
                                        : Colors.black87),
                                onSelected: (_) =>
                                    setDlg(() => eegType = t),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6),
                              ),
                          ]),
                          if (premedText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border: Border.all(
                                    color: Colors.orange.shade200),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(children: [
                                Icon(Icons.medication_outlined,
                                    size: 14,
                                    color: Colors.orange.shade700),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(premedText,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Colors.orange.shade800)),
                                ),
                              ]),
                            ),
                          ],
                          const SizedBox(height: 6),
                          TextField(
                            controller: eegMotifCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Motif EEG (ex : épilepsie, crises…)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                          ),
                        ],
                        const Divider(),

                        // ── Biologie ──────────────────────────────────────
                        InkWell(
                          onTap: () => setDlg(() => hasBio = !hasBio),
                          borderRadius: BorderRadius.circular(6),
                          child: Row(children: [
                            Checkbox(
                              value: hasBio,
                              onChanged: (v) =>
                                  setDlg(() => hasBio = v ?? false),
                              activeColor: teal,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Text('Biologie',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13, color: teal)),
                          ]),
                        ),
                        if (hasBio) ...[
                          // ── Sélecteur de profil ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Profil diagnostique',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade700)),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 5, runSpacing: 4,
                                  children: List.generate(
                                    _kHdjProfilLabels.length,
                                    (i) => ChoiceChip(
                                      label: Text(_kHdjProfilLabels[i],
                                          style: const TextStyle(fontSize: 11)),
                                      selected: hdjProfil == i,
                                      selectedColor: teal.withOpacity(0.18),
                                      labelStyle: TextStyle(
                                          color: hdjProfil == i
                                              ? teal : Colors.black87,
                                          fontWeight: hdjProfil == i
                                              ? FontWeight.w700
                                              : FontWeight.normal),
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      onSelected: (_) => setDlg(() {
                                        hdjProfil = i;
                                        hasBio = true;
                                        // Appliquer le profil
                                        final sang  = _kHdjSangParProfil[i];
                                        final urine = _kHdjUrinesParProfil[i];
                                        final lcr   = _kHdjLCRParProfil[i];
                                        for (final k in bioSang.keys) {
                                          bioSang[k] = sang.contains(k);
                                        }
                                        for (final k in bioUrines.keys) {
                                          bioUrines[k] = urine.contains(k);
                                        }
                                        for (final k in bioLCR.keys) {
                                          bioLCR[k] = lcr.contains(k);
                                        }
                                        final eegSuggere = _kHdjEEGParProfil[i];
                                        if (eegSuggere == 'VS') {
                                          hasEEG  = true;
                                          eegType = 'Veille-Sommeil';
                                        }
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 10),
                          bioGroup('Sang', bioSang),
                          bioGroup('Urines', bioUrines),
                          bioGroup('LCR', bioLCR),
                          const SizedBox(height: 6),
                          TextField(
                            controller: bioAutreCtrl,
                            decoration: const InputDecoration(
                              hintText:
                                  'Autre(s) examen(s) biologique(s)…',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // ── Pied de page ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                  child: Row(children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.description_outlined,
                          size: 16),
                      label: const Text('Générer les documents'),
                      onPressed: () {
                        final motif    = motifCtrl.text.trim();
                        final eegMotif = eegMotifCtrl.text.trim();
                        final bioSangList = bioSang.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();
                        final bioUrinesList = bioUrines.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();
                        final bioLCRList = bioLCR.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();
                        final bioAutre = bioAutreCtrl.text.trim();
                        Navigator.pop(ctx2);
                        _genererDocumentsHDJ(
                          motif:       motif,
                          delai:       hdjDelai,
                          hasEEG:      hasEEG,
                          eegType:     eegType,
                          eegMotif:    eegMotif,
                          hasBio:      hasBio,
                          bioSang:     bioSangList,
                          bioUrines:   bioUrinesList,
                          bioLCR:      bioLCRList,
                          bioAutre:    bioAutre,
                        );
                      },
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _genererDocumentsHDJ({
    required String motif,
    required String delai,
    required bool   hasEEG,
    required String eegType,
    required String eegMotif,
    required bool   hasBio,
    required List<String> bioSang,
    required List<String> bioUrines,
    required List<String> bioLCR,
    required String bioAutre,
  }) async {
    final nom    = _nomEnfantController.text.trim().toUpperCase();
    final prenom = _prenomEnfantController.text.trim();
    final ddnStr = ddnEnfant != null
        ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : '';
    final ageStr = _ageConsultLabel();
    final sexeVal = sexe == 'Masculin' ? 'Masculin' : 'Féminin';
    final ddj      = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final dateFile = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final tel      = ''; // pas de champ téléphone dans ce formulaire

    final folderPath = await getDirectoryPath(nom, prenom);
    final tempDir = await getTemporaryDirectory();

    final List<String> generated = [];

    // ── Helper PS ──────────────────────────────────────────────────────────
    Future<void> genDoc({
      required String templateAsset,
      required String outputName,
      required List<List<String>> bookmarks,
      required String psFilename,
    }) async {
      final templatePath = await _getTemplatePath(templateAsset);
      final tpEsc  = templatePath.replaceAll("'", "''");
      final outPath = '$folderPath\\$outputName';
      final opEsc  = outPath.replaceAll("'", "''");

      final sb = StringBuffer();
      sb.writeln('\$word = New-Object -ComObject Word.Application');
      sb.writeln('\$word.Visible = \$false');
      sb.writeln("\$doc = \$word.Documents.Open('$tpEsc')");
      for (final bm in bookmarks) {
        sb.write(_psSetBookmark(bm[0], bm[1]));
      }
      sb.writeln('\$doc.Fields.Update()');
      sb.writeln("\$doc.SaveAs2('$opEsc', 16)");
      sb.writeln('\$doc.Close()');
      sb.writeln('\$word.Quit()');
      await _runPsScript(tempDir, psFilename, sb.toString());
      await Process.run('explorer', [outPath]);
    }

    try {
      // ── Construire le texte de la liste HDJ ───────────────────────────
      final listItems = <String>[];
      if (hasBio)  listItems.add('- un bilan biologique (à jeun)');
      if (hasEEG) {
        final typeLabel = eegType == 'Veille'
            ? 'de veille'
            : eegType == 'Veille-Sommeil'
                ? 'de veille et de sommeil avec prémédication'
                : eegType == 'Longue durée'
                    ? 'de longue durée'
                    : 'ENMG';
        listItems.add('- un EEG $typeLabel');
      }
      listItems.add(
          '- une consultation neurologique avec le Dr Kuchenbuch');
      final listeTxt =
          'La sortie aura lieu vers 17h30 après une consultation '
          'avec un neuropédiatre.\n'
          'Au cours de cette journée sera réalisé(e) :\n'
          '${listItems.join('\n')}';

      // ── Texte biologie ─────────────────────────────────────────────────
      String sangTxt = '';
      String urineTxt = '';
      String lcrTxt   = '';
      if (hasBio) {
        final allSang = [...bioSang, if (bioAutre.isNotEmpty) bioAutre];
        sangTxt  = allSang.join('\n');
        urineTxt = bioUrines.join('\n');
        lcrTxt   = bioLCR.join('\n');
      }

      // ── Prémédication EEG ──────────────────────────────────────────────
      final doseMela = _doseMelatonineEEG();
      final premedEEG = eegType == 'Veille-Sommeil'
          ? 'Mélatonine $doseMela mg — 30 min avant l\'examen'
          : '';

      // ── Type EEG pour le template ──────────────────────────────────────
      final typeEEGLabel = eegType == 'Veille'
          ? 'EEG de veille'
          : eegType == 'Veille-Sommeil'
              ? 'EEG de veille et de sommeil'
              : eegType == 'Longue durée'
                  ? 'EEG de longue durée'
                  : 'ENMG';

      // ── Bookmarks communs ──────────────────────────────────────────────
      final bmBase = <List<String>>[
        ['Nom',          nom],
        ['Prenom',       prenom],
        ['Sexe',         sexeVal],
        ['DDN',          ddnStr],
        ['Age',          ageStr],
        ['Tel',          tel],
        ['Add',          ''],
        ['Date_du_jour', ddj],
        ['Delai',        delai],
        ['Delai_HDJ',    delai],
        ['Medecin',      'Kuchenbuch'],
        ['Liste',        listeTxt],
        ['Fin',          ''],
      ];

      // ── Sélectionner le bon template ───────────────────────────────────
      final String templateFile;
      if (hasBio && hasEEG) {
        templateFile = 'Programmer une HDJ et Bio et EEG_2.docm';
      } else if (hasBio) {
        templateFile = 'Programmer une HDJ et Bio.docm';
      } else if (hasEEG) {
        templateFile = 'Programmer une HDJ et EEG.docm';
      } else {
        templateFile = 'Programmer une HDJ.docm';
      }

      final bmHDJ = <List<String>>[...bmBase];

      // Signets doublons (Nom2/Prenom2/… pour les sous-formulaires)
      if (hasEEG || hasBio) {
        bmHDJ.addAll([
          ['Nom2',    nom],
          ['Prenom2', prenom],
          ['Sexe2',   sexeVal],
          ['DDN2',    ddnStr],
          ['Age2',    ageStr],
          ['Tel2',    tel],
          ['Add2',    ''],
        ]);
      }
      if (hasBio && hasEEG) {
        bmHDJ.addAll([
          ['Nom3',    nom],
          ['Prenom3', prenom],
          ['Sexe3',   sexeVal],
          ['DDN3',    ddnStr],
          ['Age3',    ageStr],
          ['Tel3',    tel],
          ['Add3',    ''],
        ]);
      }
      if (hasEEG) {
        bmHDJ.addAll([
          ['Motif_EEG',  eegMotif.isNotEmpty ? eegMotif : motif],
          ['Type_EEG',   typeEEGLabel],
          ['Type_EEG2',  typeEEGLabel],
          ['Premed_EEG', premedEEG],
          ['TTT',        _traitementsEnCours.isNotEmpty ? _traitementsEnCours.map((t) => '\${t[\'nom\'] ?? \'\'} \${t[\'dose\'] ?? \'\'}'.trim()).join(', ') : _traitements.text.trim()],
          ['Date2',      ddj],
        ]);
      }
      if (hasBio) {
        bmHDJ.addAll([
          ['sang',       sangTxt],
          ['urine',      urineTxt],
          ['LCR',        lcrTxt],
          ['Titre_sang',  sangTxt.isNotEmpty  ? 'Bilan sanguin'       : ''],
          ['Titre_urine', urineTxt.isNotEmpty ? 'Urines'              : ''],
          ['Titre_LCR',   lcrTxt.isNotEmpty   ? 'Bilan dans le LCR'   : ''],
          ['NDA2',        ''],
          ['NIP2',        ''],
          if (hasBio && hasEEG) ...[ ['NDA',  ''], ['NIP',  ''],
                                     ['NDA3', ''], ['NIP3', ''] ],
        ]);
      }

      await genDoc(
        templateAsset: templateFile,
        outputName:    '${dateFile}_Programmer HDJ_${nom}_${prenom}.docx',
        bookmarks:     bmHDJ,
        psFilename:    'hdj_prog.ps1',
      );
      generated.add('Programmation HDJ');

      // ── Feuille de renseignements métabolique (CHRU Biochimie) ──────────
      if (hasBio) {
        final templateMetabo =
            await _getTemplatePath('Renseignements Biochimie Métabolique.doc');
        final tpMetaboEsc = templateMetabo.replaceAll("'", "''");
        final outMetabo =
            '$folderPath\\${dateFile}_Fiche renseignements métabolique_${nom}_${prenom}.docx';
        final outMetaboEsc = outMetabo.replaceAll("'", "''");

        // Poids, taille, PC avec DS/percentile depuis les courbes
        final poidsVal  = _poidsConsultCtrl.text.trim();
        final tailleVal = _tailleConsultCtrl.text.trim();
        final pcVal     = _pcConsultCtrl.text.trim();
        final _ageConsult = _calculerAgeAnsConsult();
        final _garcon     = sexe == 'Masculin';

        String poidsStr = '';
        if (poidsVal.isNotEmpty) {
          final pv = double.tryParse(poidsVal);
          if (pv != null && pv > 0) {
            final rP = AuxologieConsult.calculerDsPoids(
                poidsKg: pv, ageAns: _ageConsult, garcon: _garcon);
            final percStr = rP != null ? ' (${rP.percentileBand}e perc.)' : '';
            poidsStr = '$poidsVal kg$percStr';
          } else {
            poidsStr = '$poidsVal kg';
          }
        }

        String tailleStr = '';
        if (tailleVal.isNotEmpty) {
          final tv = double.tryParse(tailleVal);
          if (tv != null && tv > 0) {
            final rT = AuxologieConsult.calculerDsTaille(
                tailleCm: tv, ageAns: _ageConsult, garcon: _garcon);
            if (rT != null && rT.ds != null) {
              final sign = rT.ds! >= 0 ? '+' : '';
              tailleStr = '$tailleVal cm ($sign${rT.ds!.toStringAsFixed(2)} DS)';
            } else {
              tailleStr = '$tailleVal cm';
            }
          } else {
            tailleStr = '$tailleVal cm';
          }
        }

        String pcStr = '';
        if (pcVal.isNotEmpty) {
          final cv = double.tryParse(pcVal);
          if (cv != null && cv > 0) {
            final rC = AuxologieConsult.calculerDsPC(
                pcCm: cv, ageAns: _ageConsult, garcon: _garcon);
            if (rC != null && rC.ds != null) {
              final sign = rC.ds! >= 0 ? '+' : '';
              pcStr = '$pcVal cm ($sign${rC.ds!.toStringAsFixed(2)} DS)';
            } else {
              pcStr = '$pcVal cm';
            }
          } else {
            pcStr = '$pcVal cm';
          }
        }

        final sbM = StringBuffer();
        sbM.writeln(r'$word = New-Object -ComObject Word.Application');
        sbM.writeln(r'$word.Visible = $false');
        sbM.writeln("\$doc = \$word.Documents.Open('$tpMetaboEsc')");

        // ── Signets nommés (issus du VBA) ─────────────────────────────
        // Prénom / Nom du patient (signet Prnom = Prénom dans le .doc)
        for (final bmName in ['Prnom', 'Prenom']) {
          sbM.writeln(
              "if (\$doc.Bookmarks.Exists('$bmName')) { "
              "\$bm = \$doc.Bookmarks.Item('$bmName'); "
              "\$rng = \$bm.Range; "
              "\$rng.Text = '${prenom} ${nom}'.Trim(); "
              "\$doc.Bookmarks.Add('$bmName', \$rng) }");
        }
        sbM.write(_psSetBookmark('poids',  poidsStr));
        sbM.write(_psSetBookmark('taille', tailleStr));
        sbM.write(_psSetBookmark('PC',     pcStr));
        sbM.write(_psSetBookmark('Motif',  motif.replaceAll("'", "''")));

        // ── Find & Replace pour les champs sans signet ────────────────
        String fr(String find, String replace) {
          final fEsc = find.replaceAll("'", "''");
          final rEsc = replace.replaceAll("'", "''");
          return "\$doc.Content.Find.Execute('$fEsc', \$false, \$false, \$false, \$false, \$false, \$true, 1, \$true, '$rEsc', 2) | Out-Null\n";
        }
        // Date du prélèvement → aujourd'hui
        sbM.write(fr('Date :', 'Date : $ddj'));
        // Patient : Nom Prénom
        sbM.write(fr('Nom Prénom', '${prenom} ${nom}'));
        // DDN
        if (ddnStr.isNotEmpty) {
          sbM.write(fr('Date de naissance :', 'Date de naissance : $ddnStr'));
        }
        // Poids
        if (poidsStr.isNotEmpty) {
          sbM.write(fr('Poids :', 'Poids : $poidsStr'));
        }
        // Taille
        if (tailleStr.isNotEmpty) {
          sbM.write(fr('Taille :', 'Taille : $tailleStr'));
        }
        // PC avec DS
        if (pcStr.isNotEmpty) {
          sbM.write(fr('PC :', 'PC : $pcStr'));
        }

        sbM.writeln(r'$doc.Fields.Update()');
        sbM.writeln("\$doc.SaveAs2('$outMetaboEsc', 16)");
        sbM.writeln(r'$doc.Close()');
        sbM.writeln(r'$word.Quit()');

        await _runPsScript(tempDir, 'hdj_metabo.ps1', sbM.toString());
        await Process.run('explorer', [outMetabo]);
        generated.add('Fiche Biochimie Métabolique');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('HDJ : ${generated.join(' · ')} générés'),
          backgroundColor: const Color(0xFF00695C),
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur HDJ : $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
        ));
      }
    }
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // BILAN PARACLINIQUE — templates Save_bilan + dialog de sélection
  // ═══════════════════════════════════════════════════════════════════════════

  static const Map<String, List<String>> _bilanTemplates = {
    'Retard psychomoteur/Déficience intellectuelle': [
      'Neuropédiatrie',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
      'CPK', 'LDH', 'TQ-TCA-Fibrinogène',
      'Bilan énergetique pré & postprandial', 'Ac methylmalonique',
      'Ac. pristanique, phytanique et pipécolique',
      'Plasmalogènes érythrocytaires', 'Profil des acylcarnitines',
      'Acides gras à très longues chaines', 'Ammoniémie',
      'Chromatographie des acides aminés', 'Isoforme de la transferrine',
      'Bilan lipidique', 'Frottis sanguins', 'Homocystéine',
      'Bandelette urinaire', 'Chromatographie des acides organiques',
      'AICAR/SAICAR', 'Guanidino-acétate', 'Créatine', 'Créatinine',
      'FRM1', 'Purines, pyramidines', '15q11q13', 'ACPA',
    ],
    'Retard psychomoteur/DI & microcéphalie': [
      'Neuropédiatrie', 'Génétique', 'Métabolique',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
      'CPK', 'TQ-TCA-Fibrinogène',
      'Bilan énergetique pré & postprandial', 'Ac methylmalonique',
      'Ac. pristanique, phytanique et pipécolique',
      'Plasmalogènes érythrocytaires', 'Profil des acylcarnitines',
      'Acides gras à très longues chaines', 'Ammoniémie',
      'Chromatographie des acides aminés', 'Isoforme de la transferrine',
      'Chitotriosidase & keratan sulfate', 'Bilan lipidique', 'Cholestanol',
      'Frottis sanguins', 'Homocystéine',
      'Chromatographie des acides organiques', 'Acide sialique',
      'Oligo & mucopolysaccharides', 'Guanidino-acétate', 'Créatine',
      'Créatinine', 'IRM cérébrale',
      'un EEG de veille & sommeil avec prémédication',
      'FRM1', 'Purines, pyramidines', 'ACPA', 'DNAthèque',
      'sérologie CMV', 'sérologie HSV', 'sérologie syphilis',
    ],
    'Retard psychomoteur/DI + doute surcharge': [
      'Neuropédiatrie', 'Génétique', 'Métabolique',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
      'CPK', 'TQ-TCA-Fibrinogène',
      'Bilan énergetique pré & postprandial', 'Ac methylmalonique',
      'Ac. pristanique, phytanique et pipécolique',
      'Plasmalogènes érythrocytaires', 'Profil des acylcarnitines',
      'Acides gras à très longues chaines', 'Ammoniémie',
      'Chromatographie des acides aminés', 'Isoforme de la transferrine',
      'Chitotriosidase & keratan sulfate', 'Bilan lipidique', 'Cholestanol',
      'Frottis sanguins', 'Homocystéine',
      'Chromatographie des acides organiques', 'Acide sialique',
      'Oligo & mucopolysaccharides', 'AICAR/SAICAR',
      'Guanidino-acétate', 'Créatine', 'Créatinine', 'Albumine',
      'IRM cérébrale', 'un EEG de veille & sommeil avec prémédication',
      'FRM1', 'Purines, pyramidines', 'ACPA', 'DNAthèque',
      'Hexosaminidase A et B', 'sérologie CMV', 'sérologie HSV',
      'sérologie syphilis',
    ],
    'Trouble du spectre autistique': [
      'Neuropédiatrie',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
      'CPK', 'Bilan énergetique pré & postprandial', 'Ac methylmalonique',
      'Profil des acylcarnitines', 'Ammoniémie',
      'Chromatographie des acides aminés', 'Glycosylation des protéines',
      '25OHD', 'Vitamines B1, B6, B9 et B12', 'Frottis sanguins',
      'Homocystéine', 'Bandelette urinaire',
      'Chromatographie des acides organiques', 'AICAR/SAICAR',
      'FRM1', '15q11q13', 'ACPA',
    ],
    'Syndrome cérébelleux': [
      'Neuropédiatrie', 'Génétique', 'Métabolique',
      'NFS-plaquettes', 'Bilan énergetique pré & postprandial',
      'Ac. pristanique, phytanique et pipécolique',
      'Acides gras à très longues chaines', 'Ammoniémie',
      'Bilan lipidique', 'Cholestanol', 'Vitamines B1, B6, B9 et B12',
      'Frottis sanguins', 'Cuivre, coeruloplasmine', 'Homocystéine',
      'Oligo & mucopolysaccharides', 'Vitamine E', 'Alphafoetoprotéine',
      'Lyso SM509', '15q11q13', 'ACPA', 'DNAthèque',
      'Hexosaminidase A et B', 'Mannosidase A et B',
      'Galactocérébrosidase (Krabbe)', 'Arylsulfatase A',
    ],
    'Dystonie': [
      'Neuropédiatrie', 'Génétique',
    ],
    'Convulsion sans fièvre': [
      'Neuropédiatrie',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT',
      'Bilan énergetique pré & postprandial', 'Ammoniémie',
      'Chromatographie des acides aminés',
      'IRM cérébrale', 'un EEG de veille & sommeil avec prémédication',
      'DNAthèque',
    ],
    'Malaise': [
      'Neuropédiatrie', 'Cardiopédiatrique',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT',
      'Bilan énergetique pré & postprandial', 'Ammoniémie',
      'Chromatographie des acides aminés',
      'une recherche hypotension orthostatique',
      'IRM cérébrale', 'un EEG de veille & sommeil avec prémédication',
      'Toxiques urinaires', 'Troponine',
    ],
    'Pathologie inflammatoire': [
      'Neuropédiatrie', 'Ophtalmologie', 'Neuropsychologique',
      'NFS-plaquettes', 'ASAT, ALAT, Ph. alc., Gamma GT', 'T4, TSH, T3',
      '25OHD', 'Vitamines B1, B6, B9 et B12',
      'Chimie avec glycorrachie', 'Cytologie', 'Bactériologie',
      'Synthèse intrathécale', 'Vitamine E',
      'Ac anti-nucléaires', 'Ac anti-DNA natifs', 'Ac anti-neuronaux',
      'Ac anti-phospholipides', 'ANCA', 'ASCA', 'C3, C4, CH50', 'ECA',
      'Ac anti-MOG & anti-NMO', 'Ac anti TPO & Ac anti-thyroglobuline',
    ],
    'Oedème papillaire': [
      'Neuropédiatrie',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie', 'T4, TSH, T3',
      'Magnésémie', 'Frottis sanguins',
      'Chimie avec glycorrachie', 'Cytologie', 'Bactériologie',
      'PCR multiplex', 'Synthèse intrathécale',
      'Sérologie EBV', 'sérologie bartonella henselae', 'sérologie Lyme',
      'Ac anti-MOG & anti-NMO',
      'sérologie CMV', 'sérologie HSV', 'Vitamine A', 'Toxoplasmose',
      'sérologie VZV', 'Mesure de pression', 'Ferritine',
    ],
    'Paraplégie spastique': [
      'Neuropédiatrie', 'Génétique', 'Métabolique',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'CPK',
      'Bilan énergetique pré & postprandial',
      'Acides gras à très longues chaines', 'Ammoniémie',
      'Chromatographie des acides aminés', 'Isoforme de la transferrine',
      'Biotinidase', 'Bilan lipidique', 'Cholestanol',
      'Vitamines B1, B6, B9 et B12', 'Frottis sanguins',
      'Cuivre, coeruloplasmine', 'Homocystéine',
      'Bandelette urinaire', 'Chromatographie des acides organiques',
      'Chimie avec glycorrachie', 'Cytologie',
      'neurotransmetteurs', 'CAA', 'Interferon', 'Vitamine E',
      'Purines, pyramidines', 'ACPA', 'IRM cérébrale et médullaire',
    ],
    'Sclérose tubéreuse de Bourneville': [
      'Neuropédiatrie', 'Ophtalmologie',
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'T4, TSH, T3', 'CRP',
      'Echographie rénale', 'DNAthèque',
    ],
  };

  static const Map<String, List<String>> _bilanCategories = {
    'Consultations spécialisées': [
      'Neuropédiatrie', 'Génétique', 'Métabolique', 'Ophtalmologie', 'ORL',
      'Neuropsychologique', 'Kinésithérapeutique', 'Ergothérapeutique',
      'Orthophonique', 'Cardiopédiatrique', 'Pédopsychiatrique',
      'Diététique',
    ],
    'Biologie standard': [
      'NFS-plaquettes', 'Ionogramme-Calcémie-phosphorémie',
      'ASAT, ALAT, Ph. alc., Gamma GT', 'Acide urique', 'T4, TSH, T3',
      'CPK', 'LDH', 'CRP', 'VS', 'TQ-TCA-Fibrinogène',
      'Bilan lipidique', 'Magnésémie', '25OHD',
      'Vitamines B1, B6, B9 et B12', 'Frottis sanguins', 'Homocystéine',
      'Albumine', 'Ferritine', 'Vitamine A', 'Vitamine E',
      'Alphafoetoprotéine', 'Troponine',
    ],
    'Biologie métabolique': [
      'Bilan énergetique pré & postprandial', 'Ac methylmalonique',
      'Ac. pristanique, phytanique et pipécolique',
      'Plasmalogènes érythrocytaires', 'Profil des acylcarnitines',
      'Carnitine libre et totale', 'Acides gras à très longues chaines',
      'Ammoniémie', 'Chromatographie des acides aminés',
      'Glycosylation des protéines', 'Isoforme de la transferrine',
      'Biotinidase', 'Chitotriosidase & keratan sulfate', 'Cholestanol',
      'Cuivre, coeruloplasmine', 'Lyso SM509',
      'AICAR/SAICAR', 'Bioptérines', 'Guanidino-acétate',
      'Créatine', 'Créatinine', 'Purines, pyramidines',
      'Hexosaminidase A et B', 'Mannosidase A et B',
      'Galactocérébrosidase (Krabbe)', 'Arylsulfatase A',
    ],
    'Biologie urinaire': [
      'Bandelette urinaire', 'Chromatographie des acides organiques',
      'Acide sialique', 'Oligo & mucopolysaccharides',
      'Toxiques urinaires', 'Calciurie',
    ],
    'Immunologie / Auto-immun': [
      'Ac anti-nucléaires', 'Ac anti-DNA natifs', 'Ac anti-neuronaux',
      'Ac anti-phospholipides', 'Ac anti-MOG & anti-NMO',
      'ANCA', 'ASCA', 'C3, C4, CH50', 'ECA', 'ACPA',
      'Ac anti TPO & Ac anti-thyroglobuline', 'Dosage pondérale des IG',
    ],
    'Sérologies': [
      'Sérologie EBV', 'sérologie mycoplasme', 'sérologie bartonella henselae',
      'sérologie Lyme', 'sérologie CMV', 'sérologie HSV',
      'sérologie syphilis', 'sérologie VZV', 'Toxoplasmose',
      'Index de Lyme', 'Sérologie HIV',
    ],
    'Génétique moléculaire': [
      'FRM1', '15q11q13', 'Panel EPI/DI', 'Exome clinique',
      'DNAthèque', 'Panel epilepsie',
    ],
    'LCR (ponction lombaire)': [
      'Chimie avec glycorrachie', 'Cytologie', 'Bactériologie',
      'PCR multiplex', 'Lactates/pyruvates', 'neurotransmetteurs',
      'CAA', 'Interferon', 'Synthèse intrathécale', 'Mesure de pression',
    ],
    'Imagerie': [
      'IRM cérébrale', 'IRM cérébrale sous prémédication',
      'IRM cérébrale sous AG', 'IRM cérébrale et médullaire',
      'TDM cérébral', 'Echographie rénale', 'Echographie cardiaque',
      'Echographie de la thyroide', 'radio pulmonaire de face',
      'EOS', 'radio du bassin et des hanches', 'une ostéodensitométrie',
    ],
    'EEG / Neurophysiologie': [
      'un EEG de veille',
      'un EEG de veille & sommeil avec prémédication',
      'un EEG longue durée', 'un ENMG', 'une polysomnographie',
    ],
    'Autres examens': [
      'une recherche hypotension orthostatique',
      'un test au synACTHène', '1 tube à conserver',
      'un bilan biologique à compléter avec métabolicien',
    ],
  };

  void _ouvrirBilan(BuildContext context) {
    // Travailler sur une copie locale
    final Set<String> localSel = Set<String>.from(_bilanSelected);
    // Profils groupés par type
    const profileGroups = <String, List<String>>{
      'Retard psychomoteur': [
        'Retard psychomoteur/Déficience intellectuelle',
        'Retard psychomoteur/DI & microcéphalie',
        'Retard psychomoteur/DI + doute surcharge',
        'Trouble du spectre autistique',
      ],
      'Mouvements anormaux': [
        'Syndrome cérébelleux',
        'Dystonie',
        'Paraplégie spastique',
      ],
      'Épilepsie / Malaise': [
        'Convulsion sans fièvre',
        'Malaise',
      ],
      'Inflammatoire': [
        'Pathologie inflammatoire',
        'Oedème papillaire',
      ],
      'Autres': [
        'Sclérose tubéreuse de Bourneville',
      ],
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        const Color blue = Color(0xFF00599A);

        void applyProfile(String profileName) {
          final items = _bilanTemplates[profileName] ?? [];
          setS(() {
            localSel.addAll(items);
          });
        }

        Widget profileChip(String name) {
          final short = name.length > 30 ? name.substring(0, 28) + '…' : name;
          return ActionChip(
            label: Text(short, style: const TextStyle(fontSize: 11)),
            backgroundColor: Colors.indigo.shade50,
            onPressed: () => applyProfile(name),
          );
        }

        Widget catSection(String catName, List<String> items) {
          return ExpansionTile(
            dense: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(catName,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00599A))),
            children: items.map((item) {
              final sel = localSel.contains(item);
              return CheckboxListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
                title: Text(item, style: const TextStyle(fontSize: 12.5)),
                value: sel,
                activeColor: blue,
                onChanged: (v) =>
                    setS(() => v! ? localSel.add(item) : localSel.remove(item)),
              );
            }).toList(),
          );
        }

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 720,
            height: MediaQuery.of(ctx).size.height * 0.88,
            child: Column(children: [
              // ── Titre ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Row(children: [
                  const Icon(Icons.biotech_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Bilan paraclinique',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  Text('${localSel.length} item(s)',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              // ── Profils ───────────────────────────────────────────
              Container(
                color: Colors.indigo.shade50,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🪄  Appliquer un profil type',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E))),
                    const SizedBox(height: 6),
                    ...profileGroups.entries.map((group) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(
                          width: 130,
                          child: Text(group.key,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic)),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 4, runSpacing: 4,
                            children: group.value
                                .map((p) => profileChip(p))
                                .toList(),
                          ),
                        ),
                      ]),
                    )),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setS(() => localSel.clear()),
                        icon: const Icon(Icons.clear_all, size: 15),
                        label: const Text('Tout effacer', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Listes par catégorie ───────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _bilanCategories.entries
                        .map((e) => catSection(e.key, e.value))
                        .toList(),
                  ),
                ),
              ),
              // ── Boutons ───────────────────────────────────────────
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: blue),
                      icon: const Icon(Icons.check, size: 16),
                      label: Text('Appliquer (${localSel.length})'),
                      onPressed: () {
                        setState(() => _bilanSelected = Set<String>.from(localSel));
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }


  String _psEscape(String text) => text
      .replaceAll("'", "''")
      .replaceAll("\r\n", "' + [char]13 + '")
      .replaceAll("\n", "' + [char]13 + '")
      .replaceAll("\r", "");

  /// Génère l'instruction PowerShell qui remplit un signet Word.
  String _psSetBookmark(String name, String value) {
    final escaped = _psEscape(value);
    return "if (\$doc.Bookmarks.Exists('$name')) "
        "{ \$doc.Bookmarks.Item('$name').Range.Text = '$escaped' }\n";
  }

  /// Écrit un script .ps1 UTF-8-BOM et l'exécute via PowerShell.
  Future<void> _runPsScript(
      Directory tempDir, String filename, String script) async {
    final psFile = File('${tempDir.path}/$filename');
    final List<int> bom = [0xEF, 0xBB, 0xBF];
    await psFile.writeAsBytes([...bom, ...utf8.encode(script)]);
    final result = await Process.run('powershell.exe', [
      '-ExecutionPolicy', 'Bypass',
      '-NoProfile',
      '-File', psFile.path,
    ]);
    if (result.exitCode != 0) {
      throw Exception('PowerShell ($filename) : ${result.stderr}');
    }
  }

  /// Calcule la dose Buccolam (midazolam buccal) selon l'âge,
  /// et la dose Valium (diazépam rectal) selon le poids.
  String _buildDoseBuccolamTxt(double ageAns, double? poids) {
    // Dose Buccolam par âge
    final String tubeBuccolam;
    if (ageAns < 1) {
      tubeBuccolam = '2,5 mg (tube 2,5 mg)';
    } else if (ageAns < 5) {
      tubeBuccolam = '5 mg (tube 5 mg)';
    } else if (ageAns < 10) {
      tubeBuccolam = '7,5 mg (tube 7,5 mg)';
    } else {
      tubeBuccolam = '10 mg (tube 10 mg)';
    }

    // Dose Valium 0,5 mg/kg — flacon 10 mg/2 ml (concentration 5 mg/ml)
    String ligneValium = '';
    if (poids != null && poids > 0) {
      final double doseMg = 0.5 * poids;
      final double doseMl = doseMg / 5.0;
      final String mgStr = doseMg == doseMg.roundToDouble()
          ? doseMg.toInt().toString()
          : doseMg.toStringAsFixed(1);
      final String mlStr = doseMl == doseMl.roundToDouble()
          ? doseMl.toInt().toString()
          : doseMl.toStringAsFixed(1);
      ligneValium = "VALIUM\u00ae 10 mg/2 ml : $mgStr mg ($mlStr ml) par voie rectale.\n"
          "Si fièvre (T>38°C), découvrir l'enfant et donner du Doliprane. "
          "Désinfecter le flacon de Valium 10 mg/2 ml, prélever "
          "$mgStr mg ($mlStr ml), injecter par voie rectale, "
          'puis serrer les fesses. Noter l\'heure d\'administration.';
    }

    final sb = StringBuffer();
    sb.write("BUCCOLAM\u00ae (midazolam buccal) : $tubeBuccolam.\n"
        "Ouvrir le tube Buccolam. Déposer le contenu entre la joue et la gencive. "
        "Maintenir la bouche fermée 2 minutes.");
    if (ligneValium.isNotEmpty) {
      sb.write("\n\n$ligneValium");
    }
    return sb.toString();
  }

  /// Génère les documents Word PAI (Absences, Migraine, CCH, CGTC)
  /// pour chaque case cochée dans l’onglet CAT.
  // ─────────────────────────────────────────────────────────────────────────
  //  Génération demande d'imagerie + ordonnance de prémédication
  // ─────────────────────────────────────────────────────────────────────────

  /// Calcule les doses de prémédication IRM
  /// Retourne (doseMelatonine mg, doseAtarax mg, doseAtarax ml)
  (double, double, double) _calcDosesPremed() {
    final double ageAns = _calculerAgeAnsConsult();
    final double? poids = double.tryParse(_poidsConsultCtrl.text.trim());
    final double doseMel = ageAns.clamp(0, 10).roundToDouble();
    if (poids == null) return (doseMel, 0, 0);
    final double doseMg = (poids / 2).roundToDouble();
    final double doseMl = doseMg / 2; // Atarax sirop 2mg/ml
    return (doseMel, doseMg, doseMl);
  }

  Future<void> _genererDemandeEtOrdoImagerie() async {
    final bool irmPremed     = _catDEM_IRM_Premed;
    final bool irmSansPremed = _catDEM_IRM_SansPremed;
    final bool irmAG         = _catDEM_IRM_AG;

    final bool anyIRM = irmPremed || irmSansPremed || irmAG;

    if (!anyIRM) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucune demande d'imagerie sélectionnée dans la CAT."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final String nom    = _nomEnfantController.text.trim().toUpperCase();
    final String prenom = _prenomEnfantController.text.trim();
    if (nom.isEmpty || prenom.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez renseigner le nom et le prénom de l'enfant."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text("Génération des demandes en cours…"),
          ]),
          duration: Duration(seconds: 60),
          backgroundColor: Color(0xFF6A1B9A),
        ),
      );
    }

    try {
      final folderPath  = await getDirectoryPath(nom, prenom);
      final tempDir     = await getTemporaryDirectory();
      final DateTime dateRef = dateConsultation ?? DateTime.now();
      final String dateStr   = DateFormat('dd/MM/yyyy').format(dateRef);
      final String ddnStr    = ddnEnfant != null
          ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : '';
      final double ageAns    = _calculerAgeAnsConsult();
      final int ageAnsFull   = ageAns.floor();
      final int ageMoisReste = _ageM - ageAnsFull * 12;
      final String ageStr    = ageAnsFull > 0
          ? '$ageAnsFull an${ageAnsFull > 1 ? "s" : ""} et $ageMoisReste mois'
          : '$_ageM mois';
      // Les templates sont dans assets/templates/ et extraits en temp au 1er usage

      final String dateFile = DateFormat('yyyy-MM-dd').format(dateRef);
      final List<String> generated = [];

      // ── Helper PS : remplir bookmarks + find/replace ──────────────────────
      Future<void> genDoc({
        required String template,
        required String output,
        required List<List<String>> bookmarks,
        List<List<String>> findReplace = const [],
        required String psFilename,
      }) async {
        final sb = StringBuffer();
        sb.writeln('\$word = New-Object -ComObject Word.Application');
        sb.writeln('\$word.Visible = \$false');
        sb.writeln("\$doc = \$word.Documents.Open('$template')");
        for (final bm in bookmarks) {
          sb.write(_psSetBookmark(bm[0], bm[1]));
        }
        if (findReplace.isNotEmpty) {
          sb.writeln('\$sel = \$word.Selection');
          for (final fr in findReplace) {
            final ef = _psEscape(fr[0]);
            final er = _psEscape(fr[1]);
            sb.writeln("\$sel.Find.Execute('$ef', \$false, \$false, \$false, \$false, \$false, \$true, 1, \$false, '$er', 2)");
          }
        }
        // Mise à jour des champs REF (références croisées dans le document)
        sb.writeln('\$doc.Fields.Update()');
        sb.writeln("\$doc.SaveAs2('$output', 16)");
        sb.writeln('\$doc.Close()');
        sb.writeln('\$word.Quit()');
        await _runPsScript(tempDir, psFilename, sb.toString());
        await Process.run('explorer', [output]);
      }

      // ── Demande d'imagerie IRM ────────────────────────────────────────────
      if (anyIRM) {
        final String typeExamen = irmPremed
            ? "IRM cérébrale sous prémédication (ordonnance remise aux parents)"
            : irmAG
                ? "IRM cérébrale sous anesthésie générale"
                : "IRM cérébrale sans prémédication";

        await genDoc(
          template:   await _getTemplatePath('Imagerie.docx'),
          output:     '$folderPath\\${dateFile}_Demande IRM_${nom}_${prenom}.docx',
          psFilename: 'dem_imagerie.ps1',
          bookmarks: [
            ['Nom',      nom],
            ['Prenom',   prenom],
            ['ddn',      ddnStr],
            ['Age',      ageStr],
            ['genre',    sexe == 'Masculin' ? 'M' : 'F'],
            ['Poids',    _poidsConsultCtrl.text.trim()],
            ['Taille',   _tailleConsultCtrl.text.trim()],
            ['date',     dateStr],
            ['ATCD',     _atcdMedCtrl.text.trim()],
            ['Allergie', _allergiesController.text.trim()],
            ['motif',    _motifController.text.trim()],
            ['Type',     typeExamen],
          ],
        );
        generated.add('Demande IRM');

        // ── Ordonnance de prémédication ───────────────────────────────────
        if (irmPremed) {
          final (double doseMel, double doseMg, double doseMl) = _calcDosesPremed();
          final String doseMelStr = doseMel == doseMel.roundToDouble()
              ? doseMel.toInt().toString() : doseMel.toStringAsFixed(1);

          if (_catIRM_Premed100) {
            // ── Ordonnance bizone 100% ALD ──────────────────────────────
            final String doseMgStr = doseMg == doseMg.roundToDouble()
                ? doseMg.toInt().toString() : doseMg.toStringAsFixed(1);
            final String doseMlStr = doseMl % 1 == 0
                ? doseMl.toInt().toString() : doseMl.toStringAsFixed(2);
            await genDoc(
              template:   await _getTemplatePath('Ordo bizone MK.docx'),
              output:     '$folderPath\\${dateFile}_Ordo prémédication 100%_${nom}_${prenom}.docx',
              psFilename: 'ordo_bizone.ps1',
              bookmarks: [
                ['Genre',  sexe == 'Masculin' ? 'M.' : 'Mme'],
                ['Nom',    nom],
                ['Prenom', prenom],
                ['Age',    ageStr],
                ['Poids',  _poidsConsultCtrl.text.trim().isNotEmpty
                    ? '${_poidsConsultCtrl.text.trim()} kg' : ''],
                ['taille', _tailleConsultCtrl.text.trim().isNotEmpty
                    ? '${_tailleConsultCtrl.text.trim()} cm' : ''],
              ],
              findReplace: [
                [': 10 mg à donner', ': $doseMelStr mg à donner'],
                ['16,5 mg soit 8,25 ml', '$doseMgStr mg soit $doseMlStr ml'],
              ],
            );
            generated.add('Ordo prémédication 100% ALD');
          } else {
            // ── Ordonnance simple (normale) ─────────────────────────────
            await genDoc(
              template:   await _getTemplatePath('Ordo simple MK.docx'),
              output:     '$folderPath\\${dateFile}_Ordo prémédication normale_${nom}_${prenom}.docx',
              psFilename: 'ordo_simple.ps1',
              bookmarks: [
                ['Genre',  sexe == 'Masculin' ? 'M.' : 'Mme'],
                ['Nom',    nom],
                ['Prenom', prenom],
                ['DDN',    ddnStr],
                ['Age',    ageStr],
                ['Poids',  _poidsConsultCtrl.text.trim()],
                ['Taille', _tailleConsultCtrl.text.trim()],
              ],
              findReplace: [
                [': 2 mg à donner', ': $doseMelStr mg à donner'],
              ],
            );
            generated.add('Ordo prémédication normale');
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✓ Générés : ${generated.join(', ')}'),
          backgroundColor: const Color(0xFF6A1B9A),
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      debugPrint('Erreur génération imagerie : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Génère la demande d'EEG (veille ou veille+sommeil)
  Future<void> _genererDemandeEEG() async {
    try {
      final bool veilleSommeil = _catDEM_EEG_VeilleSommeil;

      final String nom    = _nomEnfantController.text.trim().toUpperCase();
      final String prenom = _prenomEnfantController.text.trim();
      final DateTime dateRef = dateConsultation ?? DateTime.now();
      final String dateFich  = DateFormat('yyyy-MM-dd').format(dateRef);
      final String ddnStr    = ddnEnfant != null
          ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : '';
      final double ageAns = ddnEnfant != null
          ? dateRef.difference(ddnEnfant!).inDays / 365.25 : 0;
      final int ans      = ageAns.floor();
      final int moisRem  = ((ageAns - ans) * 12).round();
      final String ageStr = ans == 0
          ? '$moisRem mois'
          : (moisRem == 0
              ? '$ans an${ans > 1 ? "s" : ""}'
              : '$ans an${ans > 1 ? "s" : ""} et $moisRem mois');
      final String sexeStr = sexe == 'Masculin' ? 'Masculin' : 'Féminin';
      final String tttStr  = _buildTraitementsText();

      final templatePath = await _getTemplatePath('EEG_demande.docx');
      final folderPath   = await getDirectoryPath(nom, prenom);
      final String typeLabel = veilleSommeil ? 'Veille-Sommeil' : 'Veille';
      final String outputPath =
          '$folderPath\\${dateFich}_Demande EEG ${typeLabel}_${nom}_${prenom}.docx';
      final tempDir = await getTemporaryDirectory();

      final sb = StringBuffer();
      sb.writeln('\$word = New-Object -ComObject Word.Application');
      sb.writeln('\$word.Visible = \$false');
      sb.writeln("\$doc = \$word.Documents.Open('$templatePath')");

      void bm(String name, String value) =>
          sb.write(_psSetBookmark(name, value));

      bm('Prenom', prenom);
      bm('Nom',    nom);
      bm('Sexe',   sexeStr);
      bm('ddn',    ddnStr);
      bm('age',    ageStr);
      bm('NIP',    '');
      bm('NDA',    '');
      bm('Add',    '');
      bm('Tel',    '');
      bm('Id_med', '');
      bm('TTT',    tttStr.isEmpty ? 'Aucun' : tttStr);
      bm('Motif',  _motifController.text.trim());

      // Cocher le bon type d'enregistrement et la préparation via contrôles ActiveX
      // OptionButton81 = Veille, OptionButton91 = Veille+Sommeil
      // OptionButton71 = Rien (préparation), OptionButton111 = Mélatonine (si besoin selon le protocole)
      sb.writeln(r'$doc.InlineShapes | ForEach-Object {');
      sb.writeln(r'    try {');
      sb.writeln(r'        $ctrl = $_.OLEFormat.Object');
      sb.writeln(r'        switch ($ctrl.Name) {');
      if (veilleSommeil) {
        sb.writeln(r"            'OptionButton81'  { $ctrl.Value = $false }");  // Veille
        sb.writeln(r"            'OptionButton91'  { $ctrl.Value = $true  }");  // Veille+Sommeil
        sb.writeln(r"            'OptionButton101' { $ctrl.Value = $false }");  // 24h
        sb.writeln(r"            'OptionButton71'  { $ctrl.Value = $false }");  // Rien
        sb.writeln(r"            'OptionButton111' { $ctrl.Value = $true  }");  // Mélatonine
      } else {
        sb.writeln(r"            'OptionButton81'  { $ctrl.Value = $true  }");  // Veille
        sb.writeln(r"            'OptionButton91'  { $ctrl.Value = $false }");  // Veille+Sommeil
        sb.writeln(r"            'OptionButton101' { $ctrl.Value = $false }");  // 24h
        sb.writeln(r"            'OptionButton71'  { $ctrl.Value = $true  }");  // Rien
        sb.writeln(r"            'OptionButton111' { $ctrl.Value = $false }");  // Mélatonine
      }
      sb.writeln(r'        }');
      sb.writeln(r'    } catch {}');
      sb.writeln(r'}');

      sb.writeln("\$doc.SaveAs2('$outputPath', 16)");
      // Laisser le document ouvert et Word visible
      sb.writeln('\$word.Visible = \$true');

      await _runPsScript(tempDir, 'gen_eeg.ps1', sb.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Demande EEG $typeLabel générée'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur EEG : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur EEG : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Génère la demande de TEP
  Future<void> _genererDemandeTEP() async {
    try {
      final String nom    = _nomEnfantController.text.trim().toUpperCase();
      final String prenom = _prenomEnfantController.text.trim();
      final DateTime dateRef = dateConsultation ?? DateTime.now();
      final String dateFich  = DateFormat('yyyy-MM-dd').format(dateRef);
      final String dateStr   = DateFormat('dd/MM/yyyy').format(dateRef);
      final String ddnStr    = ddnEnfant != null
          ? DateFormat('dd/MM/yyyy').format(ddnEnfant!) : '';
      final String poidsStr  = _poidsConsultCtrl.text.trim();
      final String tailleStr = _tailleConsultCtrl.text.trim();

      final templatePath = await _getTemplatePath('Demande TEP.docx');
      final folderPath   = await getDirectoryPath(nom, prenom);
      final String outputPath =
          '$folderPath\\${dateFich}_Demande de TEP_${nom}_${prenom}.docx';
      final tempDir = await getTemporaryDirectory();

      final sb = StringBuffer();
      sb.writeln('\$word = New-Object -ComObject Word.Application');
      sb.writeln('\$word.Visible = \$false');
      sb.writeln("\$doc = \$word.Documents.Open('$templatePath')");

      void bm(String name, String value) =>
          sb.write(_psSetBookmark(name, value));

      bm('ddj',    dateStr);
      bm('Nom',    nom);
      bm('Prenom', prenom);
      bm('ddn',    ddnStr);
      bm('add',    '');
      bm('tel',    '');
      bm('mail',   '');
      bm('Poids',  poidsStr);
      bm('Taille', tailleStr);
      bm('Motif',  _motifController.text.trim());

      sb.writeln("\$doc.SaveAs2('$outputPath', 16)");
      // Laisser le document ouvert et Word visible
      sb.writeln('\$word.Visible = \$true');

      await _runPsScript(tempDir, 'gen_tep.ps1', sb.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Demande de TEP générée'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur TEP : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur TEP : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Génère tous les documents CAT : PAI + imagerie/ordonnances + EEG + TEP
  Future<void> _genererTousDocuments() async {
    final bool anyPAI = _catPAI_Absences || _catPAI_CGTC || _catPAI_CCH || _catPAI_Migraine;
    final bool anyIRM = _catDEM_IRM_AG || _catDEM_IRM_Premed || _catDEM_IRM_SansPremed;
    final bool anyEEG = _catDEM_EEG_Veille || _catDEM_EEG_VeilleSommeil;
    final bool anyTEP = _catDEM_TEP;

    if (!anyPAI && !anyIRM && !anyEEG && !anyTEP) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun document sélectionné (PAI, imagerie, EEG ou TEP).'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    if (anyPAI) await _genererDocumentsWordPAI();
    if (anyIRM) await _genererDemandeEtOrdoImagerie();
    if (anyEEG) await _genererDemandeEEG();
    if (anyTEP) await _genererDemandeTEP();
  }

  Future<void> _genererDocumentsWordPAI() async {
    final bool anyPAI =
        _catPAI_Absences || _catPAI_CGTC || _catPAI_CCH || _catPAI_Migraine;
    if (!anyPAI) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucun PAI sélectionné. Cochez au moins un PAI."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final String nom    = _nomEnfantController.text.trim().toUpperCase();
    final String prenom = _prenomEnfantController.text.trim();
    if (nom.isEmpty || prenom.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Veuillez renseigner le nom et le prénom de l'enfant."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Indicateur de progression
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Génération des PAI en cours…'),
          ]),
          duration: Duration(seconds: 60),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }

    try {
      final folderPath = await getDirectoryPath(nom, prenom);
      final tempDir    = await getTemporaryDirectory();
      final double ageAns = _calculerAgeAnsConsult();
      final double? poids = double.tryParse(_poidsConsultCtrl.text.trim());
      final DateTime dateRef = dateConsultation ?? DateTime.now();
      final String dateAujourd =
          DateFormat('dd/MM/yyyy').format(dateRef);
      final String dateFile = DateFormat('yyyy-MM-dd').format(dateRef);
      final String dateFinValidite = DateFormat('dd/MM/yyyy').format(
          DateTime(dateRef.year + 1, dateRef.month, dateRef.day));
      final String ddnStr = ddnEnfant != null
          ? DateFormat('dd/MM/yyyy').format(ddnEnfant!)
          : '';
      final String poidsStr = poids != null
          ? '${poids.toStringAsFixed(1)} kg'
          : '(poids non renseigné)';

      // Âge lisible
      final int ageMoisTotal = _ageM;
      final int ageAnsFull   = ageAns.floor();
      final int ageMoisReste = ageMoisTotal - ageAnsFull * 12;
      final String ageStr = ageAnsFull > 0
          ? '$ageAnsFull an${ageAnsFull > 1 ? "s" : ""} et $ageMoisReste mois'
          : '$ageMoisTotal mois';

      // Les templates PAI sont dans assets/templates/ (extraits en temp au 1er usage)

      // Helper local : construit le script PS1 et le lance
      Future<void> genDoc({
        required String template,
        required String output,
        required List<List<String>> bookmarks,
        required String psFilename,
      }) async {
        final sb = StringBuffer();
        sb.writeln(r'$word = New-Object -ComObject Word.Application');
        sb.writeln(r'$word.Visible = $false');
        sb.writeln("\$doc = \$word.Documents.Open('$template')");
        for (final bm in bookmarks) {
          sb.write(_psSetBookmark(bm[0], bm[1]));
        }
        // Mise à jour des champs REF (références croisées dans le document)
        sb.writeln(r'$doc.Fields.Update()');
        sb.writeln("\$doc.SaveAs2('$output', 16)");
        sb.writeln(r'$doc.Close()');
        sb.writeln(r'$word.Quit()');
        await _runPsScript(tempDir, psFilename, sb.toString());
        await Process.run('explorer', [output]);
      }

      final List<String> generated = [];

      // PAI Absences
      if (_catPAI_Absences) {
        await genDoc(
          template:   await _getTemplatePath('PAI absences MK.doc'),
          output:     '$folderPath\\${dateFile}_PAI absences_${nom}_${prenom}.docx',
          psFilename: 'pai_absences.ps1',
          bookmarks: [
            ['Prénom', prenom],
            ['Nom',    nom],
            ['Genre',  sexe == 'Masculin' ? 'né' : 'née'],
            ['Ddn',    ddnStr],
            ['Age',    ageStr],
            ['Date',   dateAujourd],
          ],
        );
        generated.add('PAI Absences');
      }

      // PAI Migraine
      if (_catPAI_Migraine) {
        final String doseIbu;
        if (poids == null) {
          doseIbu = '?? (poids non renseigné)';
        } else if (poids < 20) {
          doseIbu = "sirop d'ibuprofène";
        } else if (poids < 30) {
          doseIbu = '200 mg';
        } else if (poids < 40) {
          doseIbu = '300 mg';
        } else {
          doseIbu = '400 mg';
        }
        // Triptan (sumatriptan) autorisé dès 12 ans
        final String triptanTxt = ageAns >= 12
            ? 'Imigrane® 50 mg (sumatriptan) : 1 comprimé, '
              'à renouveler 1 fois si douleur persistante après 2 h'
            : '';
        await genDoc(
          template:   await _getTemplatePath('PAImigraineMK 2.docx'),
          output:     '$folderPath\\${dateFile}_PAI migraine_${nom}_${prenom}.docx',
          psFilename: 'pai_migraine.ps1',
          bookmarks: [
            ['Nom',      nom],
            ['Prénom',   prenom],
            ['ddn',      ddnStr],
            ['DDJ',      dateAujourd],
            ['DDJ_2',    dateFinValidite],
            ['Poids',    poidsStr],
            ['dose_ibu', doseIbu],
            ['triptan',  triptanTxt],
          ],
        );
        generated.add('PAI Migraine');
      }

      // PAI CCH
      if (_catPAI_CCH) {
        final String doseTxt = _buildDoseBuccolamTxt(ageAns, poids);
        await genDoc(
          template:   await _getTemplatePath('PAI CCH MK.doc'),
          output:     '$folderPath\\${dateFile}_PAI CCH_${nom}_${prenom}.docx',
          psFilename: 'pai_cch.ps1',
          bookmarks: [
            ['Nom',           nom],
            ['Prénom',        prenom],
            ['ddn',           ddnStr],
            ['DDJ',           dateAujourd],
            ['DDJ_2',         dateFinValidite],
            ['Dose_buccolam', doseTxt],
          ],
        );
        generated.add('PAI CCH');
      }

      // PAI CGTC
      if (_catPAI_CGTC) {
        final String doseTxt = _buildDoseBuccolamTxt(ageAns, poids);
        await genDoc(
          template:   await _getTemplatePath('PAI epilepsie buccolam MK 2.doc'),
          output:     '$folderPath\\${dateFile}_PAI épilepsie_${nom}_${prenom}.docx',
          psFilename: 'pai_cgtc.ps1',
          bookmarks: [
            ['Nom',           nom],
            ['Prénom',        prenom],
            ['ddn',           ddnStr],
            ['DDJ',           dateAujourd],
            ['DDJ_2',         dateFinValidite],
            ['Age',           ageStr],
            ['Poids',         poidsStr],
            ['Dose_buccolam', doseTxt],
          ],
        );
        generated.add('PAI CGTC');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✓ PAI générés : ${generated.join(', ')}'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      debugPrint('Erreur génération PAI : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur PAI : $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Dialog Brochures (Userform7)
  // ─────────────────────────────────────────────────────────────────────────

  /// Catalogue des brochures intégrées dans les assets.
  /// Clé = nom d'affichage, valeur = chemin asset sans 'assets/brochures/'.
  static const Map<String, String> _brochuresCatalog = {
    'Brochure et accords de soins': 'Brochure_et_accords',
    'Échelles d\'évaluation':       'Echelles',
    'Épilepsie':                    'Epilepsie',
    'Génétique':                    'Genetique',
    'MDPH':                         'MDPH',
    'Migraine':                     'Migraine',
    'Sommeil et TSA':               'Sommeil_TSA',
    'TDAH':                         'TDAH',
  };

  /// Extrait un PDF bundlé vers le dossier temp et retourne son chemin.
  Future<String> _getBrochurePath(String assetPath) async {
    final tempDir = await getTemporaryDirectory();
    final dest = File('${tempDir.path}\\neuro_brochures\\$assetPath');
    if (!await dest.exists()) {
      await dest.parent.create(recursive: true);
      final data = await rootBundle.load('assets/brochures/$assetPath');
      await dest.writeAsBytes(data.buffer.asUint8List());
    }
    return dest.path;
  }

  /// Charge la liste des fichiers PDF dans un dossier asset donné
  /// en utilisant le manifest de l'application.
  // ignore: unused_element
  Future<List<String>> _listBrochureAssets(String folderKey) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final prefix = 'assets/brochures/$folderKey/';
    return manifest
        .listAssets()
        .where((key) => key.startsWith(prefix) && key.endsWith('.pdf'))
        .map((key) => key.replaceFirst('assets/brochures/', ''))
        .toList()
      ..sort();
  }

  void _ouvrirBrochures(BuildContext context) async {
    const Color headerColor = Color(0xFF00599A);

    // ── Charger le catalogue depuis AssetManifest ──────────────────────────
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    // Structure : { nomAffichage → [ 'FolderKey/fichier.pdf', ... ] }
    final Map<String, List<String>> structure = {};

    for (final entry in _brochuresCatalog.entries) {
      final displayName = entry.key;
      final folderKey   = entry.value;
      final prefix = 'assets/brochures/$folderKey/';
      final files = allAssets
          .where((key) => key.startsWith(prefix) && key.endsWith('.pdf'))
          .map((key) => key.replaceFirst('assets/brochures/', ''))
          .toList()
        ..sort();
      if (files.isNotEmpty) structure[displayName] = files;
    }

    if (!context.mounted) return;

    if (structure.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Aucune brochure trouvée dans les assets.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    // ── État du dialog ─────────────────────────────────────────────────────
    final Map<String, bool> selected = {
      for (final files in structure.values)
        for (final f in files) f: false,
    };
    final Set<String> expanded = {};

    IconData _catIcon(String name) {
      final n = name.toLowerCase();
      if (n.contains('épilepsie') || n.contains('epilepsie'))
        return Icons.bolt_outlined;
      if (n.contains('tdah'))   return Icons.psychology_alt_outlined;
      if (n.contains('tsa') || n.contains('sommeil'))
        return Icons.bedtime_outlined;
      if (n.contains('migraine')) return Icons.sick_outlined;
      if (n.contains('mdph'))   return Icons.accessibility_new_outlined;
      if (n.contains('généti') || n.contains('geneti'))
        return Icons.biotech_outlined;
      if (n.contains('brochure') || n.contains('accord'))
        return Icons.medication_outlined;
      if (n.contains('échelle') || n.contains('evaluation'))
        return Icons.assignment_outlined;
      return Icons.folder_outlined;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlg) {
          final int totalSel =
              selected.values.where((v) => v).length;

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── En-tête ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                  decoration: const BoxDecoration(
                    color: headerColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.menu_book_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Brochures & Documents',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx2),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ]),
                ),

                // ── Corps scrollable ─────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: structure.entries.map((entry) {
                        final catName = entry.key;
                        final files   = entry.value;
                        final catSel  = files
                            .where((f) => selected[f] == true)
                            .length;
                        final isOpen  = expanded.contains(catName);

                        return Column(children: [
                          // Titre de catégorie
                          InkWell(
                            onTap: () => setDlg(() => isOpen
                                ? expanded.remove(catName)
                                : expanded.add(catName)),
                            child: Container(
                              color: Colors.grey.shade100,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              child: Row(children: [
                                Icon(_catIcon(catName),
                                    size: 16, color: headerColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(catName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: headerColor)),
                                ),
                                if (catSel > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: headerColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text('$catSel',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                const SizedBox(width: 4),
                                Icon(
                                    isOpen
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 18,
                                    color: Colors.grey.shade600),
                              ]),
                            ),
                          ),
                          // Liste de PDFs
                          if (isOpen)
                            ...files.map((assetRelPath) {
                              final fileName =
                                  assetRelPath.split('/').last;
                              final label = fileName.endsWith('.pdf')
                                  ? fileName.substring(
                                      0, fileName.length - 4)
                                  : fileName;
                              return InkWell(
                                onTap: () => setDlg(() =>
                                    selected[assetRelPath] =
                                        !(selected[assetRelPath] ?? false)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 1),
                                  child: Row(children: [
                                    Checkbox(
                                      value:
                                          selected[assetRelPath] ?? false,
                                      onChanged: (v) => setDlg(() =>
                                          selected[assetRelPath] =
                                              v ?? false),
                                      activeColor: headerColor,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Expanded(
                                      child: Text(label,
                                          style: const TextStyle(
                                              fontSize: 12.5)),
                                    ),
                                  ]),
                                ),
                              );
                            }),
                          const Divider(height: 1),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),

                // ── Pied de page ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  child: Row(children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text('Fermer'),
                    ),
                    const Spacer(),
                    if (totalSel > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '$totalSel sélectionné${totalSel > 1 ? "s" : ""}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600),
                        ),
                      ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: headerColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Ouvrir la sélection'),
                      onPressed: totalSel == 0
                          ? null
                          : () async {
                              // Collecter les noms avant de fermer
                              final toOpen = selected.entries
                                  .where((e) => e.value)
                                  .map((e) => e.key)
                                  .toList();
                              final names = toOpen.map((p) {
                                final fn = p.split('/').last;
                                return fn.endsWith('.pdf')
                                    ? fn.substring(0, fn.length - 4)
                                    : fn;
                              }).toList();

                              Navigator.pop(ctx2);

                              // Extraire les PDFs des assets et les ouvrir
                              for (final assetRelPath in toOpen) {
                                try {
                                  final localPath =
                                      await _getBrochurePath(assetRelPath);
                                  await Process.run(
                                      'cmd', ['/c', 'start', '', localPath]);
                                } catch (_) {}
                              }

                              // Mettre à jour la liste des brochures remises
                              if (mounted) {
                                setState(() {
                                  for (final n in names) {
                                    if (!_brochuresRemises.contains(n)) {
                                      _brochuresRemises.add(n);
                                    }
                                  }
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '${toOpen.length} document'
                                      '${toOpen.length > 1 ? "s" : ""}'
                                      ' ouvert'
                                      '${toOpen.length > 1 ? "s" : ""}'),
                                  backgroundColor: headerColor,
                                  duration: const Duration(seconds: 3),
                                ));
                              }
                            },
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Dialogue de sélection patient avec recherche en temps réel
// ═══════════════════════════════════════════════════════════════════════════

class _PatientPickerDialog extends StatefulWidget {
  final List<Map<String, dynamic>> patients;
  const _PatientPickerDialog({required this.patients});

  @override
  State<_PatientPickerDialog> createState() => _PatientPickerDialogState();
}

class _PatientPickerDialogState extends State<_PatientPickerDialog> {
  final _searchCtrl = TextEditingController();
  late List<Map<String, dynamic>> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.patients);
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.of(widget.patients)
          : widget.patients.where((p) {
              final full = '${p['prenom']} ${p['nom']}'.toLowerCase();
              return full.contains(q);
            }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_search, color: Colors.teal),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Charger un patient',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(
            '${_filtered.length} / ${widget.patients.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            // ── Champ de recherche ──────────────────────────────────
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou prénom…',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: _searchCtrl.clear,
                      )
                    : null,
                filled: true,
                                fillColor: Colors.teal.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── Liste patients ──────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(
                      child: Text('Aucun patient trouvé.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 56),
                      itemBuilder: (_, i) {
                        final p = _filtered[i];
                        final initial =
                            (p['prenom'] as String).isNotEmpty
                                ? (p['prenom'] as String)[0].toUpperCase()
                                : '?';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Text(initial,
                                style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(
                            '${p['prenom']} ${p['nom']}'.trim(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                              'Dernière sauvegarde : ${p['date']}',
                              style: const TextStyle(fontSize: 11.5)),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.teal),
                          onTap: () => Navigator.pop(
                              context, p['data'] as Map<String, dynamic>),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
