/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: ADF_fnc_takeCover
Author: Whiztler
Script version: 1.02

File: fn_takeCover.sqf
**********************************************************************************
ABOUT
Function used by the defend (garrison) function to change behavior and stance of
an AI simulating a natural response to gunfire.

INSTRUCTIONS:
Execute (call) from the server

REQUIRED PARAMETERS:
0. Object:      the unit you wish to apply the skill set to.

OPTIONAL PARAMETERS:
1. String:      The current stance of the unit:
                - "UP" (default)
                - "MIDDLE"
                - "DOWN"
2. Bool:        Switch behavior to combat mode?
                - true (default)
                - false

EXAMPLES USAGE IN SCRIPT:
[_myUnit, "veteran"] call ADF_fnc_takeCover;

EXAMPLES USAGE IN EDEN:
[this, "expert"] call ADF_fnc_takeCover;

DEFAULT/MINIMUM OPTIONS
[_soldier] call ADF_fnc_takeCover;

RETURNS:
Object
*********************************************************************************/

// Reporting
if (ADF_extRpt || {ADF_debug}) then {diag_log "ADF rpt: fnc - executing: ADF_fnc_takeCover"};

// Init
params [
	["_unit", objNull, [objNull]],
	["_stance", "UP", [""]],
	["_combatMode", true, [false]],
	["_coverStance", "MIDDLE", [""]]
];

// Check valid vars
if !(_unit isKindOf "CAManBase") exitWith {[format ["ADF_fnc_takeCover - Incorrect unit passed: '%1'. Exiting", _unit], true] call ADF_fnc_log; false};
if (	(_stance != "UP") && (_stance != "MIDDLE") && (_stance != "DOWN")) then {	_stance = "UP"; if ADF_debug then {[format ["ADF_fnc_takeCover - incorrect stance (%1) passed for unit: %2. Defaulted to 'UP'.",_stance, _unit]] call ADF_fnc_log;}};

// Remove EH
_unit removeAllEventHandlers "FiredNear";

// If the unit is already prone then do nothing.
if (_stance == "DOWN") exitWith {if ADF_debug then {[format ["ADF_fnc_takeCover - unit '%1' is already in a 'DOWN' stance. Exiting", _unit]] call ADF_fnc_log}; false};

// Check the cover position stance
if (_stance == "MIDDLE") then {_coverStance = "DOWN"}; 

if ADF_debug then {[format ["ADF_fnc_takeCover - unit: %1, org stance: %2, new stance: %3", _unit, _stance, _coverStance]] call ADF_fnc_log};

if _combatMode then {_unit setBehaviour "COMBAT"; };

// Spawn a new thread that will make the unit take cover and return to the original stance after a random pause.
[_unit, _stance, _coverStance] spawn {
	params ["_unit", "_stance", "_coverStance"];
	sleep (random 1.5);
	_unit setUnitPos _coverStance;
	
	// Debug reporting
	if (ADF_debug && {alive _unit}) then {[format ["ADF_fnc_takeCover - Stance changed to '%1' for unit: %2", _coverStance, _unit]] call ADF_fnc_log};
	
	sleep (2 + random 3 + random 2);
	if (!alive _unit) exitWith {};
	_unit setUnitPos _stance;
	
	_unit addEventHandler ["FiredNear", {[_this # 0, _stance, _coverStance] call ADF_fnc_takeCover}];
};

true