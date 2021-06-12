/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_unitSetSkill
Author: Whiztler
Script version: 1.05

File: fn_unitSetSkill.sqf
Diag: 0.0281 ms
**********************************************************************************
ABOUT
Function to change the skill set of an AI in one swoop. See optional parameters for
skill set options.

Applies skill to a single unit. Use ADF_fnc_groopSetSkill if you wish to apply a
skill set for an entire group.
Info: https://community.bistudio.com/wiki/AI_Sub-skills

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Object:      the unit you wish to apply the skill set to.

OPTIONAL PARAMETERS:
1. String:      The skill set to apply:
                "untrained" - unskilled, slow to react 
                "recruit"   - semi skilled
                "novice"    - Skilled, trained. Vanilla+ setting (default)
                "veteran"   - Very skilled, Well trained
                "expert"    - Special forces quality

EXAMPLES USAGE IN SCRIPT:
[_myUnit, "veteran"] call ADF_fnc_unitSetSkill;

EXAMPLES USAGE IN EDEN:
[this, "expert"] call ADF_fnc_unitSetSkill;

DEFAULT/MINIMUM OPTIONS
[_soldier] call ADF_fnc_unitSetSkill;

RETURNS:
Object
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_unitSetSkill"};

// Init
params [
	["_unit", objNull, [objNull]],
	["_skill", "novice", [""]]
];

// Check if an AI behavior mod is running. Exit the script if this is the case.
if (ADF_mod_ASRAI || {ADF_mod_VCOMAI} || {ADF_mod_BCOMBAT} || {ADF_mod_BAI}) exitWith {if ADF_debug then {["ADF_fnc_unitSetSkill - AI skill & behavior is controlled by a mod. Exiting."] call ADF_fnc_log;}; _unit};

// Check valid vars
if !(_unit isKindOf "CAManBase") exitWith {[format ["ADF_fnc_unitSetSkill - Incorrect unit passed: '%1'. Exiting", _unit], true] call ADF_fnc_log; false};
if ((_skill != "untrained") && {(_skill != "recruit")} && {(_skill != "novice")} && {(_skill != "veteran")} && {(_skill != "expert")}) then {_skill = "novice"; if ADF_debug then {[format ["ADF_fnc_unitSetSkill - incorrect skill (%1) passed for group: %2. Defaulted to 'novice'.",_skill, _g]] call ADF_fnc_log;}};

// Default skill values (novice)
private _cadet = false;
private _skill_1	= 0.15; // aimingAccuracy
private _skill_2	= 0.3; // aimingShake
private _skill_3	= 0.2; // aimingSpeed
private _skill_4	= 0.5; // endurance
private _skill_5	= 0.4; // spotDistance
private _skill_6	= 0.3; // spotTime
private _skill_7	= 0.5; // courage
private _skill_8	= 0.4; // reloadspeed
private _skill_9	= 0.4; // general
private _skill_10	= 0.6; // commanding
private _skill_11	= 0.3; // commanding

// Switch to selected skill set
switch _skill do {	
	case "untrained": {_skill_1 = 0.05; _skill_2 = 0.1; _skill_3 = 0.1; _skill_4 = 0.1; _skill_5 = 0.3; _skill_6 = 0.1; _skill_7 = 0.2; _skill_8 = 0.1; _skill_9 = 0.2; _skill_10 = 0.2; _skill_11 = 0; _cadet = true};
	case "recruit": {_skill_1 = 0.07; _skill_2 = 0.2; _skill_3 = 0.1; _skill_4 = 0.2; _skill_5 = 0.4; _skill_6 = 0.2; _skill_7 = 0.3; _skill_8 = 0.3; _skill_9 = 0.3; _skill_10 = 0.4; _skill_11 = 0.1};
	case "novice": {};
	case "veteran": {_skill_1 = 0.2; _skill_2 = 0.6; _skill_3 = 0.25; _skill_4 = 0.6; _skill_5 = 0.5; _skill_6 = 0.4; _skill_7 = 0.8; _skill_8 = 0.6; _skill_9 = 0.5; _skill_10 = 0.7; _skill_11 = 0.4};
	case "expert": {_skill_1 = 0.35; _skill_2 = 0.75; _skill_3 = 0.35; _skill_4 = 1; _skill_5 = 0.8; _skill_6 = 0.55; _skill_7 = 1; _skill_8 = 0.7; _skill_9 = 0.6; _skill_10 = 1; _skill_11 = 0.7;};
	default {};
};

/*
// Disabled due to invulnerable giunner bug ADF 2.25
// Set the skills
if _cadet then {_unit disableAI "FSM";};
_unit setSkill ["aimingAccuracy",_skill_1];
_unit setSkill ["aimingShake",_skill_2];
_unit setSkill ["aimingSpeed",_skill_3];
_unit setSkill ["endurance",_skill_4];		
_unit setSkill ["spotDistance",_skill_5];
_unit setSkill ["spotTime",_skill_6];
_unit setSkill ["courage",_skill_7];
_unit setSkill ["reloadspeed",_skill_8];	
_unit setSkill ["general",_skill_9];
if (_unit == leader group _unit) then {
	_unit setSkill ["commanding",_skill_10];
} else {
	_unit setSkill ["commanding",_skill_11];
};
*/

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_unitSetSkill - Skill set to '%1' for unit: %2", _skill, _unit]] call ADF_fnc_log};

// Return the unit object with extensive job training added
_unit