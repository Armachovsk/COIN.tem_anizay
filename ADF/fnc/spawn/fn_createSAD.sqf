/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: search and destroy
Author: Whiztler
Script version: 1.06

File: fn_createSAD.sqf
**********************************************************************************
ABOUT
This function spawns an infantry group that actively tracks another group and
assaults them when possible.

You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute (call) fro the server or HC

REQUIRED PARAMETERS:
0. Group:       Group that will be tracked/assaulted.

OPTIONAL PARAMETERS:
1. Side:        Side of OpFor. Default: east 
2. Integer:     Opfor group size. 2, 4 or 8. Default: 4
3. Integer:     Spawn distance in meters. Default: 500
4. String:      Skill set:
                "untrained"
                "recruit"
                "novice" (default)
                "veteran"
                "expert"
5. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
6. String:      Code to execute on the crew of a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.
7. String:      This can be a variable set to either true or false. At the end off
                each cycle it checks the variable. If set to true it stops the
                cycle. By default it is set to false (infinite cycle).
8. Bool:        Set skill:
                true (default)
                false

EXAMPLES USAGE IN SCRIPT:
[_targetGrp, east, 8, 300, "veteran", "", "my_fnc_uniformChange", "cancelHunt"] call ADF_fnc_createSAD;
[_targetGrp, east, 2] call ADF_fnc_createSAD;

EXAMPLES USAGE IN EDEN:
[enemyGroup_1, west, 8] call ADF_fnc_createSAD;

DEFAULT/MINIMUM OPTIONS
[_grp] call ADF_fnc_createSAD;

RETURNS:
SAD group
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createSAD"};

// Init
params [
	["_targetGroup", grpNull, [grpNull]], 
	["_side", east, [west]], 
	["_size", 4, [0]], 
	["_radius", 500, [999]], 
	["_skillSet", "novice", [""]], 
	["_code_1", "", [""]], 
	["_code_2", "", [""]], 
	["_exitCheck", false, ["", true]],
	["_setSkill", true, [false]],
	["_groupType", "", [""]], 
	["_groupSide", "", [""]], 
	["_groupFaction", "", [""]] 
];

// Check valid vars
if (_targetGroup == grpNull) exitWith {[format ["ADF_fnc_createSAD - Invalid group passed: %1. Exiting", _targetGroup]] call ADF_fnc_log; grpNull};	
if (_side == civilian || {_side == sideLogic}) exitWith {[format ["ADF_fnc_createSAD - %1 SAD side passed for group %2. Exiting", _side, _targetGroup]] call ADF_fnc_log; grpNull};
if (_side == side _targetGroup) exitWith {[format ["ADF_fnc_createSAD - It seems the tracking group side (%1) is the same as the target group side (%2). Exiting", _side, side _targetGroup]] call ADF_fnc_log; grpNull};
if (_radius < 250) then {_radius = 250;};
if (_size > 8) then {_size = 8;};
if (	(_skillSet != "untrained") && {(_skillSet != "recruit") && {(_skillSet != "novice") && {(_skillSet != "veteran") && {(_skillSet != "expert")}}}}) then {_skillSet = "novice"; if ADF_debug then {[format ["ADF_fnc_createSAD - incorrect skill (%1) passed. Defaulted to 'novice'.", _skillSet]] call ADF_fnc_log;}};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createSAD - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createSAD - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
	
// check group size/type
private _groupTeam = switch _size do {
	case 1;
	case 2: {"InfSentry", "SniperTeam"};
	case 3;
	case 4;
	case 5: {selectRandom ["InfTeam", "InfTeam_AA", "InfTeam_AT"]};
	case 6;
	case 7;
	case 8: {selectRandom ["InfSquad_Weapons", "InfSquad"]};		
	default {"InfTeam"};
};

switch _side do {
	case west:			{_groupSide = "WEST"; _groupFaction = "BLU_F"; _groupType = "BUS_"};
	case east: 			{_groupSide = "EAST"; _groupFaction = "OPF_F"; _groupType = "OIA_"};
	case independent:		{_groupSide = "INDEP"; _groupFaction = "IND_F"; _groupType = "HAF_"};
};

// Determine spawn position
private _position = [_targetGroup, _radius] call ADF_fnc_randomPosMax;

// Format the group class
private _acmGroup = format ["%1%2", _groupType, _groupTeam];

// Create the SAD group
private _group = [_position, _side, (configFile >> "CfgGroups" >> _groupSide >> _groupFaction >> "Infantry" >> _acmGroup)] call BIS_fnc_spawnGroup;
_group deleteGroupWhenEmpty true;
_group setBehaviour "CARELESS";
_group allowFleeing 0;

// Set the given skill set
if _setSkill then {[_group, _skillSet] call ADF_fnc_groupSetSkill};

// Execute custom passed code/function
if (_code_1 != "") then {
	// Each unit in the group
	{[_x] call (call compile format ["%1", _code_1])} forEach units _group;
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createSAD - call %1 for each unit of group: %2", _code_1, _group]] call ADF_fnc_log};	
};

if (_code_2 != "") then {
	// Group
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createSAD - call %1 for group: %2", _code_2, _group]] call ADF_fnc_log};		
};

// call the SAD function
[_group, _targetGroup, _exitCheck] spawn ADF_fnc_sad;
{_x allowDamage true} forEach units _group; // hack ADF 2.22

// Add the SAD group to Zeus
if isServer then {
	[_group] call ADF_fnc_addToCurator;
} else {
	[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];
};	

// Return the new group
_group