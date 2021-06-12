/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_heliPilotAI
Author: Whiztler
Script version: 1.05

File: fn_heliPilotAI.sqf
Diag: 0.0123 ms
**********************************************************************************
ABOUT
Makes pilots perform their pilot duties even when under fire or when they
have spotted enemies. Works on both heli and jet pilots

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Object:      Aircraft pilot

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[driver _veh] call ADF_fnc_heliPilotAI;

EXAMPLES USAGE IN EDEN:
[driver this] call ADF_fnc_heliPilotAI;

DEFAULT/MINIMUM OPTIONS
[driver _veh] call ADF_fnc_heliPilotAI; 

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_heliPilotAI"};

// Init
params [
	["_unit", objNull, [objNull]]
];
private _group = group _unit;

// Check vars
if !(_unit isKindOf "CAManBase") exitWith {[format ["ADF_fnc_heliPilotAI - Incorrect unit passed. Must pass a vehicle crew member: '%1'. Exiting", _unit], true] call ADF_fnc_log; false}; 

// Disable targetting modes, combat modes for pilots
_unit setBehaviour "SAFE";
_group setCombatMode "BLUE";

// AI Enhance mods overrides
if ADF_mod_VCOMAI then {
	_group setVariable ["VCM_NOFLANK", true];
	_group setVariable ["VCM_NORESCUE", true];
	_group setVariable ["VCM_TOUGHSQUAD", true];
	_group setVariable ["Vcm_Disable", true]; 
	_group setVariable ["VCM_DisableForm", true]; 
	_group setVariable ["VCM_Skilldisable", true];
};
if ADF_mod_BCOMBAT then {_unit setVariable ["bcombat_fnc_is_active", false]};
//if (ADF_mod_ASRAI) then {};
_group setVariable ["lambs_danger_disableGroupAI", true]; // LAMBS Improved Danger.fsm

// BIS AI settings
_unit disableAI "SUPPRESSION"; 
_unit disableAI "CHECKVISIBLE";
_unit disableAI "TARGET";
_unit disableAI "AUTOTARGET";
_unit disableAI "AUTOCOMBAT";

_unit enableAttack false;
_unit allowFleeing 0;
_unit setSkill 0.9;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_heliPilotAI - Helicopter pilot AI aspects disabled for: %1", _unit]] call ADF_fnc_log};

true