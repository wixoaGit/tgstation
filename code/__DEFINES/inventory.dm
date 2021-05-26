#define WEIGHT_CLASS_TINY     1
#define WEIGHT_CLASS_SMALL    2
#define WEIGHT_CLASS_NORMAL   3
#define WEIGHT_CLASS_BULKY    4
#define WEIGHT_CLASS_HUGE     5
#define WEIGHT_CLASS_GIGANTIC 6

#define INVENTORY_DEPTH		3
#define STORAGE_VIEW_DEPTH	2

#define ITEM_SLOT_OCLOTHING		(1<<0)
#define ITEM_SLOT_ICLOTHING		(1<<1)
#define ITEM_SLOT_GLOVES		(1<<2)
#define ITEM_SLOT_EYES			(1<<3)
#define ITEM_SLOT_EARS			(1<<4)
#define ITEM_SLOT_MASK			(1<<5)
#define ITEM_SLOT_HEAD			(1<<6)
#define ITEM_SLOT_FEET			(1<<7)
#define ITEM_SLOT_ID			(1<<8)
#define ITEM_SLOT_BELT			(1<<9)
#define ITEM_SLOT_BACK			(1<<10)
#define ITEM_SLOT_POCKET		(1<<11)
#define ITEM_SLOT_DENYPOCKET	(1<<12)
#define ITEM_SLOT_NECK			(1<<13)

#define SLOT_BACK			1
#define SLOT_WEAR_MASK		2
#define SLOT_HANDCUFFED		3
#define SLOT_HANDS			4
#define SLOT_BELT			5
#define SLOT_WEAR_ID		6
#define SLOT_EARS			7
#define SLOT_GLASSES		8
#define SLOT_GLOVES			9
#define SLOT_NECK			10
#define SLOT_HEAD			11
#define SLOT_SHOES			12
#define SLOT_WEAR_SUIT		13
#define SLOT_W_UNIFORM		14
#define SLOT_L_STORE		15
#define SLOT_R_STORE		16
#define SLOT_S_STORE		17
#define SLOT_IN_BACKPACK	18
#define SLOT_LEGCUFFED		19
#define SLOT_GENERC_DEXTROUS_STORAGE	20

#define SLOTS_AMT			20

#define HIDEGLOVES		(1<<0)
#define HIDESUITSTORAGE	(1<<1)
#define HIDEJUMPSUIT	(1<<2)
#define HIDESHOES		(1<<3)
#define HIDEMASK		(1<<4)
#define HIDEEARS		(1<<5)
#define HIDEEYES		(1<<6)
#define HIDEFACE		(1<<7)
#define HIDEHAIR		(1<<8)
#define HIDEFACIALHAIR	(1<<9)
#define HIDENECK		(1<<10)

#define HEAD		(1<<0)
#define CHEST		(1<<1)
#define GROIN		(1<<2)
#define LEG_LEFT	(1<<3)
#define LEG_RIGHT	(1<<4)
#define LEGS		(LEG_LEFT | LEG_RIGHT)
#define FOOT_LEFT	(1<<5)
#define FOOT_RIGHT	(1<<6)
#define FEET		(FOOT_LEFT | FOOT_RIGHT)
#define ARM_LEFT	(1<<7)
#define ARM_RIGHT	(1<<8)
#define ARMS		(ARM_LEFT | ARM_RIGHT)
#define HAND_LEFT	(1<<9)
#define HAND_RIGHT	(1<<10)
#define HANDS		(HAND_LEFT | HAND_RIGHT)
#define NECK		(1<<11)
#define FULL_BODY	(~0)

#define NO_FEMALE_UNIFORM			0
#define FEMALE_UNIFORM_FULL			1
#define FEMALE_UNIFORM_TOP			2

#define NO_MUTANTRACE_VARIATION		0
#define MUTANTRACE_VARIATION		1

#define NOT_DIGITIGRADE				0
#define FULL_DIGITIGRADE			1
#define SQUISHED_DIGITIGRADE		2

#define GLASSESCOVERSEYES	(1<<0)
#define MASKCOVERSEYES		(1<<1)
#define HEADCOVERSEYES		(1<<2)
#define MASKCOVERSMOUTH		(1<<3)
#define HEADCOVERSMOUTH		(1<<4)