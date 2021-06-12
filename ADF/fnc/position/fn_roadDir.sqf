/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_roadDir
Author: Whiztler
Script version: 1.02

File: fn_roadDir.sqf
Diag: 0.0231 ms
**********************************************************************************
ABOUT
Returns the direction of the closest road from a position on or close to a road.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. Array:		Position on road, array [x,y,z]

EXAMPLES USAGE IN SCRIPT:
_rdDir = [getPos _veh] call ADF_fnc_roadDir;

EXAMPLES USAGE IN EDEN:
vehicleDirection = [position this] call ADF_fnc_roadDir;

DEFAULT/MINIMUM OPTIONS
_dir = [_pos] call ADF_fnc_roadDir;	

RETURNS:
integer (0-360 degrees)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_roadDir"};

// Init
params [
	["_position", [], [[]], [3]]
];

private _allRoads = _position nearRoads 10;
private _direction = random 360;
private _dummy = _direction;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_roadDir - position: %1 - road: %2", _position, _allRoads]] call ADF_fnc_log};

if (count _allRoads > 0) then {	
	private _road = _allRoads # 0;
	private _connectedRoads = roadsConnectedTo _road;
	private _connection = _connectedRoads # 0;
	_direction = [_road, _connection] call BIS_fnc_dirTo;	

	// Debug reporting
	if ADF_debug then {diag_log format ["ADF Debug: ADF_fnc_roadDir - road direction", _direction]};	
};

if (ADF_debug && {_dummy == _direction}) then {["ADF_fnc_roadDir - ERROR! No valid direction. No Road position."] call ADF_fnc_log};

_direction
