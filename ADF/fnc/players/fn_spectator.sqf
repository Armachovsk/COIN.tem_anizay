/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_spectator
Author: Whiztler
Script version: 1.01

File: fn_spectator.sqf
**********************************************************************************
ABOUT
BIS spectator initialization. Handles TFAR and ACRE.

INSTRUCTIONS:
This function is exclusively used by the mission respawn template service.

RETURNS
Nothing
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_spectate"};

// Only players
if !hasInterface exitWith {diag_log "ADF Debug: ADF_fnc_teleport - ERROR! This entity cannot execute this function!"};

// Check if TFAR or ACRE are used
if ADF_mod_TFAR then {[player, true] call TFAR_fnc_forceSpectator};
if ADF_mod_ACRE then {[true] call acre_api_fnc_setSpectator};

// Init the BIS spectator
["Initialize", [player, [], true]] call BIS_fnc_EGSpectator;


