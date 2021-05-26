#define MC_TICK_CHECK ( ( TICK_USAGE > Master.current_ticklimit || src.state != SS_RUNNING ) ? pause() : 0 )

#define MC_SPLIT_TICK_INIT(phase_count) var/original_tick_limit = Master.current_ticklimit; var/split_tick_phases = ##phase_count
#define MC_SPLIT_TICK \
    if(split_tick_phases > 1){\
        Master.current_ticklimit = ((original_tick_limit - TICK_USAGE) / split_tick_phases) + TICK_USAGE;\
        --split_tick_phases;\
    } else {\
        Master.current_ticklimit = original_tick_limit;\
    }

#define MC_AVERAGE_FAST(average, current) (0.7 * (average) + 0.3 * (current))
#define MC_AVERAGE(average, current) (0.8 * (average) + 0.2 * (current))
#define MC_AVERAGE_SLOW(average, current) (0.9 * (average) + 0.1 * (current))

#define MC_AVG_FAST_UP_SLOW_DOWN(average, current) (average > current ? MC_AVERAGE_SLOW(average, current) : MC_AVERAGE_FAST(average, current))

#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define START_PROCESSING(Processor, Datum) if (!(Datum.datum_flags & DF_ISPROCESSING)) {Datum.datum_flags |= DF_ISPROCESSING;Processor.processing += Datum}
#define STOP_PROCESSING(Processor, Datum) Datum.datum_flags &= ~DF_ISPROCESSING;Processor.processing -= Datum

#define SS_IDLE 0
#define SS_QUEUED 1
#define SS_RUNNING 2
#define SS_PAUSED 3
#define SS_SLEEPING 4
#define SS_PAUSING 5

#define SS_NO_INIT 1

#define SS_NO_FIRE 2

#define SS_BACKGROUND 4

#define SS_NO_TICK_CHECK 8

#define SS_TICKER 16

#define SS_KEEP_TIMING 32

#define SS_POST_FIRE_TIMING 64

#define SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/##X);\
/datum/controller/subsystem/##X/New(){\
    NEW_SS_GLOBAL(SS##X);\
    PreInit();\
}\
/datum/controller/subsystem/##X

#define PROCESSING_SUBSYSTEM_DEF(X) GLOBAL_REAL(SS##X, /datum/controller/subsystem/processing/##X);\
/datum/controller/subsystem/processing/##X/New(){\
    NEW_SS_GLOBAL(SS##X);\
    PreInit();\
}\
/datum/controller/subsystem/processing/##X
