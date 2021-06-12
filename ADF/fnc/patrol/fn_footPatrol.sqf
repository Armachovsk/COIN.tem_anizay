/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: foot patrol script
Author: Whiztler
Script version: 1.13

File: ADF_fnc_footPatrol.sqf
Diag: 0.976563 ms
**********************************************************************************
ABOUT
This is an infantry foot patrol function for pre-existing (editor placed or
scripted) groups

INSTRUCTIONS:
Execute (call) fro the server or HC

REQUIRED PARAMETERS:
0. Group:       Group (aircraft crew)
1. position:    Center patrol start position. Marker, object, trigger or position
                array [x,y,z]

OPTIONAL PARAMETERS:
2. Number:      Waypoint radius in meters. Default: 500. Maximum: 5000
3. Number:      Number of total waypoints to patrol. Default: 4. Maximum: 10
4. String:      Waypoint type. Default: "MOVE"
                Info: https:community.bistudio.com/wiki/Waypoint_types
5. String:      Waypoint behaviour. Default: "SAFE"
                Info: https:community.bistudio.com/wiki/setWaypointBehaviour                
6. String:      Waypoint combat mode. Default: "WHITE"
                Info: https:community.bistudio.com/wiki/setWaypointCombatMode
7. String:      Waypoint speed. Default: "LIMITED"
                Info: https:community.bistudio.com/wiki/waypointSpeed
8. String:      Waypoint formation. Default: "FILE"
                Info: https:community.bistudio.com/wiki/waypointFormation
9. Number:      Waypoint completion radius. Default: 5
                Info: https:community.bistudio.com/wiki/setWaypointCompletionRadius
10. Bool:       Search buildings: 
                - true: Search buildings within a 50 meter radius upon waypoint
                  completion.
                - false: Do not search buildings (default)
11. Array:      Waypoint time out. Default: "[0,0,0]"
                Info: https://community.bistudio.com/wiki/setWaypointTimeout

EXAMPLES USAGE IN SCRIPT:
[_grp, _pos, 300, 3, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, true, [5,10,15]] call ADF_fnc_footPatrol;
[_myGroup, "PatrolMarker", 500, 4, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 5, false] call ADF_fnc_footPatrol;

EXAMPLES USAGE IN EDEN:
[group this, position this, 750, 5, "MOVE", "SAFE", "RED", "NORMAL", "WEDGE", 5, false] call ADF_fnc_footPatrol;

DEFAULT/MINIMUM OPTIONS
[_grp, "myMarker"] call ADF_fnc_footPatrol;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_footPatrol"};

// Init
params [
	["_group", grpNull, [grpNull]],
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 500, [0]],
	["_waypoints", 4, [0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "SAFE", [""]],
	["_wp_combatMode", "WHITE", [""]],
	["_wp_speed", "LIMITED", [""]],
	["_wp_formation", "FILE", [""]],
	["_wp_complRadius", 5, [0]],
	["_searchBuildings", false, [true]],
	["_wp_timeOut", [0,0,0], [[]], [3]],	
	["_index", -1, [0]]
];
// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_footPatrol - Empty group passed: %1. Exiting", _group], true] call ADF_fnc_log; false};
if (_radius > 5000) then {_radius = 5000};
if (_waypoints > 10) then {_waypoints = 10};
if (_wp_complRadius > (_radius / _waypoints)) then {_wp_complRadius = (_radius / _waypoints)};

// Check location position
_position = [_position] call ADF_fnc_checkPosition;

// Loop through the number of waypoints needed
for "_i" from 0 to (_waypoints - 1) do {
	_index = _index + 1;
	[_group, _position, _radius, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, "foot", _searchBuildings, _wp_timeOut, _index] call ADF_fnc_addWaypoint;
};

// Add a cycle waypoint
[_group, _position, _radius, "CYCLE", _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, "foot", _searchBuildings, _wp_timeOut, _index + 1] call ADF_fnc_addWaypoint;

// Remove the spawn/start waypoint
deleteWaypoint ((waypoints _group) # 0);

true