/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_groupSetSkill
Author: Whiztler
Script version: 1.04

File: fn_groupSetSkill.sqf
**********************************************************************************
ABOUT
Applies skill to a group of AI units
Info: https://community.bistudio.com/wiki/AI_Sub-skills

INSTRUCTIONS:
Execute (call) from the server or HC (whoever owns the unit). The function is
ignored when a AI behavior mod (ASR, bCombat, vCom) is running on the server/HC.

REQUIRED PARAMETERS:
0. Group:       Existing group

OPTIONAL PARAMETERS:
1. String:      "untrained" - unskilled, slow to react 
                "recruit"   - semi skilled
                "novice"    - Skilled, trained. Vanilla+ setting
                "veteran"   - Very skilled, Well trained
                "expert"    - Special forces quality
                Default: novice

EXAMPLES USAGE IN SCRIPT:
[_myGroup, "veteran"] call ADF_fnc_groupSetSkill;

EXAMPLES USAGE IN EDEN:
[group this, "veteran"] call ADF_fnc_groupSetSkill;

DEFAULT/MINIMUM OPTIONS
[_myGroup] call ADF_fnc_groupSetSkill;

RETURNS:
group
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_groupSetSkill"};

// Init
params [
	["_group", grpNull, [grpNull]],
	["_skill", "novice", [""]]
];

// Check if an AI behavior mod is running. Exit the script if this is the case.
if (ADF_mod_ASRAI || {ADF_mod_VCOMAI} || {ADF_mod_BCOMBAT} || {ADF_mod_BAI})  exitWith {if ADF_debug then {["ADF_fnc_groupSetSkill - AI skill & behavior is controlled by a mod. Exiting."] call ADF_fnc_log;}; _group};

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_groupSetSkill - Empty group passed: %1. Exiting", _group]] call ADF_fnc_log; grpNull};
if ((_skill != "untrained") && {(_skill != "recruit")} && {(_skill != "novice")} && {(_skill != "veteran")} && {(_skill != "expert")}) then {	_skill = "novice"; if ADF_debug then {[format ["ADF_fnc_groupSetSkill - incorrect skill (%1) passed for group: %2. Defaulted to 'novice'.",_skill, _group]] call ADF_fnc_log;}};

// Default (Novice) skill set
private _cadet	= false;
private _skill_1	= 0.15; // aimingAccuracy
private _skill_2	= 0.3; // aimingShake
private _skill_3	= 0.2; // aimingSpeed
private _skill_4	= 0.5; // endurance
private _skill_5	= 0.4; // spotDistance
private _skill_6	= 0.3; // spotTime
private _skill_7	= 0.5; // courage
private _skill_8	= 0.4; // reloadspeed
private _skill_9	= 0.4; // general
private _skill_10	= 0.55; // commanding assigned leaders
private _skill_11	= 0.3; // commanding remaining team members

switch _skill do {	
	case "untrained"	: {_skill_1 = 0.05; _skill_2 = 0.1; _skill_3 = 0.1; _skill_4 = 0.1; _skill_5 = 0.3; _skill_6 = 0.1; _skill_7 = 0.2; _skill_8 = 0.1; _skill_9 = 0.2; _skill_10 = 0.2; _skill_11 = 0; _cadet = true};
	case "recruit"	: {_skill_1 = 0.07; _skill_2 = 0.2; _skill_3 = 0.1; _skill_4 = 0.2; _skill_5 = 0.4; _skill_6 = 0.2; _skill_7 = 0.3; _skill_8 = 0.3; _skill_9 = 0.3; _skill_10 = 0.4; _skill_11 = 0.1};
	case "veteran"	: {_skill_1 = 0.2; _skill_2 = 0.6; _skill_3 = 0.25; _skill_4 = 0.6; _skill_5 = 0.5; _skill_6 = 0.4; _skill_7 = 0.8; _skill_8 = 0.6; _skill_9 = 0.5; _skill_10 = 0.7; _skill_11 = 0.4};
	case "expert"	: {_skill_1 = 0.35; _skill_2 = 0.75; _skill_3 = 0.35; _skill_4 = 1; _skill_5 = 0.8; _skill_6 = 0.55; _skill_7 = 1; _skill_8 = 0.7; _skill_9 = 0.6; _skill_10 = 1; _skill_11 = 0.7; };
	case "novice";
	case default {};
};

{
	if (_cadet) then {_x disableAI "FSM";};
	_x setSkill ["aimingAccuracy",_skill_1];
	_x setSkill ["aimingShake",_skill_2];
	_x setSkill ["aimingSpeed",_skill_3];
	_x setSkill ["endurance",_skill_4];		
	_x setSkill ["spotDistance",_skill_5];
	_x setSkill ["spotTime",_skill_6];
	_x setSkill ["courage",_skill_7];
	_x setSkill ["reloadspeed",_skill_8];	
	_x setSkill ["general",_skill_9];
	if (_x == leader _group) then {
		_x setSkill ["commanding",_skill_10];
	} else {
		_x setSkill ["commanding",_skill_11];
	};
} forEach units _group;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_groupSetSkill - Skill (%1) set for group: %2", _skill, _group]] call ADF_fnc_log};

_group