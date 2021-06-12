/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_randomPosInArea
Author: Whiztler
Script version: 1.05

File: fn_randomPosInArea.sqf
Diag: 0.0392 ms
**********************************************************************************
ABOUT
Searches for a position in a predefined area (e.g. marker, trigger). The function 
is precise with circular triggers/markers. With uneven shapes, units/objects might
spawn outside of the given radius.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Position:    marker or trigger

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
_pos = ["myMarker"] call ADF_fnc_randomPosInArea;   

EXAMPLES USAGE IN EDEN:
myPos = [myTrigger] call ADF_fnc_randomPosInArea;    

DEFAULT/MINIMUM OPTIONS
_pos = ["myMarker"] call ADF_fnc_randomPosInArea;   

RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_randomPosInArea"};

// Init
params [
	["_position", "", ["", objNull]]
];
private _center = _position;

// Check if marker or trigger
private _isMarker = if (_position isEqualType "" && {_position in allMapMarkers}) then {true} else {false};
private _size = if (_isMarker) then {getMarkerSize _position} else {triggerArea _position};

_size params ["_size_X", "_size_Y"];
private _radius = if ((_size_X + _size_Y) > 0) then {(_size_X + _size_Y) / 2} else {0};
private _result = if (_radius > 0) then {
	[_center, _radius, random 360] call ADF_fnc_randomPos
} else {
	if (_isMarker) then {getMarkerPos _position} else {getPosASL _position}
};

// Create debug marker if debug is enabled
if ADF_debug then {
	[format ["ADF_fnc_randomPos - Position: %1", _result]] call ADF_fnc_log;
	private _marker = createMarker [format ["m_%1", diag_tickTime], _result];
	_marker setMarkerSize [.7, .7];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "hd_dot";
	_marker setMarkerColor "ColorYellow";
};	

_result