/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_getRelPos
Author: Whiztler
Script version: 1.04

File: fn_getRelPos.sqf
**********************************************************************************
ABOUT
Use this function to determine a relative position.

INSTRUCTIONS:
n/a

REQUIRED PARAMETERS:
0. Position:    Marker, object, trigger or position array [x,y,z]
1. Number:      distance in meters

OPTIONAL PARAMETERS:
2. Number:      Azimuth (0-360). Default: 0
3. Number:      Z-axe, altitude offset. Default: -1

EXAMPLES USAGE IN SCRIPT:
_rePos = [_unit, 10, 45, 0] call ADF_fnc_getRelPos;

EXAMPLES USAGE IN EDEN:
n/a

DEFAULT/MINIMUM OPTIONS
_rePos = [_unit, 10] call ADF_fnc_getRelPos;

RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_getRelPos"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]],
	["_distance", 15, [0]],
	["_azimuth", 0, [0]],
	["_altitude", -1, [0]]
];

// Check the location position
_position = [_position] call ADF_fnc_checkPosition;

// Compile and return the relative position
[(_position # 0) + sin (_distance * _azimuth), (_position # 1) + cos (_distance * _azimuth), _altitude];