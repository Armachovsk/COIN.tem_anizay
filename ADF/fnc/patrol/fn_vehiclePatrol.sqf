/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: Vehicle patrol script
Author: Whiztler
Script version: 1.10

File: ADF_fnc_vehiclePatrol.sqf
Diag: 1.03619 ms
**********************************************************************************
ABOUT
This is a vehicle patrol function for pre-spawned/editor placed (crewed) vehicles.

The function looks for roads. If no nearby road is found a waypoint is created
in the 'field'. Make sure the initial position is close to roads (or on a road)
and roads are within the radius. Keep the radius below 2000 else the script
might take a long time to search for suitable locations.

INSTRUCTIONS:
Execute (call) fro the server or HC

REQUIRED PARAMETERS:
0. Group:       Group (aircraft crew)
1. position:    Center patrol start position. Marker, object, trigger or position
                array [x,y,z]

OPTIONAL PARAMETERS:
2. Number:      Waypoint radius in meters. Default: 500. Maximum: 7500
3. Number:      Number of total waypoints to patrol. Default: 4
4. String:      Waypoint type. Default: "MOVE"
                Info: https:community.bistudio.com/wiki/Waypoint_types
5. String:      Waypoint behaviour. Default: "SAFE"
                Info: https:community.bistudio.com/wiki/setWaypointBehaviour                
6. String:      Waypoint combat mode. Default: "WHITE"
                Info: https:community.bistudio.com/wiki/setWaypointCombatMode
7. String:      Waypoint speed. Default: "LIMITED"
                Info: https:community.bistudio.com/wiki/waypointSpeed
8. Number:      Waypoint completion radius in meters. Default: 5
                Info: https:community.bistudio.com/wiki/setWaypointCompletionRadius
9. Array:       Waypoint time out. Default: "[0,0,0]"
                Info: https://community.bistudio.com/wiki/setWaypointTimeout

EXAMPLES USAGE IN SCRIPT:
[_grp, _myPosition, 800, 5, "MOVE", "SAFE", "RED", "LIMITED", 25] call ADF_fnc_vehiclePatrol;
[_c, "PatrolMarker", 1000, 6, "MOVE", "SAFE", "RED", "NORMAL", 25, [5,10,15]] call ADF_fnc_vehiclePatrol;

EXAMPLES USAGE IN EDEN:
[group this, position this, 800, 5, "MOVE", "SAFE", "GREEN", "LIMITED", 25] call ADF_fnc_vehiclePatrol;

DEFAULT/MINIMUM OPTIONS
[_grp, "marker"] call ADF_fnc_vehiclePatrol;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_vehiclePatrol"};

// Init
private _dt = diag_tickTime;
params [
	["_group", grpNull, [grpNull]],
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 1000,[0]],
	["_waypoints", 4, [0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "SAFE", [""]],
	["_wp_combatMode", "WHITE", [""]],
	["_wp_speed", "NORMAL", [""]],
	["_wp_complRadius", 25,[0]],
	["_wp_timeOut", [0,0,0], [[]], [3]],
	["_index", -1, [0]]
];

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_vehiclePatrol - Empty group passed: %1. Exiting", _group], true] call ADF_fnc_log; false};
if (_radius > 7500) then {_radius = 7500};
if (_waypoints > 10) then {_waypoints = 10};
if (_wp_complRadius > (_radius / _waypoints)) then {_wp_complRadius = (_radius / _waypoints)};

// Check location position
_position = [_position] call ADF_fnc_checkPosition;

// Loop through the number of waypoints needed
for "_i" from 0 to (_waypoints - 1) do {
	_index = _index + 1;
	[_group, _position, _radius, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, "COLUMN", _wp_complRadius, "road", false, _wp_timeOut, _index] call ADF_fnc_addWaypoint;
};

// Add a cycle waypoint
[_group, _position, _radius, "CYCLE", _wp_behaviour, _wp_combatMode, _wp_speed, "COLUMN", _wp_complRadius, "road", false, _wp_timeOut, _index + 1] call ADF_fnc_addWaypoint;

// Remove the spawn/start waypoint
deleteWaypoint ((waypoints _group) # 0);

// Debug Diag reporting
if ADF_debug then {[format ["ADF_fnc_vehiclePatrol - Diag time to execute function: %1",diag_tickTime - _dt]] call ADF_fnc_log};

true