/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: sea patrol script
Author: Whiztler
Script version: 1.05

File: ADF_fnc_seaPatrol.sqf
**********************************************************************************
ABOUT
This is an patrol function for pre-spawned, pre-crewed boats.

INSTRUCTIONS:
Execute (call) fro the server or HC

REQUIRED PARAMETERS:
0. Group:       Group (vessel crew)
1. position:    Center patrol start position. Marker, object, trigger or position
                array [x,y,z]

OPTIONAL PARAMETERS:
2. Number:      Waypoint radius in meters. Default: 1000. Maximum: 7500
3. Number:      Number of total waypoints to patrol. Default: 5. Maximum: 10
4. String:      Waypoint type. Default: "MOVE"
                Info: https:community.bistudio.com/wiki/Waypoint_types
5. String:      Waypoint behaviour. Default: "SAFE"
                Info: https:community.bistudio.com/wiki/setWaypointBehaviour                
6. String:      Waypoint combat mode. Default: "WHITE"
                Info: https:community.bistudio.com/wiki/setWaypointCombatMode
7. String:      Waypoint speed. Default: "LIMITED"
                Info: https:community.bistudio.com/wiki/waypointSpeed
8. String:      Waypoint formation. Default: "DIAMOND"
                Info: https:community.bistudio.com/wiki/waypointFormation
9. Number:      Waypoint completion radius in meters. Default: 15
                Info: https:community.bistudio.com/wiki/setWaypointCompletionRadius
10. Array:	   Waypoint time out. Default: "[0,0,0]"
                Info: https://community.bistudio.com/wiki/setWaypointTimeout

EXAMPLES USAGE IN SCRIPT:
[_grp, _Pos, 1000, 4, "MOVE", "COMBAT"] call ADF_fnc_seaPatrol;
[_grp, "PatrolMarker", 2500, 7, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 25, [5,10,15]] call ADF_fnc_seaPatrol;

EXAMPLES USAGE IN EDEN:
[group this, position this, 1500, 6, "MOVE", "SAFE", "RED", "NORMAL", "FILE", 35] call ADF_fnc_seaPatrol;

DEFAULT/MINIMUM OPTIONS
[_grp, "marker"] call ADF_fnc_seaPatrol;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_seaPatrol"};

// Init
params [
	["_group", grpNull, [grpNull]],
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 1000,[0]],
	["_waypoints", 5,[0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "SAFE", [""]],
	["_wp_combatMode", "WHITE", [""]],
	["_wp_speed", "NORMAL", [""]],
	["_wp_formation", "DIAMOND", [""]],
	["_wp_complRadius", 15,[0]],
	["_wp_timeOut", [0,0,0], [[]], [3]],
	["_index", -1, [0]]	
];

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_seaPatrol - Empty group passed: %1. Exiting", _group], true] call ADF_fnc_log; false};
if (_radius > 7500) then {_radius = 7500};
if (_waypoints > 10) then {_waypoints = 10};
if (_wp_complRadius > (_radius / _waypoints)) then {_wp_complRadius = (_radius / _waypoints)};

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Loop through the number of waypoints needed
for "_i" from 0 to (_waypoints - 1) do {
	_index = _index + 1;
	[_group, _position, _radius, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, "sea", false, _wp_timeOut, _index] call ADF_fnc_addWaypoint;
};

// Add a cycle waypoint
[_group, _position, _radius, "CYCLE", _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, "sea", false, _wp_timeOut, _index + 1] call ADF_fnc_addWaypoint;

// Remove the spawn/start waypoint
deleteWaypoint ((waypoints _group) # 0);

true