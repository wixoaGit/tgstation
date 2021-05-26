#define QDEL_IN(item, time) addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, item), time, TIMER_STOPPABLE)
#define QDEL_NULL(item) qdel(item); item = null
#define QDEL_LIST(L) if(L) { for(var/I in L) qdel(I); L.Cut(); }