#define HELPER_PARTIAL(Fulltype, Iconbase, Color) \
	##Fulltype {						\
		pipe_color = Color;				\
		color = Color;					\
	}									\
	##Fulltype/visible {				\
		level = PIPE_VISIBLE_LEVEL;		\
		layer = GAS_PIPE_VISIBLE_LAYER;	\
	}									\
	##Fulltype/visible/layer1 {			\
		piping_layer = 1;				\
		icon_state = Iconbase + "-1";	\
	}									\
	##Fulltype/visible/layer3 {			\
		piping_layer = 3;				\
		icon_state = Iconbase + "-3";	\
	}									\
	##Fulltype/hidden {					\
		level = PIPE_HIDDEN_LEVEL;		\
	}									\
	##Fulltype/hidden/layer1 {			\
		piping_layer = 1;				\
		icon_state = Iconbase + "-1";	\
	}									\
	##Fulltype/hidden/layer3 {			\
		piping_layer = 3;				\
		icon_state = Iconbase + "-3";	\
	}
	

#define HELPER_PARTIAL_NAMED(Fulltype, Iconbase, Name, Color) \
	HELPER_PARTIAL(Fulltype, Iconbase, Color)	\
	##Fulltype {								\
		name = Name;							\
	}

#define HELPER(Type, Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/simple/##Type, "pipe11", Color) 		\
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/manifold/##Type, "manifold", Color)		\
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/manifold4w/##Type, "manifold4w", Color)

#define HELPER_NAMED(Type, Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/simple/##Type, "pipe11", Name, Color) 		\
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/manifold/##Type, "manifold", Name, Color)		\
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/manifold4w/##Type, "manifold4w", Name, Color)

HELPER(general, null)
//HELPER(yellow, rgb(255, 198, 0))
HELPER(yellow, "#FFC600")//not_actual
//HELPER(cyan, rgb(0, 255, 249))
HELPER(cyan, "#00FFF9")//not_actual
//HELPER(green, rgb(30, 255, 0))
HELPER(green, "#1EFF00")//not_actual
//HELPER(orange, rgb(255, 129, 25))
HELPER(orange, "#FF8119")//not_actual
//HELPER(purple, rgb(128, 0, 182))
HELPER(purple, "#8000B6")//not_actual
//HELPER(dark, rgb(69, 69, 69))
HELPER(dark, "#454545")//not_actual
//HELPER(brown, rgb(178, 100, 56))
HELPER(brown, "#B26438")//not_actual
//HELPER(violet, rgb(64, 0, 128))
HELPER(violet, "#400080")//not_actual

//HELPER_NAMED(scrubbers, "scrubbers pipe", rgb(255, 0, 0))
HELPER_NAMED(scrubbers, "scrubbers pipe", "#FF0000")//not_actual
//HELPER_NAMED(supply, "air supply pipe", rgb(0, 0, 255))
HELPER_NAMED(supply, "air supply pipe", "#0000FF")//not_actual
//HELPER_NAMED(supplymain, "main air supply pipe", rgb(130, 43, 255))
HELPER_NAMED(supplymain, "main air supply pipe", "#822BFF")//not_actual

#undef HELPER_NAMED
#undef HELPER
#undef HELPER_PARTIAL_NAMED
#undef HELPER_PARTIAL