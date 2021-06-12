/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Foot Patrol
Author: Whiztler
Script version: 1.18

File: ADF_fnc_createFootPatrol.sqf
Diag: 70.3125 ms
**********************************************************************************
ABOUT
This function creates an infantry group (2, 4 or 8 pax) that patrols a predefined
position. The function creates waypoints for a given radius. There are options you
can define such as waypoint behaviour/speed/etc. and search nearest building.
You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute from the server or headless client.

REQUIRED PARAMETERS:
0: Position:    Spawn position. Marker, Object or Trigger.              

OPTIONAL PARAMETERS:
1. Side:        west, east or independent. Default: east
2. Integer:     Group size: 1 - 8 units. Default: 4
3. Bool:        true for weapons squad, false for rifle squad. Default: false
4. Integer:     Radius in meters from the spawn position. Default: 250
5. Integer:     Number of patrol waypoints. Default: 4
6. String:      Waypoint type. Info: https://community.bistudio.com/wiki/Waypoint_types (Default: "MOVE")
7. String:      Waypoint behaviour. Info: https://community.bistudio.com/wiki/setWaypointBehaviour (Default: "SAFE")
8. String:      Combat mode. Info: https://community.bistudio.com/wiki/setWaypointCombatMode (Default: "YELLOW")
9. String:      Waypojnt speed. Info: https://community.bistudio.com/wiki/waypointSpeed (Default: "LIMITED")
10. String:     Waypoint formation. Info: https://community.bistudio.com/wiki/waypointFormation
11. Integer:    Completion radius. Info: https://community.bistudio.com/wiki/setWaypointCompletionRadius
12. Bool:       Search buildings (patrol units):
                - true: search nearest building
                - false: Do not search nearest building. (Default)
13. String:     Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
14. String:     Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc. 
15. Array:      Waypoint time out. Default: "[0,0,0]"
                Info: https://community.bistudio.com/wiki/setWaypointTimeout

EXAMPLES USAGE IN SCRIPT:
[_spawnPos, west, 6, true, 1000, 6, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, true, "", "", [5,10,15]] call ADF_fnc_createFootPatrol;

EXAMPLES USAGE IN EDEN:
["myMarker", east, 8, true, 500, 6, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false, "fnc_myFunction", ""] call ADF_fnc_createFootPatrol;

DEFAULT/MINIMUM OPTIONS
["myMarker"] call ADF_fnc_createFootPatrol;

RETURNS:
Group
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createFootPatrol"};

// Init
private _dt = diag_tickTime;
params [
	["_position", "", ["", [], objNull, grpNull]], 
	["_side", east, [west]], 
	["_size", 5, [0]], 
	["_weaponsSquad", false, [true]], 
	["_radius", 250, [0]], 
	["_waypoints", 4, [0]], 
	["_wp_type", "MOVE", [""]], 
	["_wp_behaviour", "SAFE", [""]], 
	["_wp_combatMode", "YELLOW", [""]], 
	["_wp_speed", "LIMITED", [""]], 
	["_wp_formation", "COLUMN", [""]], 
	["_wp_complRadius", 5, [0]], 
	["_searchBuildings", false, [true]], 
	["_code_1", "", [""]], 
	["_code_2", "", [""]],
	["_wp_timeOut", [0,0,0], [[]], [3]],
	["_groupType", "", [""]],
	["_groupSide", "", [""]],
	["_groupFaction", "", [""]]
];

// Check valid vars
if (_side == sideLogic) exitWith {[format ["ADF_fnc_createFootPatrol - %1  side passed. Exiting", _side], true] call ADF_fnc_log; grpNull};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createFootPatrol - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createFootPatrol - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if (_size > 8) then {_size = 8;};
if (_size < 2) then {_size = 2;};

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// check group size/type
private _groupTeam = switch _size do {
	case 1;
	case 2: {"InfSentry"};
	case 3;
	case 4;
	case 5: {selectRandom ["InfTeam", "InfTeam_AA", "InfTeam_AT"]};
	case 6;
	case 7;
	case 8: {if (_weaponsSquad) then {"InfSquad_Weapons"} else {"InfSquad"}};		
	default {"InfTeam"};
};

switch _side do {
	case west:			{_groupSide = "WEST"; _groupFaction = "BLU_F"; _groupType = "BUS_"};
	case east: 			{_groupSide = "EAST"; _groupFaction = "OPF_F"; _groupType = "OIA_"};
	case independent:		{_groupSide = "INDEP"; _groupFaction = "IND_F"; _groupType = "HAF_"};
};

private _acmGroup = format ["%1%2", _groupType, _groupTeam];

//Create the group
private _group = [_position, _side, (configFile >> "CfgGroups" >> _groupSide >> _groupFaction >> "Infantry" >> _acmGroup)] call BIS_fnc_spawnGroup;
_group deleteGroupWhenEmpty true;

// Execute custom passed code/function
if (_code_1 != "") then {
	// Each unit in the group
	{[_x] call (call compile format ["%1", _code_1])} forEach units _group;
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createFootPatrol - call %1 for each unit of group: %2", _code_1, _group]] call ADF_fnc_log};	
};

if (_code_2 != "") then {
	// Group
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_createFootPatrol - call %1 for group: %2", _code_2, _group]] call ADF_fnc_log};		
};

// Create the foot patrol for the created group
[_group, _position, _radius, _waypoints, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, _searchBuildings, _wp_timeOut] call ADF_fnc_footPatrol;
{_x allowDamage true} forEach units _group; // hack - ADF 2.22

// Add the group to Zeus
if isServer then {
	[_group] call ADF_fnc_addToCurator;
} else {
	[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];
};

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_createFootPatrol - Diag time to execute function: %1", diag_tickTime - _dt]] call ADF_fnc_log};

// Return the group
_group