/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_searchBuilding
Author: Whiztler
Script version: 1.18

File: fn_searchBuilding.sqf
**********************************************************************************
This function can be used for a group leader to search a building close to him.
The function is used by ADF_fnc_foorPatrol.
The group leader searches a closeby building within the given radius. After
searching the group continues with their directives (e.g. waypoints, patrol, etc).

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Group:       group that will search the nearest building

OPTIONAL PARAMETERS:
1. Number:      Maximum search time in seconds. Default: 60.
2. Number:      Maximum distance to search for nearest building. Default: 50.

EXAMPLES USAGE IN SCRIPT:
[_grp, 30, 25] call ADF_fnc_searchBuilding;

EXAMPLES USAGE IN EDEN:
[group this, 120, 100] call ADF_fnc_searchBuilding;

DEFAULT/MINIMUM OPTIONS
[_grp] call ADF_fnc_searchBuilding;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_searchBuilding"};

// init
params [
	"_grp",
	["_maxTime", 60, [0]],
	["_distance", 50, [0]]
];
private _group = if (_grp isEqualType grpNull) then {_grp} else {group _grp};
private _leader = leader _group;
private _position = getPosASL _leader;

// Lock the wayoint cycle
_group lockwp true;

// Ownership change and debug reporting
if !(local _group) exitWith {if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_searchBuilding - Group %1 -- Ownership changed. Current owner ID: %2 [EXITING]", _group, (groupOwner _group)]] call ADF_fnc_log}};
if ADF_debug then {[format ["ADF_fnc_searchBuilding - starting. Time: %1 (search timer: %2 seconds) -- Max. search distance: %3 meters", time, _maxTime, _distance]] call ADF_fnc_log};

// Check the closest building and verify that the diatance group leader, building is less than 50 meters
private _building = nearestBuilding _position;
if ((isNil "_building") || {(_building == objNull)} || {((_position distance (getPosASL _building)) > _distance)}) exitWith {
	_group lockwp false;
	if ADF_debug then {[format ["ADF_fnc_searchBuilding - No results for group: %1 -- Building: %2 (distance: %4) -- Position group loader: %3", _group, _building, _position, round (_leader distance _building)]] call ADF_fnc_log};
};

// Get the building positions within the building
private _allBuildingPositions = [_building, 5] call BIS_fnc_buildingPositions;
_allBuildingPositionsCount = count _allBuildingPositions;
if ADF_debug then {[format ["ADF_fnc_searchBuilding - Group: %1 -- Building: %2 (distance: %5) -- Positions: %3 (max: %4)", _group, _building, count _allBuildingPositions, _allBuildingPositionsCount, round (_leader distance _building)]] call ADF_fnc_log};

// Order the leader to search max 4 of the building positions within the building.
for "_i" from 0 to _allBuildingPositionsCount do {
	// Set the timer
	private _searchTime = time + _maxTime;
	
	// Ownership change and debug reporting
	if !(local _group) exitWith {if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_searchBuilding - Group %1 -- Ownership changed. Current owner ID: %2 [EXITING]", _group, (groupOwner _group)]] call ADF_fnc_log}};
	if ADF_debug then {[format ["ADF_fnc_searchBuilding - Time: %1 (max time: %2)", time, _searchTime]] call ADF_fnc_log};
	
	// All positions searched. Continue with patrol
	if (_i == _allBuildingPositionsCount) exitWith {
		if ADF_debug then {[format ["ADF_fnc_searchBuilding - Group: %1 -- Last position reached. Position: %2", _group, _i]] call ADF_fnc_log};
		_group lockwp false;
	};	
	
	// Order the group leader to search the building positions
	_leader commandMove (_building buildingPos _i);
	if ADF_debug then {[format ["ADF_fnc_searchBuilding - SEARCHING Position: %1", _i]] call ADF_fnc_log};
	
	// Stop searching when the timer runs out
	if (time > _searchTime) exitWith {
		if ADF_debug then {[format ["ADF_fnc_searchBuilding - Group: %1 -- Search timer (%2 seconds) ran out: %3 seconds. Time: %4", _group, _maxTime, time - _searchTime, time]] call ADF_fnc_log};
		_group lockwp false;
	};
	
	waitUntil {sleep 1; unitready _leader || !(local _group) || !alive _leader};
	if ADF_debug then {[format ["ADF_fnc_searchBuilding - Finished Searching Position: %1 -- Time: %2", _i, time]] call ADF_fnc_log};
};

true
