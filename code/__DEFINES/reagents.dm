#define SOLID 			1
#define LIQUID			2
#define GAS				3

#define INJECTABLE		(1<<0)
#define DRAWABLE		(1<<1)

#define REFILLABLE		(1<<2)
#define DRAINABLE		(1<<3)

#define TRANSPARENT		(1<<4)
#define AMOUNT_VISIBLE	(1<<5)
#define NO_REACT        (1<<6)

#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)


#define TOUCH			1
#define INGEST			2
#define VAPOR			3
#define PATCH			4
#define INJECT			5


#define DEL_REAGENT		1
#define ADD_REAGENT		2
#define REM_REAGENT		3
