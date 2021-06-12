/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_defendAreaPatrol
Author: Whiztler
Script version: 1.17

File: fn_defendAreaPatrol.sqf
**********************************************************************************
ABOUT
The defendAreaPatrol function is executed by the defendArea function for units
that cannot be garrisoned (no buildings, or no positions left). The remaining
units are grouped in a new group and send out to patrol the area. Same radius as
the garrison area radius.

INSTRUCTIONS:
Called from ADF_fnc_defendArea

REQUIRED PARAMETERS:
0: Number:      Index for reporting
1: Group:       Left over units for the garrison group
2: Array:       Position [X, Y, Z]

OPTIONAL PARAMETERS:
3: Number:      Radius in meters (default: 75)
4. Bool:        Search nearby building (default: false)

EXAMPLE
Called from within ADF_fnc_defendArea

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_defendAreaPatrol"};

// Init
private _diag_time = diag_tickTime;
params [
	["_index", 0, [0]],
	["_group", grpNull, [grpNull]],
	["_position", [], ["", [], objNull, grpNull]],
	["_radius", 75, [0]],
	["_searchBuildings", false, [true]],
	["_array", [], [[]]]
];

// Debug reporting
if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_defendAreaPatrol - Group units: %1", units _group]] call ADF_fnc_log};

// Check if the unit is garrisoned
{
	if !(_x getVariable ["ADF_garrSet",true]) then {
		_array append [_x];
		// Debug reporting
		if ADF_debug then {[format ["ADF_fnc_defendAreaPatrol - Unit: %1 -- ADF_garrSet: %2", _x, _x getVariable ["ADF_garrSet",true]]] call ADF_fnc_log};
	}
} forEach units _group;	

// Debug reporting
if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_defendAreaPatrol - # garrisoned units: %1 -- # patrol units: %2 -- Patrol units: %3",_index, count _array, _array]] call ADF_fnc_log};

// Create a new group for not-garrisoned units 
private _patrolGroup = createGroup (side _group);
{[_x] joinSilent _patrolGroup} forEach _array;

// Check and set the patrol radius/distance
if (_radius < 75) then {_radius = 75};

// Send the group on patrol, set the variable as non-garrisoned and re-enable the combat mode
[_patrolGroup, _position, _radius, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, _searchBuildings, [5, 25, 10]] call ADF_fnc_footPatrol;
_patrolGroup setVariable ["ADF_hc_garrison_ADF", false];
_patrolGroup enableAttack true;

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_defendAreaPatrol - Diag time to execute function: %1",diag_tickTime - _diag_time]] call ADF_fnc_log};

true