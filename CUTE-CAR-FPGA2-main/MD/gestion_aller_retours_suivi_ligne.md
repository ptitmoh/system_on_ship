# Gestion des aller-retours avec suivi de ligne et rotation complete

## Objectif de la seance

Cette seance vise a mettre en place une strategie de deplacement cyclique du robot, supervisee par le processeur NIOS. Le principe est d'alterner automatiquement :

- une phase de suivi de ligne,
- puis une phase de rotation sur place lorsque la ligne est perdue.

Le systeme doit rester stable, lisible et repetable d'un cycle a l'autre.

---

## Scenario fonctionnel attendu

Le comportement global est le suivant :

1. Au demarrage, le robot reste a l'arret tant que la ligne noire n'est pas validee.
2. Des que la ligne est detectee, la phase de suivi est activee.
3. Si `fin_SL` passe a `1`, la phase de suivi se termine, le robot marque une pause de 1 seconde, puis passe en rotation.
4. La rotation se poursuit tant que `fin_rot = 0`.
5. Quand `fin_rot` passe a `1`, le robot s'arrete 1 seconde, puis relance un nouveau cycle de suivi.

---

## Architecture de commande

La commande est repartie sur deux niveaux :

- Niveau VHDL : automate a 4 etats qui sequence les modes moteurs.
- Niveau C (NIOS) : supervision des signaux d'etat et activation des blocs de suivi/rotation.

Cette separation permet de garder un automate materiel simple, tout en conservant une logique de pilotage flexible cote logiciel.

---

## Automate VHDL a 4 etats

### Etat S0 - Initialisation / attente de ligne

L'automate verifie `PosLigne`.

- Si `PosLigne` est hors plage utile (par exemple en dehors de [-6, +6]), la ligne est consideree absente et l'automate reste en attente.
- Si `PosLigne` devient coherent avec une detection de ligne, le signal `START` est active puis l'automate passe en `S1`.

### Etat S1 - Mode suivi de ligne

Les commandes moteurs proviennent du bloc de suivi.

- Tant que `Start_SL = 1`, le robot continue le suivi.
- Quand `Start_SL` retombe a `0`, une temporisation de 1 seconde est lancee.
- A la fin de cette temporisation, transition vers `S2`.

### Etat S2 - Mode rotation

Les commandes moteurs proviennent du bloc de rotation (pivot sur place).

- Tant que `Start_rot = 1`, la rotation est maintenue.
- Quand `Start_rot` retombe a `0`, une nouvelle temporisation de 1 seconde est appliquee.
- A la fin de cette pause, transition vers `S3`.

### Etat S3 - Attente de relance du suivi

Etat de synchronisation avant reprise du cycle.

- Si `Start_SL` est reactive, retour en `S1`.
- Sinon, maintien en `S3`.

---

## Signaux de decision

- `fin_SL` : fin de phase suivi (ligne perdue ou suivi interrompu selon la logique du bloc).
- `fin_rot` : fin de phase rotation (objectif de recentrage atteint).

Ces deux signaux servent de jalons pour enchainer proprement les phases sans conflit de commande moteur.

---

## Supervision NIOS (code C)

Le programme C tourne en boucle infinie et agit comme orchestrateur des modes.

### Initialisation

1. Attendre que `START` soit actif.
2. Tant que `START` est inactif, conserver le robot a l'arret.

### Activation du suivi de ligne

Quand la sequence doit revenir en suivi :

1. Desactiver `START_ROT`.
2. Attendre `READY = 0` (donnees capteurs disponibles).
3. Activer `START_SL`.
4. Surveiller l'evolution de `FIN_SL`.

### Activation de la rotation

Quand la sequence doit passer en rotation :

1. Desactiver `START_SL`.
2. Positionner `DIR_ROT` selon le sens voulu.
3. Activer `START_ROT`.
4. Surveiller `FIN_ROT` jusqu'a la fin de rotation.
5. Desactiver `START_ROT`.
6. Attendre `READY = 0`.
7. Reactiver `START_SL` pour relancer le suivi.

---

## Synthese du cycle

```text
S0 (attente ligne)
 -> S1 (suivi de ligne)
 -> pause 1 s
 -> S2 (rotation)
 -> pause 1 s
 -> S3 (synchronisation)
 -> S1 (reprise suivi)
```

Ce schema garantit des aller-retours robustes entre suivi et rotation complete, avec des transitions temporisees qui limitent les changements brusques de commande.
