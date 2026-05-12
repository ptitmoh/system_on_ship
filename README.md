"# system_on_ship" 

# L'objectuf est de connecter le registre aux afficheur 8 segments

# Composants et Instructions Spécialisés pour Nios II

## Composant spécialisé

Un **composant spécialisé** est un module matériel qui communique directement avec le **bus Avalon** et sert d'interface entre le processeur **Nios II** et un composant physique externe (capteur, actionneur, etc.).  
Ces composants sont souvent utilisés pour des tâches spécifiques nécessitant un traitement matériel rapide ou une interaction directe avec des périphériques externes.

---

## Instruction spécialisée

Une **instruction spécialisée** est une instruction du processeur Nios II qui interagit avec un **convertisseur d’instructions** ou un module matériel spécifique pour contrôler ou communiquer avec un composant physique.  il nécéssite unne extention UAL du NIOS
Ces instructions permettent d’optimiser certaines opérations critiques qui seraient trop lentes si elles étaient exécutées uniquement par le logiciel.



# Making Qsys Components — Version VHDL

> **Source :** *Making Qsys Components for Quartus II 13.0* — Altera University Program, Mai 2013  
> **Outil visé :** Quartus II 13.0 + Qsys  
> **Langage :** VHDL

## schéma block

<img src="schema_block.png" alt="Logo" width="200">

## Concept général

Un **composant Qsys** est un sous-circuit VHDL exposé comme bibliothèque réutilisable dans Qsys. Il comporte deux parties :

- **Entités internes** : la logique fonctionnelle (ex. registre, compteur…)
- **Interfaces Avalon** : les ports de communication avec le reste du système

Le système Qsys génère automatiquement le fabric d'interconnexion (**Avalon Interconnect**) à partir des interfaces déclarées. En VHDL, chaque composant est décrit via une `ENTITY` et une `ARCHITECTURE`.

---

## Types d'interfaces Avalon

| Interface | Rôle |
|-----------|------|
| **Clock** | Fournit ou reçoit l'horloge |
| **Reset** | Signal de réinitialisation |
| **Memory-Mapped (MM)** | Lecture/écriture par adresse (master ↔ slave) |
| **Streaming (ST)** | Flux de données unidirectionnel |
| **Conduit** | Signaux exportés hors du système Qsys (LEDs, afficheurs…) |

> **Règle :** tout composant doit inclure au minimum les interfaces Clock et Reset.

---

## Exemple de composant : `reg16`

Le tutoriel construit un **registre 16 bits** accessible en mémoire mappée. En VHDL, on sépare systématiquement le registre interne (`reg16`) de son enveloppe Avalon (`reg16_avalon_interface`).

### Signaux de l'interface Avalon MM (slave)

| Signal | Direction VHDL | Type VHDL | Description |
|--------|---------------|-----------|-------------|
| `clock` | `IN` | `STD_LOGIC` | Horloge système |
| `resetn` | `IN` | `STD_LOGIC` | Reset actif bas |
| `writedata` | `IN` | `STD_LOGIC_VECTOR(15 DOWNTO 0)` | Donnée à écrire |
| `readdata` | `OUT` | `STD_LOGIC_VECTOR(15 DOWNTO 0)` | Donnée lue |
| `write` | `IN` | `STD_LOGIC` | Actif lors d'une écriture |
| `read` | `IN` | `STD_LOGIC` | Actif lors d'une lecture |
| `byteenable` | `IN` | `STD_LOGIC_VECTOR(1 DOWNTO 0)` | Sélection d'octet |
| `chipselect` | `IN` | `STD_LOGIC` | Sélection du composant |
| `Q_export` | `OUT` | `STD_LOGIC_VECTOR(15 DOWNTO 0)` | Conduit vers périphériques externes |



---

## Protocole Avalon MM — Transactions

### Lecture (Read)
- Le master pose l'adresse et asserte `read`
- Le slave détecte `chipselect` et répond en plaçant la donnée sur `readdata`
- Si besoin, le slave peut retarder la réponse via `waitrequest`
- Avec **Read wait = 0**, la donnée est disponible dès le cycle suivant

### Écriture (Write)
- Le master pose l'adresse + la donnée et asserte `write`
- Le slave capture la donnée sur `writedata` **uniquement si `chipselect = '1'`**
- `byteenable` indique quels octets sont concernés (`"01"` = octet bas, `"10"` = octet haut, `"11"` = les deux)
- Le signal `waitrequest` peut étendre la transaction sur plusieurs cycles

### Adressage
- Les adresses maîtres sont alignées sur des **mots de 32 bits**
- Ex. : 1er registre = `0x10000000`, 2ème = `0x10000004`, etc.
- Les 2 bits de poids faible de l'adresse maître ne sont **pas vus** par le slave



