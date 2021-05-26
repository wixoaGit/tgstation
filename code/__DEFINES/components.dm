#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? NONE : target._SendSignal(sigtype, list(target, ##arguments)) )

#define GET_COMPONENT_FROM(varname, path, target) var##path/##varname = ##target.GetComponent(##path)
#define GET_COMPONENT(varname, path) GET_COMPONENT_FROM(varname, path, src)

#define COMPONENT_INCOMPATIBLE 1

#define COMPONENT_DUPE_HIGHLANDER		0
#define COMPONENT_DUPE_ALLOWED			1
#define COMPONENT_DUPE_UNIQUE			2
#define COMPONENT_DUPE_UNIQUE_PASSARGS	4

#define COMSIG_GLOB_NEW_Z "!new_z"
#define COMSIG_GLOB_VAR_EDIT "!var_edit"
#define COMSIG_GLOB_MOB_CREATED "!mob_created"
#define COMSIG_GLOB_MOB_DEATH "!mob_death"

#define COMSIG_COMPONENT_ADDED "component_added"
#define COMSIG_COMPONENT_REMOVING "component_removing"
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"
#define COMSIG_PARENT_QDELETED "parent_qdeleted"

#define COMSIG_PARENT_ATTACKBY "atom_attackby"
	#define COMPONENT_NO_AFTERATTACK 1
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
#define COMSIG_PARENT_EXAMINE "atom_examine"
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
	#define EXAMINE_POSITION_ARTICLE 1
	#define EXAMINE_POSITION_BEFORE 2
	#define COMPONENT_EXNAME_CHANGED 1
#define COMSIG_ATOM_ENTERED "atom_entered"
#define COMSIG_ATOM_EXIT "atom_exit"
	#define COMPONENT_ATOM_BLOCK_EXIT 1
#define COMSIG_ATOM_EXITED "atom_exited"
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"
#define COMSIG_ATOM_RAD_PROBE "atom_rad_probe"
	#define COMPONENT_BLOCK_RADIATION 1
#define COMSIG_ATOM_RAD_CONTAMINATING "atom_rad_contam"
	#define COMPONENT_BLOCK_CONTAMINATION 1
#define COMSIG_ATOM_RAD_WAVE_PASSING "atom_rad_wave_pass"
  #define COMPONENT_RAD_WAVE_HANDLED 1
#define COMSIG_ATOM_CANREACH "atom_can_reach"
	#define COMPONENT_BLOCK_REACH 1
#define COMSIG_ATOM_SCREWDRIVER_ACT "atom_screwdriver_act"
#define COMSIG_ATOM_INTERCEPT_TELEPORT "intercept_teleport"
	#define COMPONENT_BLOCK_TELEPORT 1

#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
	#define COMPONENT_NO_ATTACK_HAND 1

#define COMSIG_ENTER_AREA "enter_area"
#define COMSIG_EXIT_AREA "exit_area"

#define COMSIG_CLICK "atom_click"
#define COMSIG_CLICK_SHIFT "shift_click"
#define COMSIG_CLICK_CTRL "ctrl_click"
#define COMSIG_CLICK_ALT "alt_click"
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"
	#define COMPONENT_NO_MOUSEDROP 1
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"

#define COMSIG_AREA_ENTERED "area_entered"
#define COMSIG_AREA_EXITED "area_exited"

#define COMSIG_TURF_CHANGE "turf_change"
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"

#define COMSIG_MOVABLE_MOVED "movable_moved"
#define COMSIG_MOVABLE_CROSS "movable_cross"
#define COMSIG_MOVABLE_CROSSED "movable_crossed"
#define COMSIG_MOVABLE_UNCROSS "movable_uncross"
	#define COMPONENT_MOVABLE_BLOCK_UNCROSS 1
#define COMSIG_MOVABLE_UNCROSSED "movable_uncrossed"
#define COMSIG_MOVABLE_BUMP "movable_bump"
#define COMSIG_MOVABLE_IMPACT "movable_impact"
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"
#define COMSIG_MOVABLE_BUCKLE "buckle"
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"
	#define COMPONENT_CANCEL_THROW 1
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit"
#define COMSIG_MOVABLE_SECLUDED_LOCATION "movable_secluded"
#define COMSIG_MOVABLE_HEAR "movable_hear"
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"

#define COMSIG_MOB_DEATH "mob_death"
#define COMSIG_MOB_CLICKON "mob_clickon"
	#define COMSIG_MOB_CANCEL_CLICKON 1
#define COMSIG_MOB_ALLOWED "mob_allowed"
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_BLOCK_MAGIC 1
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
#define COMSIG_MOB_THROW "mob_throw"
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"

#define COMSIG_LIVING_RESIST "living_resist"
#define COMSIG_LIVING_IGNITED "living_ignite"
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"

#define COMSIG_LIVING_STATUS_STUN "living_stun"
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
	#define COMPONENT_NO_STUN 1

#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"

#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"

#define COMSIG_ITEM_ATTACK "item_attack"
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"
	#define COMPONENT_NO_INTERACT 1
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"
	#define COMPONENT_NO_ATTACK_OBJ 1
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"
	#define COMPONENT_NO_ATTACK 1
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"
#define COMSIG_ITEM_EQUIPPED "item_equip"
#define COMSIG_ITEM_DROPPED "item_drop"
#define COMSIG_ITEM_PICKUP "item_pickup"
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
#define COMSIG_ITEM_HIT_REACT "item_hit_react"

#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"

#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING 1
#define COMSIG_IMPLANT_OTHER "implant_other"
	#define COMPONENT_DELETE_NEW_IMPLANT 2
	#define COMPONENT_DELETE_OLD_IMPLANT 4
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"

#define COMSIG_PDA_CHANGE_RINGTONE "pda_change_ringtone"
	#define COMPONENT_STOP_RINGTONE_CHANGE 1

#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"

#define COMSIG_PEN_ROTATED "pen_rotated"

#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"

#define COMSIG_SPECIES_GAIN "species_gain"
#define COMSIG_SPECIES_LOSS "species_loss"

#define COMSIG_TURF_IS_WET "check_turf_wet"
#define COMSIG_TURF_MAKE_DRY "make_turf_try"
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"

#define COMSIG_FOOD_EATEN "food_eaten"

#define COMSIG_ADD_MOOD_EVENT "add_mood"
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood"

#define COMSIG_COMPONENT_NTNET_RECEIVE "ntnet_receive"

#define COMSIG_HAS_NANITES "has_nanites"
#define COMSIG_NANITE_GET_PROGRAMS	"nanite_get_programs"
#define COMSIG_NANITE_SET_VOLUME "nanite_set_volume"
#define COMSIG_NANITE_ADJUST_VOLUME "nanite_adjust"
#define COMSIG_NANITE_SET_MAX_VOLUME "nanite_set_max_volume"
#define COMSIG_NANITE_SET_CLOUD "nanite_set_cloud"
#define COMSIG_NANITE_SET_SAFETY "nanite_set_safety"
#define COMSIG_NANITE_SET_REGEN "nanite_set_regen"
#define COMSIG_NANITE_SIGNAL "nanite_signal"
#define COMSIG_NANITE_SCAN "nanite_scan"
#define COMSIG_NANITE_UI_DATA "nanite_ui_data"
#define COMSIG_NANITE_ADD_PROGRAM "nanite_add_program"
	#define COMPONENT_PROGRAM_INSTALLED		1
	#define COMPONENT_PROGRAM_NOT_INSTALLED		2
#define COMSIG_NANITE_SYNC "nanite_sync"

#define COMSIG_CONTAINS_STORAGE "is_storage"
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"

#define COMSIG_ACTION_TRIGGER "action_trigger"
	#define COMPONENT_ACTION_BLOCK_TRIGGER 1

#define REDIRECT_TRANSFER_WITH_TURF 1

#define ARCH_PROB "probability"
#define ARCH_MAXDROP "max_drop_amount"

#define CALTROP_BYPASS_SHOES 1
#define CALTROP_IGNORE_WALKERS 2

#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
#define COMSIG_XENO_SLIME_CLICK_ALT "xeno_slime_click_alt"
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"
