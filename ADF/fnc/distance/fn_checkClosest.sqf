/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_checkClosest
Author: Whiztler
Script version: 1.04

File: fn_checkClosest.sqf
Diag: 0.0006 ms 1p
Diag: 0.0012 ms 5p
**********************************************************************************
ABOUT
Checks closest players to an object, marker, trigger, AI, etc.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Array:      E.g. allPlayer, allUnits, etc.
1. Position:   Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
[allPlayers, myObject] call ADF_fnc_checkClosest;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
[EnemyArray, "bluBase"] call ADF_fnc_checkClosest;

RETURNS:
Integer (distance in meters)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_checkClosest"};

params [
	["_units", [], [[]]],
	["_position", "", ["", [], objNull, grpNull, locationNull]],
	["_radius", 10^4, [0]]
];	
private _result = _radius + 1;

{
	_result = [_x, _position] call ADF_fnc_checkDistance;

	// Debug reporting
	if ADF_debug then {[format ["ADF_fnc_checkClosest - distance %1 to %2 is %3 meters", _x, _position, _result]] call ADF_fnc_log};
	
	if (_result < _radius) then {_radius = _result};
} forEach _units;

_result