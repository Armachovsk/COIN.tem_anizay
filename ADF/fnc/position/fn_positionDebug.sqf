/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_positionDebug
Author: Whiztler
Script version: 1.02

File: fn_positionDebug.sqf
**********************************************************************************
ABOUT
Creates a debug marker for a passed on position. In case of a patrol waypoint it
adds the group name and waypoint number as text. In case of a generic position it
add 'pos_x' where x is the index number.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Position:		Position array [x, y, z]

OPTIONAL PARAMETERS:
1. Bool:			Patrol Waypoint debug or (road) position debug?
                   - true for patrol waypoint (default)
                   - false for general position.
2. Group:		Group in case of patrol waypoint. Default: GrpNull
3. String:		Type of waypoint. Default: "foot"
4. Number:		Index. Default: 0

EXAMPLES USAGE IN SCRIPT:
[_pos, false, grpNull, "", _i] call ADF_fnc_positionDebug;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[_pos] call ADF_fnc_positionDebug;	

RETURNS:
Marker
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_positionDebug"};

// Init
params [
	["_position", [], [[], true]],
	["_patrolWaypoint", true, [false]],	
	["_group", grpNull, [grpNull]],
	["_mode", "foot", [""]],
	["_index", 0, [0]],
	["_varName", "DM", [""]],
	["_colour", "", [""]],
	["_label", "", [""]]
];	

if (_position isEqualType true) exitWith {if ADF_debug then {["ADF_fnc_positionDebug - passed true/false as position. Exiting."] call ADF_fnc_log;}; false}; 

// patrol waypoint marker
if (_patrolWaypoint) then {
	// Check position type
	switch _mode do {
		case "foot":	{_varName = "FP"; _colour = "ColorOrange"};
		case "road":	{_varName = "VP"; _colour = "colorIndependent"};
		case "air":	{_varName = "AP"; _colour = "ColorPink"};
		case "sea":	{_varName = "SP"; _colour = "ColorBlue"};
	};	
	// Create marker text
	_label = format ["%1-%2-%3",_group, _varName, _index];

// Generic position marker
} else {
	// Create marker text
	_label = format ["POS_",_index];
	_colour = "ColorWhite"	
};

// Create the debug marker 
private _marker = createMarker [format ["m%1%2%3", _varName, round (_position # 0), round (_position # 1)], _position];
_marker setMarkerSize [.7, .7];
_marker setMarkerShape "ICON";
_marker setMarkerType "hd_dot";
_marker setMarkerColor _colour;
_marker setMarkerText _label;

// Return the marker
_marker
