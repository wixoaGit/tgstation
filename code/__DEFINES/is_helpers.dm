#define islist(L) (istype(L, /list))

//#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))
#define in_range(source, user) (get_dist(source, user) <= 1)//not_actual

#define ismovableatom(A) (istype(A, /atom/movable))

#define isatom(A) (isloc(A))

#define isopenturf(A) (istype(A, /turf/open))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define isliving(A) (istype(A, /mob/living))

//#define isbrain(A) (istype(A, /mob/living/brain))
#define isbrain(A) (FALSE)//not_actual

#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))
#define ismonkey(A) (FALSE)//not_actual

//#define isalien(A) (istype(A, /mob/living/carbon/alien))
#define isalien(A) (FALSE)//not_actual

//#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid) || istype(A, /mob/living/simple_animal/hostile/alien))
#define isalienadult(A) (FALSE)//not_actual

#define issilicon(A) (istype(A, /mob/living/silicon))

#define issiliconoradminghost(A) (istype(A, /mob/living/silicon) || IsAdminGhost(A))

//#define iscyborg(A) (istype(A, /mob/living/silicon/robot))
#define iscyborg(A) (FALSE)//not_actual

//#define isAI(A) (istype(A, /mob/living/silicon/ai))
#define isAI(A) (FALSE)//not_actual

#define isanimal(A) (istype(A, /mob/living/simple_animal))

//#define isbot(A) (istype(A, /mob/living/simple_animal/bot))
#define isbot(A) (FALSE)//not_actual

//#define isslime(A) (istype(A, /mob/living/simple_animal/slime))
#define isslime(A) (FALSE)//not_actual

//#define isdrone(A) (istype(A, /mob/living/simple_animal/drone))
#define isdrone(A) (FALSE)//not_actual

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

//#define iscameramob(A) (istype(A, /mob/camera))
#define iscameramob(A) (FALSE)//not_actual

//#define isshoefoot(A) (is_type_in_typecache(A, GLOB.shoefootmob))
#define isshoefoot(A) (TRUE)//not_actual

//#define isclawfoot(A) (is_type_in_typecache(A, GLOB.clawfootmob))
#define isclawfoot(A) (FALSE)//not_actual

//#define isbarefoot(A) (is_type_in_typecache(A, GLOB.barefootmob))
#define isbarefoot(A) (FALSE)//not_actual

//#define isheavyfoot(A) (is_type_in_typecache(A, GLOB.heavyfootmob))
#define isheavyfoot(A) (FALSE)//not_actual

#define isobj(A) istype(A, /obj)

#define isitem(A) (istype(A, /obj/item))

#define ismachinery(A) (istype(A, /obj/machinery))

//#define ismecha(A) (istype(A, /obj/mecha))
#define ismecha(A) (FALSE)//not_actual

//#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune))
#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable))//not_actual

#define isbodypart(A) (istype(A, /obj/item/bodypart))

//#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))
#define is_glass_sheet(O) (istype(O, /obj/item/stack/sheet/glass))//not_actual

#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))