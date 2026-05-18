# Automate de rotation sur place

## Objectif

L'objectif de cette seance est de decrire en VHDL un automate permettant au robot de pivoter sur lui-meme lorsqu'il perd la ligne noire. L'automate maintient la rotation jusqu'a ce que la ligne soit retrouvee et que le robot soit recentre.

Cet automate est concu pour fonctionner en complement de l'automate de suivi de ligne :

- Le suivi de ligne s'arrete quand la ligne n'est plus detectee et active `fin_SL`.
- Le signal `fin_SL` sert au superviseur (code C) pour autoriser le lancement de la rotation.

---

## Fonctionnement attendu

L'automate de rotation doit :

- Attendre un ordre de demarrage `start_rot = 1`.
- Tourner sur place dans le sens indique par `dir_rot` (gauche ou droite).
- Continuer a tourner tant que la ligne n'est pas recentree.
- S'arreter automatiquement quand la ligne est retrouvee au centre.
- Activer `fin_rot = 1` pour signaler la fin de la rotation.

---

## Entrées et sorties

### Entrées

| Signal           | Description                                              |
|------------------|-----------------------------------------------------------|
| `clk`            | Horloge du système                                       |
| `rst`            | Remise à zéro active à 0                                 |
| `start_rot`      | Signal de démarrage de la rotation                       |
| `dir_rot`        | Sens de rotation : `0` = gauche / `1` = droite           |
| `posLigne`       | Position estimée de la ligne par rapport au centre       |

### Sorties

| Signal           | Description               |
|------------------|----------------------------|
| `fin_rot`        | Indique la fin de rotation |
| `CmdLR_rot`      | Commande concaténée des deux moteurs (28 bits) |

---

## Format des commandes moteur

Les commandes moteur sont codées sur **14 bits** :

| Bits      | Signification                              |
|-----------|--------------------------------------------|
| Bit 13    | `1` = moteur actif / `0` = moteur arrêté   |
| Bit 12    | `0` = sens avant / `1` = sens arrière      |
| Bits 11–0 | Vitesse PWM                                |

**Exemples :**

```
"10" & vitesse  →  moteur actif, sens avant,   vitesse donnée
"11" & vitesse  →  moteur actif, sens arrière, vitesse donnée
```

---

## Principe général

Quand l'automate démarre, le robot tourne sur lui-même en commandant les deux roues en sens opposé — l'une vers l'avant, l'autre vers l'arrière — ce qui lui permet de pivoter sur place sans avancer.

L'automate surveille en permanence la valeur de `posLigne`.

Lorsque `posLigne = 0`, la rotation s'arrete et `fin_rot` est active.

---

## Structure de l'automate

L'automate comporte **3 états** :

```
R0_ATTENTE  →  R1_ROTATION  →  R2_FIN
```

---

### État `R0_ATTENTE`

**Rôle :** Attente du démarrage. Le robot reste immobile.

**Actions :**

- `fin_rot = 0`
- Moteurs arrêtés (commandes nulles)

**Transition :**

```
Si start_rot = 1  →  passer à R1_ROTATION
```

---

### État `R1_ROTATION`

**Rôle :** Rotation sur place dans le sens imposé par `dir_rot`.

---

#### Cas 1 — Ligne retrouvée près du centre

**Condition d'arret :**

```
posLigne = 0
```

**Actions :**

- Moteurs arrêtés
- `fin_rot = 1`
- Passage à l'état `R2_FIN`

---

#### Cas 2 — Ligne non recentrée → poursuite de la rotation

| `dir_rot` | Roue droite    | Roue gauche    | Effet              |
|-----------|----------------|----------------|--------------------|
| `0`       | Avant          | Arrière        | Rotation à gauche  |
| `1`       | Arrière        | Avant          | Rotation à droite  |

---

### État `R2_FIN`

**Rôle :** Fin de la rotation.

**Actions :**

- `fin_rot = 1`
- Moteurs arrêtés (commandes nulles)

**Transition :**

```
Tant que start_rot = 1  →  rester dans R2_FIN
Si start_rot = 0        →  retour à R0_ATTENTE
```

> Cela évite un redémarrage automatique immédiat : il faut relâcher le signal de départ avant de pouvoir relancer une nouvelle rotation.

---

## Vitesse de rotation

La vitesse de rotation est fixée par une constante :

```
VROT = 1600   (valeur PWM envoyée aux moteurs)
```

Elle doit être choisie de manière à obtenir une rotation :

- Assez rapide pour retrouver la ligne
- Pas trop rapide pour éviter de dépasser brutalement le centre

Une saturation est appliquée pour garantir que la vitesse reste dans l'intervalle autorisé :

```
0  ≤  vitesse  ≤  PWM_MAX
```

---

## Enchaînement avec le suivi de ligne

Cet automate s'utilise directement en complément de l'automate de suivi de ligne :

```
Robot suit la ligne  (automate de suivi)
        ↓
  Perte de la ligne  →  fin_SL = 1
        ↓
  Rotation démarre   →  start_rot ← fin_SL
        ↓
  Ligne retrouvée au centre  →  fin_rot = 1
```

---

## Coordination avec le code C

Dans le code C de supervision, les signaux `FIN_SL` et `FIN_ROT` sont surveilles en continu.

Selon leurs valeurs, le programme active l'automate approprie :

- `START_SL` est active pour lancer (ou relancer) le suivi de ligne.
- `START_ROT` est active pour lancer la rotation lorsque la ligne est perdue.

Ainsi, la sequence globale est la suivante :

1. Suivi actif tant que la ligne est detectee.
2. Si perte de ligne : `FIN_SL = 1`, puis lancement de la rotation (`START_ROT = 1`).
3. Quand le robot se recentre : `FIN_ROT = 1`, arret de la rotation et retour au suivi de ligne.