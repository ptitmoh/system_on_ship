#include <stdio.h>
#include <io.h>
#include "system.h"
#include "alt_types.h"

// Offsets basés sur le VHDL PWM (address : '0'=droit, '1'=gauche)
// En C, l'adresse est multipliée par 4 pour l'alignement 32-bits
#define PWM_RIGHT_OFFSET 0
#define PWM_LEFT_OFFSET  4

// Offsets basés sur le VHDL CAP_SOL
#define CAP_SOL_REG_STATUS_VECT (1 * 4)
#define CAP_SOL_REG_NIVEAU      (9 * 4)

// Valeurs de vitesse (14 bits max = 16383)
// Attention : vérifiez si votre PWM gère le signe ou si 8192 est l'arrêt.
// Ici on suppose que 0 est l'arrêt et que la valeur contrôle le rapport cyclique.
#define SPEED_FAST    8000
#define SPEED_SLOW    3000
#define SPEED_STOP    0

/**
 * Commande des moteurs
 * @param left  Vitesse roue gauche (0 à 16383)
 * @param right Vitesse roue droite (0 à 16383)
 */
void drive_motors(alt_u16 left, alt_u16 right) {
    // Écriture sur le moteur Droit (Address 0)
    IOWR_16DIRECT(PWM_AVALON_INTERFACE_0_BASE, PWM_RIGHT_OFFSET, right & 0x3FFF);
    // Écriture sur le moteur Gauche (Address 1 -> Offset 4 octets)
    IOWR_16DIRECT(PWM_AVALON_INTERFACE_0_BASE, PWM_LEFT_OFFSET, left & 0x3FFF);
}

int main() {
    printf("Initialisation Acutecar...\n");

    // Fixer le seuil de détection (NIVEAU)
    IOWR_32DIRECT(CAP_SOL_AVALON_INTERFACE_0_BASE, CAP_SOL_REG_NIVEAU, 130);

    alt_u32 data_reg;
    alt_u8 sensors;
    alt_u8 ready;

    while (1) {
        data_reg = IORD_32DIRECT(CAP_SOL_AVALON_INTERFACE_0_BASE, CAP_SOL_REG_STATUS_VECT);
        
        ready   = data_reg & 0x01;
        sensors = (data_reg >> 1) & 0x7F; // Les 7 capteurs

        if (ready) {
            // LOGIQUE DE SUIVI (Exemple simple)
            // Bit: 6 5 4 [3] 2 1 0  (3 est le centre)
            
            if (sensors == 0x08) { // 0001000 : Pile au centre
                drive_motors(SPEED_FAST, SPEED_FAST);
            } 
            else if (sensors & 0x07) { // 0000XXX : Ligne à droite
                // On tourne à droite : moteur gauche avance, moteur droit ralentit
                drive_motors(SPEED_FAST, SPEED_SLOW);
            } 
            else if (sensors & 0x70) { // XXX0000 : Ligne à gauche
                // On tourne à gauche : moteur droit avance, moteur gauche ralentit
                drive_motors(SPEED_SLOW, SPEED_FAST);
            } 
            else if (sensors == 0x7F) { // 1111111 : Ligne partout (intersection)
                drive_motors(SPEED_SLOW, SPEED_SLOW);
            }
            else { // 0000000 : Perdu
                drive_motors(SPEED_STOP, SPEED_STOP);
            }
        }
    }
    return 0;
}