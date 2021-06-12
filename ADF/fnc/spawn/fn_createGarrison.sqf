/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: Create Garrison
Author: Whiztler
Script version: 1.11

File: fn_createGarrison.sqf
**********************************************************************************
ABOUT:
This function creates a group (2, 4 or 8 pax) that will garrison/militarize/defend
a given area/position. The units will first populate all available empty turrets
(static weapons and vehicle turrets). If you do not want a turret to be populated
than lock the turret in the editor/script (lock, NOT lock player).

Units will look for buildings that have pre-defined (ARMA 3 engine) garrison
positions. There is a 60% chance they will populate the highest (incl roof)
positions first. 
Once all the garrison positions have been populated, the units that could not
get a garrison position will patrol the area (same radius). You can order the
patrol units to search nearby houses (default is false).
You can (optional) pass two functions. One that is executed on group level and one
that is executed for each unit of the group. See 'OPTIONAL PARAMETERS' for more
information.

INSTRUCTIONS:
Execute from the server or headless client.

REQUIRED PARAMETERS:
0. Position:    Spawn position. Marker, Object or Trigger.

OPTIONAL PARAMETERS:
1. Side:        west, east or independent. Default: east
2. Integer:     Group size: 1 - 8 units. Default: 4
3. Bool:        true for weapons squad, false for rifle squad. Default: false
4. Integer:     Radius in meters from the spawn position.  . Default: 50)
5. Bool:        Search buildings (patrol units)
                - true
                - false (default)
6. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
7. String:      Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.
8. Integer:     Maximum number of positions to be occuppied in each building.
                Default: -1 (uncapped)
9. Bool:        Roof top and top floor positions get prioritized for garrison?
                - true (default)
                - false

EXAMPLES USAGE IN SCRIPT:
[_spawnPos, west, 4, false, 100, false, "my_fnc_changeUniform"] call ADF_fnc_createGarrison;

EXAMPLES USAGE IN EDEN:
["mySpawnMarker", east, 8, true, 100, true, "", ""] call ADF_fnc_createGarrison;

DEFAULT/MINIMUM OPTIONS
["DefendMarker"] call ADF_fnc_createGarrison;

RETURNS:
Group
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_createGarrison"};

// Init
private _diag_time = diag_tickTime;
params [
	["_position", "", ["", [], objNull, grpNull]], 
	["_side", east, [west]], 
	["_size", 4, [0]], 
	["_weaponsSquad", false, [true]], 
	["_radius", 50], 
	["_searchBuildings", false, [true]], 
	["_code_1", "", [""]], 
	["_code_2", "", [""]], 
	["_maxBuildingPositions", -1, [0]], 
	["_roofTopPositions", true, [false]],
	["_groupType", "", [""]],
	["_groupSide", "", [""]],
	["_groupFaction", "", [""]]
];

// Check valid vars
if (_side == sideLogic) exitWith {[format ["ADF_fnc_createGarrison - %1  side passed. Exiting", _side], true] call ADF_fnc_log; grpNull};
if (_code_1 != "") then {if (isNil _code_1) then {if ADF_debug then {[format ["ADF_fnc_createGarrison - incorrect code (%1) passed. Defaulted to ''.", _code_1]] call ADF_fnc_log;}; _code_1 = "";}};
if (_code_2 != "") then {if (isNil _code_2) then {if ADF_debug then {[format ["ADF_fnc_createGarrison - incorrect code (%1) passed. Defaulted to ''.", _code_2]] call ADF_fnc_log;}; _code_2 = "";}};
if (_size > 8) then {_size = 8;};
if (_size < 2) then {_size = 2;};

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// check group size/type
private _groupTeam = switch (_size) do {
	case 1;
	case 2: {"InfSentry"};
	case 3;
	case 4;
	case 5: {"InfTeam"};
	case 6;
	case 7;
	case 8: {if (_weaponsSquad) then {"InfSquad_Weapons"} else {"InfSquad"}};		
	default {"InfTeam"};
};

switch _side do {
	case west:			{_groupSide = "WEST"; _groupFaction = "BLU_F"; _groupType = "BUS_"};
	case east: 			{_groupSide = "EAST"; _groupFaction = "OPF_F"; _groupType = "OIA_"};
	case independent:	{_groupSide = "INDEP"; _groupFaction = "IND_F"; _groupType = "HAF_"};
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
	if ADF_debug then {[format ["ADF_mod_createGarrison - call %1 for each unit of group: %2", _code_1, _group]] call ADF_fnc_log};
};

if (_code_2 != "") then {
	// Group
	[_group] call (call compile format ["%1", _code_2]);
	// Debug reporting
	if ADF_debug then {[format ["ADF_mod_createGarrison - call %1 for group: %2", _code_2, _group]] call ADF_fnc_log};		
};

// Garrison function
[_group, _position, _radius, _maxBuildingPositions, _searchBuildings, _roofTopPositions] spawn ADF_fnc_defendArea;


// Add the group to Zeus
if isServer then {
	[_group] call ADF_fnc_addToCurator;
} else {
	[_group] remoteExecCall ["ADF_fnc_addToCurator", 2];
};

// Debug Diag reporting
if ADF_debug then {[format ["ADF_mod_createGarrison - Diag time to execute function: %1", diag_tickTime - _diag_time]] call ADF_fnc_log};

// Return the group
_group