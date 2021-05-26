#define NUM_E 2.71828183

#define PI						3.1416
#define INFINITY				1e31

#define TICK_DELTA_TO_MS(percent_of_tick_used) ((percent_of_tick_used) * world.tick_lag)

#define CLAMP01(x) (CLAMP(x, 0, 1))

//#define REALTIMEOFDAY (world.timeofday + (MIDNIGHT_ROLLOVER * MIDNIGHT_ROLLOVER_CHECK))
#define REALTIMEOFDAY world.timeofday//not_actual

#define CEILING(x, y) ( -round(-(x) / (y)) * (y) )

#define FLOOR(x, y) ( round((x) / (y)) * (y) )

#define CLAMP(CLVALUE,CLMIN,CLMAX) ( max( (CLMIN), min((CLVALUE), (CLMAX)) ) )

#define WRAP(val, min, max) ( min == max ? min : (val) - (round(((val) - (min))/((max) - (min))) * ((max) - (min))) )

#define MODULUS(x, y) ( (x) - (y) * round((x) / (y)) )

#define ATAN2(x, y) ( !(x) && !(y) ? 0 : (y) >= 0 ? arccos((x) / sqrt((x)*(x) + (y)*(y))) : -arccos((x) / sqrt((x)*(x) + (y)*(y))) )

#define SIMPLIFY_DEGREES(degrees) (MODULUS((degrees), 360))

#define GET_ANGLE_OF_INCIDENCE(face, input) (MODULUS((face) - (input), 360))