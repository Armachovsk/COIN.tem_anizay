// Reporting
if (time < 180 || {ADF_extRpt || {ADF_debug}}) then {diag_log "ADF rpt: Init - executing: scripts\init.sqf"};
private _tickTime = diag_tickTime;

// Set the local host prevention variable
if (!isMultiplayer && {!isNil "init_Exec"}) exitWith {diag_log format ["ADF rpt: Init - Local Client exiting to prevent double execution."]};
init_Exec = true;

//###########################################################################
//  GLOBAL MISSION VARIABLES
//###########################################################################

// Vars init
ADF_missionTest = false;
ADF_endMission = false;
if !isMultiplayer then {ADF_missionTest = true;};

COIN_air_1 = false;
COIN_air_2 = false;
COIN_air_3 = false;
COIN_airliftActive = false;
COIN_ambientAirSpawn = [];
COIN_ao_active = false;
COIN_ao_activeMarker = "";
COIN_ao_groups = [];
COIN_ao_spawned = false;
COIN_ao_vehicles = [];
COIN_clipperDropped = false;
COIN_clipperDropping = false;
COIN_clipperGo = false;
COIN_commandAssigned = false;
COIN_infPatch = true;
COIN_knightAssigned = false;
COIN_knightDumbAI = false;
COIN_knightNr = 0;
COIN_supportActive = false;
COIN_tomcatApproach = false;
COIN_tomcatDustoffFOB = false;
COIN_tomcatDustoffLZ = false;
COIN_tomcatGo = false;
COIN_TomcatKIA = false;
COIN_tomcatTouchdownFOB = false;
COIN_tomcatTouchdownLZ = false;
COIN_totalAOs = 0;
COIN_viperActive = false;
COIN_viperAssigned = false;
COIN_sideMission_complete = false;
COIN_sideMission_failed = false;
COIN_sideMission_completedNr = 0;
COIN_sideMission_groups = [];
COIN_sideMission_vehicles = [];
COIN_sideMission_spawned = false;
COIN_sideMission_skipped = false;
COIN_activeMission = [];
COIN_intelFoundActive = false;
COIN_EXEC_aoMissions = true;
COIN_EXEC_sideMissions = true;
COIN_EXEC_ACT = true;

COIN_fnc_aoSpawn = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  AO activated & Spawning"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_announceAO = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  AO Spawned announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_clearedAO = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  AO Cleared announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_knightAnnounce = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  KNIGHT activated announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_knightDestroyed = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  KNIGHT destroyed announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_knightDestroyedAO = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  KNIGHT KIA announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_knightAOarrive = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  KNIGHT on station announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_knightRTB = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  KNIGHT RTB announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_viper = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  VIPER activated 9-liner"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_tomcat = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  TOMCAT activated 9-liner"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_clipper = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  TOMCAT activated 9-liner"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_tomcatDestroyed = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  TOMCAT destroyed announcement"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_msg_sideMission = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  Side Mission Message"; diag_log "--------------------------------------------------------------------------------------------------------";};
COIN_fnc_intelFoundMsg = {diag_log "--------------------------------------------------------------------------------------------------------"; diag_log "« C O I N »  Side Mission Message"; diag_log "--------------------------------------------------------------------------------------------------------";};


// Params
if (("ADF_AO_missions" call BIS_fnc_getParamValue) == 0) then {COIN_EXEC_aoMissions = false};
if (("ADF_side_missions" call BIS_fnc_getParamValue) == 0) then {COIN_EXEC_sideMissions = false};
if (!COIN_EXEC_aoMissions && !COIN_EXEC_sideMissions) then {COIN_EXEC_aoMissions = true}; // Gotta have something to do
if (("ADF_map_ACT" call BIS_fnc_getParamValue) == 0) then {COIN_EXEC_ACT = false};
call {
	if (ADF_mod_RHS && {(("ADF_modOverride" call BIS_fnc_getParamValue) == 0)})  exitWith {ADF_mod_CFP = false};
	if (ADF_mod_CFP && {(("ADF_modOverride" call BIS_fnc_getParamValue) == 1)})  exitWith {
		ADF_mod_RHS = false;
		ADF_mod_PROPFOR = false;
		ADF_mod_3CB_FACT = false;
	};
};
//COIN_EXEC_aoMissions = false; // debug
//COIN_EXEC_sideMissions = false; // debug

// Global vars vars based on the map being played
#include "init_world_cfg.sqf"


if isServer then {
	#include "init_redress.sqf"
	#include "init_server.sqf"
};

if hasInterface then {
	#include "init_client.sqf"
};

if ADF_isHC then {
	#include "init_redress.sqf"
	#include "init_hc.sqf"
};

if ADF_HC_execute then {
	#include "init_ao.sqf"
};

#include "init_sup_command.sqf"
if COIN_EXEC_sideMissions then {execVM "scripts\init_sides.sqf"};

// Last line should be:
diag_log format ["ADF rpt: Init - FINISHED Scripts\init.sqf  [%1]", diag_tickTime - _tickTime];