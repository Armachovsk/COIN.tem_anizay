/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_randomPosMax
Author: Whiztler
Script version: 1.03

File: fn_randomPosMax.sqf
Diag: 0.0249 ms
**********************************************************************************
ABOUT
Returns a random position on the far end of the radius.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Position:    Center position: Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
1. Number:      Radius in meters. Default: 500
2. Number:      Direction (0-360). Default is random 360

EXAMPLES USAGE IN SCRIPT:
_maxPos = ["myMarker", 500, random 360] call ADF_fnc_randomPosMax;

EXAMPLES USAGE IN EDEN:
this setpos (getPos (["myMarker", 500, random 360] call ADF_fnc_randomPosMax);

DEFAULT/MINIMUM OPTIONS
_pos = ["myMarker"] call ADF_fnc_randomPosMax;

RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_randomPosMax"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]],
	["_radius", 500, [0]],
	["_direction", -1, [0]]
];

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Set direction
private _d = if (_direction == -1) then {random 360} else {_direction};

// Create random position from center & radius
private _position_X = (_position # 0) + (_radius * sin _d);
private _position_Y = (_position # 1) + (_radius * cos _d);

// Create debug marker if debug is enabled.
if ADF_debug then {
	[format ["ADF_fnc_randomPos - Position: [%1,%2, 0]", _position_X, _position_Y]] call ADF_fnc_log;
	private _marker = createMarker [format ["m_%1%2", round _position_X, round _position_Y], [_position_X, _position_Y, 0]];
	_marker setMarkerSize [.5, .5];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "hd_flag";
	_marker setMarkerColor "ColorKhaki";
	_marker setMarkerText "rndPosMax";
};

// Return position
[_position_X, _position_Y, 0]