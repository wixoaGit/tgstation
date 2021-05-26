#define ZTRAIT_CENTCOM "CentCom"
#define ZTRAIT_STATION "Station"
#define ZTRAIT_MINING "Mining"
#define ZTRAIT_REEBE "Reebe"
#define ZTRAIT_RESERVED "Transit/Reserved"
#define ZTRAIT_AWAY "Away Mission"
#define ZTRAIT_SPACE_RUINS "Space Ruins"
#define ZTRAIT_LAVA_RUINS "Lava Ruins"

#define ZTRAIT_LINKAGE "Linkage"
    #define UNAFFECTED null
    #define SELFLOOPING "Self"
    #define CROSSLINKED "Cross"

#define ZTRAITS_CENTCOM list(ZTRAIT_CENTCOM = TRUE)
#define ZTRAITS_STATION list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_STATION = TRUE)
#define ZTRAITS_SPACE list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_SPACE_RUINS = TRUE)

#define DL_NAME "name"
#define DL_TRAITS "traits"
#define DECLARE_LEVEL(NAME, TRAITS) list(DL_NAME = NAME, DL_TRAITS = TRAITS)

#define DEFAULT_MAP_TRAITS list(\
    DECLARE_LEVEL("CentCom", ZTRAITS_CENTCOM),\
)

#define RESERVED_TURF_TYPE /turf/open/space/basic