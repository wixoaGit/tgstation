#define EQUIP			1
#define LIGHT			2
#define ENVIRON			3
#define TOTAL			4
#define STATIC_EQUIP 	5
#define STATIC_LIGHT	6
#define STATIC_ENVIRON	7

#define NO_POWER_USE 0
#define IDLE_POWER_USE 1
#define ACTIVE_POWER_USE 2

#define OPEN	(1<<0)
#define IDSCAN	(1<<1)
#define BOLTS	(1<<2)
#define SHOCK	(1<<3)
#define SAFE	(1<<4)

#define IMPRINTER		(1<<0)
#define PROTOLATHE		(1<<1)
#define AUTOLATHE		(1<<2)
#define CRAFTLATHE		(1<<3)
#define MECHFAB			(1<<4)
#define BIOGENERATOR	(1<<5)
#define LIMBGROWER		(1<<6)
#define SMELTER			(1<<7)
#define NANITE_COMPILER  (1<<8)

#define FIREDOOR_OPEN 1
#define FIREDOOR_CLOSED 2

#define MACHINE_NOT_ELECTRIFIED 0
#define MACHINE_ELECTRIFIED_PERMANENT -1
#define MACHINE_DEFAULT_ELECTRIFY_TIME 30