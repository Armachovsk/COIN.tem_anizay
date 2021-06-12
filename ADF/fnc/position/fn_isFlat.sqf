/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_isFlat
Author: Whiztler
Script version: 1.02

File: fn_isFlat.sqf
Diag: 0.0222 ms
**********************************************************************************
ABOUT
Checks if a passed position is on flat ground.
Info: https://en.wikipedia.org/wiki/Normal_(geometry)

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Position:        marker / object / vehicle / group

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
_isFlat = ["myMarker"] call ADF_fnc_isFlat;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
_isFlat = ["myMarker"] call ADF_fnc_isFlat;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_isFlat"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]]
];

// Check location position
_position = [_position] call ADF_fnc_checkPosition;

private _surface = surfaceNormal _position;
private _result = if (((_surface # 2) * 1000) > 995) then {true} else {false};

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_isFlat - Flat Position Z-axe: %1", _surface # 2]] call ADF_fnc_log};

// Return result (true or false)
_result