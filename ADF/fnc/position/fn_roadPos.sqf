/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_roadPos
Author: Whiztler
Script version: 1.05

File: fn_roadPos.sqf
Diag: 0.0611 ms
**********************************************************************************
ABOUT
Searches for road positions with in a given radius. Returns a position on a road
if successful.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Position:		Center position: Marker, object, trigger or
				position array [x,y,z]

OPTIONAL PARAMETERS:
1. Number:		Radius in meters. Default: 150

EXAMPLES USAGE IN SCRIPT:
_road = ["myMarker", 500] call ADF_fnc_roadPos;

EXAMPLES USAGE IN EDEN:
this setPos (getPos (["myMarker", 500] call ADF_fnc_roadPos;));

DEFAULT/MINIMUM OPTIONS
_pos = ["myMarker"] call ADF_fnc_roadPos;	

RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_roadPos"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 150, [0]],
	["_result", [], [[]]]
];

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Check nearby raods from passed position
private _allRoads = _position nearRoads _radius;

// if road position found, use it else use original position
if (count _allRoads > 0) then {_result = getPos (selectRandom _allRoads)} else {_result = _position};

// Create debug marker if debug is enabled
if ADF_debug then {
	diag_log format ["ADF Debug: ADF_fnc_roadPos - Position: %1", _result];
	private _marker = createMarker [format ["m_%1%2", round (_result # 0), round (_result # 1)], _result];
	_marker setMarkerSize [.7, .7];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "mil_triangle";
	_marker setMarkerColor "ColorRed";
	_marker setMarkerText "rdPos";		
};

// return the position
_result