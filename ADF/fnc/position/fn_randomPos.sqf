/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_randomPos
Author: Whiztler
Script version: 1.04

File: fn_randomPos.sqf
Diag: 0.0234 ms
**********************************************************************************
ABOUT
Returns a random position within a given radius (marker, trigger, etc)

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Position:    Center position of the search radius. Marker, object, trigger or
                position array [x,y,z]
                
OPTIONAL PARAMETERS:
1. Number:      Radius in meters. Default: 500

EXAMPLES USAGE IN SCRIPT:
_pos = ["myMarker", 500] call ADF_fnc_randomPos;

EXAMPLES USAGE IN EDEN:
myPosition = ["myMarker", 500] call ADF_fnc_randomPos;

DEFAULT/MINIMUM OPTIONS
_pos = ["myMarker"] call ADF_fnc_randomPos;

RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_randomPos"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 500, [0]]
];

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Create random position from center & radius
private _position_X = (_position # 0) + (_radius - (random (1.5 *_radius)));
private _position_Y = (_position # 1) + (_radius - (random (1.5 *_radius)));

// Create debug markers if debug is enabled
if ADF_debug then {
	[format ["ADF_fnc_randomPos - Position: [%1,%2, 0]", _position_X, _position_Y]] call ADF_fnc_log;
	private _marker = createMarker [format ["m_%1%2", round _position_X, round _position_Y], [_position_X, _position_Y, 0]];
	_marker setMarkerSize [.7, .7];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "hd_dot";
	_marker setMarkerColor "ColorYellow";
};

// Return position
[_position_X, _position_Y, 0]