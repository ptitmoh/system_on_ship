// Test PWM signal triangle - vitesse croissante puis décroissante
#include <stdio.h>
#include "system.h"   // Généré par Altera Monitor Program
                      // Contient : PWM_AVALON_INTERFACE_0_BASE = 0x1040
#include "io.h"       // Contient : IOWR_16DIRECT(base, offset, data)

// ============================================================
// ADRESSE PWM - vient directement de system.h
// PWM_AVALON_INTERFACE_0_BASE est défini à 0x1040
// C'est l'adresse de base du composant dans l'espace mémoire Nios II
// ============================================================
#define PWM_BASE    PWM_AVALON_INTERFACE_0_BASE

// ============================================================
// FORMAT DU REGISTRE PWM (14 bits utiles)
//   bit 13   = GO  : 1=marche, 0=stop
//   bit 12   = DIR : 0=avant,  1=arriere
//   bits 11:0= vitesse (0 à 3125 = freqFPGA/freqPWM)
// ============================================================
#define PWM_GO      (1 << 13)
#define PWM_AVANT   (0 << 12)
#define PWM_ARRIERE (1 << 12)

// Bornes du signal triangle
#define VIT_MIN     0x000   // 0%   - moteur à l'arrêt
#define VIT_MAX     0xC35   // 100% - 3125 en décimal
#define VIT_STEP    0x040   // pas d'incrément par palier

// ============================================================
// ÉCRITURE DANS LES REGISTRES PWM
//   offset 0x00 = registre moteur DROIT
//   offset 0x02 = registre moteur GAUCHE
// IOWR_16DIRECT(base, offset, valeur) écrit 16 bits
// à l'adresse (base + offset)
// ============================================================
void moteur_droit(int go, int direction, int vitesse) {
    unsigned short cmd = 0;
    if (go)
        cmd = PWM_GO | (direction ? PWM_ARRIERE : PWM_AVANT) | (vitesse & 0xFFF);
    IOWR_16DIRECT(PWM_BASE, 0x00, cmd);
}

void moteur_gauche(int go, int direction, int vitesse) {
    unsigned short cmd = 0;
    if (go)
        cmd = PWM_GO | (direction ? PWM_ARRIERE : PWM_AVANT) | (vitesse & 0xFFF);
    IOWR_16DIRECT(PWM_BASE, 0x02, cmd);
}

void stop(void) {
    IOWR_16DIRECT(PWM_BASE, 0x00, 0x0000);
    IOWR_16DIRECT(PWM_BASE, 0x02, 0x0000);
}

// Délai : CPU à 50 MHz → ~50000 cycles par ms
void delay_ms(unsigned int ms) {
    volatile unsigned int i;
    for (i = 0; i < ms * 50000; i++);
}

// ============================================================
// MAIN - Signal triangle
//
// Le signal triangle fait varier la vitesse de VIT_MIN à VIT_MAX
// puis de VIT_MAX à VIT_MIN, en boucle infinie.
//
//  vitesse
//  VIT_MAX |    /\      /\      /\
//          |   /  \    /  \    /  \
//  VIT_MIN |  /    \  /    \  /    \
//          +--+----+--+----+--+-----> temps
//
// Moteur droit  : AVANT  tout le temps
// Moteur gauche : ARRIÈRE tout le temps
// → les deux tournent en sens opposés (utile pour pivot sur place)
// ============================================================
int main(void) {
    int vitesse;

    printf("=== Signal triangle PWM ===\n");
    printf("Droit=AVANT  Gauche=ARRIERE\n");
    printf("Vitesse : 0x%03X -> 0x%03X -> 0x%03X ...\n",
           VIT_MIN, VIT_MAX, VIT_MIN);

    while (1) {

        // ----- Phase montante : VIT_MIN → VIT_MAX -----
        printf("-- Montee --\n");
        for (vitesse = VIT_MIN; vitesse <= VIT_MAX; vitesse += VIT_STEP) {
            moteur_droit (1, 0, vitesse);   // AVANT
            moteur_gauche(1, 1, vitesse);   // ARRIERE

            printf("vitesse = 0x%03X (%4d / 3125 = %3d%%)\n",
                   vitesse, vitesse, (vitesse * 100) / VIT_MAX);

            delay_ms(100);   // palier de 100 ms par pas
        }

        // ----- Phase descendante : VIT_MAX → VIT_MIN -----
        printf("-- Descente --\n");
        for (vitesse = VIT_MAX; vitesse >= VIT_MIN; vitesse -= VIT_STEP) {
            moteur_droit (1, 0, vitesse);
            moteur_gauche(1, 1, vitesse);

            printf("vitesse = 0x%03X (%4d / 3125 = %3d%%)\n",
                   vitesse, vitesse, (vitesse * 100) / VIT_MAX);

            delay_ms(100);
        }
    }

    return 0;
}