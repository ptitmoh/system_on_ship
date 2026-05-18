#include <stdio.h>

#define pio_output ((volatile unsigned char *) 0x00001030)/* volatile : dit au compilateur de ne pas optimizer les ports */
#define pio_input ((volatile unsigned char *) 0x00001040)

/*
*pio_output(0) : Start_SL
*pio_output(1) : start_rot
*pio_output(2) : dir_rot

*pio_input(0)  : Fin_SL
*pio_input(1)  : Ready
*pio_input(2)  : Fin_rot
*/

// Définition des masques de bits
#define START_SL    (1 << 0)  // Bit 0
#define START_ROT   (1 << 1)  // Bit 1
#define DIR_ROT     (1 << 2)  // Bit 2

#define FIN_SL      (1 << 0)  // Bit 0
#define READY       (1 << 1)  // Bit 1
#define FIN_ROT     (1 << 2)  // Bit 2
#define START       (1 << 3)  // Bit 3

// Fonction pour convertir un entier (sur 'bits' bits) en chaîne binaire
void int_to_binary_str(unsigned int value, char *str, int bits) {
    int i;
	for (i = 0; i < bits; i++) {
        // On extrait le bit (du MSB vers le LSB)
        int bit = (value >> (bits - 1 - i)) & 0x01;
        str[i] = bit ? '1' : '0';
    }
    str[bits] = '\0';  // Terminaison de la chaîne
}

void delays(){
	int j;
	for(j=0;j<1000000;j++);					

}	


int main(){
	
    while (1) {
		
		while(!((*pio_input) & START));
		
		if (!((*pio_input) & FIN_SL)){
			
			*pio_output &= ~START_ROT; // met START_ROT à 0
			while ((*pio_input) & READY);
			*pio_output |= START_SL;  // met START_SL à 1
			while(!((*pio_input) & FIN_SL));
		
		}else if ((*pio_input) & FIN_SL){
			*pio_output &= ~START_SL;  // met START_SL à 0
			*pio_output |= DIR_ROT;
			*pio_output |= START_ROT; // met START_ROT à 1
			while(!((*pio_input) & FIN_ROT));
			*pio_output &= ~START_ROT; // met START_ROT à 0
			while ((*pio_input) & READY);
			*pio_output |= START_SL;  // met START_SL à 1
		}
			
			
			
		/* else if (!(*pio_input & FIN_SL) && *pio_input & FIN_ROT) {
			
			*pio_output &= ~START_SL;  // met START_SL à 0
			*pio_output |= START_ROT; // met START_ROT à 1
			*pio_output |= DIR_ROT;   // met DIR_ROT à 1
			
		}else if ((*pio_input & FIN_SL) && (*pio_input & FIN_ROT) && !(*pio_output & START_ROT)) {
			
			*pio_output |= START_ROT; // met START_ROT à 1
			*pio_output &= ~START_SL;  // met START_SL à 0
			
		} */
			
    }

    return 0;
}