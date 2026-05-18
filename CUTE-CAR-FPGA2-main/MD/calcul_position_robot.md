# Calcul de la position du robot par rapport a la ligne

## Objectif

Estimer la position laterale du robot par rapport a la ligne noire a partir de 7 capteurs de sol afin de corriger la trajectoire.

## Donnees utilisees

- `data_capteur(6 downto 0)`: etat binaire des capteurs apres seuillage.
- `PPU`: index du premier capteur actif (premier capteur qui voit la ligne).
- `PDU`: index du dernier capteur actif (dernier capteur qui voit la ligne).

## Formule de position

La position est calculee par:

```text
pos_ligne = PPU + PDU - 6
```

Avec 7 capteurs indexes de 0 a 6:

- `pos_ligne = 0`: ligne centree sous le robot.
- `pos_ligne > 0`: ligne decalee d'un cote.
- `pos_ligne < 0`: ligne decalee de l'autre cote.

## Cas sans detection

Si aucun capteur n'est actif:

- la ligne est consideree perdue,
- une valeur speciale peut etre envoyee pour `pos_ligne` (exemple: 8),
- la logique de suivi peut alors s'arreter et signaler `fin_SL`.

## Exploitation dans la commande moteurs

La valeur `pos_ligne` alimente la correction de trajectoire:

```text
VitMotD = VitMoy + K * pos_ligne
VitMotG = VitMoy - K * pos_ligne
```

Ce calcul permet de recentrer le robot en ajustant la vitesse relative des roues droite et gauche.
