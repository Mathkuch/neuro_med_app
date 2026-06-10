# Neuro Consult — App Médecin

Application Flutter destinée aux médecins du service de neurologie pédiatrique (CHRU).

## Démo en ligne

👉 [Ouvrir la démo](https://YOUR_GITHUB_USERNAME.github.io/neuro_med_app/)

> Remplacer `YOUR_GITHUB_USERNAME` par votre nom d'utilisateur GitHub.

## Fonctionnalités

- Questionnaire médecin et examen clinique neurologique
- Auxologie : courbes de croissance (naissance et consultation)
- Scanner QR code patient (via caméra)
- Génération de documents DOCX
- Accès aux brochures par catégorie (épilepsie, migraine, TDAH, TSA, génétique, MDPH…)

## Stack

- Flutter 3.32+ / Dart 3.11+
- `qr_flutter`, `mobile_scanner`, `encrypt`, `docx_template`, `file_picker`, `intl`

## Lancer en local

```bash
flutter pub get
flutter run -d chrome
```

## Build web

```bash
flutter build web --release
```

> ⚠️ Certaines fonctionnalités (ouverture native de fichiers, accès au système de fichiers) sont limitées sur le web par rapport aux versions mobiles/desktop.
