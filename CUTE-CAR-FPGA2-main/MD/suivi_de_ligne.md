# Automate de suivi de ligne

## Objectif

L'objectif de cette seance est de concevoir et d'implementer un automate VHDL permettant au robot de suivre une ligne noire de maniere autonome.

Fonctionnalites attendues :

- L'automate attend que `start_SL = 1` pour demarrer le suivi de ligne.
- Si la ligne n'est plus detectee, le robot s'arrete et active `fin_SL = 1`.
- Les signaux `start_SL` et `fin_SL` sont affiches sur les LEDs pendant l'experimentation.

---

## Principe general

Le suivi de ligne repose sur deux volets complementaires :

- Correction sur trajectoire rectiligne.
- Correction en virage.

Le coeur du calcul est la variable `pos_ligne`, qui represente la position de la ligne noire par rapport au centre du robot.

---

## Volet 1 - Correction sur trajectoire rectiligne

### Estimation de la position de la ligne

La position est calculee a partir des capteurs qui voient la ligne noire :

- `PPU` : index du premier capteur actif.
- `PDU` : index du dernier capteur actif.

Formule utilisee :

```text
pos_ligne = PPU + PDU - 6
```

Interpretation :

- `pos_ligne = 0` : robot centre sur la ligne.
- `pos_ligne > 0` : ligne decalee d'un cote, correction a appliquer.
- `pos_ligne < 0` : ligne decalee de l'autre cote, correction inverse.

### Correction des moteurs

Les consignes moteurs sont corrigees autour d'une vitesse moyenne `VitMoy` :

```text
VitMotD = VitMoy + pos_ligne * K
VitMotG = VitMoy - pos_ligne * K
```

Avec :

- `K` : gain de correction (reglage type PID selon votre implementation).
- `VitMotD` : consigne moteur droit.
- `VitMotG` : consigne moteur gauche.

Cette loi permet de recentrer le robot en continu lorsque la trajectoire est globalement rectiligne.

---

## Volet 2 - Correction en virage

Quand la ligne forme un virage, la repartition des capteurs actifs change. L'automate detecte alors un motif de virage pour adapter la commande.

### Detection d'un virage a droite

Condition :

```text
PPU = 3 et PDU >= 5
```

### Detection d'un virage a gauche

Condition :

```text
PPU = 0 et PDU >= 2
```

### Action en virage

Pour tourner efficacement, les roues peuvent etre commandees en sens oppose (rotation plus marquee), ce qui aide le robot a suivre des courbes serrees sans perdre la ligne.

---

## Gestion de la perte de ligne

Si aucun capteur ne detecte la ligne noire :

- Le robot arrete les moteurs.
- Le signal `fin_SL` est positionne a `1`.

Ce signal peut ensuite etre reutilise pour declencher un autre automate (exemple : rotation sur place pour rechercher la ligne).

---

## Resume de fonctionnement

1. Attente de `start_SL = 1`.
2. Lecture des capteurs et calcul de `pos_ligne`.
3. Application de la correction moteur (ligne droite ou virage).
4. Surveillance de la presence de ligne.
5. En cas de perte de ligne : arret + `fin_SL = 1`.

Ce decoupage permet un suivi de ligne robuste, lisible et facilement integrable avec les autres automates du projet.
