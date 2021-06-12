/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_getTurrets
Author: Whiztler
Script version: 1.17

File: fn_getTurrets.sqf
Diag: 0.017 ms
**********************************************************************************
ABOUT
Creates and populates an array of empty unlocked static weapons and vehicles with 
empty turrets. If you have vehicles on the map you DO NOT want to be populated by
AI's, then 'LOCK' the vehicle (not player lock!).
The function is exclusively used by ADF_fnc_DefendArea.

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. Array:       Position [X,Y,Z]
1. Number:      Radius in meters

OPTIONAL PARAMETERS:
N/a

EXAMPLE
[[1234,1234,0], 100] call ADF_fnc_getTurrets;

RETURNS:
Array (available turrets)
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_getTurrets"};

// init
params [
	["_position", [0, 0, 0], [[]], [3]],
	["_radius", 10, [0]],
	["_allTurrets", [], [[]]],
	["_availableTurrets", [], [[]]]
];

// Create array of empty static turrets
{_allTurrets append (_position nearEntities [[_x], _radius])} forEach ["TANK", "APC", "CAR", "StaticWeapon"];

// Remove already populated turrest from the array
{if (((locked _x) != 2) && {(_x emptyPositions "gunner") > 0} && {((count crew _x) == 0)}) then {_availableTurrets append [_x]}} forEach _allTurrets;

// Debug reporting
if ADF_debug then {[format ["ADF_fnc_getTurrest - Turrets array: %1", _availableTurrets]] call ADF_fnc_log};

// return turrets array
_availableTurrets