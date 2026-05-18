### Voiture 27 Benfetima Mohamed Cherif & Chiha Faress

##Caractérisation des moteurs :

##Pour chaque moteur :
bit 13 = go/stop
bit 12 = sens
bits 11..0 = largeur d’impulsion PWM

##Méthode : 
fréquence du processeur fixée à 50 MHz 
fréquence du PWM définie à 16 kHz

##Le calcul réalisé:
Nombre de coups d’horloge = 50 000 000 / 16 000 = 3 125 (periode est de 3 125 ticks )

Application de différents rapports cycliques aux roues gauche et droite afin de mesurer les vitesses minimales auxquelles elles commencent à tourner hors sol et sur le sol


##Résultats obtenus avec piles : : 

#Roue Droite:  
 -Hors sol :  0x"(2/3)800"   :  65,5% duty-cyclee 2048/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)600"  
 -Sur sol  :  0x"(2/3)800"   :  65,5% duty-cycle  2048/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)700"

#Roue Gauche:  
 -Hors sol :  0x"(2/3)800"   :  65,5% duty-cyclee 2048/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)550"  
 -Sur sol  :  0x"(2/3)800"   :  65,5% duty-cycle  2048/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)700"    
   
##Résultats obtenus sans piles : : 

#Roue Droite:  
 -Hors sol :  0x"(2/3)850"   :  68,09% duty-cyclee 2128/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)700"  
 -Sur sol  :  0x"(2/3)850"   :  68,09% duty-cycle  2128/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)750"

#Roue Gauche:  
 -Hors sol :  0x"(2/3)900"   :  73,7% duty-cyclee 2304/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)750"  
 -Sur sol  :  0x"(2/3)850"   :  68,09% duty-cycle  2128/3125
   Vitesse minimal que l’on peut donner au moteur en mouvement sans  que la roue ne s’arrête : 0x"(2/3)750" 