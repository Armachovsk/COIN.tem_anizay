/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_outsidePosUnit
Author: Whiztler
Script version: 1.04

File: fn_outsidePosUnit.sqf
Diag: 0.012 ms
**********************************************************************************
Checks if an AI/player is outside by checking the z-axe for a 25 meter visibility.
If inside the roof will break visibility and the function will return true. The
script can be used to determine rooftop positions.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0: Object:      Object or position array [x,y,z]

OPTIONAL PARAMETERS:
N/A

EXAMPLES USAGE IN SCRIPT:
_inside = [player] call ADF_fnc_outsidePosUnit;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
_inside = [_ei] call ADF_fnc_outsidePosUnit;

RETURNS:
Bool (true if inside)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_outsidePosUnit"};

// Init
params [
	["_unit", objNull, [objNull]]
];

private _result = lineIntersects [eyePos _unit, (eyePos _unit) vectorAdd [0, 0, 25]];

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_outsidePosUnitUnit - Position inside: %1", _result]] call ADF_fnc_log};

// Return result (true or false)
_result