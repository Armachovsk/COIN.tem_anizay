/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_outsidePos
Author: Whiztler
Script version: 1.03

File: fn_outsidePos.sqf
Diag: 0.0234 ms
**********************************************************************************
ABOUT
Checks if a given position is outside by checking the z-axe for a 25 meter
visibility. If inside the roof will break visibility and the function will return
true.

INSTRUCTIONS:
Call from script on the server

REQUIRED PARAMETERS:
0. position:         Marker, object, trigger or position array [x,y,z]

OPTIONAL PARAMETERS:
n/a

EXAMPLES USAGE IN SCRIPT:
_outside = [myObject] call ADF_fnc_outsidePos;

EXAMPLES USAGE IN EDEN:
N/A

DEFAULT/MINIMUM OPTIONS
_outside = ["myMarker"] call ADF_fnc_outsidePos;

RETURNS:
Bool
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_outsidePos"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull]]
];

// Check location position
_position = [_position] call ADF_fnc_checkPosition;

private _result = lineIntersects [ATLToASL [_position # 0, _position # 1, 1], ATLToASL [_position # 0, _position # 1, 25]];

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_outsidePos - Position inside: %1", _result]] call ADF_fnc_log};

// Return result (true or false)
_result
