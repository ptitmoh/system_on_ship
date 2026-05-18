# Projet Robot Suiveur de Ligne - CUTE-CAR2

## But du projet

Ce projet consiste a concevoir une chaine complete de commande pour un robot CUTE-CAR2 base sur FPGA (DE0-NANO).
L'objectif principal est de permettre au robot de :

- suivre une ligne noire de maniere autonome,
- detecter la perte de ligne,
- se reorienter par rotation,
- enchainer des cycles d'aller-retour robustes.

Le systeme combine des blocs VHDL (temps reel) et une supervision logicielle en C sur NIOS.

---

## Ce que nous avons realise

1. Mise en place d'une architecture NIOS-SDRAM-PIO pour interfacer capteurs, commandes et supervision.
2. Caracterisation des moteurs (format de commande, seuils utiles de PWM).
3. Calcul de la position du robot par rapport a la ligne a partir des capteurs.
4. Implementation du suivi de ligne avec correction sur ligne droite et en virage.
5. Implementation de la rotation sur place apres perte de ligne.
6. Gestion des aller-retours avec alternance suivi/rotation et temporisations.

---

## Documents par etape

### Etape 1 - Architecture NIOS-SDRAM-PIO

- [MD/architecture_nios_sdram_pio.md](architecture_nios_sdram_pio.md)

### Etape 2 - Caracterisation des moteurs

- [MD/notes_moteurs.md](notes_moteurs.md)

### Etape 3 - Calcul de la position du robot

- [MD/calcul_position_robot.md](calcul_position_robot.md)

### Etape 4 - Suivi de ligne

- [MD/suivi_de_ligne.md](suivi_de_ligne.md)

### Etape 5 - Gestion de la rotation

- [MD/gestion_de_la_rotation.md](gestion_de_la_rotation.md)

### Etape 6 - Gestion des aller-retours

- [MD/gestion_aller_retours_suivi_ligne.md](gestion_aller_retours_suivi_ligne.md)

---

## Organisation du dossier MD

Le dossier MD centralise la documentation technique du projet, de l'architecture materielle jusqu'au comportement dynamique du robot en fonctionnement.

