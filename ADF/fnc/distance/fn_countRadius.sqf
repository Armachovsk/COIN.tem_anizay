/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_countRadius
Author: Whiztler
Script version: 1.03

File: fn_countRadius.sqf
Diag: 0.0273 ms
**********************************************************************************
ABOUT
Counts the number of units / vehicles / object (whatever you specify) in a certain
radius.

INSTRUCTIONS:
Execute (call) from the server

REQUIRED PARAMETERS:
0. Position:    Marker, object, trigger or position array [x,y,z].
1. Side:        east, west, independent, etc.


OPTIONAL PARAMETERS:
2. Number:      Radius in meters. Default: 250. Maximum is 5000
3. type:        ["man", "car", "apc", "tank", "all"]. Default: "man"
                either string for a single type or an array for multiple types

EXAMPLES USAGE IN SCRIPT:
_enemyCount = ["myMarker", independent, 250, "MAN"] call ADF_fnc_countRadius;

EXAMPLES USAGE IN EDEN:
AO_EI_East = ["eastAO", east, 750, ["MAN", "CAR"]] call ADF_fnc_countRadius;

DEFAULT/MINIMUM OPTIONS
_cnt = ["myMarker", west] call ADF_fnc_countRadius;

RETURNS:
Integer (number of units / vehicles / etc.)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_countRadius"};

// Init
params [
	["_position", "", ["", [], objNull, grpNull, locationNull]],
	["_side", east, [west]],
	["_radius", 100, [0]],
	["_type", "man", ["",[]]]
];

// Check valid vars
if (_radius > 5000) then {_radius = 5000;};

// Check the position of the location
_position = [_position] call ADF_fnc_checkPosition;

private _result = {side _x == _side} count (_position nearEntities [_type, _radius]);

_result