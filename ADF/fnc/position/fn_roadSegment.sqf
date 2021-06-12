/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_roadSegment
Author: Whiztler
Script version: 1.04

File: fn_roadSegment.sqf
Diag: 0.0387 ms
**********************************************************************************
ABOUT
Searches for roads with in a given radius. Returns a road segment on a road
if successful.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Position:		Center position: Marker, object, trigger or
				position array [x,y,z]

OPTIONAL PARAMETERS:
1. Number:		Radius in meters. Default: 150

EXAMPLES USAGE IN SCRIPT:
_road = ["myMarker", 500] call ADF_fnc_roadSegment;

EXAMPLES USAGE IN EDEN:
this setPos (getPos (["myMarker", 500] call ADF_fnc_roadSegment;));

DEFAULT/MINIMUM OPTIONS
_pos = ["myMarker"] call ADF_fnc_roadSegment;	

RETURNS:
road segment
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_roadSegment"};

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

// if road segment found, use it else use original position
if (count _allRoads > 0) then {
	_result = getPos (_allRoads # 0);
	// Create debug markers if debug is enabled
	if ADF_debug then {	
		[format ["ADF_fnc_roadSegment - Array: %1", _result]] call ADF_fnc_log;
		for "_i" from 0 to (count _allRoads) do {
			private _marker = createMarker [format ["m_%1%2", _allRoads # _i, random 999], getPos (_allRoads # _i)];
			_marker setMarkerSize [.5, .5];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_triangle";
			_marker setMarkerColor "ColorOpfor";
			_marker setMarkerText "rd";
		};
	};
} else {_result = _position};
[format ["getPos (_allRoads # _0):  %1", getPos (_allRoads # 0)]] call ADF_fnc_log;

// return road segments
_result