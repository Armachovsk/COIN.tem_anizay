/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_addWaypoint
Author: Whiztler
Script version: 1.10

File: fn_addWaypoint.sqf
Diag: 0.141746 ms
**********************************************************************************
ABOUT
This function is used by various scripts and functions to create random waypoints.
It can also be used to add manual waypoints

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Group:       Existing group that gets the waypoints assigned
1. Array:       Position [X,Y,Z]

OPTIONAL PARAMETERS:
2. Integer:     Waypoint radius in meters. Default: 500 
3. String:      Waypoint type. Default: "MOVE"
                Info: https:community.bistudio.com/wiki/Waypoint_types
4. String:      Waypoint behaviour. Default: "SAFE"
                Info: https:community.bistudio.com/wiki/setWaypointBehaviour                
5. String:      Waypoint combat mode. Default: "WHITE"
                Info: https:community.bistudio.com/wiki/setWaypointCombatMode
6. String:      Waypoint speed. Default: "LIMITED"
                Info: https:community.bistudio.com/wiki/waypointSpeed
7. String:      Waypoint formation. Default: "FILE"
                Info: https:community.bistudio.com/wiki/waypointFormation
8. Integer:     Waypoint completion radius in meters. Default: 5
                Info: https:community.bistudio.com/wiki/setWaypointCompletionRadius
9. String:      The type of group/vehicle to create the waypoint(s) for:
                - "foot" (default)
                - "road"
                - "air"
                - "sea"
10. Bool        Search buildings: 
                - true: Search buildings within a 50 meter radius upon waypoint
                  completion.
                - false: Do not search buildings (default)

EXAMPLES USAGE IN SCRIPT:
[_aiGroup, _pos, 500, "MOVE", "COMBAT", "WHITE", "LIMITED", "COLUMN", 15, "foot", false] call ADF_fnc_addWaypoint;

EXAMPLES USAGE IN EDEN:
[group this, position this, 750, "MOVE", "COMBAT", "BLUE", "LIMITED", "FILE", 15, "road", true] call ADF_fnc_addWaypoint;

DEFAULT/MINIMUM OPTIONS
[_grp, _pos] call ADF_fnc_addWaypoint; // add infantry waypoint

RETURNS:
Array (Waypoint format)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_addWaypoint"};

// init	
params [
	["_group", grpNull, [grpNull]],
	["_position", [0,0,0], [[]], [3]],
	["_radius", 500, [0]],
	["_wp_type", "MOVE", [""]],
	["_wp_behaviour", "SAFE", [""]],
	["_wp_combatMode", "WHITE", [""]],
	["_wp_speed", "LIMITED", [""]],
	["_wp_formation", "NO CHANGE", [""]],
	["_wp_complRadius", 5, [0]], 
	["_mode", "foot", [""]],
	["_searchBuildings", false, [true]],
	["_wp_timeOut", [0,0,0], [[]], [3]],
	["_index", 0, [0]]
];
private _direction = random 360;

// Debug reporting
if (ADF_debug || ADF_extRpt) then {[format ["ADF_fnc_addWaypoint - #%1 - WP radius: %2", _index, _radius]] call ADF_fnc_log};

// Check valid vars
if (_group == grpNull) exitWith {[format ["ADF_fnc_addWaypoint - Empty group passed: %1. Exiting", _group]] call ADF_fnc_log; grpNull};
if (_wp_complRadius > 500) then {_wp_complRadius = 500;};
if !((toLowerANSI _mode) in ["foot", "road", "air", "sea"]) then {_mode = "foot"; if ADF_debug then {[format ["ADF_fnc_addWaypoint - incorrect vehicle type (%1) passed for group: %2. Defaulted to 'foot'.", _mode, _group]] call ADF_fnc_log;}};
if !((toUpperANSI _wp_type) in ["MOVE", "DESTROY", "GETIN", "SAD", "JOIN", "LEADER", "GETOUT", "CYCLE", "LOAD", "UNLOAD", "TR UNLOAD", "HOLD", "SENTRY", "GUARD", "TALK", "SCRIPTED", "SUPPORT", "GETIN NEAREST", "DISMISS", "AND", "OR"]) then {_wp_type = "MOVE"; if ADF_debug then {[format ["ADF_fnc_addWaypoint - incorrect waypoint type (%1) passed for group: %2. Defaulted to 'MOVE'.", _wp_type, _group]] call ADF_fnc_log;}};
if !((toUpperANSI _wp_behaviour) in ["UNCHANGED", "CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH"]) then {_wp_behaviour = "SAFE"; if ADF_debug then {[format ["ADF_fnc_addWaypoint - incorrect behaviour type (%1) passed for group: %2. Defaulted to 'SAFE'.", _wp_behaviour, _group]] call ADF_fnc_log;}};
if !((toUpperANSI _wp_combatMode) in ["NO CHANGE" ,"BLUE", "GREEN" ,"WHITE", "YELLOW", "RED"]) then {_wp_combatMode = "WHITE"; if ADF_debug then {[format ["ADF_fnc_addWaypoint - incorrect combat mode (%1) passed for group: %2. Defaulted to 'WHITE'.", _wp_combatMode, _group]] call ADF_fnc_log;}};
if !((toUpperANSI _wp_speed) in ["UNCHANGED", "LIMITED", "NORMAL", "FULL"]) then {_wp_speed = "LIMITED"; if ADF_debug then {[format ["ADF_fnc_addWaypoint - incorrect speed mode (%1) passed for group: %2. Defaulted to 'LIMITED'.", _wp_speed, _group]] call ADF_fnc_log;}};
if !((toUpperANSI _wp_formation) in ["NO CHANGE", "COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"]) then {_wp_formation = "FILE"; if ADF_debug then {[format ["ADF_fnc_addWaypoint - incorrect formation mode (%1) passed for group: %2. Defaulted to 'FILE'.", _wp_formation, _group]] call ADF_fnc_log;}};

// Check if the location is at [0,0,0] lower left side of the map (0,0)
if (_position isEqualTo [0,0,0]) exitWith {
	private _msg = format ["Incorrect position passed for group: %1 (%2)", _group, _mode];
	["ADF_fnc_addWaypoint", _msg] call ADF_fnc_terminateScript;
	false
};

// Find a suitable waypoint location based on the type of object/vehicle that will be using the waypoint
switch _mode do {
	case "foot"	: {
		private "_i";
		for "_i" from 1 to 3 do {
			private _find = selectRandom [ADF_fnc_randomPosMax, ADF_fnc_randomPos];
			private _result = [_position, _radius, _direction] call _find;				
			if !(surfaceIsWater _result) exitWith {_position = _result};
			_radius = _radius + 25;
		};
		if ADF_debug then {[_position, true, _group, "foot", _index] call ADF_fnc_positionDebug};
	};
	case "road"	: {
		private _road = [];
		// Debug reporting
		if ADF_debug then {[format ["ADF_fnc_addRoadWaypoint - WP radius: %1", _radius]] call ADF_fnc_log};

		// Find road position within the parameters (near to the random position)
		for "_i" from 1 to 4 do {
			private _find = selectRandom [ADF_fnc_randomPosMax, ADF_fnc_randomPos];
			private _result = [_position, _radius, random 360] call _find;
			_road = [_result, _radius] call ADF_fnc_roadPos;		
			if (isOnRoad _road) exitWith {_position = _road};
			_radius = _radius + 150;
			if (_i == 4) then {_position = [_position, _radius, (random 180) + (random 180)] call ADF_fnc_randomPosMax;};
		};
		if ADF_debug then {[_position, true, _group, "road", _index] call ADF_fnc_positionDebug};
	};
	case "air"	: {
		private _find = selectRandom [ADF_fnc_randomPosMax, ADF_fnc_randomPos];
		_position = [_position, _radius, (random 180) + (random 180)] call _find;
		if ADF_debug then {[_position, true, _group, "air", _index] call ADF_fnc_positionDebug};
	};
	case "sea"	: {
		// Find a location with a depth of at least 10 meters		
		private _dummy = "Sign_Sphere10cm_F" createVehicle [0,0,0];
		
		for "_i" from 1 to 25 do {
			private _find = selectRandom [ADF_fnc_randomPosMax, ADF_fnc_randomPos];
			private _result = [_position, _radius, random 360] call _find;
			_dummy setPosASL _result;
			private _d = abs (getTerrainHeightASL (getPos _dummy));				
			if ((surfaceIsWater _result) && {(_d > 10)}) exitWith {_position = _result};
			_radius = _radius + 50;
		};
		
		deleteVehicle _dummy;
		if ADF_debug then {[_position, true, _group, "sea", _index] call ADF_fnc_positionDebug};
	};
};

// Create the waypoint
private _waypoint = _group addWaypoint [_position, 0];
_waypoint setWaypointType _wp_type;
_waypoint setWaypointBehaviour _wp_behaviour;
_waypoint setWaypointCombatMode _wp_combatMode;
_waypoint setWaypointSpeed _wp_speed;
_waypoint setWaypointFormation _wp_formation;
_waypoint setWaypointCompletionRadius _wp_complRadius;
_waypoint setWaypointTimeout _wp_timeOut;
if (_searchBuildings) then {_waypoint setWaypointStatements ["TRUE", "this spawn ADF_fnc_searchBuilding"]};

// return the waypoint
_waypoint