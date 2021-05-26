#define R_BUILD		(1<<0)
#define R_ADMIN			(1<<1)
#define R_BAN			(1<<2)
#define R_FUN			(1<<3)
#define R_SERVER		(1<<4)
#define R_DEBUG			(1<<5)
#define R_POSSESS		(1<<6)
#define R_PERMISSIONS	(1<<7)
#define R_STEALTH		(1<<8)
#define R_POLL			(1<<9)
#define R_VAREDIT		(1<<10)
#define R_SOUND		(1<<11)
#define R_SPAWN			(1<<12)
#define R_AUTOADMIN		(1<<13)
#define R_DBRANKS		(1<<14)

#define R_DEFAULT R_AUTOADMIN

#define R_EVERYTHING (1<<15)-1

#define ADMIN_JMP(src) "(<a href='?_src_=holder;[HrefToken(TRUE)];adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)"
#define COORD(src) "[src ? "([src.x],[src.y],[src.z])" : "nonexistent location"]"
//#define AREACOORD(src) "[src ? "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])" : "nonexistent location"]"
#define AREACOORD(src) "[get_area_name(src, TRUE)] ([src.x], [src.y], [src.z])"//not_actual