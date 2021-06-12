/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Script: air patrol script
Author: Whiztler
Script version: 1.19

File: ADF_fnc_airPatrol.sqf
Diag: 0.976563 ms
**********************************************************************************
ABOUT
This is an patrol function for pre-spawned, crewed aircraft. 

INSTRUCTIONS:
Execute from the server

REQUIRED PARAMETERS:
0. Group:       Group (aircraft crew)
1. position:    Center patrol start position. Marker, object, trigger or position
                array [x,y,z]

OPTIONAL PARAMETERS:
2. Number:      Waypoint radius in meters. Default: 2500 
3. Number:      Aircraft altitude (above ground level in meters). Default: 100
4. Number:      Number of total waypoints to patrol. Default: 4
5. String:      Waypoint type. Default: "MOVE"
                Info: https:community.bistudio.com/wiki/Waypoint_types
6. String:      Waypoint behaviour. Default: "SAFE"
                Info: https:community.bistudio.com/wiki/setWaypointBehaviour                
7. String:      Waypoint combat mode. Default: "WHITE"
                Info: https:community.bistudio.com/wiki/setWaypointCombatMode
8. String:      Waypoint speed. Default: "LIMITED"
                Info: https:community.bistudio.com/wiki/waypointSpeed
9. String:      Waypoint formation. Default: "FILE"
                Info: https:community.bistudio.com/wiki/waypointFormation
10. Number:     Waypoint completion radius in meters. Default: 5
                Info: https:community.bistudio.com/wiki/setWaypointCompletionRadius
11. Bool        Pilot Behavior: 
                - true: Pilots do not ignore combat situations. 
                - false: Pilots ignore combat situations. (Default)  

EXAMPLES USAGE IN SCRIPT:
[_grp, _Position, 1000, 100, 5, "MOVE", "SAFE", "RED", "LIMITED", "FILE", 250, false] call ADF_fnc_airPatrol;

EXAMPLES USAGE IN EDEN:
[group this, position this, 5000, 100, 8, "MOVE", "SAFE", "RED", "NORMAL", "FILE", 250, false] call ADF_fnc_airPatrol;

DEFAULT/MINIMUM OPTIONS
[_grp, "ap_marker"] call ADF_fnc_airPatrol;

RETURNS:
Bool (success flag)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_airPatrol"};

// Init
params [
	["_group", grpNull, [grpNull]],
	["_position", "", ["", [], objNull, grpNull, locationNull]],
	["_radius", 2500, [0]],
	["_altitude" , 100, [0]],
	["_waypoints", 4, [0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "SAFE", [""]],
	["_wp_combatMode", "WHITE", [""]],
	["_wp_speed", "LIMITED", [""]],
	["_wp_formation", "DIAMOND", [""]],
	["_wp_complRadius", 250, [0]],
	["_behaviourDisabled", false, [false]],
	["_index", 0, [0]]
];

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_airPatrol - Empty group passed: %1. Exiting", _group], true] call ADF_fnc_log; false};
if (_altitude > 1000) then {_altitude = 1000};
if (_waypoints > 10) then {_waypoints = 10};
if (_wp_complRadius > (_radius / _waypoints)) then {_wp_complRadius = (_radius / _waypoints)};

// Check the position of the location
_position = [_position] call ADF_fnc_checkPosition;

// Loop through the number of waypoints needed
for "_i" from 0 to (_waypoints - 1) do {
	_index = _index + 1;
	[_group, _position, _radius, _wp_type, _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, "air", false, [0, 0, 0], _index] call ADF_fnc_addWaypoint;
};

// Add a cycle waypoint
[_group, _position, _radius, "CYCLE", _wp_behaviour, _wp_combatMode, _wp_speed, _wp_formation, _wp_complRadius, "air", false, [0, 0, 0], _index + 1] call ADF_fnc_addWaypoint;

// Remove the spawn/start waypoint
deleteWaypoint ((waypoints _group) # 0);

// Set the patrol altitude
private _vehicle = objectParent (leader _group);
_vehicle flyInHeight _altitude;

// Set pilot behavior
if (_behaviourDisabled) then {[driver _vehicle] call ADF_fnc_heliPilotAI};

true