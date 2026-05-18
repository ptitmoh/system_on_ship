# Architecture NIOS-SDRAM-PIO

## Objectif

Mettre en place une architecture materielle permettant au processeur NIOS de superviser le robot, de lire les capteurs et de piloter les automates de deplacement.

## Blocs principaux

- Processeur NIOS: execute le code C de supervision.
- Controleur SDRAM: stocke programme et tables de donnees.
- PIO d'entree: lecture des signaux d'etat (`fin_SL`, `fin_rot`, `ready`, capteurs derives).
- PIO de sortie: ecriture des commandes (`start_SL`, `start_rot`, `dir_rot`, seuil capteurs).
- Blocs VHDL de traitement: suivi de ligne, rotation, mux de commande moteurs.
- Generation PWM: conversion des consignes en signaux moteurs droite/gauche.

## Principe de fonctionnement

1. Le NIOS initialise les PIO et les parametres (notamment le seuil de capteurs).
2. Les capteurs sont acquis puis seuilles par les blocs materiels.
3. Le NIOS active le mode suivi ou rotation via les signaux de commande.
4. Les automates VHDL produisent les consignes moteurs.
5. Les generateurs PWM appliquent les commandes aux deux moteurs.

## Interet de cette architecture

- Separation claire entre supervision logicielle et controle temps reel.
- Reponse rapide des blocs critiques en VHDL.
- Parametrage simple depuis le logiciel sans recompiler tout le materiel.
