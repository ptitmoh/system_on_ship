# Calibration des Capteurs de Sol

## Résultats de Mesure

### Conditions de Test
- **Robot en position:** [1] à [50] = sur NOIR | [51] à [100] = sur BLANC
- **Nombre de mesures:** 100
- **Module utilisé:** `capteurs_sol` (valeurs brutes ADC, 8 bits)

### Valeurs Mesurées

#### État SUR NOIR ([1] à [50])
```
[1]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[2]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[3]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[4]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[5]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[6]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[7]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[8]  C0:202  C1:202  C2:202  C3:202  C4:202  C5:202  C6:202
[9]  C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
[10] C0:255  C1:255  C2:255  C3:255  C4:255  C5:255  C6:255
... (valeurs similaires jusqu'à [50])
```

#### État SUR BLANC ([51] à [100])
```
[51] C0: 40  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[52] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[53] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[54] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[55] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[56] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[57] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[58] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[59] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
[60] C0: 15  C1: 15  C2: 15  C3: 15  C4: 15  C5: 15  C6: 15
... (valeurs similaires jusqu'à [100])
```

## Analyse et Seuil Optimal

| Paramètre | Valeur |
|-----------|--------|
| **MIN (blanc)** | ~15-40 |
| **MAX (noir)** | ~255 |
| **Seuil optimal** | **(15 + 255) / 2 = 135** |
| **Seuil recommandé** | **130-140** |

## Interprétation

- **Si valeur_capteur > 130** → **NOIR DÉTECTÉ** (bit = 1)
- **Si valeur_capteur < 130** → **BLANC** (bit = 0)

## Configuration NIOS II

**À appliquer dans `PIO_OUT_NIVEAU`:**
```
Seuil = 135 (ou 130-140)    en HEX : 0x87
```

## Notes

- Tous les capteurs (C0-C6) ont des réponses **très similaires**
- La détection est **claire et nette** (255 vs 15-40)
- Aucun capteur défectueux détecté
- Bonne plage de variation permet du filtrage robuste

## Prochaines Étapes

1. ✅ Capteurs calibrés avec seuil = 135 en HEX : 0x87
2. ⏳ Vérifier que `ligne_presente_s` = 1 quand robot sur noir
3. ⏳ Vérifier que machine d'état `suivi_ligne` passe en SUIVRE
4. ⏳ Faire tourner les moteurs avec contrôle proportionnel

---

**Total mesures:** 100 (50 noir + 50 blanc)
