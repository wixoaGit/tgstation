//#define CONFIG_GET(X) global.config.Get(/datum/config_entry/##X)
#define CONFIG_GET(X) config.Get(/datum/config_entry/##X)//not_actual

#define CONFIG_ENTRY_LOCKED 1
#define CONFIG_ENTRY_HIDDEN 2